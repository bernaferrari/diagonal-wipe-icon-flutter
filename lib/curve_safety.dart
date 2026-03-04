import 'package:flutter/animation.dart';

/// Returns a curve that clamps endpoints to exact [0.0] and [1.0].
///
/// Some custom curve chains can produce edge-case numerical values at exact
/// endpoints, which can trigger assertions in `CurvedAnimation`/`CurveTween`
/// when they expect the transform to return clean boundary values.
Curve withSafeCurveEndpoints(Curve curve) {
  if (curve is _EndpointSafeCurve) return curve;
  return _EndpointSafeCurve(curve);
}

class _EndpointSafeCurve extends Curve {
  const _EndpointSafeCurve(this.delegate);

  final Curve delegate;

  @override
  double transformInternal(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    final double value = delegate.transform(t);
    if (!value.isFinite) return t.clamp(0.0, 1.0);
    return value.clamp(0.0, 1.0);
  }
}
