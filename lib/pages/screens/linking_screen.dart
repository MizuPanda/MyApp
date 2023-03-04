
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/pages/screens/subscreens/nearby_subscreen.dart';
import 'package:myapp/providers/nearby_provider.dart';


class LinkingScreen extends StatefulWidget {
  const LinkingScreen({Key? key}) : super(key: key);

  @override
  State<LinkingScreen> createState() => _LinkingScreenState();
}

class _LinkingScreenState extends State<LinkingScreen> {
  @override
  void dispose() {
      super.dispose();
  }

  final NearbyProvider _nearbyProvider = NearbyProvider();
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.0,
      width: 300.0,
      padding: const EdgeInsets.all(20.0),
      child: AnimatedBuilder(
        animation: _nearbyProvider,
        builder: (BuildContext context, Widget? widget) {
          return FutureBuilder(
              future: _peripheral.enableBluetooth(askUser: false),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:  <Widget>[
                      Text(!_nearbyProvider.isAwaitingPairing ?
                      'Nearby Users' : "Linking...",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      NearbyDevicesList(disposeSuper: dispose,),
                      const SizedBox(height: 20.0),
                      // Add your linking form widgets here
                    ],
                  );
                } else {
                  return Center(
                    child: ElevatedButton(onPressed: () {
                      _peripheral.enableBluetooth(askUser: true);
                    }, child: const Text("Activate bluetooth")),
                  );
                }
              });
        },
      ),
    );
  }
}


