import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _storiesFuture = prophetStoryService.getStories();
  }

  void _retry() {
    prophetStoryService.clearCache();
    setState(() {
      _storiesFuture = prophetStoryService.getStories();
    });
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
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(title: l10n.homeStories),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: FutureBuilder<List<ProphetStory>>(
                  future: _storiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _StoriesError(onRetry: _retry);
                    }

                    final stories = snapshot.data ?? const <ProphetStory>[];
                    if (stories.isEmpty) {
                      return _StoriesError(onRetry: _retry);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: stories.length,
                      itemBuilder: (context, i) {
                        final story = stories[i];
                        return AppCard(
                          margin: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              story.prophetName,
                              style: GoogleFonts.amiri(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              story.title,
                              style: GoogleFonts.amiri(
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: cs.onSurface,
                            ),
                            onTap: () => Navigator.pushNamed(
                                context, '/story/${story.id}'),
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
}

class _StoriesError extends StatelessWidget {
  final VoidCallback onRetry;

  const _StoriesError({required this.onRetry});

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
            Text(
              l10n.storyLoadError,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
