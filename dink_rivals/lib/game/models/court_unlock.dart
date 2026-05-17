class CourtUnlockIds {
  const CourtUnlockIds._();

  static const training = 'training_gray';
  static const park = 'park_court';
  static const defaultCourt = park;

  static const all = <String>[training, park];

  static bool isKnown(String id) => all.contains(id);
}

String normalizedCourtId(String? value) {
  if (value != null && CourtUnlockIds.isKnown(value)) {
    return value;
  }
  return CourtUnlockIds.defaultCourt;
}
