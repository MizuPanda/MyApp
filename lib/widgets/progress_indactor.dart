import 'package:flutter/material.dart';

class MyCircularProgress extends StatelessWidget {
  const MyCircularProgress({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        width: 20,
        height: 20,
        child: Center(child: CircularProgressIndicator()));
  }
}
