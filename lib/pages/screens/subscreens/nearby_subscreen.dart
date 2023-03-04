import 'package:flutter/material.dart';

import '../../../providers/nearby_provider.dart';
import '../../../widgets/charging_bolt.dart';
import '../../../widgets/progress_indactor.dart';

class NearbyDevicesList extends StatefulWidget {
  final VoidCallback disposeSuper;
  const NearbyDevicesList({required this.disposeSuper,super.key});

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
          if(!_provider.isAwaitingPairing) {
            if(_provider.length() == 0) {
              return const MyCircularProgress();
            } else {
              return ListView.builder(
                itemCount: _provider.length(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.bluetooth_rounded),
                    title: Text(_provider.username(index)),
                    subtitle: Text(_provider.isFriend(index)
                        ? "Your Friend"
                        : "Not Friend"),
                    trailing: Text('S.LVL ${_provider.socialLevel(index)}'),
                    onTap: () {
                      _provider.onTap(index, context);
                    },
                  );
                },
              );
            }
          } else {
            return FutureBuilder(
                future: _provider.awaitPairing(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(!snapshot.hasData) {
                  } else if (!snapshot.data) {
                    _provider.awaitPairing();
                  } else {
                    _provider.acceptPairing();
                    widget.disposeSuper;
                  }

                  return const ChargingBolt(height: 100, width: 100);
                }
            );
          }
        },
      ),
    );
  }
}
