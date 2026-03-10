import 'dart:math' as math;

import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';
import 'package:flutter/material.dart';

import '../demo_catalog.dart';
import 'app_shared.dart';
import 'support/support.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    required this.onOpenHowItWorks,
    required this.onIconTap,
    required this.accentColor,
    super.key,
  });

  final VoidCallback? onOpenHowItWorks;
  final ValueChanged<MaterialWipeIconPair> onIconTap;
  final Color accentColor;

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
      label: 'Cloud',
      enabledIcon: MaterialSymbolName.cloud,
      disabledIcon: MaterialSymbolName.cloudOff,
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroMeshBackgroundPainter(
                backgroundColor: Theme.of(context).colorScheme.surface,
                seedColor: accentColor,
              ),
            ),
          ),
          Positioned.fill(
            child: _AnimatedHeroOrbs(accentColor: accentColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
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
                        'Elegant morphing transitions for icons in Flutter',
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
                    child: RepeatingAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 2400),
                      animatable: Tween<double>(begin: 0, end: 1),
                      builder: (context, cycleProgress, _) => HeroIconShowcase(
                        pairs: _heroPairs,
                        cycleProgress: cycleProgress,
                        onIconTap: onIconTap,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _HowItWorksButton(
                    key: const ValueKey('how-it-works-button'),
                    onTap: onOpenHowItWorks,
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

class _AnimatedHeroOrbs extends StatelessWidget {
  const _AnimatedHeroOrbs({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return RepeatingAnimationBuilder<double>(
      duration: const Duration(milliseconds: 25000),
      animatable: Tween<double>(begin: 0, end: 1),
      builder: (_, orbitProgress, __) {
        return CustomPaint(
          painter: _HeroOrbsPainter(
            accentColor: accentColor,
            orbitPhase: orbitProgress * math.pi * 2,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
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

class _HeroMeshBackgroundPainter extends CustomPainter {
  const _HeroMeshBackgroundPainter({
    required this.backgroundColor,
    required this.seedColor,
  });

  final Color backgroundColor;
  final Color seedColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            seedColor.withValues(alpha: 0.025),
            Colors.transparent,
          ],
          center: Alignment.center,
          radius: 0.7,
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _HeroMeshBackgroundPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.seedColor != seedColor;
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
    animateScaleWithSpring(
      _scaleController,
      _targetScale,
      stiffness: 200,
      dampingRatio: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              border: _hovered
                  ? Border.all(
                      color: colors.outline.withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: AnimatedDiagonalWipe.icon(
              isWiped: widget.isWiped,
              baseIcon: fallbackIconData(widget.iconPair.enabledIcon),
              wipedIcon: fallbackIconData(widget.iconPair.disabledIcon),
              baseTint: colors.primary,
              wipedTint: colors.secondary,
              size: widget.size * 0.49,
              animationStyle: const AnimationStyle(
                duration: Duration(milliseconds: 530),
                reverseDuration: Duration(milliseconds: 800),
                curve: Curves.ease,
                reverseCurve: Curves.ease,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
