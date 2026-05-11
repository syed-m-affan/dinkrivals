import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';

class _CharacterDef {
  const _CharacterDef({
    required this.name,
    required this.role,
    required this.strength,
    required this.weakness,
  });

  final String name;
  final String role;
  final String strength;
  final String weakness;
}

const _mvpRoster = <_CharacterDef>[
  _CharacterDef(
    name: 'Rookie',
    role: 'Default balanced player',
    strength: 'Easy control',
    weakness: 'No specialty',
  ),
  _CharacterDef(
    name: 'Rally Queen',
    role: 'Dink / control specialist',
    strength: 'Soft game',
    weakness: 'Lower power',
  ),
  _CharacterDef(
    name: 'Veteran',
    role: 'Defensive placement',
    strength: 'Consistency',
    weakness: 'Slower speed',
  ),
  _CharacterDef(
    name: 'Showman',
    role: 'Aggressive flashy player',
    strength: 'Power / specials',
    weakness: 'Less consistent',
  ),
];

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROSTER'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.menu),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _mvpRoster.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final char = _mvpRoster[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    char.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4AA3FF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    char.role,
                    style: const TextStyle(
                      color: Color(0xFFC0C8DC),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Strength: ${char.strength}'),
                  Text('Weakness: ${char.weakness}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
