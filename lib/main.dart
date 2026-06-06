import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmeet/core/theme/theme.dart';
import 'package:vmeet/data/sources/local_storage.dart';
import 'package:vmeet/domain/providers/providers.dart';
import 'package:vmeet/presentation/home/home_screen.dart';
import 'package:vmeet/presentation/onboarding/onboarding_screen.dart';

void main() async {
  // Ensure native widgets framework is bound before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load SharedPreferences to avoid asynchronous race conditions during boot
  final sharedPreferences = await SharedPreferences.getInstance();
  final localStorage = LocalStorage(sharedPreferences);

  runApp(
    ProviderScope(
      overrides: [
        // Inject the pre-loaded SharedPreferences wrapper
        localStorageProvider.overrideWithValue(localStorage),
      ],
      child: const VMeetApp(),
    ),
  );
}

class VMeetApp extends ConsumerWidget {
  const VMeetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamically watch profile state to control routing
    final profile = ref.watch(profileStateProvider);

    return MaterialApp(
      title: 'VMeet',
      debugShowCheckedModeBanner: false,
      theme: VMeetTheme.darkTheme,
      // If display name is set, take the user straight to dashboard, otherwise run onboarding
      home: profile.isOnboarded ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
