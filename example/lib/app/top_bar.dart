import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    final iconColor = colors.onSurface;
    return AppBar(
      centerTitle: false,
      title: Opacity(
        opacity: scrollTitleAlpha,
        child: Text(
          'Diagonal Wipe Icons for Flutter',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      backgroundColor: colors.surface.withValues(alpha: 0.95),
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
                constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
                padding: EdgeInsets.zero,
                iconSize: 22,
                splashRadius: 18,
                style: _topBarButtonStyle(),
                icon: _TopBarVectorIcon(
                  path: _appTopBarXPath,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Open GitHub',
                onPressed: onOpenGitHub,
                constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
                padding: EdgeInsets.zero,
                iconSize: 22,
                splashRadius: 18,
                style: _topBarButtonStyle(),
                icon: _TopBarVectorIcon(
                  path: _appTopBarGitHubPath,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip:
                    isDark ? 'Switch to light mode' : 'Switch to dark mode',
                onPressed: onToggleDark,
                constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
                padding: EdgeInsets.zero,
                iconSize: 22,
                splashRadius: 18,
                style: _topBarButtonStyle(),
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

  ButtonStyle _topBarButtonStyle() {
    return IconButton.styleFrom(
      visualDensity: VisualDensity.compact,
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarVectorIcon extends StatelessWidget {
  const _TopBarVectorIcon({
    required this.path,
    required this.color,
  });

  final Path path;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
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
