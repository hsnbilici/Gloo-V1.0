import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/meta/resource_manager.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import 'island_widgets.dart';

class IslandScreen extends ConsumerStatefulWidget {
  const IslandScreen({super.key});

  @override
  ConsumerState<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends ConsumerState<IslandScreen> {
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
    _resources.setEnergy(await repo.getGelEnergy());
    _resources.setTotalEarned(repo.getTotalEarnedEnergy());
    _island.loadFromMap(repo.getIslandState());
    setState(() => _loaded = true);

    // Backend'den sync (local-first, backend override)
    final remote = ref.read(remoteRepositoryProvider);
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
      ref.read(remoteRepositoryProvider).saveMetaState(
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
          const IslandBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
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
                          color: kGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: kGreen.withValues(alpha: 0.5),
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
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0, duration: 300.ms),
                const SizedBox(height: 24),
                Expanded(
                  child: _loaded
                      ? ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            for (final entry
                                in BuildingType.values.asMap().entries)
                              BuildingCard(
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
                          child: CircularProgressIndicator(color: kGreen),
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
