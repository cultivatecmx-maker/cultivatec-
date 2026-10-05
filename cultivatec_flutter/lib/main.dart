import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/config/firebase_config.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
import 'package:cultivatec_flutter/providers/learning_provider.dart';
import 'package:cultivatec_flutter/screens/auth/auth_screen.dart';
import 'package:cultivatec_flutter/screens/auth/onboarding_screen.dart';
import 'package:cultivatec_flutter/screens/home/home_screen.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_states.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
  await SoundService.init();
  await DailyGoalService.init();
  await MotionSettings.init();
  runApp(const CultivaTecApp());
}

class CultivaTecApp extends StatelessWidget {
  const CultivaTecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
      ],
      child: MaterialApp(
        title: 'Wokov',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const AppRouter(),
      ),
    );
  }
}

/// Root router that decides which screen to show based on auth/onboarding state.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final String stage;
        final Widget screen;
        if (auth.isInitializing) {
          stage = 'splash';
          screen = const WokovSplash();
        } else if (!auth.isLoggedIn) {
          stage = 'auth';
          screen = const AuthScreen();
        } else if (!auth.onboardingDone) {
          stage = 'onboarding';
          screen = const OnboardingScreen();
        } else {
          stage = 'home';
          screen = const HomeScreen();
        }

        // Fundido suave entre pantallas raíz (la misma etapa conserva su estado).
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOut,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: Tween<double>(begin: 0.97, end: 1).animate(anim), child: child),
          ),
          child: KeyedSubtree(key: ValueKey(stage), child: screen),
        );
      },
    );
  }
}
