import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prophet_story.dart';
import '../stories/prophet_story_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class StoryDetailPage extends StatefulWidget {
  final String id;
  const StoryDetailPage({required this.id, super.key});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  late Future<ProphetStory> _storyFuture;
  bool isPlaying = false;
  bool read = false;

  @override
  void initState() {
    super.initState();
    _storyFuture = prophetStoryService.getStoryById(widget.id);
    _loadReadState();
    _playerStateSubscription = _player.playerStateStream.listen((st) {
      if (!mounted) return;
      if (st.processingState == ProcessingState.completed || !st.playing) {
        setState(() => isPlaying = false);
      }
    });
  }

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => read = prefs.getBool('stories.read.${widget.id}') ?? false);
  }

  Future<void> _toggleRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => read = !read);
    await prefs.setBool('stories.read.${widget.id}', read);
  }

  Future<void> _playAudio(ProphetStory story) async {
    final l10n = AppLocalizations.of(context)!;
    if (!story.hasAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.storyNoAudio)),
      );
      return;
    }
    try {
      if (isPlaying) {
        await _player.stop();
        if (!mounted) return;
        setState(() => isPlaying = false);
        return;
      }
      await _player.setUrl(story.audioUrl!);
      await _player.play();
      if (!mounted) return;
      setState(() => isPlaying = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.storyAudioError)),
      );
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;

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
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const BackButtonWidget(),
                              Expanded(
                                child: Text(
                                  story.prophetName,
                                  style: GoogleFonts.amiri(
                                    color: cs.onSurface,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _StoryAudioPanel(
                                  story: story,
                                  isPlaying: isPlaying,
                                  onPressed: () => _playAudio(story),
                                ),
                                Expanded(child: _StoryContent(story: story)),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.shadowColor
                                            .withValues(alpha: 0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: read,
                                        activeColor: cs.primary,
                                        onChanged: (_) => _toggleRead(),
                                      ),
                                      Text(
                                        l10n.storyReadDone,
                                        style: GoogleFonts.amiri(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

class _StoryAudioPanel extends StatelessWidget {
  final ProphetStory story;
  final bool isPlaying;
  final VoidCallback onPressed;

  const _StoryAudioPanel({
    required this.story,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: story.hasAudio
          ? ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(
                isPlaying ? l10n.storyStop : l10n.storyPlay,
                style: GoogleFonts.amiri(),
              ),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                l10n.storyNoAudio,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  color: cs.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
    );
  }
}

class _StoryContent extends StatelessWidget {
  final ProphetStory story;

  const _StoryContent({required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              story.title,
              style: GoogleFonts.amiri(
                fontSize: 22,
                height: 1.5,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            Text(
              story.fullContent,
              style: GoogleFonts.amiri(
                fontSize: 18,
                height: 1.7,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              softWrap: true,
            ),
            _SectionGroup(title: 'الأحداث', sections: story.events),
            _SectionGroup(title: 'التسلسل', sections: story.timeline),
            _SectionGroup(title: 'الدروس', sections: story.lessons),
          ],
        ),
      ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  final String title;
  final List<StorySection> sections;

  const _SectionGroup({
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.amiri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (section.title.isNotEmpty)
                    Text(
                      section.title,
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  Text(
                    section.content,
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      height: 1.6,
                      color: cs.onSurface.withValues(alpha: 0.85),
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
            const BackButtonWidget(),
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
