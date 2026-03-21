import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../core/utils/motion_utils.dart';
import '../../game/meta/resource_manager.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import 'character_background.dart';
import 'character_widgets.dart';

class CharacterScreen extends ConsumerStatefulWidget {
  const CharacterScreen({super.key});

  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen> {
  late final ResourceManager _resources;
  late final CharacterState _character;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _resources = ResourceManager();
    _character = CharacterState();
    _loadState();
  }

  Future<void> _loadState() async {
    final repo = await ref.read(localRepositoryProvider.future);
    _resources.setEnergy(await repo.getGelEnergy());
    _character.loadFromMap(repo.getCharacterState());
    setState(() => _loaded = true);

    // Backend'den sync
    final remote = ref.read(remoteRepositoryProvider);
    final meta = await remote.loadMetaState();
    if (meta != null && mounted) {
      final backendChar = meta.characterState;
      final backendEnergy = meta.gelEnergy;
      if (backendChar != null && backendChar.isNotEmpty) {
        _character.loadFromMap(backendChar);
        await repo.saveCharacterState(_character.toMap());
      }
      if (backendEnergy != null && backendEnergy > _resources.energy) {
        _resources.setEnergy(backendEnergy);
        await repo.saveGelEnergy(backendEnergy);
      }
      setState(() {});
    }
  }

  Future<void> _onUpgradeTalent(TalentType type) async {
    final success = _character.upgradeTalent(type, _resources);
    if (success) {
      final repo = await ref.read(localRepositoryProvider.future);
      await repo.saveCharacterState(_character.toMap());
      await repo.saveGelEnergy(_resources.energy);
      setState(() {});

      // Backend sync (fire-and-forget)
      ref.read(remoteRepositoryProvider).saveMetaState(
            characterState: _character.toMap(),
            gelEnergy: _resources.energy,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final surfaceColor = resolveColor(brightness, dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness, dark: Colors.white.withValues(alpha: 0.10), light: kCardBorderLight);
    final textSecondary = resolveColor(brightness, dark: Colors.white.withValues(alpha: 0.50), light: kTextSecondaryLight);
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const CharBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
                child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Row(
                    children: [
                      Semantics(
                        label: ref.read(stringsProvider).backLabel,
                        button: true,
                        child: GestureDetector(
                          onTap: () => context.go('/'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusMd),
                              border: Border.all(color: borderColor),
                            ),
                            child: Icon(directionalBackIcon(dir),
                                color: kLavender, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'KARAKTER',
                        style: TextStyle(
                          color: kLavender,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: kLavender.withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kCyan.withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusMd),
                          border: Border.all(
                            color: kCyan.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: kCyan, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _loaded ? '${_resources.energy}' : '-',
                              style: const TextStyle(
                                color: kCyan,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animateOrSkip(reduceMotion: shouldReduceMotion(context)).fadeIn(duration: 300.ms),
                const SizedBox(height: 20),
                const GlooMascot()
                    .animateOrSkip(reduceMotion: shouldReduceMotion(context), delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 24),
                Expanded(
                  child: _loaded
                      ? ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: hPadding),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'YETENEKLER',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            ...TalentType.values.asMap().entries.map((e) {
                              final type = e.value;
                              final def = kTalents[type]!;
                              final level = _character.getTalentLevel(type);
                              final cost = def.costPerLevel * (level + 1);
                              final isMax = level >= def.maxLevel;

                              return TalentCard(
                                def: def,
                                level: level,
                                cost: cost,
                                isMax: isMax,
                                canAfford: _resources.canAfford(cost),
                                onUpgrade: () => _onUpgradeTalent(type),
                                delay: Duration(milliseconds: 100 * e.key),
                              );
                            }),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: kLavender),
                        ),
                ),
              ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
