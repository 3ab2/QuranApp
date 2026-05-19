import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prophet_story.dart';
import '../stories/prophet_story_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/common_ui.dart';
import '../ui/app_tokens.dart';

class StoryDetailPage extends StatefulWidget {
  final String id;
  const StoryDetailPage({required this.id, super.key});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late Future<ProphetStory> _storyFuture;
  bool read = false;
  double _readingProgress = 0;
  bool _restoredScrollPosition = false;
  bool _scrollListenerAttached = false;

  String get _readKey => 'stories.read.${widget.id}';
  String get _progressKey => 'stories.progress.${widget.id}';

  @override
  void initState() {
    super.initState();
    _storyFuture = prophetStoryService.getStoryById(widget.id);
    _loadReadState();
  }

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedRead = prefs.getBool(_readKey) ?? false;
    final savedProgress = prefs.getDouble(_progressKey) ?? 0;
    setState(() {
      read = savedRead;
      _readingProgress = savedProgress.clamp(0, 1).toDouble();
    });
  }

  Future<void> _toggleRead() async {
    final prefs = await SharedPreferences.getInstance();
    final nextValue = !read;
    setState(() {
      read = nextValue;
      if (nextValue) _readingProgress = math.max(_readingProgress, 1);
    });
    await prefs.setBool(_readKey, read);
    await prefs.setDouble(_progressKey, _readingProgress.clamp(0, 1));
  }

  Future<void> _onStoryScroll() async {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final ratio =
        max <= 0 ? 0.0 : (_scrollController.offset / max).clamp(0, 1).toDouble();
    if ((ratio - _readingProgress).abs() < 0.01) return;

    final prefs = await SharedPreferences.getInstance();
    final reachedCompletion = ratio >= 0.95;

    if (!mounted) return;
    setState(() {
      _readingProgress = ratio;
      if (reachedCompletion) read = true;
    });

    await prefs.setDouble(_progressKey, _readingProgress);
    if (reachedCompletion) {
      await prefs.setBool(_readKey, true);
    }
  }

  void _attachScrollListener() {
    if (_scrollListenerAttached) return;
    _scrollController.addListener(_onStoryScroll);
    _scrollListenerAttached = true;
  }

  void _restoreScrollIfNeeded() {
    if (_restoredScrollPosition) return;
    _restoredScrollPosition = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (max <= 0 || _readingProgress <= 0 || _readingProgress >= 1) return;
      _scrollController.jumpTo(max * _readingProgress);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onStoryScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);

    return Directionality(
      textDirection: Directionality.of(ctx),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: FutureBuilder<ProphetStory>(
                  future: _storyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return _StoryLoadError(
                        onRetry: () {
                          prophetStoryService.clearCache();
                          setState(() {
                            _storyFuture =
                                prophetStoryService.getStoryById(widget.id);
                          });
                        },
                      );
                    }

                    final story = snapshot.data!;
                    _attachScrollListener();
                    _restoreScrollIfNeeded();
                    final bottomPad =
                        MediaQuery.paddingOf(context).bottom + AppSpacing.md;
                    return CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageH,
                            AppSpacing.sm,
                            AppSpacing.pageH,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CompactStoryHeader(
                                  story: story,
                                  read: read,
                                  progress: _readingProgress,
                                  onToggleRead: _toggleRead,
                                  onContinueReading: _restoreScrollIfNeeded,
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.pageH,
                            0,
                            AppSpacing.pageH,
                            bottomPad,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _StoryBodyColumn(
                              story: story,
                              storyId: widget.id,
                            ),
                          ),
                        ),
                      ],
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
}

class _CompactStoryHeader extends StatelessWidget {
  final ProphetStory story;
  final bool read;
  final double progress;
  final Future<void> Function() onToggleRead;
  final VoidCallback onContinueReading;

