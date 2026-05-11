import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_provider.dart';
import 'app_theme.dart';
import 'router.dart';

class DinkRivalsApp extends ConsumerStatefulWidget {
  const DinkRivalsApp({super.key});

  @override
  ConsumerState<DinkRivalsApp> createState() => _DinkRivalsAppState();
}

class _DinkRivalsAppState extends ConsumerState<DinkRivalsApp> {
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    _adTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(adPlacementSystemProvider).advance(const Duration(seconds: 1));
      ref.read(adPlacementTickProvider.notifier).state++;
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dink Rivals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
