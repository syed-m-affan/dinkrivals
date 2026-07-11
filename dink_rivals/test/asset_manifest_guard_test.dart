import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _approvedSpritePngs = {
  'ball.png',
  'opponent_dink.png',
  'opponent_drive.png',
  'opponent_hit_confirm.png',
  'opponent_idle.png',
  'opponent_lob.png',
  'opponent_ready.png',
  'opponent_run.png',
  'opponent_smash.png',
  'opponent_swing.png',
  'paddle_opponent.png',
  'paddle_player.png',
  'player_dink.png',
  'player_drive.png',
  'player_hit_confirm.png',
  'player_idle.png',
  'player_lob.png',
  'player_ready.png',
  'player_run.png',
  'player_smash.png',
  'player_swing.png',
};

void main() {
  test('pubspec asset declarations exist and cover the asset tree', () {
    final declaredAssets = _declaredFlutterAssets();
    final violations = <String>[];

    for (final assetPath in declaredAssets) {
      final type = FileSystemEntity.typeSync(assetPath);
      switch (type) {
        case FileSystemEntityType.directory:
          final files = Directory(assetPath).listSync(recursive: true);
          if (files.whereType<File>().isEmpty) {
            violations.add('$assetPath is declared but contains no files');
          }
          break;
        case FileSystemEntityType.file:
          break;
        case FileSystemEntityType.notFound:
          violations.add('$assetPath is declared but does not exist');
        default:
          violations.add('$assetPath is declared but is not a file/directory');
      }
    }

    final uncoveredFiles = Directory('assets')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => _normalizePath(file.path))
        .where(
          (assetPath) => !declaredAssets
              .any((declared) => _coversAsset(declared, assetPath)),
        )
        .toList()
      ..sort();

    for (final file in uncoveredFiles) {
      violations.add('$file exists under assets/ but is not declared');
    }

    expect(
      violations,
      isEmpty,
      reason: 'Every shipped asset should be declared in pubspec.yaml, and '
          'declared asset directories should point at real checked-in files.',
    );
  });

  test('sprite PNG set matches the approved runtime sheet package', () {
    final spritePngs = Directory('assets/images/sprites')
        .listSync()
        .whereType<File>()
        .map((file) => _fileName(file.path))
        .where((name) => name.endsWith('.png'))
        .toSet();

    expect(
      spritePngs,
      _approvedSpritePngs,
      reason:
          'Runtime sprite PNG changes need an intentional art-review update '
          'instead of accidental asset churn.',
    );
  });

  test('every character has complete north and south runtime packs', () {
    const frameCounts = <String, int>{
      'idle': 2,
      'ready': 6,
      'run': 12,
      'dink': 6,
      'drive': 6,
      'lob': 6,
      'smash': 6,
      'hit_confirm': 4,
    };
    for (final character in const [
      'rookie',
      'rally_queen',
      'veteran',
      'showman',
    ]) {
      for (final direction in const ['north', 'south']) {
        for (final entry in frameCounts.entries) {
          final file = File(
            'assets/images/sprites/characters/$character/$direction/'
            '${entry.key}.png',
          );
          expect(file.existsSync(), isTrue, reason: file.path);
          final bytes = file.readAsBytesSync();
          expect(bytes.length, greaterThan(24), reason: file.path);
          expect(_pngDimension(bytes, 16), entry.value * 64,
              reason: '${file.path} width');
          expect(_pngDimension(bytes, 20), 64, reason: '${file.path} height');
        }
      }
    }
  });
}

int _pngDimension(List<int> bytes, int offset) {
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}

List<String> _declaredFlutterAssets() {
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  final flutter = pubspec['flutter'] as YamlMap;
  final assets = flutter['assets'] as YamlList;
  return assets.map((asset) => _normalizePath(asset.toString())).toList();
}

bool _coversAsset(String declaredAsset, String assetPath) {
  if (declaredAsset.endsWith('/')) {
    return assetPath.startsWith(declaredAsset);
  }
  return assetPath == declaredAsset;
}

String _fileName(String path) {
  final normalized = _normalizePath(path);
  final slashIndex = normalized.lastIndexOf('/');
  return slashIndex == -1 ? normalized : normalized.substring(slashIndex + 1);
}

String _normalizePath(String path) => path.replaceAll(r'\', '/');
