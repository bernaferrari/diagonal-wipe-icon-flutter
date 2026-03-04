import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const double _composeStiffnessMediumLow = 400;
const double _composeStiffnessLow = 200;

/// Defines how a [DiagonalWipeIcon] animates between its two icon states.
///
/// Use this object to bundle timing, easing, spring behavior, seam overlap,
/// and wipe direction into a reusable motion preset.
class DiagonalWipeMotion {
  final Duration wipeInDuration;
  final Duration wipeOutDuration;
  final Curve wipeInCurve;
  final Curve wipeOutCurve;
  final bool useSpring;
  final double wipeInStiffness;
  final double wipeOutStiffness;
  final double wipeInDampingRatio;
  final double wipeOutDampingRatio;
  final double seamOverlapPx;
  final WipeDirection direction;

  /// Creates a fully custom motion definition.
  const DiagonalWipeMotion({
    this.wipeInDuration = const Duration(milliseconds: 530),
    this.wipeOutDuration = const Duration(milliseconds: 800),
    this.wipeInCurve = const Cubic(0.22, 1, 0.36, 1),
    this.wipeOutCurve = const Cubic(0.4, 0, 0.2, 1),
    this.useSpring = false,
    this.wipeInStiffness = _composeStiffnessMediumLow,
    this.wipeOutStiffness = _composeStiffnessLow,
    this.wipeInDampingRatio = 1.0,
    this.wipeOutDampingRatio = 1.0,
    this.seamOverlapPx = 0.8,
    this.direction = WipeDirection.topLeftToBottomRight,
  }) : assert(seamOverlapPx >= 0);

  /// A quick non-spring preset tuned for responsive tap interactions.
  const DiagonalWipeMotion.snappy({
    this.direction = WipeDirection.topLeftToBottomRight,
    this.seamOverlapPx = 0.8,
  })  : wipeInDuration = const Duration(milliseconds: 220),
        wipeOutDuration = const Duration(milliseconds: 300),
        wipeInCurve = Curves.fastOutSlowIn,
        wipeOutCurve = Curves.linearToEaseOut,
        useSpring = false,
        wipeInStiffness = _composeStiffnessMediumLow,
        wipeOutStiffness = _composeStiffnessLow,
        wipeInDampingRatio = 1,
        wipeOutDampingRatio = 1,
        assert(seamOverlapPx >= 0);

  /// A slower eased preset intended for softer, calmer transitions.
  const DiagonalWipeMotion.gentle({
    this.direction = WipeDirection.topLeftToBottomRight,
    this.seamOverlapPx = 0.8,
  })  : wipeInDuration = const Duration(milliseconds: 530),
        wipeOutDuration = const Duration(milliseconds: 800),
        wipeInCurve = const Cubic(0.22, 1, 0.36, 1),
        wipeOutCurve = const Cubic(0.4, 0, 0.2, 1),
        useSpring = false,
        wipeInStiffness = _composeStiffnessMediumLow,
        wipeOutStiffness = _composeStiffnessLow,
        wipeInDampingRatio = 1,
        wipeOutDampingRatio = 1,
        assert(seamOverlapPx >= 0);

  /// A spring-driven preset with the same general pacing as [gentle].
  const DiagonalWipeMotion.expressive({
    this.direction = WipeDirection.topLeftToBottomRight,
    this.seamOverlapPx = 0.8,
  })  : wipeInDuration = const Duration(milliseconds: 530),
        wipeOutDuration = const Duration(milliseconds: 800),
        wipeInCurve = const Cubic(0.22, 1, 0.36, 1),
        wipeOutCurve = const Cubic(0.4, 0, 0.2, 1),
        useSpring = true,
        wipeInStiffness = _composeStiffnessMediumLow,
        wipeOutStiffness = _composeStiffnessLow,
        wipeInDampingRatio = 1,
        wipeOutDampingRatio = 1,
        assert(seamOverlapPx >= 0);

  /// A fully spring-driven preset with configurable stiffness and damping.
  const DiagonalWipeMotion.spring({
    this.direction = WipeDirection.topLeftToBottomRight,
    this.seamOverlapPx = 0.8,
    this.wipeInStiffness = _composeStiffnessMediumLow,
    this.wipeOutStiffness = _composeStiffnessLow,
    this.wipeInDampingRatio = 1,
    this.wipeOutDampingRatio = 1,
  })  : wipeInDuration = const Duration(milliseconds: 530),
        wipeOutDuration = const Duration(milliseconds: 800),
        wipeInCurve = Curves.linear,
        wipeOutCurve = Curves.linear,
        useSpring = true,
        assert(seamOverlapPx >= 0);

