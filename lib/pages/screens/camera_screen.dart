import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// CameraApp is the Main Application.

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 400.0,
        width: 300.0,
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              children: [
                const Text('Your turn!'),
                const SizedBox(
                  height: 20,
                ),
                const Text("Memorize this moment!"),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child:
                        TextButton(onPressed: () {}, child: const Text('Skip')),
                  ),
                )
              ],
            ),
            Center(
                child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 3,color: Colors.black),
              ),
              child: IconButton(
                  onPressed: () {
                    context.push('/camera');
                  },
                  icon: const Icon(
                    Icons.add_a_photo_rounded,
                    size: 30,
                  )),
            )),
          ],
        ));
  }
}
