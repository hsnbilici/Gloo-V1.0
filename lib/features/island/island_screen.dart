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

// ─── Gloo Adasi Ekrani ──────────────────────────────────────────────────────

class IslandScreen extends ConsumerStatefulWidget {
  const IslandScreen({super.key});

  @override
  ConsumerState<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends ConsumerState<IslandScreen> {
  static const _kAccent = Color(0xFF3CFF8B);
  static const _kEnergy = Color(0xFF00E5FF);

  late final ResourceManager _resources;
  late final IslandState _island;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _resources = ResourceManager();
    _island = IslandState();
    _loadState();
  }

  Future<void> _loadState() async {
    final repo = await ref.read(localRepositoryProvider.future);
    _resources.setEnergy(repo.getGelEnergy());
    _resources.setTotalEarned(repo.getTotalEarnedEnergy());
    _island.loadFromMap(repo.getIslandState());
    setState(() => _loaded = true);

    // Backend'den sync (local-first, backend override)
    final remote = RemoteRepository();
    final meta = await remote.loadMetaState();
    if (meta != null && mounted) {
      final backendIsland = meta.islandState;
      final backendEnergy = meta.gelEnergy;
      final backendTotal = meta.totalEarnedEnergy;
      if (backendIsland != null && backendIsland.isNotEmpty) {
        _island.loadFromMap(backendIsland.map((k, v) => MapEntry(k, v as int)));
        await repo.saveIslandState(_island.toMap());
      }
      if (backendEnergy != null && backendEnergy > _resources.energy) {
        _resources.setEnergy(backendEnergy);
        await repo.saveGelEnergy(backendEnergy);
      }
      if (backendTotal != null &&
          backendTotal > _resources.totalEarnedLifetime) {
        _resources.setTotalEarned(backendTotal);
        await repo.saveTotalEarnedEnergy(backendTotal);
      }
      setState(() {});
    }
  }

  Future<void> _onUpgrade(BuildingType type) async {
    if (!_island.canBuild(type)) return;
    final cost = _island.getUpgradeCost(type);
    if (!_resources.canAfford(cost)) return;

    final success = _island.upgrade(type, _resources);
    if (success) {
      final repo = await ref.read(localRepositoryProvider.future);
      await repo.saveIslandState(_island.toMap());
      await repo.saveGelEnergy(_resources.energy);
      setState(() {});

      // Backend sync (fire-and-forget)
      RemoteRepository().saveMetaState(
        islandState: _island.toMap(),
        gelEnergy: _resources.energy,
        totalEarnedEnergy: _resources.totalEarnedLifetime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          _IslandBackground(),
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
                        'GLOO ADASI',
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
                      // Jel Enerjisi bakiyesi
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
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0, duration: 300.ms),
                const SizedBox(height: 24),
                // Bina kartlari
                Expanded(
                  child: _loaded
                      ? ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            for (final entry
                                in BuildingType.values.asMap().entries)
                              _BuildingCard(
                                type: entry.value,
                                building: kBuildings[entry.value]!,
                                level: _island.getBuildingLevel(entry.value),
                                canBuild: _island.canBuild(entry.value),
                                cost: _island.getUpgradeCost(entry.value),
                                canAfford: _resources.canAfford(
                                    _island.getUpgradeCost(entry.value)),
                                onUpgrade: () => _onUpgrade(entry.value),
                                delay: Duration(milliseconds: 80 * entry.key),
                              ),
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

// ─── Bina Karti ─────────────────────────────────────────────────────────────

class _BuildingCard extends StatefulWidget {
  const _BuildingCard({
    required this.type,
    required this.building,
    required this.level,
    required this.canBuild,
    required this.cost,
    required this.canAfford,
    required this.onUpgrade,
    required this.delay,
  });

  final BuildingType type;
  final Building building;
  final int level;
  final bool canBuild;
  final int cost;
  final bool canAfford;
  final VoidCallback onUpgrade;
  final Duration delay;

  @override
  State<_BuildingCard> createState() => _BuildingCardState();
}

class _BuildingCardState extends State<_BuildingCard> {
  bool _pressed = false;

  IconData get _buildingIcon => switch (widget.type) {
        BuildingType.gelFactory => Icons.factory_rounded,
        BuildingType.asmrTower => Icons.music_note_rounded,
        BuildingType.colorLab => Icons.science_rounded,
        BuildingType.arena => Icons.sports_mma_rounded,
        BuildingType.harbor => Icons.sailing_rounded,
      };

  Color get _buildingColor => switch (widget.type) {
        BuildingType.gelFactory => const Color(0xFF3CFF8B),
        BuildingType.asmrTower => const Color(0xFFB080FF),
        BuildingType.colorLab => const Color(0xFFFF8C42),
        BuildingType.arena => const Color(0xFFFF4D6D),
        BuildingType.harbor => const Color(0xFF00BFFF),
      };

  @override
  Widget build(BuildContext context) {
    final color = _buildingColor;
    final isMaxLevel = !widget.canBuild;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0.10),
              color.withValues(alpha: 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            // Bina ikonu
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Icon(_buildingIcon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            // Bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.building.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Seviye gostergesi
                      _LevelDots(
                        level: widget.level,
                        maxLevel: widget.building.maxLevel,
                        color: color,
                      ),
                    ],
                  ),
                  if (widget.building.description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.building.description!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Yukselt butonu
            if (!isMaxLevel)
              GestureDetector(
                onTap: widget.canAfford ? widget.onUpgrade : null,
                onTapDown: widget.canAfford
                    ? (_) => setState(() => _pressed = true)
                    : null,
                onTapUp: widget.canAfford
                    ? (_) => setState(() => _pressed = false)
                    : null,
                onTapCancel: widget.canAfford
                    ? () => setState(() => _pressed = false)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  transform: Matrix4.diagonal3Values(
                      _pressed ? 0.93 : 1.0, _pressed ? 0.93 : 1.0, 1.0),
                  transformAlignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.canAfford
                        ? color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                    border: Border.all(
                      color: widget.canAfford
                          ? color.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: widget.canAfford ? color : kMuted, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.cost}',
                        style: TextStyle(
                          color: widget.canAfford ? color : kMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border: Border.all(color: color.withValues(alpha: 0.20)),
                ),
                child: Text(
                  'MAKS',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.60),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: widget.delay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.08, end: 0, duration: 300.ms);
  }
}

// ─── Seviye noktalari ───────────────────────────────────────────────────────

class _LevelDots extends StatelessWidget {
  const _LevelDots({
    required this.level,
    required this.maxLevel,
    required this.color,
  });

  final int level;
  final int maxLevel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLevel, (i) {
        final filled = i < level;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : color.withValues(alpha: 0.15),
            border: Border.all(
              color: filled ? color : color.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Arkaplan ───────────────────────────────────────────────────────────────

class _IslandBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          left: -60,
          child: GlowOrb(size: 340, color: Color(0xFF3CFF8B), opacity: 0.07),
        ),
        const Positioned(
          bottom: -80,
          right: -40,
          child: GlowOrb(size: 260, color: Color(0xFF00BFFF), opacity: 0.06),
        ),
      ],
    );
  }
}