  static const WipeDirection defaultDirection =
      WipeDirection.topLeftToBottomRight;
  static const double defaultSeamOverlapPx = 0.8;
}

/// Builds an icon widget using the size and resolved color from the wipe icon.
typedef SizedIconBuilder = Widget Function(double size, Color color);

/// Animates between two icon widgets by revealing the destination icon with a
/// diagonal, horizontal, or vertical wipe.
class DiagonalWipeIcon extends StatefulWidget {
  final bool isWiped;
  final SizedIconBuilder baseIcon;
  final SizedIconBuilder wipedIcon;
  final Color? baseTint;
  final Color? wipedTint;
  final String? semanticsLabel;
  final double size;
  final WipeDirection direction;
  final Duration wipeInDuration;
  final Duration wipeOutDuration;
  final Curve wipeInCurve;
  final Curve wipeOutCurve;
  final bool useSpring;
  final double wipeInStiffness;
  final double wipeOutStiffness;
  final double wipeInDampingRatio;
  final double wipeOutDampingRatio;
  final double seamOverlapPx;

  /// Creates a wipe icon using a reusable [DiagonalWipeMotion] preset.
  DiagonalWipeIcon.fromMotion({
    super.key,
    required this.isWiped,
    required this.baseIcon,
    required this.wipedIcon,
    this.baseTint,
    this.wipedTint,
    this.semanticsLabel,
    this.size = 24,
    DiagonalWipeMotion motion = const DiagonalWipeMotion(),
  })  : direction = motion.direction,
        wipeInDuration = motion.wipeInDuration,
        wipeOutDuration = motion.wipeOutDuration,
        wipeInCurve = motion.wipeInCurve,
        wipeOutCurve = motion.wipeOutCurve,
        useSpring = motion.useSpring,
        wipeInStiffness = motion.wipeInStiffness,
        wipeOutStiffness = motion.wipeOutStiffness,
        wipeInDampingRatio = motion.wipeInDampingRatio,
        wipeOutDampingRatio = motion.wipeOutDampingRatio,
        seamOverlapPx = motion.seamOverlapPx;

  /// Creates a wipe icon with explicit animation parameters.
  const DiagonalWipeIcon({
    super.key,
    required this.isWiped,
    required this.baseIcon,
    required this.wipedIcon,
    this.baseTint,
    this.wipedTint,
    this.semanticsLabel,
    this.size = 24,
    this.direction = WipeDirection.topLeftToBottomRight,
    this.wipeInDuration = const Duration(milliseconds: 530),
    this.wipeOutDuration = const Duration(milliseconds: 800),
    this.wipeInCurve = const Cubic(0.22, 1, 0.36, 1),
    this.wipeOutCurve = const Cubic(0.4, 0, 0.2, 1),
    this.useSpring = false,
    this.wipeInStiffness = _composeStiffnessMediumLow,
    this.wipeOutStiffness = _composeStiffnessLow,
    this.wipeInDampingRatio = 1.0,
    this.wipeOutDampingRatio = 1.0,
    this.seamOverlapPx = 0.8,
  }) : assert(seamOverlapPx >= 0);

  @override
  State<DiagonalWipeIcon> createState() => _DiagonalWipeIconState();
}

