import 'package:flutter/material.dart';
import 'package:myapp/widgets/round_buttons.dart';

import '../providers/camera_provider.dart';
import '../widgets/progress_indactor.dart';

class CameraPage extends StatefulWidget {
  /// Default Constructor
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  final CameraProvider _provider = CameraProvider();

  @override
  void initState() {
    super.initState();
    _provider.initState(context, this);
  }

  @override
  void dispose() {
    _provider.disposed();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    void pop() {
       Navigator.of(context).pop();
    }

    return AnimatedBuilder(
      animation: _provider,
      builder: (BuildContext context, Widget? child) {
        if (!_provider.isInitialized()) {
          return Container(
            color: Colors.white,
            child: const MyCircularProgress(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Add a picture to this Memory'),
          ),
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: const BottomAppBar(color: Colors.black, height: 60, child: Center(child: Text('Take a picture!', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, color: Colors.white),)),),
          body: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(child: _provider.cameraWidget(context)),
                  SizedBox(
                    height: 135,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RotationTransition(
                          turns: _provider.getTween(),
                          child: RoundButton(
                            size: 50,
                            icon: Icons.autorenew_rounded,
                            colorUnpressed: Colors.white,
                            onPressed: () {
                              _provider.changeCameraLens(context);
                            },
                          ),
                        ),
                        RoundButton(
                          icon: _provider.data,
                          onPressed: _provider.changeFlashState,
                          size: 50,
                          colorUnpressed: Colors.white,
                          borderColor: Colors.transparent,
                        ),
                        RoundButton(
                            size: 50,
                            icon: Icons.circle_rounded,
                            shouldGrow: true,
                            colorUnpressed: Colors.white,
                            colorPressed: Colors.pink.withOpacity(0.7),
                            onPressed: () {
                              _provider.takePicture(pop);
                            }),
                      ],
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
