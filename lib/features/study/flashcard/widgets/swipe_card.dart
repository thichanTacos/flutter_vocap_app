import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/models/card_model.dart';

class SwipeCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const SwipeCard({
    super.key,
    required this.card,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  double _dragOffset = 0;
  bool _isDragging = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;

  late AnimationController _swipeController;
  late Animation<double> _swipeAnimation;
  double _swipeDirection = 0;

  // Press scale
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
    );
    _swipeController.addListener(() => setState(() {}));

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(SwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _flipController.reset();
      _swipeController.reset();
      setState(() {
        _isFront = true;
        _dragOffset = 0;
        _isDragging = false;
        _swipeDirection = 0;
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _swipeController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isDragging) return;
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _isFront = !_isFront);
    HapticFeedback.lightImpact();
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset += details.delta.dx);
    if ((_dragOffset > 59 && _dragOffset < 61) ||
        (_dragOffset < -59 && _dragOffset > -61)) {
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldSwipeRight = _dragOffset > 100 || velocity > 800;
    final shouldSwipeLeft = _dragOffset < -100 || velocity < -800;

    if (shouldSwipeRight) {
      _triggerSwipe(1);
    } else if (shouldSwipeLeft) {
      _triggerSwipe(-1);
    } else {
      _snapBack();
    }
    setState(() => _isDragging = false);
  }

  void _triggerSwipe(double direction) {
    _swipeDirection = direction;
    _swipeController.forward().then((_) {
      if (direction > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _snapBack() {
    final startOffset = _dragOffset;
    final snapAnim = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final snapTween = Tween<double>(begin: startOffset, end: 0).animate(
      CurvedAnimation(parent: snapAnim, curve: Curves.elasticOut),
    );
    snapAnim.addListener(() => setState(() => _dragOffset = snapTween.value));
    snapAnim.addStatusListener((status) {
      if (status == AnimationStatus.completed) snapAnim.dispose();
    });
    snapAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    double totalOffset = _dragOffset;
    double rotation = _dragOffset * 0.001;

    if (_swipeController.isAnimating || _swipeController.isCompleted) {
      final screenWidth = MediaQuery.of(context).size.width;
      totalOffset =
          _dragOffset + (_swipeDirection * screenWidth * 1.5 * _swipeAnimation.value);
      rotation = totalOffset * 0.001;
    }

    final opacity =
        (1.0 - (_dragOffset.abs() / 300).clamp(0.0, 0.4)).clamp(0.6, 1.0);

    // Border & label when dragging
    Color borderColor = AppTheme.dividerColor;
    String swipeLabel = '';
    Color labelColor = Colors.transparent;
    IconData? swipeIcon;
    Color? glowColor;

    if (_dragOffset > 30) {
      final intensity = (_dragOffset / 150).clamp(0.0, 1.0);
      borderColor = Color.lerp(AppTheme.dividerColor, AppTheme.green, intensity)!;
      glowColor = AppTheme.green.withValues(alpha: intensity * 0.2);
      swipeLabel = 'BIẾT RỒI';
      labelColor = AppTheme.green;
      swipeIcon = Icons.check_circle_rounded;
    } else if (_dragOffset < -30) {
      final intensity = (_dragOffset.abs() / 150).clamp(0.0, 1.0);
      borderColor =
          Color.lerp(AppTheme.dividerColor, Colors.red.shade400, intensity)!;
      glowColor = Colors.red.withValues(alpha: intensity * 0.2);
      swipeLabel = 'CHƯA BIẾT';
      labelColor = Colors.red.shade400;
      swipeIcon = Icons.close_rounded;
    }

    return GestureDetector(
      onTap: () {
        _pressController.forward().then((_) => _pressController.reverse());
        _flip();
      },
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(totalOffset, _dragOffset.abs() * 0.03),
            child: Transform.rotate(
              angle: rotation,
              child: AnimatedBuilder(
                animation: Listenable.merge([_flipAnimation, _pressScale]),
                builder: (context, _) {
                  final isFrontVisible = _flipAnimation.value < 0.5;
                  final angle = _flipAnimation.value * 3.14159;

                  return Transform.scale(
                    scale: _pressScale.value,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor ??
                                  Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              spreadRadius: glowColor != null ? 4 : 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(isFrontVisible ? 0 : 3.14159),
                          child: Stack(
                            children: [
                              // Main content
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    isFrontVisible
                                        ? widget.card.term
                                        : widget.card.definition,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                              // Label top-left
                              Positioned(
                                top: 16,
                                left: 18,
                                child: Text(
                                  isFrontVisible ? 'THUẬT NGỮ' : 'ĐỊNH NGHĨA',
                                  style: const TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Swipe overlay label
                              if (swipeLabel.isNotEmpty)
                                Positioned(
                                  top: 20,
                                  left: _dragOffset > 0 ? 18 : null,
                                  right: _dragOffset < 0 ? 18 : null,
                                  child: AnimatedOpacity(
                                    opacity: (_dragOffset.abs() / 80)
                                        .clamp(0.0, 1.0),
                                    duration:
                                        const Duration(milliseconds: 80),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: labelColor
                                            .withValues(alpha: 0.12),
                                        border: Border.all(
                                            color: labelColor, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (swipeIcon != null)
                                            Icon(swipeIcon,
                                                color: labelColor, size: 16),
                                          const SizedBox(width: 5),
                                          Text(
                                            swipeLabel,
                                            style: TextStyle(
                                              color: labelColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              // Hint bottom
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    isFrontVisible
                                        ? 'Nhấn để xem nghĩa'
                                        : 'Nhấn để lật lại',
                                    style: const TextStyle(
                                        color: AppTheme.textLight,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
