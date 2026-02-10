import 'package:flutter/material.dart';
import '../data/qna_repository.dart';
import 'app_state.dart';
import 'root_shell.dart';
import '../screens/login_screen.dart';

class UniQnAApp extends StatefulWidget {
  const UniQnAApp({super.key});

  @override
  State<UniQnAApp> createState() => _UniQnAAppState();
}

class _UniQnAAppState extends State<UniQnAApp> {
  late final AppState state = AppState(repo: QnaRepository());

  @override
  void initState() {
    super.initState();
    state.init();
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF4F7CFF);

    final cs =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF3F66FF),
          secondary: const Color(0xFF6C5CE7),
          surface: const Color(0xFFF9FAFF),
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFF3F5FF),
          surfaceContainer: const Color(0xFFEFF2FF),
          outlineVariant: const Color(0xFFD7DCEB),
        );

    return AppStateScope(
      notifier: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Uni Q&A",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: cs,

          textTheme: Typography.material2021().black,

          scaffoldBackgroundColor: cs.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            foregroundColor: cs.onSurface,

            titleTextStyle: TextStyle(
              color: cs.onSurface, 
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          cardTheme: CardThemeData(
            color: cs.surfaceContainerLowest,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: cs.outlineVariant),
            ),
            margin: EdgeInsets.zero,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: cs.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: cs.primary, width: 1.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: cs.outlineVariant),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: cs.outlineVariant),
            ),
            labelStyle: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
            secondaryLabelStyle: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: cs.surfaceContainerLow,
            selectedColor: cs.primary.withValues(alpha: 0.14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: cs.surfaceContainerLow,
            indicatorColor: cs.primary.withValues(alpha: 0.16),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          iconTheme: IconThemeData(color: cs.onSurfaceVariant),
        ),
        home: const _Gate(),
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    if (!state.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!state.isLoggedIn) {
      return const LoginScreen();
    }

    return const RootShell();
  }
}
