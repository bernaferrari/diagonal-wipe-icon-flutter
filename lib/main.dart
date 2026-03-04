import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import 'curve_safety.dart';
import 'diagonal_wipe_icon.dart';
import 'demo_catalog.dart';
import 'src/material_symbol_name.dart';
import 'src/symbol_icon_helpers.dart';
import 'src/ui_constants.dart';

extension _MaterialColorSchemeCompat on ColorScheme {
  Color get appOnBackground => onSurface;
  Color get appSurface => surface;
  Color get appSurfaceVariant => surfaceContainerHighest;
}

const _howItWorksDirectionOptions = [
  (
    direction: WipeDirection.topLeftToBottomRight,
    label: 'Top-left to bottom-right',
  ),
  (
    direction: WipeDirection.topRightToBottomLeft,
    label: 'Top-right to bottom-left',
  ),
  (
    direction: WipeDirection.bottomLeftToTopRight,
    label: 'Bottom-left to top-right',
  ),
  (
    direction: WipeDirection.bottomRightToTopLeft,
    label: 'Bottom-right to top-left',
  ),
  (direction: WipeDirection.topToBottom, label: 'Top to bottom'),
  (direction: WipeDirection.bottomToTop, label: 'Bottom to top'),
  (direction: WipeDirection.leftToRight, label: 'Left to right'),
  (direction: WipeDirection.rightToLeft, label: 'Right to left'),
];

const String _howItWorksPairLabel = 'Power';

final _howItWorksDirectionLabels = {
  for (final option in _howItWorksDirectionOptions)
    option.direction: option.label,
};

typedef IconTapCallback = void Function(MaterialWipeIconPair pair);

