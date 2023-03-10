import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../pages/screens/camera_screen.dart';

class CameraProvider extends ChangeNotifier {
  static late List<CameraDescription> _cameras;
  late CameraController _controller;
  late AnimationController _animationController;

  static Future<void> availableCamera() async {
    _cameras = await availableCameras();
  }

  bool isInitialized() {
    return _controller.value.isInitialized;
  }
  void changeCameraLens(BuildContext context) {
    final CameraLensDirection lensDirection = _controller.description.lensDirection;
    CameraDescription? newDescription;
    if(lensDirection == CameraLensDirection.front) {
      newDescription = _cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.front);
    }

    _setCameras(context, newDescription);
    _handleOnPressed();
  }

  Widget cameraWidget(context) {
    var camera = _controller.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller),
      ),
    );
  }

  void initState(BuildContext context, TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: vsync,
    );
    _setCameras(context, _cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.front));
    notifyListeners();
  }

  void disposed() {
    _animationController.dispose();
    _controller.dispose();
    notifyListeners();
  }

  Animation<double> getTween() {
    return Tween(begin: 0.0, end: 0.5).animate(_animationController);
  }
  void _handleOnPressed() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _setCameras(BuildContext context, CameraDescription cameraDescription) {
    _controller = CameraController(cameraDescription, ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!context.mounted) {
        return;
      }
      notifyListeners();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

   void showCameraDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shadowColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const CameraScreen(),
        );
      },
    );
  }


}