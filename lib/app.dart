import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/audio_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/monitor_screen.dart';
import 'screens/recordings_screen.dart';
import 'screens/playback_screen.dart';
import 'screens/settings_screen.dart';

class EchoBackApp extends StatelessWidget {
  const EchoBackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoBack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const MainShell(),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/playback') {
          return MaterialPageRoute(
            builder: (_) => const PlaybackScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = const [
    MonitorScreen(),
    RecordingsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Consumer<AudioProvider>(
        builder: (context, audio, _) {
          if (audio.isMonitoring || audio.isRecording) {
            return const SizedBox.shrink();
          }
          return NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.headphones_outlined),
                selectedIcon: const Icon(Icons.headphones),
                label: l.earpiece,
              ),
              NavigationDestination(
                icon: const Icon(Icons.library_music_outlined),
                selectedIcon: const Icon(Icons.library_music),
                label: l.recordList,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l.settings,
              ),
            ],
          );
        },
      ),
    );
  }
}
