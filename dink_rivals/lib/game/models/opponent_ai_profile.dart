class OpponentAiProfile {
  const OpponentAiProfile({
    required this.id,
    required this.displayName,
    required this.maxSpeed,
    required this.whiffChance,
    required this.dinkProbability,
    required this.lobProbability,
    required this.smashProbability,
  });

  final String id;
  final String displayName;
  final double maxSpeed;
  final double whiffChance;
  final double dinkProbability;
  final double lobProbability;
  final double smashProbability;
}
