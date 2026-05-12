import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../models/prophet_story.dart';
import '../stories/prophet_story_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/common_ui.dart';
import '../ui/app_tokens.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  late Future<List<ProphetStory>> _storiesFuture;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchOpen = false;
  bool _audioOnly = false;

  @override
  void initState() {
    super.initState();
    _storiesFuture = prophetStoryService.getStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _retry() {
    prophetStoryService.clearCache();
    setState(() {
      _storiesFuture = prophetStoryService.getStories();
    });
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchController.clear();
        _searchFocusNode.unfocus();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _searchFocusNode.requestFocus();
        });
      }
    });
  }

  bool _storyMatchesQuery(ProphetStory story, String q) {
    final t = q.trim().toLowerCase();
    if (t.isEmpty) return true;
    final hay = '${story.prophetName} ${story.title} ${story.fullContent}'.toLowerCase();
    return hay.contains(t);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, AppSpacing.sm, AppSpacing.pageH, AppSpacing.xs),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.quranBackToHome,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () {
                        final nav = Navigator.of(context);
                        if (nav.canPop()) {
                          nav.pop();
                        } else {
                          nav.pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                      icon: const BackButtonIcon(),
                      color: cs.primary,
                    ),
                    Expanded(
                      child: Text(
                        l10n.homeStories,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.pageTitle(cs),
                      ),
                    ),
                    FilterChip(
                      label: Text(
                        l10n.homeAudio,
                        style: AppTypography.caption(cs, opacity: 0.95),
                      ),
                      selected: _audioOnly,
                      onSelected: (v) => setState(() => _audioOnly = v),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      showCheckmark: false,
                      avatar: Icon(
                        Icons.headphones_outlined,
                        size: 16,
                        color: _audioOnly ? cs.onPrimary : cs.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: _searchOpen ? l10n.quranSearchClose : l10n.prophetStoriesSearchOpenTooltip,
                      onPressed: _toggleSearch,
                      icon: Icon(_searchOpen ? Icons.close : Icons.search, color: cs.primary),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _searchOpen
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageH,
                          0,
                          AppSpacing.pageH,
                          AppSpacing.sm,
                        ),
                        child: AppSearchTextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          hintText: l10n.prophetStoriesSearchHint,
                          textDirection: TextDirection.rtl,
                          onChanged: (_) => setState(() {}),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: FutureBuilder<List<ProphetStory>>(
                  future: _storiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return AppLoadingView(label: l10n.homeStories);
                    }

                    if (snapshot.hasError) {
                      return AppErrorView(
                        message: l10n.storyLoadError,
                        onRetry: _retry,
                        retryLabel: l10n.storyRetry,
                      );
                    }

                    final stories = snapshot.data ?? const <ProphetStory>[];
                    final baseUnique = _uniqueStories(stories);
                    if (baseUnique.isEmpty) {
                      return AppErrorView(
                        message: l10n.storyLoadError,
                        onRetry: _retry,
                        retryLabel: l10n.storyRetry,
                      );
                    }

                    final q = _searchController.text;
                    var rows = baseUnique
                        .where((s) => !_audioOnly || s.hasNarration)
                        .toList();
                    rows = rows.where((s) => _storyMatchesQuery(s, q)).toList();

                    if (rows.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            l10n.prophetStoriesSearchEmpty,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(cs, opacity: 0.85),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageH,
                        AppSpacing.xs,
                        AppSpacing.pageH,
                        AppSpacing.listBottom,
                      ),
                      itemCount: rows.length,
                      itemBuilder: (context, i) {
                        final story = rows[i];
                        final subtitle = _storyMetaLabel(story);
                        return AppCard(
                          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            title: Text(
                              story.prophetName,
                              style: AppTypography.listTitle(cs),
                              textDirection: TextDirection.rtl,
                            ),
                            subtitle: subtitle == null
                                ? null
                                : Text(
                                    subtitle,
                                    style: AppTypography.caption(cs, opacity: 0.72),
                                    textDirection: TextDirection.rtl,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: AppIconSizes.sm,
                              color: cs.onSurface.withValues(alpha: 0.45),
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/story/${story.id}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ProphetStory> _uniqueStories(List<ProphetStory> stories) {
    final seenIds = <String>{};
    final seenProphetKeys = <String>{};
    final unique = <ProphetStory>[];

    for (final story in stories) {
      final prophetKey = _normalizeProphetKey(story.prophetName);
      final isDuplicateId = !seenIds.add(story.id);
      final isDuplicateProphet =
          prophetKey.isNotEmpty && !seenProphetKeys.add(prophetKey);
      if (isDuplicateId || isDuplicateProphet) {
        if (kDebugMode) {
          debugPrint(
            '[StoriesPage] duplicate list item skipped: '
            'id=${story.id}, prophet=${story.prophetName}',
          );
        }
        continue;
      }
      unique.add(story);
    }

    return unique;
  }

  String _normalizeProphetKey(String input) {
    final lowered = input.toLowerCase().trim();
    return lowered.replaceAll(RegExp(r'[\s\-_]+'), '');
  }

  String? _storyMetaLabel(ProphetStory story) {
    final normalizedTitle = story.title.trim();
    if (normalizedTitle.isEmpty) return null;
    final compactTitle = normalizedTitle
        .replaceAll(story.prophetName, '')
        .replaceAll('قصة', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return compactTitle.isEmpty ? null : compactTitle;
  }
}
