import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/glow_orb.dart';
import '../../data/remote/remote_repository.dart';
import '../../game/meta/resource_manager.dart';
import '../../providers/user_provider.dart';

// ─── Karakter Ekrani ─────────────────────────────────────────────────────────

class CharacterScreen extends ConsumerStatefulWidget {
  const CharacterScreen({super.key});

  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen> {
  static const _kAccent = Color(0xFFB080FF);
  static const _kEnergy = Color(0xFF00E5FF);

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
    _resources.setEnergy(repo.getGelEnergy());
    _character.loadFromMap(repo.getCharacterState());
    setState(() => _loaded = true);

    // Backend'den sync
    final remote = RemoteRepository();
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
      RemoteRepository().saveMetaState(
        characterState: _character.toMap(),
        gelEnergy: _resources.energy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          _CharBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Ust bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusMd),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white70, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'KARAKTER',
                        style: TextStyle(
                          color: _kAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: _kAccent.withValues(alpha: 0.5),
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
                          color: _kEnergy.withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusMd),
                          border: Border.all(
                            color: _kEnergy.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: _kEnergy, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _loaded ? '${_resources.energy}' : '-',
                              style: const TextStyle(
                                color: _kEnergy,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 20),
                // Gloo maskot
                _GlooMascot()
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 24),
                // Yetenek agaci
                Expanded(
                  child: _loaded
                      ? ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'YETENEKLER',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.50),
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

                              return _TalentCard(
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
                          child: CircularProgressIndicator(color: _kAccent),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gloo Maskot ────────────────────────────────────────────────────────────

class _GlooMascot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [Color(0xFF5CFFA8), Color(0xFF00CC66), Color(0xFF008844)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3CFF8B).withValues(alpha: 0.30),
            blurRadius: 28,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gozler
          Positioned(
            top: 30,
            left: 28,
            child: Container(
              width: 14,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Align(
                alignment: const Alignment(0.3, 0.3),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A2E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 28,
            child: Container(
              width: 14,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Align(
                alignment: const Alignment(0.3, 0.3),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A2E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Agiz
          Positioned(
            bottom: 24,
            left: 36,
            child: Container(
              width: 28,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF006633),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          // Specular highlight
          Positioned(
            top: 14,
            left: 20,
            child: Container(
              width: 22,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Yetenek Karti ──────────────────────────────────────────────────────────

class _TalentCard extends StatelessWidget {
  const _TalentCard({
    required this.def,
    required this.level,
    required this.cost,
    required this.isMax,
    required this.canAfford,
    required this.onUpgrade,
    required this.delay,
  });

  final TalentDef def;
  final int level;
  final int cost;
  final bool isMax;
  final bool canAfford;
  final VoidCallback onUpgrade;
  final Duration delay;

  Color get _talentColor => switch (def.type) {
        TalentType.betterHand => const Color(0xFF3CFF8B),
        TalentType.colorMaster => const Color(0xFFFF8C42),
        TalentType.fastHands => const Color(0xFFFF4D6D),
        TalentType.zenGuru => const Color(0xFFB080FF),
      };

  IconData get _talentIcon => switch (def.type) {
        TalentType.betterHand => Icons.back_hand_rounded,
        TalentType.colorMaster => Icons.palette_rounded,
        TalentType.fastHands => Icons.speed_rounded,
        TalentType.zenGuru => Icons.self_improvement_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _talentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(_talentIcon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        def.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Lv.$level/${def.maxLevel}',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    def.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMax)
              GestureDetector(
                onTap: canAfford ? onUpgrade : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                    border: Border.all(
                      color: canAfford
                          ? color.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    '$cost',
                    style: TextStyle(
                      color: canAfford ? color : kMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            else
              Text(
                'MAKS',
                style: TextStyle(
                  color: color.withValues(alpha: 0.50),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.06, end: 0, duration: 250.ms);
  }
}

// ─── Arkaplan ───────────────────────────────────────────────────────────────

class _CharBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          right: -50,
          child: GlowOrb(size: 320, color: Color(0xFFB080FF), opacity: 0.07),
        ),
        const Positioned(
          bottom: -80,
          left: -60,
          child: GlowOrb(size: 260, color: Color(0xFF3CFF8B), opacity: 0.05),
        ),
      ],
    );
  }
}
