import 'package:flutter/material.dart';

class RoundButton extends StatefulWidget {
  final IconData icon;
  final Function onPressed;
  final double size;
  final Color? colorPressed;
  final Color? colorUnpressed;
  final bool? shouldGrow;
  const RoundButton({Key? key, required this.icon, required this.onPressed, required this.size, this.colorPressed, this.colorUnpressed, this.shouldGrow}) : super(key: key);

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton>  {
  bool _isPressed = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 3,color: Colors.white,)
        ),
        child: IconButton(
          color: widget.colorPressed != null? (!_isPressed? widget.colorUnpressed:widget.colorPressed): widget.colorUnpressed,
          alignment: Alignment.center,
          onPressed: () {
          widget.onPressed();
        },
          icon: Icon(widget.icon),
         iconSize: widget.shouldGrow!=null? (widget.shouldGrow!? (_isPressed? widget.size*1.2: widget.size) : widget.size) : widget.size,
        ),
      ),
    );
  }
}
