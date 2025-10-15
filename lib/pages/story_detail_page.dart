import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/prophets_data.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class StoryDetailPage extends StatefulWidget {
  final String id;
  const StoryDetailPage({required this.id, super.key});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  late Map<String, dynamic> p;
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool read = false;

  @override
  void initState() {
    super.initState();
    p = prophets.firstWhere((e) => e["id"] == widget.id);
    _loadReadState();
  }

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => read = prefs.getBool('read_${widget.id}') ?? false);
  }

  Future<void> _toggleRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => read = !read);
    await prefs.setBool('read_${widget.id}', read);
  }

  Future<void> _playAudio() async {
    await _player.setUrl(p["audioUrl"]);
    _player.play();
    setState(() => isPlaying = true);
    _player.playerStateStream.listen((st) {
      if (st.processingState == ProcessingState.completed) {
        setState(() => isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    const Color backgroundColor = Colors.white;
    const Color gold = Color(0xFFD4AF37);
    const Color darkGreen = Color(0xFF006400);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: 20),
              // Back Button and Page Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const BackButtonWidget(),
                    Expanded(
                      child: Text(
                        p["name"],
                        style: GoogleFonts.amiri(
                          color: darkGreen,
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
                      Container(
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
                        child: ElevatedButton.icon(
                          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                          label: Text(
                            isPlaying ? 'إيقاف الصوت' : 'تشغيل القصة',
                            style: GoogleFonts.amiri(),
                          ),
                          onPressed: _playAudio,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              p["story"],
                              style: GoogleFonts.amiri(
                                fontSize: 18,
                                height: 1.6,
                                color: darkGreen,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: read,
                              activeColor: darkGreen,
                              onChanged: (_) => _toggleRead(),
                            ),
                            Text(
                              'تمت القراءة',
                              style: GoogleFonts.amiri(
                                color: darkGreen,
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
          ),
        ),
      ),
    );
  }
}