  const _CompactStoryHeader({
    required this.story,
    required this.read,
    required this.progress,
    required this.onToggleRead,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final estimatedMinutes =
        math.max(1, (story.fullContent.split(RegExp(r'\s+')).length / 180).ceil());

    return AppCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () {
                  final nav = Navigator.of(context);
                  if (nav.canPop()) nav.pop();
                },
                icon: const BackButtonIcon(),
                color: cs.primary,
              ),
              Expanded(
                child: Text(
                  story.prophetName,
                  style: AppTypography.listTitle(cs),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: l10n.storyReadDone,
                visualDensity: VisualDensity.compact,
                onPressed: onToggleRead,
                icon: Icon(
                  read ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: read ? cs.primary : cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MetaChip(icon: Icons.menu_book_outlined, text: '$estimatedMinutes min'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: progress.clamp(0, 1),
              backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.45),
            ),
          ),
          if (progress > 0 && progress < 1) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onContinueReading,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.playlist_play, size: 16),
                label: Text(l10n.quranContinueReading, style: GoogleFonts.amiri(fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurface.withValues(alpha: 0.75)),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.amiri(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryBodyColumn extends StatelessWidget {
  final ProphetStory story;
  final String storyId;

  const _StoryBodyColumn({
    required this.story,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = _StoryNarrativeSections.from(story);

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StorySectionPanel(
              title: 'مقدمة وسياق',
              storyId: storyId,
              sectionId: 'intro',
              initiallyExpanded: true,
              child: _StoryParagraph(text: sections.introduction),
            ),
            const SizedBox(height: 8),
            _StorySectionPanel(
              title: 'السرد الكامل',
              storyId: storyId,
              sectionId: 'narrative',
              initiallyExpanded: true,
              child: _ImmersiveNarrativeBlock(story: story),
            ),
            const SizedBox(height: 8),
            _SectionGroup(
              title: 'التسلسل الزمني',
              storyId: storyId,
              sectionId: 'timeline',
              sections: story.timeline,
              emptyFallback: 'لا توجد مراحل زمنية إضافية في هذه القصة.',
            ),
            const SizedBox(height: 8),
            _SectionGroup(
              title: 'المحطات الأساسية',
              storyId: storyId,
              sectionId: 'events',
              sections: story.events,
              emptyFallback: 'لا توجد محطات إضافية مسجلة لهذه القصة.',
            ),
            const SizedBox(height: 8),
            _SectionGroup(
              title: 'الدروس والحكمة',
              storyId: storyId,
              sectionId: 'lessons',
              sections: story.lessons,
              emptyFallback: 'لا توجد دروس إضافية مسجلة لهذه القصة.',
            ),
            const SizedBox(height: 8),
            _StorySectionPanel(
              title: 'الخاتمة',
              storyId: storyId,
              sectionId: 'outro',
              initiallyExpanded: true,
              child: _StoryParagraph(text: sections.conclusion),
            ),
          ],
        ),
    );
  }
}

class _ImmersiveNarrativeBlock extends StatelessWidget {
  final ProphetStory story;

  const _ImmersiveNarrativeBlock({required this.story});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final paragraphs = _expandedNarrativeParagraphs(story);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < paragraphs.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == paragraphs.length - 1 ? 0 : 10),
            child: Text(
              paragraphs[i],
              style: GoogleFonts.amiri(
                fontSize: 18,
                height: 1.95,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),
      ],
    );
  }

  List<String> _expandedNarrativeParagraphs(ProphetStory story) {
    final base = _splitParagraphs(story.fullContent);
    final timeline = story.timeline.map((s) => s.content.trim()).where((e) => e.isNotEmpty);
    final events = story.events.map((s) => s.content.trim()).where((e) => e.isNotEmpty);
    final lessons = story.lessons.map((s) => s.content.trim()).where((e) => e.isNotEmpty);

    final extras = <String>[];
    if (timeline.isNotEmpty) {
      extras.add(
        'ثم تتوالى الأحداث في خطّ واضح، حيث تبدأ القصة من جذورها الأولى ثم تمضي بتدرّج يرسّخ المعنى في القلب: ${timeline.join(' ثم ')}.',
      );
    }
    if (events.isNotEmpty) {
      extras.add(
        'وفي اللحظات الحاسمة تتجلى مشاهد قوية في السرد: ${events.join('، ')}. '
        'هذه المحطات لا تُذكر لمجرد التاريخ، بل لتصنع أثرًا إيمانيًا وتربويًا حيًا.',
      );
    }
    if (lessons.isNotEmpty) {
      extras.add(
        'ومن هذا المسار كله تتبلور دروس عملية للمؤمن في حياته اليومية: ${lessons.join('، ')}.',
      );
    }

    final all = <String>[...base, ...extras];
    return all.where((p) => p.trim().isNotEmpty).toList(growable: false);
  }

  List<String> _splitParagraphs(String input) {
    final normalized = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return const [];
    final sentences = normalized
        .split(RegExp(r'(?<=[.!؟])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList(growable: false);
    if (sentences.length <= 3) return [normalized];

    final result = <String>[];
    const chunk = 3;
    for (var i = 0; i < sentences.length; i += chunk) {
      final end = math.min(i + chunk, sentences.length);
      result.add(sentences.sublist(i, end).join(' '));
    }
    return result;
  }
}

class _StoryParagraph extends StatelessWidget {
  final String text;

  const _StoryParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.amiri(
        fontSize: 18,
        height: 1.85,
        color: cs.onSurface,
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      softWrap: true,
    );
  }
}

