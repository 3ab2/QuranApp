import 'package:flutter/material.dart';

import 'qibla_view_stub.dart' if (dart.library.io) 'qibla_view_io.dart' as impl;

/// Qibla UI: live compass on mobile; premium fallback elsewhere.
Widget buildPrayerQiblaPage(BuildContext context) =>
    impl.buildPrayerQiblaPage(context);
