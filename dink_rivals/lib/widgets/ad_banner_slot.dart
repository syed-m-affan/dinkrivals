import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app/ad_provider.dart';
import '../app/app_config.dart';
import '../game/config/visual_palette.dart';
import '../services/admob_ad_service.dart';
import '../services/save_service.dart';

class AdBannerSlot extends ConsumerWidget {
  const AdBannerSlot({
    required this.placement,
    super.key,
  });

  final String placement;

  static const double height = 58;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final save = ref.watch(saveDataProvider);
    if ((!AppConfig.useAdMob && !AppConfig.showAdPlaceholders) ||
        save.matchesCompleted == 0) {
      return const SizedBox.shrink();
    }
    final adService = ref.watch(adServiceProvider);
    if (adService.adsRemoved) {
      return const SizedBox.shrink();
    }

    final fallback = AppConfig.showAdPlaceholders
        ? _FakeBannerSlot(placement: placement)
        : const SizedBox.shrink();
    if (AppConfig.useAdMob) {
      return _AdMobBannerSlot(
        placement: placement,
        fallback: fallback,
      );
    }
    return fallback;
  }
}

class _FakeBannerSlot extends StatelessWidget {
  const _FakeBannerSlot({required this.placement});

  final String placement;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: SizedBox(
              key: Key('fake-banner-$placement'),
              height: AdBannerSlot.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: VisualPalette.scoreboardSurface.withValues(
                    alpha: 0.92,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: VisualPalette.textMuted.withValues(alpha: 0.70),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AD',
                      style: TextStyle(
                        color: VisualPalette.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'TEST BANNER',
                      style: TextStyle(
                        color: VisualPalette.textSoft,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdMobBannerSlot extends StatefulWidget {
  const _AdMobBannerSlot({
    required this.placement,
    required this.fallback,
  });

  final String placement;
  final Widget fallback;

  @override
  State<_AdMobBannerSlot> createState() => _AdMobBannerSlotState();
}

class _AdMobBannerSlotState extends State<_AdMobBannerSlot> {
  BannerAd? _bannerAd;
  AdSize? _size;
  int? _requestedWidth;
  bool _loading = false;
  bool _failed = false;

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _load(int width) async {
    if (_loading || width <= 0) {
      return;
    }

    setState(() {
      _loading = true;
      _failed = false;
      _requestedWidth = width;
      _size = null;
      _bannerAd?.dispose();
      _bannerAd = null;
    });

    BannerAd? loadingAd;
    try {
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
      if (!mounted) {
        return;
      }
      if (size == null) {
        setState(() {
          _failed = true;
          _loading = false;
        });
        return;
      }

      final ad = BannerAd(
        size: size,
        adUnitId: AdMobAdService.androidTestBannerAdUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() {
              _bannerAd = ad as BannerAd;
              _size = size;
              _loading = false;
            });
          },
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            if (!mounted) {
              return;
            }
            setState(() {
              _failed = true;
              _loading = false;
            });
          },
        ),
        request: const AdRequest(),
      );
      loadingAd = ad;
      await ad.load();
    } catch (_) {
      loadingAd?.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.fallback;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth - 32
            : screenWidth - 32;
        final width = availableWidth.clamp(1.0, 360.0).floor();
        if (_requestedWidth != width && !_loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              unawaited(_load(width));
            }
          });
        }

        final bannerAd = _bannerAd;
        final size = _size;
        if (bannerAd == null || size == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Center(
              child: SizedBox(
                key: Key('admob-banner-${widget.placement}'),
                width: size.width.toDouble(),
                height: size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              ),
            ),
          ),
        );
      },
    );
  }
}
