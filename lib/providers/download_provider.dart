import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_browser.dart' as idb_browser;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../services/quran_audio_service.dart';

const int _kTilawatDbVersion = 2;
const String _kTilawatStore = 'tilawat_files';
const String _kPrefsDownloadedIds = 'downloadedTilawatIds';

class DownloadProvider with ChangeNotifier {
  DownloadProvider() {
    _init();
  }

  final Set<String> _downloadedIds = {};
  final Map<String, bool> _downloading = {};
  final Map<String, double> _downloadProgress = {};
  idb.Database? _db;
  final Map<String, String> _blobUrls = {};

  Future<void> _init() async {
    await _loadDownloaded();
    notifyListeners();
  }

  Future<idb.Database> _getDatabase() async {
    if (_db != null) return _db!;
    final factory = idb_browser.getIdbFactory();
    _db = await factory!.open(
      'quran_audio.db',
      version: _kTilawatDbVersion,
      onUpgradeNeeded: (e) {
        final db = e.database;
        if (e.oldVersion < _kTilawatDbVersion &&
            !db.objectStoreNames.contains(_kTilawatStore)) {
          db.createObjectStore(_kTilawatStore, keyPath: 'id');
        }
      },
    );
    return _db!;
  }

  Future<void> _loadDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = prefs.getStringList(_kPrefsDownloadedIds) ?? [];
    _downloadedIds
      ..clear()
      ..addAll(fromPrefs);

    if (kIsWeb) {
      final db = await _getDatabase();
      final txn = db.transaction(_kTilawatStore, idb.idbModeReadOnly);
      final store = txn.objectStore(_kTilawatStore);
      final keys = await store.getAllKeys();
      for (final key in keys) {
        if (key is! String) continue;
        _downloadedIds.add(key);
        final record = await store.getObject(key) as Map<String, dynamic>?;
        if (record != null && record['data'] is Uint8List) {
          final blob = html.Blob([record['data']]);
          _revokeBlob(key);
          _blobUrls[key] = html.Url.createObjectUrlFromBlob(blob);
        }
      }
      await txn.completed;
      await prefs.setStringList(_kPrefsDownloadedIds, _downloadedIds.toList());
    } else {
      final invalid = <String>[];
      for (final id in _downloadedIds) {
        final p = await _filePathForId(id);
        if (!await File(p).exists()) invalid.add(id);
      }
      for (final id in invalid) {
        _downloadedIds.remove(id);
      }
      await _persistIds();
    }
  }

  void _revokeBlob(String id) {
    final old = _blobUrls.remove(id);
    if (old != null) html.Url.revokeObjectUrl(old);
  }

  Future<void> _persistIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kPrefsDownloadedIds, _downloadedIds.toList());
  }

  Future<String> _getLocalDir() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'quran_audio');
  }

  Future<String> _filePathForId(String cacheId) async {
    final dir = await _getLocalDir();
    return path.join(dir, '$cacheId.mp3');
  }

  bool isDownloaded(int surahNumber, String reciter) {
    final id = QuranAudioService.tilawatCacheId(surahNumber, reciter);
    return _downloadedIds.contains(id);
  }

  bool isDownloading(int surahNumber, String reciter) {
    final id = QuranAudioService.tilawatCacheId(surahNumber, reciter);
    return _downloading[id] == true;
  }

  double? downloadProgress(int surahNumber, String reciter) {
    final id = QuranAudioService.tilawatCacheId(surahNumber, reciter);
    return _downloadProgress[id];
  }

  /// Legacy per-surah file (any reciter) — still used as offline fallback.
  Future<String?> _legacyMobilePath(int surahNumber) async {
    if (kIsWeb) return null;
    final dir = await _getLocalDir();
    final legacy = path.join(dir, '$surahNumber.mp3');
    if (await File(legacy).exists()) return legacy;
    return null;
  }

  Future<String?> getLocalFilePath(int surahNumber, String reciter) async {
    final id = QuranAudioService.tilawatCacheId(surahNumber, reciter);
    if (_downloadedIds.contains(id)) {
      if (kIsWeb) {
        var blobUrl = _blobUrls[id];
        if (blobUrl == null) {
          await _hydrateBlobFromDb(id);
          blobUrl = _blobUrls[id];
        }
        if (blobUrl != null) return blobUrl;
        _downloadedIds.remove(id);
        await _persistIds();
        notifyListeners();
        return null;
      }
      final fp = await _filePathForId(id);
      if (await File(fp).exists()) return fp;
      _downloadedIds.remove(id);
      await _persistIds();
      notifyListeners();
    }
    return _legacyMobilePath(surahNumber);
  }

  Future<void> _hydrateBlobFromDb(String id) async {
    final db = await _getDatabase();
    final txn = db.transaction(_kTilawatStore, idb.idbModeReadOnly);
    final store = txn.objectStore(_kTilawatStore);
    final record = await store.getObject(id) as Map<String, dynamic>?;
    await txn.completed;
    if (record != null && record['data'] is Uint8List) {
      final blob = html.Blob([record['data']]);
      _revokeBlob(id);
      _blobUrls[id] = html.Url.createObjectUrlFromBlob(blob);
    }
  }

  /// Returns `true` if the file is now available offline.
  Future<bool> downloadSurah({
    required int surahNumber,
    required Map<dynamic, dynamic> surah,
    required String reciter,
  }) async {
    final id = QuranAudioService.tilawatCacheId(surahNumber, reciter);
    if (_downloadedIds.contains(id) || _downloading[id] == true) return true;

    final url = QuranAudioService.resolveRemoteUrl(surah, reciter);
    if (url.isEmpty) {
      return false;
    }

    _downloading[id] = true;
    _downloadProgress[id] = 0;
    notifyListeners();

    try {
      if (kIsWeb) {
        final dio = Dio();
        final response = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (c, t) {
            if (t <= 0) return;
            _downloadProgress[id] = c / t;
            notifyListeners();
          },
        );
        final data = Uint8List.fromList(response.data!);

        final db = await _getDatabase();
        final txn = db.transaction(_kTilawatStore, idb.idbModeReadWrite);
        final store = txn.objectStore(_kTilawatStore);
        await store.put({
          'id': id,
          'surahNumber': surahNumber,
          'reciterSlug': QuranAudioService.reciterStorageSlug(reciter),
          'data': data,
        });
        await txn.completed;

        _revokeBlob(id);
        final blob = html.Blob([data]);
        _blobUrls[id] = html.Url.createObjectUrlFromBlob(blob);

        _downloadedIds.add(id);
        await _persistIds();
      } else {
        final dirPath = await _getLocalDir();
        final dir = Directory(dirPath);
        if (!await dir.exists()) await dir.create(recursive: true);
        final filePath = await _filePathForId(id);
        final dio = Dio();
        await dio.download(
          url,
          filePath,
          onReceiveProgress: (c, t) {
            if (t <= 0) return;
            _downloadProgress[id] = c / t;
            notifyListeners();
          },
        );
        _downloadedIds.add(id);
        await _persistIds();
      }
      _downloadProgress.remove(id);
      return true;
    } catch (e) {
      _downloadProgress.remove(id);
      debugPrint('downloadSurah: $e');
    } finally {
      _downloading[id] = false;
      _downloadProgress.remove(id);
      notifyListeners();
    }
    return false;
  }
}
