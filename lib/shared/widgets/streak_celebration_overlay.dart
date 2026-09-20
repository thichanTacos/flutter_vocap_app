import 'dart:math';
import 'package:flutter/material.dart';

class StreakCelebrationOverlay extends StatefulWidget {
  final int streakCount;
  final VoidCallback onContinue;

  const StreakCelebrationOverlay({
    super.key,
    required this.streakCount,
    required this.onContinue,
  });

  static Future<void> show(BuildContext context, int streakCount) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, _, __) => StreakCelebrationOverlay(
        streakCount: streakCount,
        onContinue: () => Navigator.of(ctx).pop(),
      ),
      transitionBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<StreakCelebrationOverlay> createState() =>
      _StreakCelebrationOverlayState();
}

class _StreakCelebrationOverlayState extends State<StreakCelebrationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  late final AnimationController _badgeCtrl;
  late final Animation<double> _scaleAnim;
  late final List<_Particle> _particles;
  final _rng = Random();

  @override
  void initState() {
    super.initState();

    _particles = List.generate(40, (i) => _Particle(
      x: _rng.nextDouble(),
      delay: _rng.nextDouble() * 0.4,
      color: _kColors[_rng.nextInt(_kColors.length)],
      size: 6 + _rng.nextDouble() * 9,
      isCircle: _rng.nextBool(),
    ));

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.25), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.88), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.06), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 10),
    ]).animate(CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _badgeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Confetti particles
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ConfettiPainter(_particles, _confettiCtrl.value),
              child: const SizedBox.expand(),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fire badge
                  AnimatedBuilder(
                    animation: _scaleAnim,
                    builder: (_, child) =>
                        Transform.scale(scale: _scaleAnim.value, child: child),
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFD166), Color(0xFFFF6B35)],
                          center: Alignment(0, -0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withValues(alpha: 0.55),
                            blurRadius: 36,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 46)),
                          Text(
                            '${widget.streakCount}',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'TUYỆT VỜI!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bạn đã học ${widget.streakCount} ngày liên tiếp',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Giữ vững chuỗi này nhé! 💪',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 44),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

const _kColors = [
  Color(0xFFFF6B35),
  Color(0xFF4ECDC4),
  Color(0xFFFFE66D),
  Color(0xFF6BCB77),
  Color(0xFF4D96FF),
  Color(0xFFFF6B6B),
  Color(0xFFA29BFE),
  Color(0xFFFDCB6E),
];

class _Particle {
  final double x;
  final double delay;
  final Color color;
  final double size;
  final bool isCircle;

  const _Particle({
    required this.x,
    required this.delay,
    required this.color,
    required this.size,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1.0 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = p.x * size.width + sin(t * pi * 3) * 22;
      final y = -20 + t * (size.height + 40);
      final opacity = t < 0.65 ? 1.0 : 1.0 - ((t - 0.65) / 0.35);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      if (p.isCircle) {
        canvas.drawCircle(Offset(x, y), p.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(t * pi * 5);
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.55),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
