import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'screens/web/portfolio_screen.dart';
import 'screens/android/login_screen.dart';
import 'screens/android/editor_dashboard.dart';
import 'providers/github_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'sanjay flutter SDE',
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurpleAccent,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: kIsWeb ? const PortfolioScreen() : const EditorEntry(),
    );
  }
}

class EditorEntry extends ConsumerWidget {
  const EditorEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(githubTokenProvider);
    if (token != null && token.isNotEmpty) {
      return const EditorDashboard();
    }
    return const LoginScreen();
  }
}
