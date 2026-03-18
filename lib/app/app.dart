import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/color_constants.dart';
import '../core/constants/color_constants_light.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import 'router.dart';

class GlooApp extends ConsumerWidget {
  const GlooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Gloo',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
        Locale('ru'),
        Locale('es'),
        Locale('ar'),
        Locale('hi'),
        Locale('pt'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: kThemePrimary,
          secondary: kThemeSecondary,
          tertiary: kThemeTertiary,
          surface: kSurfaceLight,
        ),
        fontFamily: 'Syne',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kThemePrimary,
          secondary: kThemeSecondary,
          tertiary: kThemeTertiary,
          surface: kSurfaceBlack,
        ),
        fontFamily: 'Syne',
      ),
      routerConfig: router,
    );
  }
}