Future<void> _animateScaleWithSpring(
  AnimationController controller,
  double target, {
  double stiffness = 200,
  double dampingRatio = 0.5,
}) {
  final clampedTarget =
      target.clamp(controller.lowerBound, controller.upperBound);
  if (clampedTarget == controller.value) {
    return Future.value();
  }

  controller.stop();
  final spring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: stiffness,
    ratio: dampingRatio,
  );
  return controller.animateWith(
    SpringSimulation(
      spring,
      controller.value,
      clampedTarget,
      controller.velocity,
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DiagonalWipeIconFlutterApp());
}

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

  bool _showIntro = false;
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
  async.Timer? _introDelay;
  async.Timer? _toolbarDelay;
  late final AnimationController _toolbarIntroController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void initState() {
    super.initState();
    _introDelay = async.Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _showIntro = true);
      _toolbarDelay = async.Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (_toolbarIntroController.status == AnimationStatus.dismissed) {
          _toolbarIntroController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _loopToken++;
    _introDelay?.cancel();
    _toolbarDelay?.cancel();
    _toolbarIntroController.dispose();
    _catalogScrollController.dispose();
    super.dispose();
  }

  void _startLoop() {
    _loopToken++;
    final int token = _loopToken;

    if (!_isLooping) {
      setState(() => _isLoopWiped = false);
      return;
    }

    _runLoop(token);
  }

  Future<void> _runLoop(int token) async {
    while (mounted && _isLooping && token == _loopToken) {
      setState(() => _isLoopWiped = true);
      final int enableDelay = autoPlayDelay(
        wipeInDurationMillis,
        _globalAnimationMultiplier,
      );
      await Future<void>.delayed(Duration(milliseconds: enableDelay));
      if (!mounted || token != _loopToken || !_isLooping) break;

      setState(() => _isLoopWiped = false);
      final int disableDelay = autoPlayDelay(
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
    setState(() {
      _isLooping = value;
    });

    if (!_isLooping) {
      _startLoop();
      return;
    }

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
    final BuildContext? navContext = _rootNavigatorKey.currentContext;
    if (_showHowItWorks || !mounted || navContext == null) return;

    final pair = materialSymbolPairByLabel(_howItWorksPairLabel) ??
        coreMaterialWipeIconCatalog.first;

    if (!mounted) return;

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
    final BuildContext? navContext = _rootNavigatorKey.currentContext;
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
      ),
    );

    return MaterialApp(
      navigatorKey: _rootNavigatorKey,
      title: 'Diagonal Wipe Icon',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeAnimationDuration: const Duration(milliseconds: 450),
      themeAnimationCurve: withSafeCurveEndpoints(Curves.easeInOutCubic),
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
                  'https://github.com/bernaferrari/diagonal-wipe-icon'),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                _ScaffoldContent(
                  introVisible: _showIntro,
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
                IgnorePointer(
                  ignoring: _toolbarIntroController.value <= 0.001,
                  child: Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedBuilder(
                      animation: _toolbarIntroController,
                      builder: (context, _) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizeTransition(
                            sizeFactor: _toolbarIntroController,
                            axis: Axis.vertical,
                            alignment: Alignment.bottomCenter,
                            child: FadeTransition(
                              opacity: _toolbarIntroController,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.5),
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
    required this.introVisible,
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

  final bool introVisible;
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

class _ScaffoldContentState extends State<_ScaffoldContent>
    with TickerProviderStateMixin {
  late final AnimationController _introController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  double _lastScrollProgress = 0;
  double? _lastScrollOffset;

  @override
  void initState() {
    super.initState();
    _lastScrollProgress = widget.scrollTitleAlpha;
    _introController.value = widget.introVisible ? 1 : 0;
  }

  @override
  void didUpdateWidget(covariant _ScaffoldContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollTitleAlpha != widget.scrollTitleAlpha) {
      _lastScrollProgress = widget.scrollTitleAlpha;
    }
    if (widget.introVisible && !oldWidget.introVisible) {
      _introController.forward();
    } else if (!widget.introVisible && oldWidget.introVisible) {
      _introController.reverse();
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroIntro = _introController.drive(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(
        CurveTween(
          curve: withSafeCurveEndpoints(
            const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        ),
      ),
    );
    final heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(heroIntro);

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
        gridHeader: widget.introVisible
            ? FadeTransition(
                opacity: heroIntro,
                child: SlideTransition(
                  position: heroSlide,
                  child: HeroSection(
                    onOpenHowItWorks: widget.onOpenHowItWorks,
                    onIconTap: widget.onHeroIconTap,
                    accentColor: widget.selectedSeed.color,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        heroSelectedIcon: widget.heroSelectedIcon,
        onHeroSelectedIconConsumed: widget.onHeroSelectedIconConsumed,
      ),
    );
  }
}

Path _buildAppTopBarXPath() {
  final path = Path();
  path.fillType = PathFillType.evenOdd;
  path.moveTo(18.901, 1.153);
  path.lineTo(22.581, 1.153);
  path.lineTo(14.541, 10.343);
  path.lineTo(24, 22.847);
  path.lineTo(16.594, 22.847);
  path.lineTo(10.794, 15.263);
  path.lineTo(4.154, 22.847);
  path.lineTo(0.47, 22.847);
  path.lineTo(9.07, 13.017);
  path.lineTo(0, 1.154);
  path.lineTo(7.594, 1.154);
  path.lineTo(12.837, 8.086);
  path.lineTo(18.9, 1.153);
  path.close();
  path.moveTo(17.611, 20.647);
  path.lineTo(19.65, 20.647);
  path.lineTo(6.486, 3.24);
  path.lineTo(4.298, 3.24);
  path.lineTo(17.611, 20.647);
  path.close();
  return path;
}

Path _buildAppTopBarGitHubPath() {
  final path = Path();
  path.moveTo(12, 0);
  path.cubicTo(5.374, 0, 0, 5.373, 0, 12);
  path.cubicTo(0, 17.302, 3.438, 21.8, 8.207, 23.387);
  path.cubicTo(8.806, 23.498, 9, 23.126, 9, 22.81);
  path.lineTo(9, 20.576);
  path.cubicTo(5.662, 21.302, 4.967, 19.16, 4.967, 19.16);
  path.cubicTo(4.421, 17.773, 3.634, 17.404, 3.634, 17.404);
  path.cubicTo(2.545, 16.659, 3.717, 16.675, 3.717, 16.675);
  path.cubicTo(4.922, 16.759, 5.556, 17.912, 5.556, 17.912);
  path.cubicTo(6.626, 19.746, 8.363, 19.216, 9.048, 18.909);
  path.cubicTo(9.155, 18.134, 9.466, 17.604, 9.81, 17.305);
  path.cubicTo(7.145, 17, 4.343, 15.971, 4.343, 11.374);
  path.cubicTo(4.343, 10.063, 4.812, 8.993, 5.579, 8.153);
  path.cubicTo(5.455, 7.85, 5.044, 6.629, 5.696, 4.977);
  path.cubicTo(5.696, 4.977, 6.704, 4.655, 8.997, 6.207);
  path.cubicTo(9.954, 5.941, 10.98, 5.808, 12, 5.803);
  path.cubicTo(13.02, 5.808, 14.047, 5.941, 15.006, 6.207);
  path.cubicTo(17.297, 4.655, 18.303, 4.977, 18.303, 4.977);
  path.cubicTo(18.956, 6.63, 18.545, 7.851, 18.421, 8.153);
  path.cubicTo(19.191, 8.993, 19.656, 10.063, 19.656, 11.374);
  path.cubicTo(19.656, 15.983, 16.849, 16.998, 14.177, 17.295);
  path.cubicTo(14.607, 17.667, 15, 18.397, 15, 19.517);
  path.lineTo(15, 22.81);
  path.cubicTo(15, 23.129, 15.192, 23.504, 15.801, 23.387);
  path.cubicTo(20.566, 21.797, 24, 17.3, 24, 12);
  path.cubicTo(24, 5.373, 18.627, 0, 12, 0);
  path.close();
  return path;
}

final Path _appTopBarXPath = _buildAppTopBarXPath();
final Path _appTopBarGitHubPath = _buildAppTopBarGitHubPath();

class _TopBarVectorIcon extends StatelessWidget {
  const _TopBarVectorIcon({
    required this.path,
    required this.color,
    this.size = 22,
  });

  final Path path;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TopBarVectorIconPainter(
          path: path,
          color: color,
        ),
      ),
    );
  }
}

class _TopBarVectorIconPainter extends CustomPainter {
  const _TopBarVectorIconPainter({
    required this.path,
    required this.color,
  });

  final Path path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = path.getBounds();
    if (bounds.isEmpty || bounds.width == 0 || bounds.height == 0) return;

    final double scale = math.min(
      size.width / bounds.width,
      size.height / bounds.height,
    );
    final double xOffset =
        (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final double yOffset =
        (size.height - bounds.height * scale) / 2 - bounds.top * scale;

    canvas.save();
    canvas.translate(xOffset, yOffset);
    canvas.scale(scale, scale);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TopBarVectorIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.path != path;
  }
}

class AnimatedTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AnimatedTopBar({
    required this.scrollTitleAlpha,
    required this.isDark,
    required this.onToggleDark,
    required this.onOpenX,
    required this.onOpenGitHub,
    super.key,
  });

  final double scrollTitleAlpha;
  final bool isDark;
  final VoidCallback onToggleDark;
  final VoidCallback onOpenX;
  final VoidCallback onOpenGitHub;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = colors.appOnBackground;
    return AppBar(
      title: Opacity(
        opacity: scrollTitleAlpha,
        child: Text(
          'Diagonal Wipe Icons',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      backgroundColor: colors.appSurface.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Open X',
                onPressed: onOpenX,
                constraints: const BoxConstraints(
                  minHeight: 40,
                  minWidth: 40,
                ),
                padding: EdgeInsets.zero,
                iconSize: 22,
                splashRadius: 18,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  splashFactory: NoSplash.splashFactory,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                ),
                icon: _TopBarVectorIcon(
                  path: _appTopBarXPath,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Open GitHub',
                onPressed: onOpenGitHub,
                constraints: const BoxConstraints(
                  minHeight: 40,
                  minWidth: 40,
                ),
                padding: EdgeInsets.zero,
                iconSize: 22,
                splashRadius: 18,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  splashFactory: NoSplash.splashFactory,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                ),
                icon: _TopBarVectorIcon(
                  path: _appTopBarGitHubPath,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip:
                    isDark ? 'Switch to light mode' : 'Switch to dark mode',
                onPressed: onToggleDark,
                constraints: const BoxConstraints(
                  minHeight: 40,
                  minWidth: 40,
                ),
                padding: EdgeInsets.zero,
                iconSize: 22,
                splashRadius: 18,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  splashFactory: NoSplash.splashFactory,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                ),
                icon: Icon(
                  isDark ? Symbols.light_mode : Symbols.dark_mode,
                  size: 22,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HeroSection extends StatefulWidget {
  const HeroSection({
    required this.onOpenHowItWorks,
    required this.onIconTap,
    required this.accentColor,
    super.key,
  });

  final VoidCallback? onOpenHowItWorks;
  final ValueChanged<MaterialWipeIconPair> onIconTap;
  final Color accentColor;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HowItWorksButton extends StatelessWidget {
  const _HowItWorksButton({
    super.key,
    required this.onTap,
    required this.label,
  });

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  static final _heroPairs = [
    MaterialWipeIconPair.symbols(
      label: 'Visibility',
      enabledIcon: MaterialSymbolName.visibility,
      disabledIcon: MaterialSymbolName.visibilityOff,
    ),
    MaterialWipeIconPair.symbols(
      label: 'Wifi',
      enabledIcon: MaterialSymbolName.wifi,
      disabledIcon: MaterialSymbolName.wifiOff,
    ),
    MaterialWipeIconPair.symbols(
      label: 'Mic',
      enabledIcon: MaterialSymbolName.mic,
      disabledIcon: MaterialSymbolName.micOff,
    ),
    MaterialWipeIconPair.symbols(
      label: 'Warning',
      enabledIcon: MaterialSymbolName.warning,
      disabledIcon: MaterialSymbolName.warningOff,
    ),
    MaterialWipeIconPair.symbols(
      label: 'Alarm',
      enabledIcon: MaterialSymbolName.alarm,
      disabledIcon: MaterialSymbolName.alarmOff,
    ),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: _AnimatedHeroOrbs(accentColor: widget.accentColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'Diagonal Wipe Icons',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elegant morphing transitions for Material Design',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 110,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => HeroIconShowcase(
                        pairs: _heroPairs,
                        cycleProgress: _controller.value,
                        onIconTap: widget.onIconTap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _HowItWorksButton(
                    key: const ValueKey('how-it-works-button'),
                    onTap: widget.onOpenHowItWorks,
                    label: 'How it works',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedHeroOrbs extends StatefulWidget {
  const _AnimatedHeroOrbs({required this.accentColor});

  final Color accentColor;

  @override
  State<_AnimatedHeroOrbs> createState() => _AnimatedHeroOrbsState();
}

class _AnimatedHeroOrbsState extends State<_AnimatedHeroOrbs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 25000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _HeroOrbsPainter(
            accentColor: widget.accentColor,
            orbitPhase: _controller.value * math.pi * 2,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _HeroOrbsPainter extends CustomPainter {
  const _HeroOrbsPainter({
    required this.accentColor,
    required this.orbitPhase,
  });

  final Color accentColor;
  final double orbitPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2 + math.cos(orbitPhase) * 120,
            size.height / 2 + math.sin(orbitPhase) * 80,
          ),
          radius: 250,
        ),
      );
    canvas.drawCircle(
      Offset(
        size.width / 2 + math.cos(orbitPhase) * 120,
        size.height / 2 + math.sin(orbitPhase) * 80,
      ),
      250,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroOrbsPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor ||
      oldDelegate.orbitPhase != orbitPhase;
}

class HeroIconShowcase extends StatelessWidget {
  const HeroIconShowcase({
    required this.pairs,
    required this.cycleProgress,
    required this.onIconTap,
    super.key,
  });

  final List<MaterialWipeIconPair> pairs;
  final double cycleProgress;
  final ValueChanged<MaterialWipeIconPair> onIconTap;

  @override
  Widget build(BuildContext context) {
    const double phaseStepMs = 200.0;
    const double wipeToggleMs = 1200.0;
    const double cycleMs = 2400.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxVisibleIcons = ((constraints.maxWidth + heroIconSpacing) /
                (heroIconSize + heroIconSpacing))
            .toInt()
            .clamp(1, pairs.length);
        final startIndex = ((pairs.length - maxVisibleIcons) / 2)
            .floor()
            .clamp(0, pairs.length - maxVisibleIcons);
        final visiblePairs =
            pairs.sublist(startIndex, startIndex + maxVisibleIcons);
        final clock = cycleProgress * cycleMs;

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var visibleIndex = 0;
                visibleIndex < visiblePairs.length;
                visibleIndex++)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: heroIconSpacing / 2),
                child: HeroIconButton(
                  iconPair: visiblePairs[visibleIndex],
                  isWiped: () {
                    final index = startIndex + visibleIndex;
                    final localClock =
                        (cycleMs + clock - index * phaseStepMs) % cycleMs;
                    return localClock < wipeToggleMs;
                  }(),
                  onTap: () => onIconTap(visiblePairs[visibleIndex]),
                  size: heroIconSize,
                ),
              ),
          ],
        );
      },
    );
  }
}

class HeroIconButton extends StatefulWidget {
  const HeroIconButton({
    required this.iconPair,
    required this.isWiped,
    required this.onTap,
    required this.size,
    super.key,
  });

  final MaterialWipeIconPair iconPair;
  final bool isWiped;
  final VoidCallback onTap;
  final double size;

  @override
  State<HeroIconButton> createState() => _HeroIconButtonState();
}

class _HeroIconButtonState extends State<HeroIconButton>
    with TickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.9,
    upperBound: 1.1,
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    _animateScale();
  }

  @override
  void didUpdateWidget(covariant HeroIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWiped != widget.isWiped) {
      _animateScale();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get _targetScale {
    if (_pressed) return 0.95;
    if (_hovered) return 1.08;
    return widget.isWiped ? 1.03 : 1.0;
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animateScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _animateScale();
  }

  void _animateScale() {
    final target = _targetScale;
    _animateScaleWithSpring(
      _scaleController,
      target,
      stiffness: 200,
      dampingRatio: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final showBorder = _hovered;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              alignment: Alignment.center,
              scale: _scaleController.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: colors.appSurfaceVariant.withValues(alpha: 0.5),
              border: showBorder
                  ? Border.all(
                      color: colors.outline.withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: DiagonalWipeIcon.fromMotion(
              isWiped: widget.isWiped,
              baseIcon: materialSymbolIconBuilder(widget.iconPair.enabledIcon),
              wipedIcon:
                  materialSymbolIconBuilder(widget.iconPair.disabledIcon),
              baseTint: colors.primary,
              wipedTint: colors.secondary,
              size: widget.size * 0.49,
              motion: const DiagonalWipeMotion.gentle(),
            ),
          ),
        ),
      ),
    );
  }
}

class DiagonalWipeIconGridDemo extends StatefulWidget {
  const DiagonalWipeIconGridDemo({
    required this.onIconTap,
    required this.onScrollProgressChanged,
    required this.animationMultiplier,
    required this.allIconsWiped,
    required this.isLooping,
    required this.accentColor,
    required this.gridHeader,
    this.heroSelectedIcon,
    required this.onHeroSelectedIconConsumed,
    required this.scrollController,
    super.key,
  });

  final IconTapCallback onIconTap;
  final ValueChanged<double> onScrollProgressChanged;
  final double animationMultiplier;
  final bool allIconsWiped;
  final bool isLooping;
  final Color accentColor;
  final Widget gridHeader;
  final MaterialWipeIconPair? heroSelectedIcon;
  final VoidCallback onHeroSelectedIconConsumed;
  final ScrollController scrollController;

  @override
  State<DiagonalWipeIconGridDemo> createState() =>
      _DiagonalWipeIconGridDemoState();
}

class _DiagonalWipeIconGridDemoState extends State<DiagonalWipeIconGridDemo> {
  @override
  void didUpdateWidget(covariant DiagonalWipeIconGridDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heroSelectedIcon == null ||
        widget.heroSelectedIcon == oldWidget.heroSelectedIcon) {
      return;
    }

    final selectedPair = widget.heroSelectedIcon;
    if (selectedPair == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.mounted) return;
      widget.onIconTap(selectedPair);
      widget.onHeroSelectedIconConsumed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > uiGridMaxContentWidth
            ? ((constraints.maxWidth - uiGridMaxContentWidth) / 2) +
                uiPageHorizontalPadding
            : uiPageHorizontalPadding;
        final contentWidth = (constraints.maxWidth - (horizontalPadding * 2))
            .clamp(uiGridItemSlotWidth, double.infinity);
        final columns =
            (contentWidth / uiGridItemSlotWidth).toInt().clamp(1, 20);
        final itemBuilders = <Widget>[];
        itemBuilders.add(
          Align(
            alignment: Alignment.topCenter,
            child: widget.gridHeader,
          ),
        );

        for (var sectionIndex = 0;
            sectionIndex < iconSections.length;
            sectionIndex++) {
          final section = iconSections[sectionIndex];
          itemBuilders.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: MaterialWipeIconSectionHeader(
                section: section,
                topPadding: sectionIndex == 0 ? 0 : 16,
                bottomPadding: 16,
              ),
            ),
          );

          final rows = <List<MaterialWipeIconPair>>[];
          for (var i = 0; i < section.icons.length; i += columns) {
            final end = (i + columns).clamp(0, section.icons.length);
            rows.add(section.icons.sublist(i, end));
          }

          for (final row in rows) {
            itemBuilders.add(
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row
                      .map(
                        (pair) => DiagonalWipeIconGridItem(
                          iconPair: pair,
                          animationMultiplier: widget.animationMultiplier,
                          allIconsWiped: widget.allIconsWiped,
                          isLooping: widget.isLooping,
                          accentColor: widget.accentColor,
                          onOpen: () => widget.onIconTap(pair),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          }
          itemBuilders.add(const SizedBox(height: 20));
        }

        final separatedChildren = <Widget>[];
        for (var i = 0; i < itemBuilders.length; i++) {
          separatedChildren.add(itemBuilders[i]);
          if (i != itemBuilders.length - 1) {
            separatedChildren.add(const SizedBox(height: 12));
          }
        }

        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(top: 0, bottom: 48),
          itemCount: separatedChildren.length,
          itemBuilder: (context, index) => separatedChildren[index],
        );
      },
    );
  }
}

