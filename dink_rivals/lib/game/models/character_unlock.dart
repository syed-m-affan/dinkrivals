class CharacterUnlockIds {
  const CharacterUnlockIds._();

  static const rookie = 'rookie';
  static const rallyQueen = 'rally_queen';
  static const veteran = 'veteran';
  static const showman = 'showman';

  static const all = <String>[
    rookie,
    rallyQueen,
    veteran,
    showman,
  ];

  static const defaultUnlocked = <String>[
    rookie,
    rallyQueen,
  ];

  static bool isKnown(String id) => all.contains(id);
}

List<String> normalizedCharacterUnlocks(List<String>? ids) {
  final selected = <String>{
    ...CharacterUnlockIds.defaultUnlocked,
    for (final id in ids ?? const <String>[])
      if (CharacterUnlockIds.isKnown(id)) id,
  };
  return [
    for (final id in CharacterUnlockIds.all)
      if (selected.contains(id)) id,
  ];
}
