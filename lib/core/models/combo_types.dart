enum ComboTier { none, small, medium, large, epic }

class ComboEvent {
  const ComboEvent({
    required this.size,
    required this.tier,
    required this.multiplier,
  });

  final int size;
  final ComboTier tier;
  final double multiplier;

  static const ComboEvent none = ComboEvent(
    size: 0,
    tier: ComboTier.none,
    multiplier: 1.0,
  );
}
