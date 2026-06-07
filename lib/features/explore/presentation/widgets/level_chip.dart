import 'package:flutter/material.dart';

const _levelColors = {
  'a1': Color(0xFF22C55E),
  'a2': Color(0xFF4ECDC4),
  'b1': Color(0xFF3B82F6),
  'b2': Color(0xFFA855F7),
  'c1': Color(0xFFFF6B35),
  'c2': Color(0xFFF44336),
};

class LevelChip extends StatelessWidget {
  final String level;
  final int deckCount;
  final VoidCallback onTap;

  const LevelChip({
    super.key,
    required this.level,
    required this.deckCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _levelColors[level.toLowerCase()] ?? const Color(0xFF6B7280);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              level.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$deckCount deck',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
