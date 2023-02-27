import 'package:flutter/material.dart';

class ChargingBolt extends StatefulWidget {
  final double height;
  final double width;

  const ChargingBolt({super.key, required this.height, required this.width});

  @override
  State<ChargingBolt> createState() => _ChargingBoltState();
}

class _ChargingBoltState extends State<ChargingBolt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _heightAnimation = Tween(begin: 0.0, end: widget.height).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: _heightAnimation.value,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/lightning.webp'),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
