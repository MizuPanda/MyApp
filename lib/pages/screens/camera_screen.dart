import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/providers/camera_provider.dart';
import 'package:myapp/widgets/buttons.dart';
import 'package:photo_view/photo_view.dart';

import '../../providers/nearby_provider.dart';

class CameraScreen extends StatefulWidget {
  final bool? disableSkip;
  const CameraScreen({Key? key, this.disableSkip}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraProvider _provider = CameraProvider();

  @override
  void dispose() async {
    super.dispose();
    if (!_provider.successful && NearbyProvider.doesLastDeviceExist()) {
      await _provider.setPictureAbandoned();
    }
    _provider.resetPicture();
  }

  @override
  void initState() {
    _provider.successful = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void push() {
      context.push('/camera');
    }

    return Container(
        height: 400.0,
        width: 300.0,
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              children: [
                const Text('Your turn!'),
                const Padding(padding: EdgeInsets.all(8)),
                const Text("Memorize this moment!"),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: (widget.disableSkip != null &&
                                    widget.disableSkip!)
                                ? null
                                : () {
                                    _provider.skip(DateTime.now().toUtc());
                                  },
                            child: const Text('Skip')),
                        TextButton(
                            onPressed: (_provider.getLastFile() == null)
                                ? null
                                : () async {
                                    await _provider.next(
                                        isDualLink: widget.disableSkip);
                                  },
                            child: const Text('Continue'))
                      ],
                    ),
                  ),
                )
              ],
            ),
            AnimatedBuilder(
                animation: _provider,
                builder: (BuildContext context, Widget? child) {
                  if (_provider.getLastFile() == null) {
                    return Center(
                        child: RectangleButton(
                      onPressed: push,
                      icon: const Icon(
                        Icons.add_a_photo_rounded,
                        size: 30,
                      ),
                      color: Colors.black,
                    ));
                  } else {
                    return Center(
                      child: Container(
                        width: 230,
                        height: 230,
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                offset: Offset(0.5, 1),
                                blurRadius: 1)
                          ],
                        ),
                        child: ClipRect(
                          child: Stack(
                            children: [
                              PhotoView(
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                imageProvider: Image.file(
                                        File(_provider.getLastFile()!.path))
                                    .image,
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black),
                                      child: IconButton(
                                          onPressed: () async {
                                            await _provider.deleteFile(push);
                                          },
                                          icon: const Icon(
                                            Icons.add_a_photo_rounded,
                                            color: Colors.white,
                                          ))))
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                })
          ],
        ));
  }
}
