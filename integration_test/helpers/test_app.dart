import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/app/app.dart';
import 'package:gloo/providers/user_provider.dart';

/// Builds the full [GlooApp] wrapped in a [ProviderScope] with sensible
/// test defaults:
///
/// - SharedPreferences: onboarding done, consent shown, colorblind prompt
///   shown, analytics disabled.
/// - [streakProvider] returns 0.
/// - Firebase / Supabase / AdManager are NOT initialised — their
///   `isConfigured` guards will skip gracefully.
///
/// Pass [additionalOverrides] to add or replace provider overrides.
Widget buildTestApp({
  List<Override> additionalOverrides = const [],
}) {
  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'consent_shown': true,
    'colorblind_prompt_shown': true,
    'analytics_enabled': false,
    'sfx_enabled': false,
    'music_enabled': false,
    'haptics_enabled': false,
  });

  final overrides = <Override>[
    streakProvider.overrideWith((ref) async => 0),
    ...additionalOverrides,
  ];

  return ProviderScope(
    overrides: overrides,
    child: const GlooApp(),
  );
}
