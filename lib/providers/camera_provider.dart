import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:myapp/models/friend_request.dart';
import 'package:myapp/providers/friends_provider.dart';
import 'package:myapp/providers/nearby_provider.dart';
import 'package:photo_view/photo_view.dart';

import 'dart:io' show File, Platform;


class CameraProvider extends ChangeNotifier {
  static late List<CameraDescription> _cameras;
  late CameraController _controller;
  late AnimationController _animationController;
  late FlashState _flashState = FlashState.off;
  static XFile? _lastFile;

  IconData data = Icons.flash_off_rounded;

  Future<void> skip(DateTime dateTime, Function disposeAll) async {
    await FriendRequest.accomplishLinking(dateTime);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      disposeAll();
    });

    FriendProvider().refresh();
    notifyListeners();
  }

  Future<File> _changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }

  Future<void> _downloadFile(String friendshipId, DateTime dateTime) async {
    File? file = File(_lastFile!.path);
    file =  await _changeFileNameOnly(file, dateTime.toUtc().toString());
    file = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path,
      quality: 85,
    );

    try {
      final fileName = file!.path.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child('friendships/$friendshipId/$fileName');
      final uploadTask = storageRef.putFile(file);
      await uploadTask.whenComplete(() => debugPrint('Picture uploaded to Firebase Storage'));
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  Future<void> next(Function disposeAll) async {
    DateTime dateTime = DateTime.now().toUtc();
    String friendshipId = NearbyProvider.getFriendshipId();
    //ADD FILE TO STORAGE
    await _downloadFile(friendshipId, dateTime);
    await skip(dateTime, disposeAll);
  }

  void changeFlashState() {
    switch (_flashState) {
      case FlashState.on:
        _flashState = FlashState.off;
        data = Icons.flash_off_rounded;
        _controller.setFlashMode(FlashMode.off);
        break;
      case FlashState.off:
        _flashState = FlashState.automatic;
        data = Icons.flash_auto_rounded;
        _controller.setFlashMode(FlashMode.auto);
        break;
      case FlashState.automatic:
        _flashState = FlashState.on;
        data = Icons.flash_on_rounded;
        _controller.setFlashMode(FlashMode.always);
        break;
    }
    notifyListeners();
  }

  static Future<void> availableCamera() async {
    _cameras = await availableCameras();
  }

  bool isInitialized() {
    return _controller.value.isInitialized;
  }

  Future<void> deleteFile(Function push) async {
    File file = File(_lastFile!.path);
    await file.delete();
    push();
  }

  XFile? getLastFile() {
    return _lastFile;
  }

  Widget renderPicture() {
    debugPrint('Path is ${_lastFile!.path}');
    return SizedBox(
      height: 200,
      width: 200,
      child: PhotoView(
        backgroundDecoration: const BoxDecoration(
          color: Colors.white,
        ),
        imageProvider: Image.file(File(_lastFile!.path)).image,
      ),
    );
  }

  Future<void> takePicture(Function pop) async {
    try {
      // Check if the controller is initialized.
      if (!_controller.value.isInitialized) {
        throw 'Camera controller is not initialized';
      }

      // Take the picture and save it to the given path.
      XFile xFile = await _controller.takePicture();

      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: xFile.path,
          aspectRatioPresets: [CropAspectRatioPreset.square]);
      if (_flashState == FlashState.on) {
        await _controller.setFlashMode(FlashMode.always);
      }
      _lastFile = XFile(croppedFile!.path);

      notifyListeners();
      pop();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void changeCameraLens(BuildContext context) {
    final CameraLensDirection lensDirection =
        _controller.description.lensDirection;
    CameraDescription? newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
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
    _setCameras(
        context,
        _cameras.firstWhere((description) =>
            description.lensDirection == CameraLensDirection.front));
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
      switch (_flashState) {
        case FlashState.on:
          _controller.setFlashMode(FlashMode.always);
          break;
        case FlashState.off:
          _controller.setFlashMode(FlashMode.off);
          break;
        case FlashState.automatic:
          _controller.setFlashMode(FlashMode.auto);
          break;
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
}

enum FlashState { on, off, automatic }
