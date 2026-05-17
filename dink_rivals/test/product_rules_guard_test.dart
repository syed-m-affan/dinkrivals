import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app source does not introduce forbidden monetization mechanics', () {
    final files = [
      ..._dartFilesUnder('lib'),
      File('pubspec.yaml'),
      ..._appConfigFilesUnder('android/app'),
    ].where((file) => file.existsSync()).toList();

    final patterns = <String, RegExp>{
      'energy timer/gate': RegExp(r'\benergy\b', caseSensitive: false),
      'stamina timer/gate': RegExp(r'\bstamina\b', caseSensitive: false),
      'premium gems': RegExp(r'\bgems?\b', caseSensitive: false),
      'gacha': RegExp(r'\bgacha\b', caseSensitive: false),
      'loot box': RegExp(r'\bloot[\s_-]?box(?:es)?\b', caseSensitive: false),
      'pay-to-win': RegExp(
        r'\bpay[\s_-]?to[\s_-]?win\b',
        caseSensitive: false,
      ),
      'premium currency': RegExp(
        r'\bpremium[\s_-]?currenc(?:y|ies)\b',
        caseSensitive: false,
      ),
      'hearts play gate': RegExp(r'\bhearts?\b', caseSensitive: false),
    };

    final violations = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex += 1) {
        final line = lines[lineIndex];
        for (final entry in patterns.entries) {
          if (entry.value.hasMatch(line)) {
            violations.add(
              '${file.path}:${lineIndex + 1} matched ${entry.key}: $line',
            );
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Build spec forbids energy, gems, gacha, loot boxes, and '
          'pay-to-win mechanics. Legitimate false positives should use a '
          'narrower test pattern, not a broad allowlist.',
    );
  });
}

Iterable<File> _dartFilesUnder(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

Iterable<File> _appConfigFilesUnder(String path) {
  const suffixes = ['.gradle', '.kts', '.xml'];
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => suffixes.any(file.path.endsWith));
}
