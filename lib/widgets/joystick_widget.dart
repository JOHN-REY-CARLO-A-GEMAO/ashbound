import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class JoystickWidget extends StatefulWidget {
  final ValueChanged<Vector2> onChanged;
  final VoidCallback onReleased;

  const JoystickWidget({
    super.key,
    required this.onChanged,
    required this.onReleased,
  });

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  Offset _dragOffset = Offset.zero;
  static const double radius = 60.0;

  void _updateOffset(Offset localPos) {
    final dx = localPos.dx - radius;
    final dy = localPos.dy - radius;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > radius) {
      final angle = atan2(dy, dx);
      _dragOffset = Offset(cos(angle) * radius, sin(angle) * radius);
    } else {
      _dragOffset = Offset(dx, dy);
    }

    final normalizedVector = Vector2(
      _dragOffset.dx / radius,
      _dragOffset.dy / radius,
    );

    widget.onChanged(normalizedVector);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updateOffset(details.localPosition),
      onPanUpdate: (details) => _updateOffset(details.localPosition),
      onPanEnd: (_) {
        setState(() {
          _dragOffset = Offset.zero;
        });
        widget.onReleased();
      },
      onPanCancel: () {
        setState(() {
          _dragOffset = Offset.zero;
        });
        widget.onReleased();
      },
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.amber.withOpacity(0.6), width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: _dragOffset,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.amberAccent, blurRadius: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