class MaterialWipeIconSectionHeader extends StatelessWidget {
  const MaterialWipeIconSectionHeader({
    required this.section,
    this.topPadding = 16,
    this.bottomPadding = 16,
    super.key,
  });

  final MaterialWipeIconSection section;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Text(
            section.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Text(
            section.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class DiagonalWipeIconGridItem extends StatefulWidget {
  const DiagonalWipeIconGridItem({
    required this.iconPair,
    required this.animationMultiplier,
    required this.allIconsWiped,
    required this.isLooping,
    required this.accentColor,
    required this.onOpen,
    super.key,
  });

  final MaterialWipeIconPair iconPair;
  final double animationMultiplier;
  final bool allIconsWiped;
  final bool isLooping;
  final Color accentColor;
  final VoidCallback onOpen;

  @override
  State<DiagonalWipeIconGridItem> createState() =>
      _DiagonalWipeIconGridItemState();
}

class _DiagonalWipeIconGridItemState extends State<DiagonalWipeIconGridItem>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.9,
    upperBound: 1.1,
    value: 1,
  );

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DiagonalWipeIconGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_targetScale != _scaleController.value) {
      _animateScale();
    }
  }

  double get _targetScale => _pressed ? 0.95 : 1;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animateScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _animateScale();
  }

  void _animateScale() {
    final double targetScale = _targetScale;
    _animateScaleWithSpring(
      _scaleController,
      targetScale,
      stiffness: 200,
      dampingRatio: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWiped = widget.isLooping ? widget.allIconsWiped : _hovered;
    final stiffness = widget.animationMultiplier > 1 ? 50.0 : 200.0;
    final motion = DiagonalWipeMotion.spring(
      wipeInStiffness: stiffness,
      wipeOutStiffness: stiffness,
      wipeInDampingRatio: 1,
      wipeOutDampingRatio: 1,
    );
    final Color borderColor = _pressed
        ? widget.accentColor
        : _hovered
            ? widget.accentColor.withValues(alpha: 0.5)
            : Colors.transparent;
    final Color textColor = _pressed
        ? widget.accentColor
        : _hovered
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurfaceVariant;
    final Color iconBgColor = _pressed
        ? widget.accentColor.withValues(alpha: 0.2)
        : _hovered
            ? widget.accentColor.withValues(alpha: 0.12)
            : Theme.of(context)
                .colorScheme
                .appSurfaceVariant
                .withValues(alpha: 0.5);

    return Semantics(
      button: true,
      label: widget.iconPair.label,
      child: SizedBox(
        width: uiGridItemSlotWidth,
        child: MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: GestureDetector(
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.onOpen,
            child: AnimatedBuilder(
              animation: _scaleController,
              builder: (_, child) => Transform.scale(
                alignment: Alignment.center,
                scale: _scaleController.value,
                child: child,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.ease,
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: iconBgColor,
                        border: Border.all(
                          color: borderColor,
                          width: (_hovered || _pressed) ? 1.5 : 0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: DiagonalWipeIcon.fromMotion(
                        isWiped: isWiped,
                        baseIcon: materialSymbolIconBuilder(
                          widget.iconPair.enabledIcon,
                        ),
                        wipedIcon: materialSymbolIconBuilder(
                          widget.iconPair.disabledIcon,
                        ),
                        baseTint: Theme.of(context).colorScheme.primary,
                        wipedTint: Theme.of(context).colorScheme.secondary,
                        size: 44,
                        motion: motion,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: uiGridItemSlotWidth,
                      child: Text(
                        widget.iconPair.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight:
                                  _hovered ? FontWeight.w600 : FontWeight.w500,
                            ),
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

class BottomToolbar extends StatelessWidget {
  const BottomToolbar({
    required this.themeSeedOptions,
    required this.selectedSeedIndex,
    required this.onSeedSelected,
    required this.isSlowMode,
    required this.onToggleSlowMode,
    required this.isLooping,
    required this.onToggleLoop,
    super.key,
  });

  final List<ThemeSeed> themeSeedOptions;
  final int selectedSeedIndex;
  final ValueChanged<int> onSeedSelected;
  final bool isSlowMode;
  final VoidCallback onToggleSlowMode;
  final bool isLooping;
  final ValueChanged<bool> onToggleLoop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSeedDivider = constraints.maxWidth >= 560;
        final toolbarTheme = Theme.of(context).colorScheme;
        final toolbarMaxWidth = (constraints.maxWidth - 32).clamp(0.0, 1180.0);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: toolbarMaxWidth,
            ),
            child: Material(
              color: toolbarTheme.surface,
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var index = 0;
                                index < themeSeedOptions.length;
                                index++)
                              Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: _ThemeColorSwatch(
                                  seed: themeSeedOptions[index],
                                  selected: selectedSeedIndex == index,
                                  onTap: () => onSeedSelected(index),
                                ),
                              ),
                            if (showSeedDivider) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 1,
                                height: 24,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: toolbarTheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: onToggleSlowMode,
                      style: TextButton.styleFrom(
                        foregroundColor: isSlowMode
                            ? toolbarTheme.primary
                            : toolbarTheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Symbols.speed, size: 17),
                          const SizedBox(width: 6),
                          Text(
                            isSlowMode ? '0.5x' : '1x',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: isSlowMode
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: () => onToggleLoop(!isLooping),
                      style: FilledButton.styleFrom(
                        backgroundColor: isLooping
                            ? toolbarTheme.primaryContainer
                            : toolbarTheme.secondaryContainer
                                .withValues(alpha: 0.78),
                        foregroundColor: isLooping
                            ? toolbarTheme.onPrimaryContainer
                            : toolbarTheme.onSecondaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLooping ? Symbols.stop : Symbols.play_arrow,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLooping ? 'Stop' : 'Loop',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: isLooping
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeColorSwatch extends StatefulWidget {
  const _ThemeColorSwatch({
    required this.seed,
    required this.selected,
    required this.onTap,
  });

  final ThemeSeed seed;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeColorSwatch> createState() => _ThemeColorSwatchState();
}

class _ThemeColorSwatchState extends State<_ThemeColorSwatch>
    with TickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _pressScaleController = AnimationController(
    vsync: this,
    lowerBound: 0.9,
    upperBound: 1.2,
    value: 1,
  );
  late final AnimationController _selectionController = AnimationController(
    vsync: this,
    lowerBound: 0,
    upperBound: 1,
    value: widget.selected ? 1 : 0,
  );

  @override
  void dispose() {
    _pressScaleController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ThemeColorSwatch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      _animateSelection();
    }
  }

  double get _pressScaleTarget => _pressed ? 0.93 : (_hovered ? 1.04 : 1);

  double get _selectionTarget => widget.selected ? 1 : 0;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animatePressScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _animatePressScale();
  }

  void _animatePressScale() {
    final double targetScale = _pressScaleTarget;
    _animateScaleWithSpring(
      _pressScaleController,
      targetScale,
      stiffness: 700,
      dampingRatio: 0.6,
    );
  }

  void _animateSelection() {
    final double target = _selectionTarget;
    _animateScaleWithSpring(
      _selectionController,
      target,
      stiffness: 520,
      dampingRatio: 0.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showSelected = widget.selected;
    final bool highContrastText = widget.seed.color.computeLuminance() > 0.5;
    final double selectionProgress = _selectionController.value.clamp(0.0, 1.0);
    final double cornerRadius = 9.5 + (9.5 * selectionProgress);
    final double glowDiameter = 54 * (0.94 + 0.06 * selectionProgress);
    final double orbScale = 0.84 + (0.16 * selectionProgress);
    final double orbSize = 27 + (5 * selectionProgress);
    final double rotation = 8 * selectionProgress;
    final double checkOpacity = selectionProgress;
    final double glowOpacity = selectionProgress;
    final Color checkColor = highContrastText ? Colors.black87 : Colors.white;
    final double borderWidth = showSelected ? 1.2 : 0;

    return Semantics(
      button: true,
      selected: showSelected,
      label: '${widget.seed.name} theme',
      onTapHint: showSelected
          ? 'Current theme selection'
          : 'Select ${widget.seed.name} theme',
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _pressScaleController,
            builder: (_, child) => Transform.scale(
              alignment: Alignment.center,
              scale: _pressScaleController.value,
              child: child,
            ),
            child: AnimatedBuilder(
              animation: _selectionController,
              builder: (_, child) => SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: glowOpacity,
                      child: Container(
                        width: glowDiameter,
                        height: glowDiameter,
                        decoration: BoxDecoration(
                          color: widget.seed.color.withValues(alpha: 0.38),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Transform.scale(
                      alignment: Alignment.center,
                      scaleX: orbScale,
                      scaleY: orbScale,
                      child: Transform.rotate(
                        angle: rotation * (math.pi / 180),
                        child: Container(
                          width: orbSize,
                          height: orbSize,
                          decoration: BoxDecoration(
                            color: widget.seed.color,
                            borderRadius: BorderRadius.circular(cornerRadius),
                            boxShadow: showSelected
                                ? [
                                    BoxShadow(
                                      color: widget.seed.color.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                            border: showSelected
                                ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: borderWidth,
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(cornerRadius),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x38FFFFFF),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Transform.rotate(
                                  angle: -rotation * (math.pi / 180),
                                  child: Opacity(
                                    opacity: checkOpacity,
                                    child: Icon(
                                      Symbols.check,
                                      size: 16,
                                      color: checkColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

class IconPreviewDialog extends StatefulWidget {
  const IconPreviewDialog({
    required this.iconPair,
    required this.baseAnimationMultiplier,
    super.key,
  });

  final MaterialWipeIconPair iconPair;
  final double baseAnimationMultiplier;

  @override
  State<IconPreviewDialog> createState() => _IconPreviewDialogState();
}

class _IconPreviewDialogState extends State<IconPreviewDialog> {
  bool _isWiped = false;
  bool _isPlaying = true;
  bool _previewSlowMode = false;
  bool _previewHovered = false;
  bool _pausedTapWiped = false;
  bool _hasHoveredWhilePaused = false;
  bool _isCopyFeedback = false;
  int _loopToken = 0;
  async.Timer? _loopDelayTimer;
  async.Timer? _copyResetTimer;

  @override
  void initState() {
    super.initState();
    _previewSlowMode = widget.baseAnimationMultiplier > 1.0;
    _startLoop();
  }

  @override
  void didUpdateWidget(covariant IconPreviewDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.baseAnimationMultiplier != oldWidget.baseAnimationMultiplier &&
        _isPlaying) {
      _startLoop();
    }
  }

  @override
  void dispose() {
    _copyResetTimer?.cancel();
    _loopDelayTimer?.cancel();
    _loopToken++;
    super.dispose();
  }

  void _startLoop() {
    _loopToken++;
    final int token = _loopToken;
    _loopDelayTimer?.cancel();
    _runLoop(token);
  }

  Future<void> _runLoop(int token) async {
    while (mounted && _isPlaying && token == _loopToken) {
      setState(() => _isWiped = true);
      final delay = autoPlayDelay(
        wipeInDurationMillis,
        _isSlow ? slowAnimationMultiplier : 1.0,
      );
      if (!await _awaitDelay(token, delay)) {
        return;
      }
      if (!mounted || token != _loopToken || !_isPlaying) break;

      setState(() => _isWiped = false);
      if (!await _awaitDelay(token, delay)) {
        return;
      }
      if (!mounted || token != _loopToken || !_isPlaying) break;
    }
  }

  Future<bool> _awaitDelay(int token, int delayMillis) {
    if (_loopDelayTimer != null && _loopDelayTimer!.isActive) {
      _loopDelayTimer!.cancel();
    }
    if (!mounted || token != _loopToken || !_isPlaying) {
      return Future.value(false);
    }

    final completer = async.Completer<void>();
    _loopDelayTimer = async.Timer(Duration(milliseconds: delayMillis), () {
      if (!mounted || token != _loopToken || !_isPlaying) {
        completer.complete();
        return;
      }
      completer.complete();
    });
    return completer.future
        .then((_) => mounted && token == _loopToken && _isPlaying);
  }

  bool get _isSlow => _previewSlowMode || widget.baseAnimationMultiplier > 1.0;

  bool get _previewIsWiped => _isPlaying
      ? _isWiped
      : _hasHoveredWhilePaused
          ? _previewHovered
          : _pausedTapWiped;

  void _setPreviewHovered(bool hovered) {
    if (_previewHovered == hovered) return;
    setState(() {
      _previewHovered = hovered;
      if (!_isPlaying && hovered) {
        _hasHoveredWhilePaused = true;
      }
    });
  }

  void _onPreviewTap() {
    if (_isPlaying) {
      _loopToken++;
      setState(() {
        _isPlaying = false;
        _isWiped = false;
        _pausedTapWiped = false;
        _hasHoveredWhilePaused = false;
      });
    } else {
      setState(() {
        _isWiped = false;
        _hasHoveredWhilePaused = false;
        _pausedTapWiped = !_pausedTapWiped;
      });
    }
  }

  void _togglePlaying() {
    if (_isPlaying) {
      _loopToken++;
      setState(() {
        _isPlaying = false;
        _isWiped = false;
        _pausedTapWiped = false;
        _hasHoveredWhilePaused = false;
      });
    } else {
      _loopToken++;
      setState(() {
        _isPlaying = true;
        _pausedTapWiped = false;
        _hasHoveredWhilePaused = false;
        _isWiped = false;
      });
      _startLoop();
    }
  }

  void _toggleSlowMode() {
    setState(() {
      _previewSlowMode = !_previewSlowMode;
    });
    if (_isPlaying) _startLoop();
  }

  Future<void> _copyCode(String snippet) async {
    await Clipboard.setData(ClipboardData(text: snippet));
    _copyResetTimer?.cancel();
    setState(() => _isCopyFeedback = true);
    _copyResetTimer = async.Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _isCopyFeedback = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final snippet = buildDiagonalWipeUsageSnippet(widget.iconPair);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, layoutConstraints) {
          final dialogWidth = (layoutConstraints.maxWidth.isFinite
                  ? layoutConstraints.maxWidth
                  : 760.0)
              .clamp(320.0, 840.0)
              .toDouble();
          final maxContentHeight = (layoutConstraints.maxHeight.isFinite
                  ? layoutConstraints.maxHeight
                  : 720.0)
              .clamp(260.0, 840.0)
              .toDouble();
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: maxContentHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: LayoutBuilder(
                        builder: (context, contentConstraints) {
                          final useWide = contentConstraints.maxWidth >= 780;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (useWide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _previewControls(context, snippet),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _codePane(context, snippet),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _previewControls(context, snippet),
                                    const SizedBox(height: 16),
                                    _codePane(context, snippet),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _previewControls(BuildContext context, String snippet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.iconPair.label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        MouseRegion(
          onEnter: (_) => _setPreviewHovered(true),
          onExit: (_) => _setPreviewHovered(false),
          child: GestureDetector(
            onTap: _onPreviewTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context)
                    .colorScheme
                    .appSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
              alignment: Alignment.center,
              child: DiagonalWipeIcon.fromMotion(
                isWiped: _previewIsWiped,
                baseIcon: materialSymbolIconBuilder(
                  widget.iconPair.enabledIcon,
                ),
                wipedIcon: materialSymbolIconBuilder(
                  widget.iconPair.disabledIcon,
                ),
                baseTint: Theme.of(context).colorScheme.primary,
                wipedTint: Theme.of(context).colorScheme.secondary,
                size: 120,
                motion: DiagonalWipeMotion.spring(
                  wipeInStiffness: _previewSlowMode ? 50 : 200,
                  wipeOutStiffness: _previewSlowMode ? 50 : 200,
                  wipeInDampingRatio: 1,
                  wipeOutDampingRatio: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PreviewDialogControl(
              label: _isPlaying ? 'Playing' : 'Paused',
              icon: _isPlaying ? Symbols.pause : Symbols.play_arrow,
              selected: _isPlaying,
              onPressed: _togglePlaying,
            ),
            const SizedBox(width: 12),
            _PreviewDialogControl(
              label: _previewSlowMode ? '0.5x' : '1x',
              icon: Symbols.speed,
              selected: _previewSlowMode,
              onPressed: _toggleSlowMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _codePane(BuildContext context, String snippet) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180, maxHeight: 320),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Code',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _copyCode(snippet),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _isCopyFeedback
                        ? Theme.of(context).colorScheme.surface
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _isCopyFeedback ? Symbols.check : Symbols.content_copy,
                    size: 20,
                    color: _isCopyFeedback
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SelectableText(
              snippet,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDialogControl extends StatefulWidget {
  const _PreviewDialogControl({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_PreviewDialogControl> createState() => _PreviewDialogControlState();
}

class _PreviewDialogControlState extends State<_PreviewDialogControl>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.9,
    upperBound: 1.1,
    value: 1,
  );

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get _scaleTarget => _pressed ? 0.95 : (_hovered ? 1 : 1);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animateScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _animateScale();
  }

  void _animateScale() {
    final double targetScale = _scaleTarget;
    _animateScaleWithSpring(
      _scaleController,
      targetScale,
      stiffness: 200,
      dampingRatio: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color background = widget.selected
        ? colors.primaryContainer
        : (_hovered ? colors.appSurfaceVariant : colors.surface);
    final Color textColor =
        widget.selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (_, child) => Transform.scale(
              alignment: Alignment.center,
              scale: _scaleController.value,
              child: child,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 20, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HowItWorksDialog extends StatefulWidget {
  const HowItWorksDialog({
    required this.onDirectionChanged,
    required this.initialDirection,
    required this.pair,
    super.key,
  });

  final ValueChanged<WipeDirection> onDirectionChanged;
  final WipeDirection initialDirection;
  final MaterialWipeIconPair pair;

  @override
  State<HowItWorksDialog> createState() => _HowItWorksDialogState();
}

class _HowItWorksDialogState extends State<HowItWorksDialog>
    with TickerProviderStateMixin {
  static const _flowFrameHeight = 100.0;
  static const _flowSquareSize = 64.0;

  late WipeDirection _direction = widget.initialDirection;
  int _loopToken = 0;
  late final AnimationController _progressController = AnimationController(
    vsync: this,
    value: 0,
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  @override
  void dispose() {
    _loopToken++;
    _progressController.dispose();
    super.dispose();
  }

  int _durationForIn() {
    return autoPlayDelay(wipeInDurationMillis, slowAnimationMultiplier);
  }

  int _durationForOut() {
    return autoPlayDelay(wipeOutDurationMillis, slowAnimationMultiplier);
  }

  void _startLoop() {
    _loopToken++;
    final int token = _loopToken;
    _runLoop(token);
  }

  Future<void> _animateToTarget(double targetValue) {
    return _animateScaleWithSpring(
      _progressController,
      targetValue,
      stiffness: slowAnimationMultiplier > 1 ? 50.0 : 200.0,
      dampingRatio: 1,
    );
  }

  Future<bool> _awaitDelay(int delayMillis, int token) {
    if (!mounted || token != _loopToken) return Future.value(false);
    return Future<void>.delayed(Duration(milliseconds: delayMillis))
        .then((_) => mounted && token == _loopToken);
  }

  Future<void> _runLoop(int token) async {
    while (mounted && token == _loopToken) {
      try {
        await _animateToTarget(1);
        if (!mounted || token != _loopToken) return;
        if (!await _awaitDelay(_durationForIn(), token)) return;

        await _animateToTarget(0);
        if (!mounted || token != _loopToken) return;
        if (!await _awaitDelay(_durationForOut(), token)) return;
      } on TickerCanceled {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowedColor = Theme.of(context).colorScheme.primary;
    final blockedColor = Theme.of(context).colorScheme.secondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDialogHeight =
            (constraints.maxHeight - 32).clamp(220.0, 980.0).toDouble();
        final maxDialogWidth =
            (constraints.maxWidth * 0.94).clamp(340.0, 840.0).toDouble();
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxDialogWidth,
              maxHeight: maxDialogHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          final progress =
                              _progressController.value.clamp(0.0, 1.0);
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How it works',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'SF Symbols has built-in symbol transitions. '
                                'Material Icons does not, so this gives you the same '
                                'kind of morph without hand-drawing a custom vector.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              _howItWorksDirectionSelector(
                                direction: _direction,
                                onDirectionChange: (value) {
                                  setState(() => _direction = value);
                                  widget.onDirectionChanged(value);
                                },
                              ),
                              const SizedBox(height: 20),
                              _howItWorksFlow(
                                allowedColor,
                                blockedColor,
                                progress,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Use two icons and one animated mask. It is much '
                                'easier and faster than building and maintaining '
                                'custom vector paths by hand.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _howItWorksFlow(
    Color allowedColor,
    Color blockedColor,
    double progress,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .appSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HowItWorksStep(
                    title: 'Base',
                    frameHeight: _flowFrameHeight,
                    child: _howItWorksSingleLayer(
                      baseIconName: widget.pair.enabledIcon,
                      wipedIconName: widget.pair.enabledIcon,
                      baseColor: allowedColor,
                      wipedColor: allowedColor,
                      entersOnReveal: false,
                      direction: _direction,
                      progress: progress,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '+',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Expanded(
                  child: _HowItWorksStep(
                    title: 'Overlay',
                    frameHeight: _flowFrameHeight,
                    child: _howItWorksSingleLayer(
                      baseIconName: widget.pair.disabledIcon,
                      wipedIconName: widget.pair.disabledIcon,
                      baseColor: blockedColor,
                      wipedColor: blockedColor,
                      entersOnReveal: true,
                      direction: _direction,
                      progress: progress,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '+',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Expanded(
                  child: _HowItWorksStep(
                    title: 'Mask',
                    frameHeight: _flowFrameHeight,
                    child: _howItWorksMaskLayer(
                      baseIconName: widget.pair.enabledIcon,
                      overlayIconName: widget.pair.disabledIcon,
                      baseColor: allowedColor,
                      overlayColor: blockedColor,
                      direction: _direction,
                      progress: progress,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '=',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HowItWorksStep(
            title: 'Result',
            frameHeight: _flowFrameHeight,
            child: _howItWorksSingleLayer(
              baseIconName: widget.pair.enabledIcon,
              wipedIconName: widget.pair.disabledIcon,
              baseColor: allowedColor,
              wipedColor: blockedColor,
              entersOnReveal: false,
              direction: _direction,
              progress: progress,
            ),
          ),
        ),
      ],
    );
  }

  Widget _howItWorksSingleLayer({
    required MaterialSymbolName baseIconName,
    required MaterialSymbolName wipedIconName,
    required Color baseColor,
    required Color wipedColor,
    required bool entersOnReveal,
    required WipeDirection direction,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: DiagonalWipeIconAtProgress(
        progress: progress,
        baseIcon: materialSymbolIconBuilder(baseIconName),
        wipedIcon: materialSymbolIconBuilder(wipedIconName),
        baseTint: entersOnReveal ? Colors.transparent : baseColor,
        wipedTint: entersOnReveal ? wipedColor : Colors.transparent,
        size: _flowSquareSize,
        direction: direction,
      ),
    );
  }

  Widget _howItWorksMaskLayer({
    required MaterialSymbolName baseIconName,
    required MaterialSymbolName overlayIconName,
    required Color baseColor,
    required Color overlayColor,
    required WipeDirection direction,
    required double progress,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final rotation = clampedProgress * 180;
    return SizedBox(
      width: _flowSquareSize,
      height: _flowSquareSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (rotation < 90) ...[
            _howItWorksRotatingIcon(
              iconName: baseIconName,
              color: baseColor,
              direction: direction,
              progress: clampedProgress,
              isBase: true,
            ),
          ] else ...[
            _howItWorksRotatingIcon(
              iconName: overlayIconName,
              color: overlayColor,
              direction: direction,
              progress: clampedProgress,
              isBase: false,
            ),
          ],
          if (clampedProgress >= 0.2 && clampedProgress <= 0.8)
            CustomPaint(
              painter: _HowItWorksBoundaryPainterWrapper(
                size: const Size(_flowSquareSize, _flowSquareSize),
                progress: clampedProgress,
                direction: direction,
                color: Theme.of(context)
                    .colorScheme
                    .tertiary
                    .withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _howItWorksRotatingIcon({
    required MaterialSymbolName iconName,
    required Color color,
    required WipeDirection direction,
    required double progress,
    required bool isBase,
  }) {
    final rotation = progress * 180;
    final bool isFirstHalf =
        isBase && rotation < 90 || (!isBase && rotation > 90);
    final double normalizedRotation = isBase ? rotation : rotation - 180;
    final double alpha = isBase ? 1 - (rotation / 90) : (rotation - 90) / 90;
    if (!isFirstHalf) return const SizedBox.shrink();

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateY(normalizedRotation * (math.pi / 180)),
      child: Opacity(
        opacity: alpha.clamp(0.0, 1.0),
        child: materialSymbolIcon(
          symbolName: iconName,
          size: _flowSquareSize,
          color: color,
        ),
      ),
    );
  }

  Widget _howItWorksDirectionSelector({
    required WipeDirection direction,
    required ValueChanged<WipeDirection> onDirectionChange,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.appSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _HowItWorksDirectionGrid(
            direction: direction,
            onDirectionChange: onDirectionChange,
          ),
          const SizedBox(height: 12),
          Text(
            _howItWorksDirectionLabels[direction] ?? 'Top-left to bottom-right',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksDirectionGrid extends StatelessWidget {
  const _HowItWorksDirectionGrid({
    required this.direction,
    required this.onDirectionChange,
  });

  final WipeDirection direction;
  final ValueChanged<WipeDirection> onDirectionChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HowItWorksDirectionButton(
              icon: Symbols.north_west,
              description: 'Bottom-right to top-left',
              selected: direction == WipeDirection.bottomRightToTopLeft,
              onPressed: () =>
                  onDirectionChange(WipeDirection.bottomRightToTopLeft),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_up,
              description: 'Bottom to top',
              selected: direction == WipeDirection.bottomToTop,
              onPressed: () => onDirectionChange(WipeDirection.bottomToTop),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.north_east,
              description: 'Bottom-left to top-right',
              selected: direction == WipeDirection.bottomLeftToTopRight,
              onPressed: () =>
                  onDirectionChange(WipeDirection.bottomLeftToTopRight),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_left,
              description: 'Right to left',
              selected: direction == WipeDirection.rightToLeft,
              onPressed: () => onDirectionChange(WipeDirection.rightToLeft),
            ),
            const SizedBox(width: 4),
            const SizedBox(width: 44, height: 44),
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_right,
              description: 'Left to right',
              selected: direction == WipeDirection.leftToRight,
              onPressed: () => onDirectionChange(WipeDirection.leftToRight),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HowItWorksDirectionButton(
              icon: Symbols.south_west,
              description: 'Top-right to bottom-left',
              selected: direction == WipeDirection.topRightToBottomLeft,
              onPressed: () =>
                  onDirectionChange(WipeDirection.topRightToBottomLeft),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_down,
              description: 'Top to bottom',
              selected: direction == WipeDirection.topToBottom,
              onPressed: () => onDirectionChange(WipeDirection.topToBottom),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.south_east,
              description: 'Top-left to bottom-right',
              selected: direction == WipeDirection.topLeftToBottomRight,
              onPressed: () =>
                  onDirectionChange(WipeDirection.topLeftToBottomRight),
            ),
          ],
        ),
      ],
    );
  }
}

class _HowItWorksDirectionButton extends StatefulWidget {
  const _HowItWorksDirectionButton({
    required this.icon,
    required this.description,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String description;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_HowItWorksDirectionButton> createState() =>
      _HowItWorksDirectionButtonState();
}

class _HowItWorksDirectionButtonState extends State<_HowItWorksDirectionButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.9,
    upperBound: 1.15,
    value: 1,
  );

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get _scaleTarget => _pressed ? 0.92 : (_hovered ? 1.08 : 1);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animateScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _animateScale();
  }

  void _animateScale() {
    final double target = _scaleTarget;
    _animateScaleWithSpring(
      _scaleController,
      target,
      stiffness: 1500,
      dampingRatio: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = widget.selected
        ? colors.primaryContainer
        : colors.appSurfaceVariant.withValues(alpha: 0.3);
    final iconColor =
        widget.selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;
    return Semantics(
      selected: widget.selected,
      button: true,
      label: widget.description,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (_, child) => Transform.scale(
              alignment: Alignment.center,
              scale: _scaleController.value,
              child: child,
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: 24,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.title,
    required this.frameHeight,
    required this.child,
  });

  final String title;
  final double frameHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: frameHeight,
          child: Center(child: child),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _HowItWorksBoundaryPainterWrapper extends CustomPainter {
  _HowItWorksBoundaryPainterWrapper({
    required this.size,
    required this.progress,
    required this.direction,
    required this.color,
  });

  final Size size;
  final double progress;
  final WipeDirection direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final line = buildWipeBoundaryLine(
      width: size.width,
      height: size.height,
      progress: progress,
      direction: direction,
    );
    if (line == null) return;

    canvas.drawLine(
      line.start,
      line.end,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(
    covariant _HowItWorksBoundaryPainterWrapper oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.direction != direction;
  }
}

class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({
    required this.seedColor,
    required this.isDark,
    super.key,
  });

  final Color seedColor;
  final bool isDark;

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 35),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base =
        widget.isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFAFAFA);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final offset = _controller.value * 2 * 3.14159;
        return CustomPaint(
          painter: _AnimatedMeshPainter(
            seedColor: widget.seedColor,
            phase: offset,
            baseColor: base,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AnimatedMeshPainter extends CustomPainter {
  _AnimatedMeshPainter({
    required this.seedColor,
    required this.phase,
    required this.baseColor,
  });

  final Color seedColor;
  final double phase;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [seedColor.withValues(alpha: 0.04), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2 + (math.cos(phase) * 100),
            size.height / 3 + (math.sin(phase) * 50),
          ),
          radius: 500,
        ),
      );

    canvas
      ..drawRect(Offset.zero & size, Paint()..color = baseColor)
      ..drawCircle(
        Offset(
          size.width / 2 + math.cos(phase) * 100,
          size.height / 3 + math.sin(phase) * 50,
        ),
        500,
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _AnimatedMeshPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.seedColor != seedColor ||
      oldDelegate.baseColor != baseColor;
}
