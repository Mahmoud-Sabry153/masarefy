import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/neon_colors.dart';

/// An animated, glowing circular progress ring showing spent-vs-budget.
///
/// The ring's fill animates from 0 up to the real [fraction] whenever it
/// changes (e.g. after adding a new billing item), rather than jumping
/// straight to the new value — this is the app's centerpiece "awesome
/// animation" moment on the Home screen.
class BudgetRing extends StatefulWidget {
  const BudgetRing({
    super.key,
    required this.fraction,
    required this.centerLabel,
    required this.subLabel,
    this.size = 180,
  });

  /// 0.0 - 1.0+ (can exceed 1.0 when over budget; the ring color shifts
  /// to the danger color past 1.0).
  final double fraction;
  final String centerLabel;
  final String subLabel;
  final double size;

  @override
  State<BudgetRing> createState() => _BudgetRingState();
}

class _BudgetRingState extends State<BudgetRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0, end: widget.fraction.clamp(0, 1.4).toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BudgetRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fraction != widget.fraction) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.fraction.clamp(0, 1.4).toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final over = _animation.value > 1.0;
        final color = over ? NeonColors.danger : NeonColors.primary;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RingPainter(fraction: _animation.value, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.centerLabel,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final track = Paint()
      ..color = NeonColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final sweep = 2 * math.pi * fraction.clamp(0, 1.0).toDouble();

    // Glow layer: a wider, blurred, translucent stroke underneath the
    // crisp progress stroke — this is what makes the ring look neon
    // instead of just a flat Material progress indicator.
    final glow = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      glow,
    );

    final progress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color;
}
