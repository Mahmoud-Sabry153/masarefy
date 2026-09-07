import 'package:flutter/material.dart';
import '../../core/theme/neon_colors.dart';
import '../home/home_screen.dart';

/// The app's launch animation: the Masarefy "M" mark draws itself in
/// neon strokes, a coin drops into its valley, the wordmark fades up,
/// then the whole scene cross-fades into [HomeScreen].
///
/// The mark is drawn live with a [CustomPainter] (see [_MLogoPainter])
/// rather than an image asset — it's the exact same shape as the app
/// icon (see assets/icon/), so the launch animation and the icon the
/// user tapped feel like one continuous piece of motion, and it stays
/// crisp on every screen density with zero extra assets to ship.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final Animation<double> _draw;
  late final Animation<double> _coin;
  late final Animation<double> _wordmark;
  late final Animation<double> _pulseValue;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    // The M strokes draw in over the first 70% of the intro...
    _draw = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
    );
    // ...the coin drops into place with a little overshoot right after...
    _coin = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.55, 0.9, curve: Curves.elasticOut),
    );
    // ...and the wordmark fades/slides up right at the end.
    _wordmark = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    // A slow, continuous glow "breathe" while the splash holds on screen.
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _pulseValue = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);

    _intro.forward();

    Future.delayed(const Duration(milliseconds: 2200), _goToHome);
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NeonColors.backdropGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_intro, _pulse]),
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 220,
                    height: 168,
                    child: CustomPaint(
                      painter: _MLogoPainter(
                        drawProgress: _draw.value,
                        coinProgress: _coin.value,
                        pulse: _pulseValue.value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Opacity(
                    opacity: _wordmark.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _wordmark.value) * 12),
                      child: const Text(
                        'MASAREFY',
                        style: TextStyle(
                          color: NeonColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Draws the Masarefy "M" mark: two neon strokes revealed progressively
/// along their own path length (so the mark looks hand-drawn rather than
/// just fading in), plus the coin that settles into the M's valley.
///
/// This mirrors [BudgetRing]'s glow technique (a blurred wide stroke
/// under a crisp gradient stroke) so the splash feels visually part of
/// the same app rather than a bespoke one-off animation.
class _MLogoPainter extends CustomPainter {
  _MLogoPainter({
    required this.drawProgress,
    required this.coinProgress,
    required this.pulse,
  });

  final double drawProgress;
  final double coinProgress;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final left = w * 0.14;
    final right = w * 0.86;
    final midX = w * 0.5;
    final top = h * 0.08;
    final bottom = h * 0.82;
    final midY = top + (bottom - top) * 0.60;

    final path = Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top)
      ..lineTo(midX, midY)
      ..lineTo(right, top)
      ..lineTo(right, bottom);

    final revealed = _extractProgress(path, drawProgress);
    if (revealed == null) return;

    final rect = Rect.fromLTRB(left, top, right, bottom);
    final shader = const LinearGradient(
      colors: [NeonColors.cyan, NeonColors.secondary],
    ).createShader(rect);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = NeonColors.primary.withOpacity(0.30 + 0.18 * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05);
    canvas.drawPath(revealed, glowPaint);

    final crispPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = shader;
    canvas.drawPath(revealed, crispPaint);

    if (coinProgress > 0) {
      final coinT = coinProgress.clamp(0.0, 1.0).toDouble();
      final r = w * 0.05 * coinT;
      final glow = Paint()
        ..color = NeonColors.danger.withOpacity(0.55 * coinT)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(Offset(midX, midY), r * 1.9, glow);
      canvas.drawCircle(Offset(midX, midY), r, Paint()..color = NeonColors.danger);
    }
  }

  /// Returns the sub-path of [source] covering the first [t] fraction of
  /// its total length — the mechanism behind the "drawing itself" effect.
  Path? _extractProgress(Path source, double t) {
    if (t <= 0) return null;
    final metrics = source.computeMetrics().toList();
    final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
    final targetLength = totalLength * t.clamp(0.0, 1.0).toDouble();

    final result = Path();
    double consumed = 0;
    for (final metric in metrics) {
      if (consumed >= targetLength) break;
      final remaining = targetLength - consumed;
      final take = remaining >= metric.length ? metric.length : remaining;
      result.addPath(metric.extractPath(0, take), Offset.zero);
      consumed += metric.length;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _MLogoPainter oldDelegate) =>
      oldDelegate.drawProgress != drawProgress ||
      oldDelegate.coinProgress != coinProgress ||
      oldDelegate.pulse != pulse;
}
