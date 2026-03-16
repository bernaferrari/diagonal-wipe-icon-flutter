import 'package:flutter/material.dart';

const WipeDirection _defaultWipeDirection = WipeDirection.topLeftToBottomRight;
const double _defaultSeamOverlapPx = 0.8;
const AnimationStyle _defaultAnimationStyle = AnimationStyle(
  duration: Duration(milliseconds: 530),
  reverseDuration: Duration(milliseconds: 800),
  curve: Curves.ease,
  reverseCurve: Curves.ease,
);
const double _eps = 1e-4;

/// Animates between two widgets by revealing the destination widget with a
/// diagonal, horizontal, or vertical wipe.
class AnimatedDiagonalWipe extends StatefulWidget {
  /// Creates a wipe transition between two prebuilt widgets.
  ///
  /// The provided children are centered, clipped to a square box sized by
  /// [size], and wrapped in an [IconTheme]. Widgets that respect [IconTheme]
  /// receive the resolved tint and size automatically. Widgets with explicit
  /// styling keep their own color or size values.
  const AnimatedDiagonalWipe({
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
    this.reverseDirection,
    this.seamOverlapPx = _defaultSeamOverlapPx,
  })  : _baseChild = baseChild,
        _wipedChild = wipedChild,
        _baseIconData = null,
        _wipedIconData = null,
        assert(seamOverlapPx >= 0);

  /// Creates a wipe transition between two [IconData] values.
  ///
  /// Use [animationStyle] to customize the timing and easing of the implicit
  /// animation.
  ///
  /// [reverseDirection] is interpreted as the visual direction of the reverse
  /// wipe. Because the reverse pass drives [progress] from `1.0` to `0.0`,
  /// the clip path internally mirrors that progress so the on-screen motion
  /// still matches the requested direction.
  const AnimatedDiagonalWipe.icon({
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
    this.reverseDirection,
    this.seamOverlapPx = _defaultSeamOverlapPx,
  })  : _baseChild = null,
        _wipedChild = null,
        _baseIconData = baseIcon,
        _wipedIconData = wipedIcon,
        assert(seamOverlapPx >= 0);

  final bool isWiped;
  final Color? baseTint;
  final Color? wipedTint;
  final String? semanticsLabel;
  final double size;
  final AnimationStyle? animationStyle;
  final WipeDirection direction;

  /// Visual direction to use while animating from wiped back to base.
  ///
  /// When omitted, the reverse pass starts from the same side as [direction].
  final WipeDirection? reverseDirection;
  final double seamOverlapPx;

  final Widget? _baseChild;
  final Widget? _wipedChild;
  final IconData? _baseIconData;
  final IconData? _wipedIconData;

  @override
  State<AnimatedDiagonalWipe> createState() => _AnimatedDiagonalWipeState();
}