class _DiagonalWipeIconState extends State<DiagonalWipeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late bool _reduceMotion;

  @override
  void initState() {
    super.initState();
    _reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    _controller = AnimationController(
      vsync: this,
      value: widget.isWiped ? 1 : 0,
    );
    _animation = _controller;
    _animateToTarget(widget.isWiped, immediate: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool nextReduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (_reduceMotion != nextReduceMotion) {
      _reduceMotion = nextReduceMotion;
      _animateToTarget(widget.isWiped, immediate: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DiagonalWipeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool targetChanged = oldWidget.isWiped != widget.isWiped;
    final bool parametersChanged = oldWidget.direction != widget.direction ||
        oldWidget.wipeInDuration != widget.wipeInDuration ||
        oldWidget.wipeOutDuration != widget.wipeOutDuration ||
        oldWidget.wipeInCurve != widget.wipeInCurve ||
        oldWidget.wipeOutCurve != widget.wipeOutCurve ||
        oldWidget.useSpring != widget.useSpring ||
        oldWidget.wipeInStiffness != widget.wipeInStiffness ||
        oldWidget.wipeOutStiffness != widget.wipeOutStiffness ||
        oldWidget.wipeInDampingRatio != widget.wipeInDampingRatio ||
        oldWidget.wipeOutDampingRatio != widget.wipeOutDampingRatio ||
        oldWidget.seamOverlapPx != widget.seamOverlapPx;

    if (targetChanged || parametersChanged) {
      _animateToTarget(widget.isWiped);
    }
  }

  void _animateToTarget(
    bool target, {
    bool immediate = false,
    bool? reduceMotion,
  }) {
    if (!mounted) return;
    final bool effectiveReduceMotion = reduceMotion ?? _reduceMotion;

    if (effectiveReduceMotion || immediate) {
      _controller
        ..stop()
        ..value = target ? 1 : 0;
      _animation = _controller;
      return;
    }

    final bool isWipingIn = target;
    final double targetValue = isWipingIn ? 1 : 0;
    _controller.stop();

    if (widget.useSpring) {
      final double stiffness =
          isWipingIn ? widget.wipeInStiffness : widget.wipeOutStiffness;
      final double dampingRatio =
          isWipingIn ? widget.wipeInDampingRatio : widget.wipeOutDampingRatio;
      final spring = SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: stiffness,
        ratio: dampingRatio,
      );
      final simulation = SpringSimulation(
        spring,
        _controller.value,
        targetValue,
        _controller.velocity,
      );

      _animation = _controller;
      _controller.animateWith(simulation);
      return;
    }

    final Duration duration =
        isWipingIn ? widget.wipeInDuration : widget.wipeOutDuration;
    final Curve curve = isWipingIn ? widget.wipeInCurve : widget.wipeOutCurve;
    _animation = _controller;

    _controller.animateTo(
      targetValue,
      duration: duration,
      curve: curve,
    );
  }

  Widget _buildIcon(SizedIconBuilder builder, Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: builder(widget.size, color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconThemeColor = IconTheme.of(context).color;
    final fallbackTint = iconThemeColor ?? theme.colorScheme.onSurface;
    final Color baseColor = widget.baseTint ?? fallbackTint;
    final Color wipedColor = widget.wipedTint ?? fallbackTint;

    final Widget result = AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final double progress = _animation.value.clamp(0.0, 1.0);
        if (progress <= 0.001) {
          return _buildIcon(widget.baseIcon, baseColor);
        }
        if (progress >= 0.999) {
          return _buildIcon(widget.wipedIcon, wipedColor);
        }

        return RepaintBoundary(
          child: Builder(
            builder: (context) {
              final double width = widget.size;
              final double height = widget.size;
              if (width <= 0 || height <= 0) {
                return _buildIcon(widget.baseIcon, baseColor);
              }

              final double travelDistance = wipeTravelDistance(
                width,
                height,
                widget.direction,
              );
              final double adjustedProgress =
                  ((progress * travelDistance + widget.seamOverlapPx) /
                          travelDistance)
                      .clamp(0.0, 1.0);

              final Path reveal = buildWipeRevealPath(
                width: width,
                height: height,
                progress: adjustedProgress,
                direction: widget.direction,
              );

              final Path baseClip = Path()
                ..fillType = PathFillType.evenOdd
                ..addRect(Rect.fromLTWH(0, 0, width, height))
                ..addPath(reveal, Offset.zero);

              return Stack(
                fit: StackFit.passthrough,
                children: [
                  ClipPath(
                    clipper: _StaticWipeClipper(baseClip),
                    child: _buildIcon(widget.baseIcon, baseColor),
                  ),
                  ClipPath(
                    clipper: _StaticWipeClipper(reveal),
                    child: _buildIcon(widget.wipedIcon, wipedColor),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (widget.semanticsLabel == null) return result;
    return Semantics(label: widget.semanticsLabel, image: true, child: result);
  }
}

/// Renders the wipe effect at an explicit progress value between `0.0` and
/// `1.0`, without owning an internal animation controller.
class DiagonalWipeIconAtProgress extends StatelessWidget {
  const DiagonalWipeIconAtProgress({
    super.key,
    required this.progress,
    required this.baseIcon,
    required this.wipedIcon,
    this.baseTint,
    this.wipedTint,
    this.semanticsLabel,
    this.size = 24,
    this.direction = WipeDirection.topLeftToBottomRight,
    this.seamOverlapPx = 0.8,
  });

  final double progress;
  final SizedIconBuilder baseIcon;
  final SizedIconBuilder wipedIcon;
  final Color? baseTint;
  final Color? wipedTint;
  final String? semanticsLabel;
  final double size;
  final WipeDirection direction;
  final double seamOverlapPx;

  Widget _buildIcon(SizedIconBuilder builder, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: builder(size, color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconThemeColor = IconTheme.of(context).color;
    final fallbackTint = iconThemeColor ?? theme.colorScheme.onSurface;
    final Color resolvedBaseTint = baseTint ?? fallbackTint;
    final Color resolvedWipedTint = wipedTint ?? fallbackTint;
    final double clampedProgress = progress.clamp(0.0, 1.0);

    final Widget staticResult = _buildIcon(baseIcon, resolvedBaseTint);
    final Widget finalResult = _buildIcon(wipedIcon, resolvedWipedTint);

    if (clampedProgress <= 0.001) {
      return staticResult;
    }
    if (clampedProgress >= 0.999) {
      return finalResult;
    }

    final Widget result = LayoutBuilder(
      builder: (context, constraints) {
        final double width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : size;
        final double height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : size;
        if (width <= 0 || height <= 0) return staticResult;

        final double travelDistance = wipeTravelDistance(
          width,
          height,
          direction,
        );
        final double adjustedProgress =
            (clampedProgress * travelDistance + seamOverlapPx) / travelDistance;

        final Path reveal = buildWipeRevealPath(
          width: width,
          height: height,
          progress: adjustedProgress.clamp(0.0, 1.0),
          direction: direction,
        );
        final Path baseClip = Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(Rect.fromLTWH(0, 0, width, height))
          ..addPath(reveal, Offset.zero);

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _StaticWipeClipper(baseClip),
              child: staticResult,
            ),
            ClipPath(
              clipper: _StaticWipeClipper(reveal),
              child: finalResult,
            ),
          ],
        );
      },
    );

    final Widget sizedResult = SizedBox(
      width: size,
      height: size,
      child: result,
    );

    if (semanticsLabel == null) return sizedResult;
    return Semantics(label: semanticsLabel, image: true, child: sizedResult);
  }
}

/// The direction in which the wipe boundary travels across the icon bounds.
enum WipeDirection {
  topLeftToBottomRight,
  bottomRightToTopLeft,
  topRightToBottomLeft,
  bottomLeftToTopRight,
  topToBottom,
  bottomToTop,
  leftToRight,
  rightToLeft,
}

class _StaticWipeClipper extends CustomClipper<Path> {
  _StaticWipeClipper(this._path);

  final Path _path;

  @override
  Path getClip(Size size) => _path;

  @override
  bool shouldReclip(covariant _StaticWipeClipper oldClipper) {
    return oldClipper._path != _path;
  }
}

Offset _wipeAxis(WipeDirection direction) {
  switch (direction) {
    case WipeDirection.topLeftToBottomRight:
      return const Offset(1, 1);
    case WipeDirection.bottomRightToTopLeft:
      return const Offset(-1, -1);
    case WipeDirection.topRightToBottomLeft:
      return const Offset(-1, 1);
    case WipeDirection.bottomLeftToTopRight:
      return const Offset(1, -1);
    case WipeDirection.topToBottom:
      return const Offset(0, 1);
    case WipeDirection.bottomToTop:
      return const Offset(0, -1);
    case WipeDirection.leftToRight:
      return const Offset(1, 0);
    case WipeDirection.rightToLeft:
      return const Offset(-1, 0);
  }
}

/// Returns the distance the wipe boundary must travel to fully cross a box.
double wipeTravelDistance(
  double width,
  double height,
  WipeDirection direction,
) {
  final axis = _wipeAxis(direction);
  final values = [
    0.0,
    axis.dx * width,
    axis.dx * width + axis.dy * height,
    axis.dy * height,
  ];
  final minValue = values.reduce(math.min);
  final maxValue = values.reduce(math.max);
  return (maxValue - minValue).abs().clamp(1.0, double.infinity);
}

double _boundaryThreshold(
  double width,
  double height,
  double progress,
  Offset axis,
) {
  final values = [
    0.0,
    axis.dx * width,
    axis.dx * width + axis.dy * height,
    axis.dy * height,
  ];
  final minValue = values.reduce(math.min);
  final maxValue = values.reduce(math.max);
  return minValue + (maxValue - minValue) * progress;
}

List<Offset> _clipRectangleWithHalfPlane({
  required double width,
  required double height,
  required Offset axis,
  required double threshold,
}) {
  const double eps = 0.0001;

  final inPoints = [
    const Offset(0, 0),
    Offset(width, 0),
    Offset(width, height),
    Offset(0, height),
  ];
  final outPoints = <Offset>[];

  void addOutputPoint(double x, double y) {
    if (outPoints.isNotEmpty) {
      final last = outPoints.last;
      final dx = last.dx - x;
      final dy = last.dy - y;
      if ((dx * dx + dy * dy) < 1e-4) return;
    }
    outPoints.add(Offset(x, y));
  }

  double prevX = inPoints[3].dx;
  double prevY = inPoints[3].dy;
  double prevValue = axis.dx * prevX + axis.dy * prevY - threshold;
  bool prevInside = prevValue <= eps;

  for (int i = 0; i < inPoints.length; i++) {
    final currentX = inPoints[i].dx;
    final currentY = inPoints[i].dy;
    final double currentValue =
        axis.dx * currentX + axis.dy * currentY - threshold;
    final bool currentInside = currentValue <= eps;

    if (prevInside && currentInside) {
      addOutputPoint(currentX, currentY);
    } else if (prevInside && !currentInside) {
      final denominator = prevValue - currentValue;
      if (denominator.abs() >= eps) {
        final t = (prevValue / denominator).clamp(0.0, 1.0);
        addOutputPoint(
          prevX + (currentX - prevX) * t,
          prevY + (currentY - prevY) * t,
        );
      }
    } else if (!prevInside && currentInside) {
      final denominator = prevValue - currentValue;
      if (denominator.abs() >= eps) {
        final t = (prevValue / denominator).clamp(0.0, 1.0);
        addOutputPoint(
          prevX + (currentX - prevX) * t,
          prevY + (currentY - prevY) * t,
        );
      }
      addOutputPoint(currentX, currentY);
    }

    prevX = currentX;
    prevY = currentY;
    prevValue = currentValue;
    prevInside = currentInside;
  }

  if (outPoints.length > 1) {
    final first = outPoints.first;
    final last = outPoints.last;
    final dx = first.dx - last.dx;
    final dy = first.dy - last.dy;
    if ((dx * dx + dy * dy) < 1e-4) {
      outPoints.removeLast();
    }
  }

  return outPoints;
}

/// Builds the clipping path that reveals the destination icon for [progress].
Path buildWipeRevealPath({
  required double width,
  required double height,
  required double progress,
  required WipeDirection direction,
}) {
  final Path path = Path();
  final p = progress.clamp(0.0, 1.0);
  if (p <= 0.0) {
    return path;
  }
  if (p >= 1.0) {
    path.addRect(Rect.fromLTWH(0, 0, width, height));
    return path;
  }

  final axis = _wipeAxis(direction);
  final threshold = _boundaryThreshold(width, height, p, axis);
  final points = _clipRectangleWithHalfPlane(
    width: width,
    height: height,
    axis: axis,
    threshold: threshold,
  );
  if (points.isEmpty) {
    return path;
  }

  path.moveTo(points[0].dx, points[0].dy);
  for (int i = 1; i < points.length; i++) {
    path.lineTo(points[i].dx, points[i].dy);
  }
  path.close();
  return path;
}

/// Returns the visible wipe boundary line for debugging or custom painting.
///
/// Returns `null` when the wipe is fully hidden or fully revealed.
({Offset start, Offset end})? buildWipeBoundaryLine({
  required double width,
  required double height,
  required double progress,
  required WipeDirection direction,
}) {
  final p = progress.clamp(0.0, 1.0);
  if (p <= 0 || p >= 1) return null;

  final axis = _wipeAxis(direction);
  final threshold = _boundaryThreshold(width, height, p, axis);

  final candidates = <Offset>[];
  const double eps = 0.0001;

  if (axis.dy.abs() > eps) {
    candidates.add(Offset(0, threshold / axis.dy));
    candidates.add(Offset(width, (threshold - axis.dx * width) / axis.dy));
  }
  if (axis.dx.abs() > eps) {
    candidates.add(Offset(threshold / axis.dx, 0));
    candidates.add(Offset((threshold - axis.dy * height) / axis.dx, height));
  }

  final filtered = <Offset>[];
  for (final c in candidates) {
    if (c.dx < -eps ||
        c.dx > width + eps ||
        c.dy < -eps ||
        c.dy > height + eps) {
      continue;
    }
    if (filtered.every((v) {
      final dx = v.dx - c.dx;
      final dy = v.dy - c.dy;
      return dx * dx + dy * dy >= 1e-6;
    })) {
      filtered.add(c);
    }
  }

  if (filtered.length < 2) return null;

  Offset start = filtered.first;
  Offset end = filtered[1];
  if (filtered.length > 2) {
    double maxDist = -1;
    for (int i = 0; i < filtered.length; i++) {
      for (int j = i + 1; j < filtered.length; j++) {
        final dx = filtered[i].dx - filtered[j].dx;
        final dy = filtered[i].dy - filtered[j].dy;
        final d2 = dx * dx + dy * dy;
        if (d2 > maxDist) {
          maxDist = d2;
          start = filtered[i];
          end = filtered[j];
        }
      }
    }
  }

  return (start: start, end: end);
}
