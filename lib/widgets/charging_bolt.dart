import 'package:flutter/material.dart';

class ChargingBolt extends StatefulWidget {
  const ChargingBolt({super.key});

  @override
  State<ChargingBolt> createState() => _ChargingBoltState();
}

class _ChargingBoltState extends State<ChargingBolt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final double size = 200;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Icon(Icons.flash_on_rounded,
                      color: Colors.black, size: size + 2),
                  Icon(
                    Icons.flash_on_rounded,
                    color: Colors.yellow,
                    size: size,
                  ),
                  Container(
                    width: size,
                    height: _animation.value / 1.5 * size,
                    color: Colors.white,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
