import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/web/portfolio_screen.dart';
import 'screens/android/login_screen.dart';
import 'screens/android/editor_dashboard.dart';
import 'providers/github_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Dynamic Portfolio',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
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
