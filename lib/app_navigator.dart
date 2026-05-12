import 'package:flutter/material.dart';

/// Root navigator for opening routes (e.g. full-screen tilawat) from the app shell.
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Route name for [TilawatFullPlayerPage] (focus / observer hooks).
const tilawatFullPlayerRouteName = '/tilawat-full';

/// Route name for [StoryNarrationFullPlayerPage] (focus / observer hooks).
const storyNarrationFullPlayerRouteName = '/story-narration-full';
