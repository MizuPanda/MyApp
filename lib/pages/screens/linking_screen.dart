
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/pages/screens/subscreens/nearby_subscreen.dart';
import 'package:myapp/providers/nearby_provider.dart';
import 'package:myapp/widgets/progress_indactor.dart';


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

  String _title = 'Nearby Users';
  void _refreshTitle() {
    setState(() {
      _title = _nearbyProvider.isAwaitingPairing()? 'Nearby Users': 'Linking...';
    });
  }
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

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
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:  <Widget>[
                  Text(_title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  NearbyDevicesList(disposeSuper: dispose, notifyParent: _refreshTitle,),
                  const SizedBox(height: 20.0),
                  // Add your linking form widgets here
                ],
              );
            } else {
              return const MyCircularProgress();
            }
          }),
    );
  }
}


