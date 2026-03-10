import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../demo_catalog.dart';

typedef IconTapCallback = void Function(MaterialWipeIconPair pair);

double composeDialogMaxWidth(BuildContext context) {
  final viewportWidth = MediaQuery.sizeOf(context).width;
  final availableWidth = math.max(0.0, viewportWidth - 32.0);
  // Compose Android Dialog uses a platform-default width; Surface then uses fillMaxWidth(0.94f).
  final platformDialogWidth = math.min(availableWidth, 560.0);
  return platformDialogWidth * 0.94;
}

Future<void> animateScaleWithSpring(
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
