import 'package:flutter/material.dart';

import 'qibla_view_stub.dart' if (dart.library.io) 'qibla_view_io.dart' as impl;

/// Qibla UI: full compass on IO (mobile/desktop with sensors); calm placeholder on web.
Widget buildPrayerQiblaPage(BuildContext context) =>
    impl.buildPrayerQiblaPage(context);