class _StorySectionPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final String storyId;
  final String sectionId;

  const _StorySectionPanel({
    required this.title,
    required this.child,
    required this.storyId,
    required this.sectionId,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final storageKey = PageStorageKey<String>('story-panel.$storyId.$sectionId');
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: storageKey,
          maintainState: true,
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          childrenPadding:
              const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            title,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  final String title;
  final String storyId;
  final String sectionId;
  final List<StorySection> sections;
  final String emptyFallback;

  const _SectionGroup({
    required this.title,
    required this.storyId,
    required this.sectionId,
    required this.sections,
    required this.emptyFallback,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _StorySectionPanel(
      title: title,
      storyId: storyId,
      sectionId: sectionId,
      child: sections.isEmpty
          ? Text(
              emptyFallback,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 16,
                height: 1.7,
                color: cs.onSurface.withValues(alpha: 0.72),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < sections.length; i++)
                  Container(
                    margin: EdgeInsets.only(bottom: i == sections.length - 1 ? 0 : 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          sections[i].title.isNotEmpty
                              ? sections[i].title
                              : 'محطة ${i + 1}',
                          style: GoogleFonts.amiri(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sections[i].content,
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            height: 1.75,
                            color: cs.onSurface.withValues(alpha: 0.86),
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StoryNarrativeSections {
  final String introduction;
  final String conclusion;

  const _StoryNarrativeSections({
    required this.introduction,
    required this.conclusion,
  });

  factory _StoryNarrativeSections.from(ProphetStory story) {
    final normalized = story.fullContent.replaceAll(RegExp(r'\s+'), ' ').trim();
    final sentences = normalized
        .split(RegExp(r'(?<=[.!؟])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList(growable: false);

    String safeJoin(List<String> list) => list.join(' ').trim();
    final intro =
        sentences.length >= 2 ? safeJoin(sentences.take(2).toList()) : normalized;
    final outro = sentences.length >= 3
        ? safeJoin(sentences.sublist(sentences.length - 2))
        : (story.lessons.isNotEmpty
            ? story.lessons.map((e) => e.content).join(' ')
            : normalized);

    return _StoryNarrativeSections(
      introduction: intro,
      conclusion: outro,
    );
  }
}

class _StoryLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _StoryLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BackButtonIcon(),
            const SizedBox(height: 20),
            Text(
              l10n.storyLoadError,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.storyRetry),
            ),
          ],
        ),
      ),
    );
  }
}
