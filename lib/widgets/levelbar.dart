import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class LevelBar extends StatefulWidget {
  final double initialValue;
  final double width;
  final double height;
  const LevelBar({super.key, required this.initialValue, required this.height, required this.width});

  @override
  State<LevelBar> createState() => _LevelBarState();
}

class _LevelBarState extends State<LevelBar> {
  List<Widget> getLines() {
    List<Widget> lines = [];
    for(int i = 0; i<9; i++) {
      lines.add(
        Row(
          children: [
            Padding(padding: EdgeInsets.only(left: widget.width/10)),
            Container(
              width: 2,
              height: widget.height,
              color: Colors.white,
            ),
          ],
        )
      );
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: FAProgressBar(
            size: widget.width,
            backgroundColor: Colors.white,
            progressColor: Colors.blueAccent,
            currentValue: widget.initialValue,
            displayText: '/10',
            maxValue: 10,
            border: Border.all(color: Colors.black, strokeAlign: BorderSide.strokeAlignOutside),
          ),
        ),
      ],
    );
  }
}
