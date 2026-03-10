import 'dart:async' as async;

import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../demo_catalog.dart';
import 'support/support.dart';
import 'animated_mesh_background.dart';
import 'app_shared.dart';
import 'bottom_toolbar.dart';
import 'grid_demo.dart';
import 'hero_section.dart';
import 'how_it_works_dialog.dart';
import 'icon_preview_dialog.dart';
import 'top_bar.dart';

const String _howItWorksPairLabel = 'Power';

class DiagonalWipeIconFlutterApp extends StatefulWidget {
  const DiagonalWipeIconFlutterApp({super.key});

  @override
  State<DiagonalWipeIconFlutterApp> createState() =>
      _DiagonalWipeIconFlutterAppState();
}

class _DiagonalWipeIconFlutterAppState extends State<DiagonalWipeIconFlutterApp>
    with TickerProviderStateMixin {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  bool _isLooping = false;
  bool _isLoopWiped = false;
  bool _isDark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
  double _globalAnimationMultiplier = 1.0;
  int _selectedSeedIndex = 3;
  bool _showHowItWorks = false;
  WipeDirection _howItWorksDirection = WipeDirection.topLeftToBottomRight;
  MaterialWipeIconPair? _heroSelectedIcon;
  double _scrollProgress = 0;
  int _loopToken = 0;
  final ScrollController _catalogScrollController = ScrollController();
  async.Timer? _toolbarDelay;
  late final AnimationController _toolbarIntroController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void initState() {
    super.initState();
    _toolbarDelay = async.Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (_toolbarIntroController.status == AnimationStatus.dismissed) {
        _toolbarIntroController.forward();
      }
    });
  }

  @override
  void dispose() {
    _loopToken++;
    _toolbarDelay?.cancel();
    _toolbarIntroController.dispose();
    _catalogScrollController.dispose();
    super.dispose();
  }

  void _startLoop() {
    _loopToken++;
    final token = _loopToken;

    if (!_isLooping) {
      setState(() => _isLoopWiped = false);
      return;
    }

    _runLoop(token);
  }

  Future<void> _runLoop(int token) async {
    while (mounted && _isLooping && token == _loopToken) {
      setState(() => _isLoopWiped = true);
      final enableDelay = autoPlayDelay(
        wipeInDurationMillis,
        _globalAnimationMultiplier,
      );
      await Future<void>.delayed(Duration(milliseconds: enableDelay));
      if (!mounted || token != _loopToken || !_isLooping) break;

      setState(() => _isLoopWiped = false);
      final disableDelay = autoPlayDelay(
        wipeOutDurationMillis,
        _globalAnimationMultiplier,
      );
      await Future<void>.delayed(Duration(milliseconds: disableDelay));
      if (!mounted || token != _loopToken || !_isLooping) break;
    }

    if (mounted && token == _loopToken) {
      setState(() => _isLoopWiped = false);
    }
  }

  void _toggleLoop(bool value) {
    setState(() => _isLooping = value);
    _startLoop();
  }

  void _toggleSlowMode() {
    setState(() {
      _globalAnimationMultiplier =
          _globalAnimationMultiplier == 1.0 ? slowAnimationMultiplier : 1.0;
    });
    if (_isLooping) _startLoop();
  }

  void _selectSeed(int index) {
    if (index == _selectedSeedIndex) return;
    setState(() => _selectedSeedIndex = index);
  }

  void _openHowItWorksDialog() {
    if (_showHowItWorks) return;
    final navContext = _rootNavigatorKey.currentContext;
    if (_showHowItWorks || !mounted || navContext == null) return;

    final pair = materialSymbolPairByLabel(_howItWorksPairLabel) ??
        coreMaterialWipeIconCatalog.first;

    setState(() => _showHowItWorks = true);
    showDialog<void>(
      context: navContext,
      useRootNavigator: true,
      builder: (_) => HowItWorksDialog(
        onDirectionChanged: (value) {
          if (mounted) {
            setState(() => _howItWorksDirection = value);
          }
        },
        initialDirection: _howItWorksDirection,
        pair: pair,
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _showHowItWorks = false);
      }
    });
  }

  void _openIconPreviewDialog(MaterialWipeIconPair pair) {
    final navContext = _rootNavigatorKey.currentContext;
    if (!mounted || navContext == null) return;

    showDialog<void>(
      context: navContext,
      useRootNavigator: true,
      builder: (_) => IconPreviewDialog(
        iconPair: pair,
        baseAnimationMultiplier: _globalAnimationMultiplier,
      ),
    );
  }

  Future<void> _openUrl(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSeed = themeSeedOptions[_selectedSeedIndex];
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: selectedSeed.color,
        brightness: _isDark ? Brightness.dark : Brightness.light,
        dynamicSchemeVariant: selectedSeed.style == ThemeSeedStyle.expressive
            ? DynamicSchemeVariant.expressive
            : DynamicSchemeVariant.neutral,
      ),
    );

    return MaterialApp(
      navigatorKey: _rootNavigatorKey,
      title: 'Diagonal Wipe Icon',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeAnimationDuration: const Duration(milliseconds: 450),
      themeAnimationCurve: Curves.easeInOutCubic,
      home: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedMeshBackground(
            seedColor: selectedSeed.color,
            isDark: _isDark,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AnimatedTopBar(
              scrollTitleAlpha: _scrollProgress,
              isDark: _isDark,
              onToggleDark: () => setState(() => _isDark = !_isDark),
              onOpenX: () => _openUrl('https://x.com/bernaferrari'),
              onOpenGitHub: () => _openUrl(
                'https://github.com/bernaferrari/diagonal-wipe-icon-flutter',
              ),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                _ScaffoldContent(
                  onHeroIconTap: (pair) =>
                      setState(() => _heroSelectedIcon = pair),
                  animationMultiplier: _globalAnimationMultiplier,
                  allIconsWiped: _isLoopWiped,
                  isLooping: _isLooping,
                  onScrollProgressChanged: (value) =>
                      setState(() => _scrollProgress = value),
                  heroSelectedIcon: _heroSelectedIcon,
                  onHeroSelectedIconConsumed: () =>
                      setState(() => _heroSelectedIcon = null),
                  onIconTap: (pair) => _openIconPreviewDialog(pair),
                  scrollController: _catalogScrollController,
                  scrollTitleAlpha: _scrollProgress,
                  selectedSeed: selectedSeed,
                  onOpenHowItWorks: _openHowItWorksDialog,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: _toolbarIntroController,
                    builder: (context, _) {
                      final interactive = _toolbarIntroController.value > 0.001;
                      return IgnorePointer(
                        ignoring: !interactive,
                        child: SafeArea(
                          minimum: const EdgeInsets.only(bottom: 16),
                          child: FadeTransition(
                            opacity: _toolbarIntroController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(_toolbarIntroController),
                              child: Center(
                                child: BottomToolbar(
                                  themeSeedOptions: themeSeedOptions,
                                  selectedSeedIndex: _selectedSeedIndex,
                                  onSeedSelected: _selectSeed,
                                  isSlowMode: _globalAnimationMultiplier > 1,
                                  onToggleSlowMode: _toggleSlowMode,
                                  isLooping: _isLooping,
                                  onToggleLoop: _toggleLoop,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaffoldContent extends StatefulWidget {
  const _ScaffoldContent({
    required this.onHeroIconTap,
    required this.animationMultiplier,
    required this.allIconsWiped,
    required this.isLooping,
    required this.onScrollProgressChanged,
    required this.heroSelectedIcon,
    required this.onHeroSelectedIconConsumed,
    required this.scrollController,
    required this.onIconTap,
    required this.scrollTitleAlpha,
    required this.selectedSeed,
    required this.onOpenHowItWorks,
  });

  final ValueChanged<MaterialWipeIconPair> onHeroIconTap;
  final double animationMultiplier;
  final bool allIconsWiped;
  final bool isLooping;
  final ValueChanged<double> onScrollProgressChanged;
  final MaterialWipeIconPair? heroSelectedIcon;
  final VoidCallback onHeroSelectedIconConsumed;
  final ScrollController scrollController;
  final IconTapCallback onIconTap;
  final double scrollTitleAlpha;
  final ThemeSeed selectedSeed;
  final VoidCallback onOpenHowItWorks;

  @override
  State<_ScaffoldContent> createState() => _ScaffoldContentState();
}

class _ScaffoldContentState extends State<_ScaffoldContent> {
  double _lastScrollProgress = 0;
  double? _lastScrollOffset;

  @override
  void initState() {
    super.initState();
    _lastScrollProgress = widget.scrollTitleAlpha;
  }

  @override
  void didUpdateWidget(covariant _ScaffoldContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollTitleAlpha != widget.scrollTitleAlpha) {
      _lastScrollProgress = widget.scrollTitleAlpha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis != Axis.vertical) return false;
        final quantized =
            (notification.metrics.pixels / uiScrollProgressOffsetPx)
                .clamp(0.0, 1.0)
                .toDouble();
        final clamped =
            (quantized * uiScrollProgressQuantizationSteps).floor() /
                uiScrollProgressQuantizationSteps;

        final currentOffset = notification.metrics.pixels;
        if (_lastScrollOffset == currentOffset) return false;
        _lastScrollOffset = currentOffset;
        if (clamped == _lastScrollProgress) return false;

        _lastScrollProgress = clamped;
        widget.onScrollProgressChanged(clamped);
        return false;
      },
      child: DiagonalWipeIconGridDemo(
        scrollController: widget.scrollController,
        onScrollProgressChanged: widget.onScrollProgressChanged,
        animationMultiplier: widget.animationMultiplier,
        allIconsWiped: widget.allIconsWiped,
        isLooping: widget.isLooping,
        accentColor: widget.selectedSeed.color,
        onIconTap: widget.onIconTap,
        gridHeader: HeroSection(
          onOpenHowItWorks: widget.onOpenHowItWorks,
          onIconTap: widget.onHeroIconTap,
          accentColor: widget.selectedSeed.color,
        ),
        heroSelectedIcon: widget.heroSelectedIcon,
        onHeroSelectedIconConsumed: widget.onHeroSelectedIconConsumed,
      ),
    );
  }
}
