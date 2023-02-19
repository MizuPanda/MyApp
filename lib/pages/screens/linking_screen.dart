
import 'package:flutter/material.dart';
import 'package:myapp/providers/linking_provider.dart';
import 'package:myapp/providers/nearby_provider.dart';

class LinkingScreen extends StatefulWidget {
  const LinkingScreen({Key? key}) : super(key: key);

  @override
  State<LinkingScreen> createState() => _LinkingScreenState();
}

class _LinkingScreenState extends State<LinkingScreen> {
  final LinkingProvider _provider = LinkingProvider();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (BuildContext context, Widget? child) {
        return Container(
          height: 400.0,
          width: 300.0,
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
              future: _provider.flutterBlue.isOn,
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
                  return Center(
                    child: TextButton(
                      onPressed: _provider.enableBluetooth,
                      child: const Text("Connect to Bluetooth"),
                    ),
                  );
                }
              }),
        );
      },
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
              final device = _provider.device(index);
              return ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(device.name),
                subtitle: Text(device.id),
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
