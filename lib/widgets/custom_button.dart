import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HackerButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isOutlined;
  final IconData? icon;
  final bool playSound;
  final String soundAsset;
  final double width;

  const HackerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isOutlined = false,
    this.icon,
    this.playSound = true,
    this.soundAsset = 'sounds/button_click.mp3',
    this.width = double.infinity,
  });

  @override
  State<HackerButton> createState() => _HackerButtonState();
}

class _HackerButtonState extends State<HackerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    if (widget.playSound) {
      final player = AudioPlayer();
      await player.play(AssetSource(widget.soundAsset));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        _playSound();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                border: _getBorder(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: _isPressed ? [] : _getShadow(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _getTextColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text.toUpperCase(),
                    style: TextStyle(
                      color: _getTextColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isOutlined) {
      return Colors.transparent;
    }
    if (widget.isPrimary) {
      return _isPressed ? Colors.cyanAccent.shade700 : Colors.cyanAccent;
    }
    return _isPressed ? Colors.blueGrey.shade800 : Colors.blueGrey.shade700;
  }

  Color _getTextColor() {
    if (widget.isOutlined) {
      return Colors.cyanAccent;
    }
    if (widget.isPrimary) {
      return Colors.black;
    }
    return Colors.white;
  }

  BoxBorder? _getBorder() {
    if (widget.isOutlined) {
      return Border.all(
        color: Colors.cyanAccent,
        width: 2,
      );
    }
    return null;
  }

  List<BoxShadow> _getShadow() {
    if (widget.isOutlined) {
      return [
        BoxShadow(
          color: Colors.cyanAccent.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    if (widget.isPrimary) {
      return [
        BoxShadow(
          color: Colors.cyanAccent.withOpacity(0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    return [];
  }
} 