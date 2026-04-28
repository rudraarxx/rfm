import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/rfm_theme.dart';
import 'logic/audio/radio_handler.dart';
import 'presentation/screens/dashboard_screen.dart';

late AudioHandler radioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  radioHandler = await AudioService.init(
    builder: () => RadioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rfm.music.playback',
      androidNotificationChannelName: 'RFM Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
    ),
  );

  runApp(
    const ProviderScope(
      child: RFMApp(),
    ),
  );
}

class RFMApp extends ConsumerWidget {
  const RFMApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'RFM Music OS',
      theme: RFMTheme.lightTheme,
      darkTheme: RFMTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
