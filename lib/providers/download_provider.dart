import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_browser.dart' as idb_browser;

class DownloadProvider with ChangeNotifier {
  Map<int, bool> isDownloaded = {};
  Map<int, bool> isDownloading = {};
  Set<int> _downloadedSurahs = {}; // For mobile
  final Set<String> _downloadedKeys = {}; // For web
  idb.Database? _db;
  final Map<int, String> _blobUrls = {}; // For web blob URLs

  DownloadProvider() {
    _loadDownloadedSurahs();
  }

  Future<idb.Database> _getDatabase() async {
    if (_db != null) return _db!;
    final factory = idb_browser.getIdbFactory();
    _db = await factory!.open('quran_audio.db', version: 1, onUpgradeNeeded: (e) {
      final db = e.database;
      if (!db.objectStoreNames.contains('audio_files')) {
        db.createObjectStore('audio_files', keyPath: 'surahNumber');
      }
    });
    return _db!;
  }

  Future<void> _loadDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedList = prefs.getStringList('downloadedSurahs') ?? [];
    _downloadedSurahs = downloadedList.map(int.parse).toSet();

    if (kIsWeb) {
      // On web, check IndexedDB for stored audio files
      final db = await _getDatabase();
      final txn = db.transaction('audio_files', idb.idbModeReadOnly);
      final store = txn.objectStore('audio_files');
      final keys = await store.getAllKeys();
      for (var key in keys) {
        if (key is int) {
          final surahKey = 'surah_${key.toString().padLeft(3, '0')}_al_fatiha'; // Use unique key
          _downloadedKeys.add(surahKey);
          isDownloaded[key - 1] = true;
          // Create blob URL for playback
          final record = await store.getObject(key) as Map<String, dynamic>?;
          if (record != null && record['data'] is Uint8List) {
            final blob = html.Blob([record['data']]);
            _blobUrls[key] = html.Url.createObjectUrlFromBlob(blob);
          }
        }
      }
      await txn.completed;
    } else {
      // On mobile, verify files exist
      for (int surah in _downloadedSurahs.toList()) {
        if (!await _checkFileExists(surah)) {
          _downloadedSurahs.remove(surah);
        } else {
          isDownloaded[surah - 1] = true;
        }
      }
    }
    _saveDownloadedSurahs();
    notifyListeners();
  }

  Future<void> _saveDownloadedSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('downloadedSurahs', _downloadedSurahs.map((e) => e.toString()).toList());
  }

  Future<bool> _checkFileExists(int surahNumber) async {
    if (kIsWeb) return false;
    final localPath = await _getLocalPath();
    final filePath = path.join(localPath, '$surahNumber.mp3');
    return File(filePath).exists();
  }

  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'quran_audio');
  }

  Map<String, String> _getSurahUrls() {
    return {
      "001": "https://server8.mp3quran.net/lhdan/001.mp3",
      "002": "https://server8.mp3quran.net/lhdan/002.mp3",
      "003": "https://server8.mp3quran.net/lhdan/003.mp3",
      "004": "https://server8.mp3quran.net/lhdan/004.mp3",
      "005": "https://server8.mp3quran.net/lhdan/005.mp3",
      "006": "https://server8.mp3quran.net/lhdan/006.mp3",
      "007": "https://server8.mp3quran.net/lhdan/007.mp3",
      "008": "https://server8.mp3quran.net/lhdan/008.mp3",
      "009": "https://server8.mp3quran.net/lhdan/009.mp3",
      "010": "https://server8.mp3quran.net/lhdan/010.mp3",
      "011": "https://server8.mp3quran.net/lhdan/011.mp3",
      "012": "https://server8.mp3quran.net/lhdan/012.mp3",
      "013": "https://server8.mp3quran.net/lhdan/013.mp3",
      "014": "https://server8.mp3quran.net/lhdan/014.mp3",
      "015": "https://server8.mp3quran.net/lhdan/015.mp3",
      "016": "https://server8.mp3quran.net/lhdan/016.mp3",
      "017": "https://server8.mp3quran.net/lhdan/017.mp3",
      "018": "https://server8.mp3quran.net/lhdan/018.mp3",
      "019": "https://server8.mp3quran.net/lhdan/019.mp3",
      "020": "https://server8.mp3quran.net/lhdan/020.mp3",
      "021": "https://server8.mp3quran.net/lhdan/021.mp3",
      "022": "https://server8.mp3quran.net/lhdan/022.mp3",
      "023": "https://server8.mp3quran.net/lhdan/023.mp3",
      "024": "https://server8.mp3quran.net/lhdan/024.mp3",
      "025": "https://server8.mp3quran.net/lhdan/025.mp3",
      "026": "https://server8.mp3quran.net/lhdan/026.mp3",
      "027": "https://server8.mp3quran.net/lhdan/027.mp3",
      "028": "https://server8.mp3quran.net/lhdan/028.mp3",
      "029": "https://server8.mp3quran.net/lhdan/029.mp3",
      "030": "https://server8.mp3quran.net/lhdan/030.mp3",
      "031": "https://server8.mp3quran.net/lhdan/031.mp3",
      "032": "https://server8.mp3quran.net/lhdan/032.mp3",
      "033": "https://server8.mp3quran.net/lhdan/033.mp3",
      "034": "https://server8.mp3quran.net/lhdan/034.mp3",
      "035": "https://server8.mp3quran.net/lhdan/035.mp3",
      "036": "https://server8.mp3quran.net/lhdan/036.mp3",
      "037": "https://server8.mp3quran.net/lhdan/037.mp3",
      "038": "https://server8.mp3quran.net/lhdan/038.mp3",
      "039": "https://server8.mp3quran.net/lhdan/039.mp3",
      "040": "https://server8.mp3quran.net/lhdan/040.mp3",
      "041": "https://server8.mp3quran.net/lhdan/041.mp3",
      "042": "https://server8.mp3quran.net/lhdan/042.mp3",
      "043": "https://server8.mp3quran.net/lhdan/043.mp3",
      "044": "https://server8.mp3quran.net/lhdan/044.mp3",
      "045": "https://server8.mp3quran.net/lhdan/045.mp3",
      "046": "https://server8.mp3quran.net/lhdan/046.mp3",
      "047": "https://server8.mp3quran.net/lhdan/047.mp3",
      "048": "https://server8.mp3quran.net/lhdan/048.mp3",
      "049": "https://server8.mp3quran.net/lhdan/049.mp3",
      "050": "https://server8.mp3quran.net/lhdan/050.mp3",
      "051": "https://server8.mp3quran.net/lhdan/051.mp3",
      "052": "https://server8.mp3quran.net/lhdan/052.mp3",
      "053": "https://server8.mp3quran.net/lhdan/053.mp3",
      "054": "https://server8.mp3quran.net/lhdan/054.mp3",
      "055": "https://server8.mp3quran.net/lhdan/055.mp3",
      "056": "https://server8.mp3quran.net/lhdan/056.mp3",
      "057": "https://server8.mp3quran.net/lhdan/057.mp3",
      "058": "https://server8.mp3quran.net/lhdan/058.mp3",
      "059": "https://server8.mp3quran.net/lhdan/059.mp3",
      "060": "https://server8.mp3quran.net/lhdan/060.mp3",
      "061": "https://server8.mp3quran.net/lhdan/061.mp3",
      "062": "https://server8.mp3quran.net/lhdan/062.mp3",
      "063": "https://server8.mp3quran.net/lhdan/063.mp3",
      "064": "https://server8.mp3quran.net/lhdan/064.mp3",
      "065": "https://server8.mp3quran.net/lhdan/065.mp3",
      "066": "https://server8.mp3quran.net/lhdan/066.mp3",
      "067": "https://server8.mp3quran.net/lhdan/067.mp3",
      "068": "https://server8.mp3quran.net/lhdan/068.mp3",
      "069": "https://server8.mp3quran.net/lhdan/069.mp3",
      "070": "https://server8.mp3quran.net/lhdan/070.mp3",
      "071": "https://server8.mp3quran.net/lhdan/071.mp3",
      "072": "https://server8.mp3quran.net/lhdan/072.mp3",
      "073": "https://server8.mp3quran.net/lhdan/073.mp3",
      "074": "https://server8.mp3quran.net/lhdan/074.mp3",
      "075": "https://server8.mp3quran.net/lhdan/075.mp3",
      "076": "https://server8.mp3quran.net/lhdan/076.mp3",
      "077": "https://server8.mp3quran.net/lhdan/077.mp3",
      "078": "https://server8.mp3quran.net/lhdan/078.mp3",
      "079": "https://server8.mp3quran.net/lhdan/079.mp3",
      "080": "https://server8.mp3quran.net/lhdan/080.mp3",
      "081": "https://server8.mp3quran.net/lhdan/081.mp3",
      "082": "https://server8.mp3quran.net/lhdan/082.mp3",
      "083": "https://server8.mp3quran.net/lhdan/083.mp3",
      "084": "https://server8.mp3quran.net/lhdan/084.mp3",
      "085": "https://server8.mp3quran.net/lhdan/085.mp3",
      "086": "https://server8.mp3quran.net/lhdan/086.mp3",
      "087": "https://server8.mp3quran.net/lhdan/087.mp3",
      "088": "https://server8.mp3quran.net/lhdan/088.mp3",
      "089": "https://server8.mp3quran.net/lhdan/089.mp3",
      "090": "https://server8.mp3quran.net/lhdan/090.mp3",
      "091": "https://server8.mp3quran.net/lhdan/091.mp3",
      "092": "https://server8.mp3quran.net/lhdan/092.mp3",
      "093": "https://server8.mp3quran.net/lhdan/093.mp3",
      "094": "https://server8.mp3quran.net/lhdan/094.mp3",
      "095": "https://server8.mp3quran.net/lhdan/095.mp3",
      "096": "https://server8.mp3quran.net/lhdan/096.mp3",
      "097": "https://server8.mp3quran.net/lhdan/097.mp3",
      "098": "https://server8.mp3quran.net/lhdan/098.mp3",
      "099": "https://server8.mp3quran.net/lhdan/099.mp3",
      "100": "https://server8.mp3quran.net/lhdan/100.mp3",
      "101": "https://server8.mp3quran.net/lhdan/101.mp3",
      "102": "https://server8.mp3quran.net/lhdan/102.mp3",
      "103": "https://server8.mp3quran.net/lhdan/103.mp3",
      "104": "https://server8.mp3quran.net/lhdan/104.mp3",
      "105": "https://server8.mp3quran.net/lhdan/105.mp3",
      "106": "https://server8.mp3quran.net/lhdan/106.mp3",
      "107": "https://server8.mp3quran.net/lhdan/107.mp3",
      "108": "https://server8.mp3quran.net/lhdan/108.mp3",
      "109": "https://server8.mp3quran.net/lhdan/109.mp3",
      "110": "https://server8.mp3quran.net/lhdan/110.mp3",
      "111": "https://server8.mp3quran.net/lhdan/111.mp3",
      "112": "https://server8.mp3quran.net/lhdan/112.mp3",
      "113": "https://server8.mp3quran.net/lhdan/113.mp3",
      "114": "https://server8.mp3quran.net/lhdan/114.mp3",
    };
  }

  Future<void> downloadSurah(BuildContext context, int surahNumber) async {
    if (isDownloading[surahNumber - 1] == true || isDownloaded[surahNumber - 1] == true) return;

    isDownloading[surahNumber - 1] = true;
    notifyListeners();

    try {
      final surahUrls = _getSurahUrls();
      final surahKey = surahNumber.toString().padLeft(3, '0');
      final url = surahUrls[surahKey]!;

      if (kIsWeb) {
        // Download to IndexedDB for persistence
        final response = await Dio().get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
        final data = Uint8List.fromList(response.data!);

        final db = await _getDatabase();
        final txn = db.transaction('audio_files', idb.idbModeReadWrite);
        final store = txn.objectStore('audio_files');
        final uniqueKey = 'surah_${surahKey}_al_fatiha'; // Use unique key
        await store.put({'surahNumber': surahNumber, 'data': data, 'key': uniqueKey});
        await txn.completed;

        // Create blob URL for playback
        final blob = html.Blob([data]);
        _blobUrls[surahNumber] = html.Url.createObjectUrlFromBlob(blob);

        isDownloaded[surahNumber - 1] = true;
        _downloadedKeys.add(uniqueKey);
        _downloadedSurahs.add(surahNumber);
        await _saveDownloadedSurahs();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحميل السورة بنجاح')),
          );
        }
      } else {
        // Mobile: download to file system
        final localPath = await _getLocalPath();
        final dir = Directory(localPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final filePath = path.join(localPath, '$surahNumber.mp3');
        await Dio().download(url, filePath);
        isDownloaded[surahNumber - 1] = true;
        _downloadedSurahs.add(surahNumber);
        await _saveDownloadedSurahs();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحميل السورة بنجاح')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل السورة: $e')),
        );
      }
    } finally {
      isDownloading[surahNumber - 1] = false;
      notifyListeners();
    }
  }

  Future<String?> getLocalFilePath(int surahNumber) async {
    if (isDownloaded[surahNumber - 1] != true) return null;
    if (kIsWeb) {
      final blobUrl = _blobUrls[surahNumber];
      if (blobUrl == null) {
        isDownloaded[surahNumber - 1] = false;
        notifyListeners();
      }
      return blobUrl;
    } else {
      final localPath = await _getLocalPath();
      final filePath = path.join(localPath, '$surahNumber.mp3');
      if (!await File(filePath).exists()) {
        isDownloaded[surahNumber - 1] = false;
        _downloadedSurahs.remove(surahNumber);
        await _saveDownloadedSurahs();
        notifyListeners();
        return null;
      }
      return filePath;
    }
  }
}
