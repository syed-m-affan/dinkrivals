import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/app_config.dart';
import '../app/game_provider.dart';
import '../app/router.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _Logo(),
                const SizedBox(height: 12),
                const Text(
                  AppConfig.phaseLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8A93AB),
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  key: const Key('menu-quick-match'),
                  onPressed: () {
                    ref.read(dinkRivalsGameProvider).resetMatch();
                    context.go(AppRoutes.game);
                  },
                  child: const Text('QUICK MATCH'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('menu-roster'),
                  onPressed: () => context.go(AppRoutes.roster),
                  child: const Text('ROSTER'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('menu-settings'),
                  onPressed: () => context.go(AppRoutes.settings),
                  child: const Text('SETTINGS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFF4AA3FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
          ),
          alignment: Alignment.center,
          child: const Text(
            'DR',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'DINK RIVALS',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
