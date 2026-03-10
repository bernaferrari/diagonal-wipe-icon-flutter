import 'dart:math' as math;

import 'package:flutter/material.dart';

const WipeDirection _defaultWipeDirection = WipeDirection.topLeftToBottomRight;
const double _defaultSeamOverlapPx = 0.8;
const AnimationStyle _defaultAnimationStyle = AnimationStyle(
  duration: Duration(milliseconds: 530),
  reverseDuration: Duration(milliseconds: 800),
  curve: Curves.ease,
  reverseCurve: Curves.ease,
);

/// Animates between two icon widgets by revealing the destination icon with a
/// diagonal, horizontal, or vertical wipe.
class AnimatedDiagonalWipeIcon extends StatefulWidget {
  final bool isWiped;
  final Color? baseTint;
  final Color? wipedTint;
  final String? semanticsLabel;
  final double size;
  final AnimationStyle? animationStyle;
  final WipeDirection direction;
  final double seamOverlapPx;
  final Widget? _baseChild;
  final Widget? _wipedChild;
  final IconData? _baseIconData;
  final IconData? _wipedIconData;

  /// Creates a wipe icon from two prebuilt widgets.
  ///
  /// This is the most permissive constructor. The provided children are
  /// centered, clipped to a square box sized by [size], and wrapped in an
  /// [IconTheme]. Widgets that respect [IconTheme] receive the resolved tint
  /// and size automatically. Widgets with explicit styling keep their own
  /// color or size values.
  const AnimatedDiagonalWipeIcon.raw({
    super.key,
    required this.isWiped,
    required Widget baseChild,
    required Widget wipedChild,
    this.baseTint,
    this.wipedTint,
    this.semanticsLabel,
    this.size = 24,
    this.animationStyle,
    this.direction = _defaultWipeDirection,
    this.seamOverlapPx = _defaultSeamOverlapPx,
  })  : _baseChild = baseChild,
        _wipedChild = wipedChild,
        _baseIconData = null,
        _wipedIconData = null,
        assert(seamOverlapPx >= 0);

  /// Creates a wipe icon from two [IconData] values.
  ///
  /// Use [animationStyle] to customize the timing and easing of the implicit
  /// animation.
  const AnimatedDiagonalWipeIcon({
    super.key,
    required this.isWiped,
    required IconData baseIcon,
    required IconData wipedIcon,
    this.baseTint,
    this.wipedTint,
    this.semanticsLabel,
    this.size = 24,
    this.animationStyle,
    this.direction = _defaultWipeDirection,
    this.seamOverlapPx = _defaultSeamOverlapPx,
  })  : _baseChild = null,
        _wipedChild = null,
        _baseIconData = baseIcon,
        _wipedIconData = wipedIcon,
        assert(seamOverlapPx >= 0);

  @override
  State<AnimatedDiagonalWipeIcon> createState() =>
      _AnimatedDiagonalWipeIconState();
}

class _AnimatedDiagonalWipeIconState extends State<AnimatedDiagonalWipeIcon>
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
  void didUpdateWidget(covariant AnimatedDiagonalWipeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool targetChanged = oldWidget.isWiped != widget.isWiped;
    final bool parametersChanged =
        oldWidget.animationStyle != widget.animationStyle ||
            oldWidget.direction != widget.direction ||
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

    final AnimationStyle animationStyle = _effectiveAnimationStyle;
    final bool isWipingIn = target;
    final double targetValue = isWipingIn ? 1 : 0;
    final Duration duration =
        isWipingIn ? animationStyle.duration! : animationStyle.reverseDuration!;
    final Curve curve =
        isWipingIn ? animationStyle.curve! : animationStyle.reverseCurve!;
    _animation = _controller;
    _controller.stop();

    if (duration == Duration.zero) {
      _controller.value = targetValue;
      return;
    }

    _controller.animateTo(
      targetValue,
      duration: duration,
      curve: curve,
    );
  }

  AnimationStyle get _effectiveAnimationStyle {
    final style = widget.animationStyle;
    if (style == null) return _defaultAnimationStyle;
    return _defaultAnimationStyle.copyWith(
      curve: style.curve,
      duration: style.duration,
      reverseCurve: style.reverseCurve,
      reverseDuration: style.reverseDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color? baseColor = widget.baseTint;
    final Color? wipedColor = widget.wipedTint ?? baseColor;

    Widget wrapLayer(Widget child, Color? color) {
      return Center(
        child: IconTheme.merge(
          data: IconThemeData(size: widget.size, color: color),
          child: child,
        ),
      );
    }

    return DiagonalWipeTransition(
      progress: _animation,
      baseChild: widget._baseChild != null
          ? wrapLayer(widget._baseChild!, baseColor)
          : Icon(widget._baseIconData, size: widget.size, color: baseColor),
      wipedChild: widget._wipedChild != null
          ? wrapLayer(widget._wipedChild!, wipedColor)
          : Icon(widget._wipedIconData, size: widget.size, color: wipedColor),
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      direction: widget.direction,
      seamOverlapPx: widget.seamOverlapPx,
    );
  }
}

/// Paints the wipe effect for an explicit [Animation] that drives progress from
/// `0.0` to `1.0`.
class DiagonalWipeTransition extends AnimatedWidget {
  const DiagonalWipeTransition({
    super.key,
    required Animation<double> progress,
    required Widget baseChild,
    required Widget wipedChild,
    this.semanticsLabel,
    this.size = 24,
    this.direction = WipeDirection.topLeftToBottomRight,
    this.seamOverlapPx = 0.8,
  })  : _progress = progress,
        _baseChild = baseChild,
        _wipedChild = wipedChild,
        super(listenable: progress);

  final Animation<double> _progress;
  final String? semanticsLabel;
  final double size;
  final WipeDirection direction;
  final double seamOverlapPx;
  final Widget _baseChild;
  final Widget _wipedChild;

  Animation<double> get progress => _progress;

  Widget _buildLayer({
    required bool base,
  }) {
    final Widget content = Center(child: base ? _baseChild : _wipedChild);
    return SizedBox.square(
      dimension: size,
      child: ClipRect(child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.value.clamp(0.0, 1.0);

    final Widget staticResult = _buildLayer(base: true);
    final Widget finalResult = _buildLayer(base: false);

    final Widget result;
    if (clampedProgress <= 0.001) {
      result = staticResult;
    } else if (clampedProgress >= 0.999) {
      result = finalResult;
    } else {
      result = LayoutBuilder(
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
              (clampedProgress * travelDistance + seamOverlapPx) /
                  travelDistance;

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
    }

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
