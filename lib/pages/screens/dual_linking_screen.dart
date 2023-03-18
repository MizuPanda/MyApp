import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/pages/screens/subscreens/nearby_palace_subscreen.dart';
import 'package:myapp/pages/screens/subscreens/palace_host_subscreen.dart';
import 'package:myapp/providers/dual_provider.dart';
import 'package:myapp/widgets/buttons.dart';

class DualLinkingScreen extends StatefulWidget {
  const DualLinkingScreen({Key? key}) : super(key: key);

  @override
  State<DualLinkingScreen> createState() => _DualLinkingScreenState();
}

class _DualLinkingScreenState extends State<DualLinkingScreen> {
  @override
  void dispose() {
    _provider.setStateSelect();
    super.dispose();
  }

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  final DualProvider _provider = DualProvider();

  @override
  Widget build(BuildContext context) {
    _peripheral.enableBluetooth(askUser: false);
    return Container(
      height: 400.0,
      width: 300.0,
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder(
          future: _peripheral.enableBluetooth(askUser: true),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return AnimatedBuilder(
                animation: _provider,
                builder: (BuildContext context, Widget? child) {
                  switch (_provider.getState()) {
                    case Selection.select:
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            const Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  'Actions',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                )),
                            Center(
                              child: SizedBox(
                                height: 90,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const Text(
                                          'My Palace',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        RectangleButton(
                                          onPressed: () =>
                                              _provider.setStateHost(context),
                                          icon: const Icon(
                                            Icons.house_rounded,
                                            size: 30,
                                            color: Colors.blue,
                                          ),
                                          color: Colors.blue,
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text('Join',
                                            style:
                                                TextStyle(color: Colors.red)),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        RectangleButton(
                                          onPressed: _provider.setStateJoiner,
                                          icon: const Icon(
                                            Icons.sensor_door_rounded,
                                            size: 30,
                                            color: Colors.red,
                                          ),
                                          color: Colors.red,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    case Selection.host:
                      return PalaceHostSubScreen(
                        back: _provider.setStateSelect,
                      );
                    case Selection.joiner:
                      return NearbyPalaceSubScreen(
                          back: _provider.setStateSelect);
                  }
                },
              );
            } else {
              return Center(
                child: TextButton(
                    onPressed: () {
                      _peripheral.enableBluetooth(askUser: true);
                    },
                    child: const Text('Active the bluetooth')),
              );
            }
          }),
    );
  }
}

class BackArrow extends StatefulWidget {
  final Function back;
  const BackArrow({Key? key, required this.back}) : super(key: key);

  @override
  State<BackArrow> createState() => _BackArrowState();
}

class _BackArrowState extends State<BackArrow> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => widget.back(), icon: const Icon(Icons.arrow_back));
  }
}