class _AnimatedDiagonalWipeState extends State<AnimatedDiagonalWipe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _disableAnimations = false;

  AnimationStyle get _effectiveAnimationStyle =>
      _defaultAnimationStyle.copyWith(
        duration: widget.animationStyle?.duration,
        reverseDuration: widget.animationStyle?.reverseDuration,
        curve: widget.animationStyle?.curve,
        reverseCurve: widget.animationStyle?.reverseCurve,
      );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.isWiped ? 1 : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextDisableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_disableAnimations == nextDisableAnimations) return;
    _disableAnimations = nextDisableAnimations;
    _animateToTarget(widget.isWiped, immediate: true);
  }

  @override
  void didUpdateWidget(covariant AnimatedDiagonalWipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetChanged = oldWidget.isWiped != widget.isWiped;
    final styleChanged = oldWidget.animationStyle != widget.animationStyle;
    if (targetChanged || styleChanged) {
      _animateToTarget(widget.isWiped);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateToTarget(bool target, {bool immediate = false}) {
    if (!mounted) return;

    if (_disableAnimations || immediate) {
      _controller
        ..stop()
        ..value = target ? 1 : 0;
      return;
    }

    final style = _effectiveAnimationStyle;
    final targetValue = target ? 1.0 : 0.0;
    final duration = target
        ? (style.duration ?? Duration.zero)
        : (style.reverseDuration ?? style.duration ?? Duration.zero);
    final curve = target
        ? (style.curve ?? Curves.linear)
        : (style.reverseCurve ?? style.curve ?? Curves.linear);

    _controller.stop();
    if (duration == Duration.zero) {
      _controller.value = targetValue;
      return;
    }

    _controller.animateTo(targetValue, duration: duration, curve: curve);
  }

  Widget _resolveChild(Widget? child, IconData? icon, Color? tint) {
    if (child == null) {
      return Icon(icon, size: widget.size, color: tint);
    }

    return IconTheme.merge(
      data: IconThemeData(size: widget.size, color: tint),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseTint;
    final wipedColor = widget.wipedTint ?? baseColor;

    return DiagonalWipeTransition(
      progress: _controller,
      baseChild: _resolveChild(
        widget._baseChild,
        widget._baseIconData,
        baseColor,
      ),
      wipedChild: _resolveChild(
        widget._wipedChild,
        widget._wipedIconData,
        wipedColor,
      ),
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      direction: widget.direction,
      reverseDirection: widget.reverseDirection,
      seamOverlapPx: widget.seamOverlapPx,
    );
  }
}

/// Paints the wipe effect for an explicit [Animation] that drives progress from
/// `0.0` to `1.0`.
class DiagonalWipeTransition extends StatefulWidget {
  const DiagonalWipeTransition({
    super.key,
    required this.progress,
    required this.baseChild,
    required this.wipedChild,
    this.semanticsLabel,
    this.size = 24,
    this.direction = _defaultWipeDirection,
    this.reverseDirection,
    this.seamOverlapPx = _defaultSeamOverlapPx,
  }) : assert(seamOverlapPx >= 0);

  final Animation<double> progress;
  final Widget baseChild;
  final Widget wipedChild;
  final String? semanticsLabel;
  final double size;
  final WipeDirection direction;

  /// Visual direction to use while animating from wiped back to base.
  ///
  /// When omitted, the reverse pass starts from the same side as [direction].
  final WipeDirection? reverseDirection;
  final double seamOverlapPx;

  @override
  State<DiagonalWipeTransition> createState() => _DiagonalWipeTransitionState();
}

enum _RenderMode { baseOnly, wiping, wipedOnly }

class _DiagonalWipeTransitionState extends State<DiagonalWipeTransition> {
  late _RenderMode _mode;
  late double _lastProgressValue;
  bool _isReversing = false;

  _RenderMode _modeFor(double value) {
    final t = value.clamp(0.0, 1.0).toDouble();
    if (t <= _eps) return _RenderMode.baseOnly;
    if (t >= 1 - _eps) return _RenderMode.wipedOnly;
    return _RenderMode.wiping;
  }

  @override
  void initState() {
    super.initState();
    _lastProgressValue = widget.progress.value.clamp(0.0, 1.0).toDouble();
    _mode = _modeFor(_lastProgressValue);
    widget.progress.addListener(_handleProgressChanged);
  }

  @override
  void didUpdateWidget(covariant DiagonalWipeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      oldWidget.progress.removeListener(_handleProgressChanged);
      widget.progress.addListener(_handleProgressChanged);
      _lastProgressValue = widget.progress.value.clamp(0.0, 1.0).toDouble();
    }

    _mode = _modeFor(widget.progress.value);
  }

  @override
  void dispose() {
    widget.progress.removeListener(_handleProgressChanged);
    super.dispose();
  }

  void _handleProgressChanged() {
    final nextValue = widget.progress.value.clamp(0.0, 1.0).toDouble();
    final nextMode = _modeFor(nextValue);
    final nextIsReversing = nextValue < _lastProgressValue - _eps
        ? true
        : nextValue > _lastProgressValue + _eps
            ? false
            : _isReversing;
    _lastProgressValue = nextValue;
    if ((nextMode == _mode && nextIsReversing == _isReversing) || !mounted) {
      _isReversing = nextIsReversing;
      return;
    }
    setState(() {
      _mode = nextMode;
      _isReversing = nextIsReversing;
    });
  }

  WipeDirection get _activeDirection {
    if (!_isReversing) return widget.direction;

    return widget.reverseDirection ?? widget.direction;
  }

  Widget _layer({
    required Widget child,
    required bool inverse,
  }) {
    return ClipPath(
      clipper: _WipeClipper(
        progress: widget.progress,
        direction: _activeDirection,
        seamOverlapPx: widget.seamOverlapPx,
        reverseProgress: _isReversing,
        inverse: inverse,
      ),
      child: _frame(child),
    );
  }

  Widget _frame(Widget child) {
    return ClipRect(
      child: SizedBox.expand(
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseInverse = !_isReversing;
    final content = switch (_mode) {
      _RenderMode.baseOnly => _frame(widget.baseChild),
      _RenderMode.wipedOnly => _frame(widget.wipedChild),
      _RenderMode.wiping => Stack(
          fit: StackFit.expand,
          children: [
            _layer(child: widget.baseChild, inverse: baseInverse),
            _layer(child: widget.wipedChild, inverse: !baseInverse),
          ],
        ),
    };

    final boxed = SizedBox.square(
      dimension: widget.size,
      child: content,
    );

    return widget.semanticsLabel == null
        ? boxed
        : Semantics(label: widget.semanticsLabel, image: true, child: boxed);
  }
}

/// The direction in which the wipe boundary travels across the widget bounds.
enum WipeDirection {
  topLeftToBottomRight(Offset(1, 1)),
  bottomRightToTopLeft(Offset(-1, -1)),
  topRightToBottomLeft(Offset(-1, 1)),
  bottomLeftToTopRight(Offset(1, -1)),
  topToBottom(Offset(0, 1)),
  bottomToTop(Offset(0, -1)),
  leftToRight(Offset(1, 0)),
  rightToLeft(Offset(-1, 0));

  const WipeDirection(this.axis);
  final Offset axis;

  WipeDirection get opposite => switch (this) {
        WipeDirection.topLeftToBottomRight =>
          WipeDirection.bottomRightToTopLeft,
        WipeDirection.bottomRightToTopLeft =>
          WipeDirection.topLeftToBottomRight,
        WipeDirection.topRightToBottomLeft =>
          WipeDirection.bottomLeftToTopRight,
        WipeDirection.bottomLeftToTopRight =>
          WipeDirection.topRightToBottomLeft,
        WipeDirection.topToBottom => WipeDirection.bottomToTop,
        WipeDirection.bottomToTop => WipeDirection.topToBottom,
        WipeDirection.leftToRight => WipeDirection.rightToLeft,
        WipeDirection.rightToLeft => WipeDirection.leftToRight,
      };
}

class _WipeClipper extends CustomClipper<Path> {
  _WipeClipper({
    required this.progress,
    required this.direction,
    required this.seamOverlapPx,
    this.reverseProgress = false,
    this.inverse = false,
  }) : super(reclip: progress);

  final Animation<double> progress;
  final WipeDirection direction;
  final double seamOverlapPx;
  final bool reverseProgress;
  final bool inverse;

  @override
  Path getClip(Size size) {
    final rawT = progress.value.clamp(0.0, 1.0).toDouble();
    final t = reverseProgress ? (1.0 - rawT) : rawT;
    final overlap = (t > 0 && t < 1) ? seamOverlapPx : 0.0;
    final reveal = buildWipeRevealPath(
      width: size.width,
      height: size.height,
      progress: t,
      direction: direction,
      seamOverlapPx: overlap,
    );

    if (!inverse) return reveal;

    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addPath(reveal, Offset.zero);
  }

  @override
  bool shouldReclip(covariant _WipeClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.direction != direction ||
        oldClipper.seamOverlapPx != seamOverlapPx ||
        oldClipper.reverseProgress != reverseProgress ||
        oldClipper.inverse != inverse;
  }
}

/// Returns the distance the wipe boundary must travel to fully cross a box.
double wipeTravelDistance(
  double width,
  double height,
  WipeDirection direction,
) {
  if (width <= 0 || height <= 0) return 1.0;
  final range = _projectionRange(Size(width, height), direction.axis);
  final distance = (range.max - range.min).abs();
  return distance < 1.0 ? 1.0 : distance;
}

/// Builds the clipping path that reveals the destination widget for [progress].
Path buildWipeRevealPath({
  required double width,
  required double height,
  required double progress,
  required WipeDirection direction,
  double seamOverlapPx = 0,
}) {
  final path = Path();
  if (width <= 0 || height <= 0) return path;

  final t = progress.clamp(0.0, 1.0).toDouble();
  if (t <= 0) return path;
  if (t >= 1) {
    path.addRect(Rect.fromLTWH(0, 0, width, height));
    return path;
  }

  final size = Size(width, height);
  final range = _projectionRange(size, direction.axis);
  final threshold = range.min + (range.max - range.min) * t + seamOverlapPx;
  final points = _clipRectWithHalfPlane(size, direction.axis, threshold);
  if (points.isNotEmpty) {
    path.addPolygon(points, true);
  }
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
  if (width <= 0 || height <= 0) return null;

  final t = progress.clamp(0.0, 1.0).toDouble();
  if (t <= 0 || t >= 1) return null;

  final axis = direction.axis;
  final range = _projectionRange(Size(width, height), axis);
  final threshold = range.min + (range.max - range.min) * t;
  final candidates = <Offset>[
    if (axis.dy.abs() > _eps) Offset(0, threshold / axis.dy),
    if (axis.dy.abs() > _eps)
      Offset(width, (threshold - axis.dx * width) / axis.dy),
    if (axis.dx.abs() > _eps) Offset(threshold / axis.dx, 0),
    if (axis.dx.abs() > _eps)
      Offset((threshold - axis.dy * height) / axis.dx, height),
  ];

  final points = <Offset>[];
  for (final point in candidates) {
    if (point.dx < -_eps ||
        point.dx > width + _eps ||
        point.dy < -_eps ||
        point.dy > height + _eps) {
      continue;
    }
    if (points.every((other) => !_samePoint(other, point))) {
      points.add(point);
    }
  }

  if (points.length < 2) return null;
  if (points.length == 2) return (start: points[0], end: points[1]);

  var start = points[0];
  var end = points[1];
  var maxDistanceSquared = -1.0;

  for (var i = 0; i < points.length; i++) {
    for (var j = i + 1; j < points.length; j++) {
      final dx = points[i].dx - points[j].dx;
      final dy = points[i].dy - points[j].dy;
      final distanceSquared = dx * dx + dy * dy;
      if (distanceSquared > maxDistanceSquared) {
        maxDistanceSquared = distanceSquared;
        start = points[i];
        end = points[j];
      }
    }
  }

  return (start: start, end: end);
}

List<Offset> _rectCorners(Size size) => <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];

({double min, double max}) _projectionRange(Size size, Offset axis) {
  var minValue = double.infinity;
  var maxValue = double.negativeInfinity;

  for (final corner in _rectCorners(size)) {
    final value = _project(corner, axis);
    if (value < minValue) minValue = value;
    if (value > maxValue) maxValue = value;
  }

  return (min: minValue, max: maxValue);
}

List<Offset> _clipRectWithHalfPlane(Size size, Offset axis, double threshold) {
  final input = _rectCorners(size);
  final output = <Offset>[];

  void addPoint(Offset point) {
    if (output.isEmpty || !_samePoint(output.last, point)) {
      output.add(point);
    }
  }

  var previous = input.last;
  var previousValue = _project(previous, axis) - threshold;
  var previousInside = previousValue <= _eps;

  for (final current in input) {
    final currentValue = _project(current, axis) - threshold;
    final currentInside = currentValue <= _eps;

    if (previousInside != currentInside) {
      final denominator = previousValue - currentValue;
      if (denominator.abs() > _eps) {
        final t = (previousValue / denominator).clamp(0.0, 1.0).toDouble();
        addPoint(_lerp(previous, current, t));
      }
    }

    if (currentInside) {
      addPoint(current);
    }

    previous = current;
    previousValue = currentValue;
    previousInside = currentInside;
  }

  if (output.length > 1 && _samePoint(output.first, output.last)) {
    output.removeLast();
  }

  return output;
}

double _project(Offset point, Offset axis) =>
    point.dx * axis.dx + point.dy * axis.dy;

Offset _lerp(Offset a, Offset b, double t) => Offset(
      a.dx + (b.dx - a.dx) * t,
      a.dy + (b.dy - a.dy) * t,
    );

bool _samePoint(Offset a, Offset b) {
  final dx = a.dx - b.dx;
  final dy = a.dy - b.dy;
  return dx * dx + dy * dy < 1e-6;
}
