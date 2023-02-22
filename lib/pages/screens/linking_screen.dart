
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/providers/nearby_provider.dart';

class LinkingScreen extends StatefulWidget {
  const LinkingScreen({Key? key}) : super(key: key);

  @override
  State<LinkingScreen> createState() => _LinkingScreenState();
}

class _LinkingScreenState extends State<LinkingScreen> {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.0,
      width: 300.0,
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder(
        future: _peripheral.enableBluetooth(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const <Widget>[
                  Text(
                    'Linking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  NearbyDevicesList(),
                  SizedBox(height: 20.0),
                  // Add your linking form widgets here
                ],
              );
            } else {
              return const SizedBox(width: 20,
                  height: 20,
                  child: Center(child: CircularProgressIndicator())
              );
            }
          }),
    );
  }
}

class NearbyDevicesList extends StatefulWidget {
  const NearbyDevicesList({super.key});

  @override
  State<NearbyDevicesList> createState() => _NearbyDevicesListState();
}

class _NearbyDevicesListState extends State<NearbyDevicesList> {
  final NearbyProvider _provider = NearbyProvider();
  @override
  void initState() {
    super.initState();

    _provider.startScanning();
  }

  @override
  void dispose() {
    _provider.stopScanning();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.0,
      height: 300.0,
      child:  AnimatedBuilder(
        animation: _provider,
        builder: (BuildContext context, Widget? child) {
          return ListView.builder(
            itemCount: _provider.length(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.bluetooth_rounded),
                title: Text(_provider.name(index)),
                subtitle: Column(
                  children: [
                    Text(_provider.username(index)),
                    Text(_provider.isFriend(index)? "Your Friend": "Not Friend")
                  ],
                ),
                trailing: Text('S.LVL ${_provider.socialLevel(index)}'),
                onTap: () {
                  _provider.onTap(index);
                },
              );
            },
          );
        },
      ),
    );
  }
}
