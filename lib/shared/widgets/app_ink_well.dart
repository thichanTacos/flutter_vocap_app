import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInkWell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool playSound;

  const AppInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.playSound = true,
  });

  @override
  State<AppInkWell> createState() => _AppInkWellState();
}

class _AppInkWellState extends State<AppInkWell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _brightnessAnim;

  // ✅ Static player khởi tạo 1 lần duy nhất
  static AudioPlayer? _player;
  static bool _playerReady = false;

  static Future<void> _initPlayer() async {
    if (_playerReady) return;
    _player = AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.stop);
    await _player!.setPlayerMode(PlayerMode.lowLatency);
    await _player!.setSourceAsset('sounds/click.mp3');
    _playerReady = true;
  }

  @override
  void initState() {
    super.initState();
    _initPlayer(); // khởi tạo trước
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _brightnessAnim = Tween<double>(begin: 0.0, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playClick() async {
    if (!widget.playSound) return;
    if (!_playerReady || _player == null) return;
    try {
      await _player!.stop();
      await _player!.resume();
    } catch (_) {}
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
    HapticFeedback.lightImpact();
    _playClick();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: ClipRRect(
            borderRadius: radius,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix([
                1, 0, 0, 0, _brightnessAnim.value * 80,
                0, 1, 0, 0, _brightnessAnim.value * 80,
                0, 0, 1, 0, _brightnessAnim.value * 80,
                0, 0, 0, 1, 0,
              ]),
              child: child,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}