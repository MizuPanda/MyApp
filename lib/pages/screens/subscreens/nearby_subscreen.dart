import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/nearby_provider.dart';
import '../../../widgets/charging_bolt.dart';
import '../../../widgets/progress_indactor.dart';
import '../camera_screen.dart';

class NearbyDevicesList extends StatefulWidget {
  final VoidCallback disposeSuper;
  final Function notifyParent;

  const NearbyDevicesList({required this.disposeSuper,super.key, required this.notifyParent});

  @override
  State<NearbyDevicesList> createState() => _NearbyDevicesListState();
}

class _NearbyDevicesListState extends State<NearbyDevicesList> {
  final NearbyProvider _provider = NearbyProvider();
  bool notified = false;
  bool first = true;

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
    void showCamera() {
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
    void dispose(){
      context.pop();
    }

    return SizedBox(
      width: 300.0,
      height: 300.0,
      child:  AnimatedBuilder(
        animation: _provider,
        builder: (BuildContext context, Widget? child) {
          if(!_provider.isAwaitingPairing()) {
            if(_provider.length() == 0) {
              return const MyCircularProgress();
            } else {
              return ListView.builder(
                itemCount: _provider.length(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/200')),
                    title: Text(_provider.username(index)),
                    subtitle: Text(_provider.isFriend(index)
                        ? "Your Friend"
                        : "Not Friend"),
                    trailing: Text('S.LVL ${_provider.socialLevel(index)}'),
                    onTap: () {
                      _provider.onTap(index);
                    },
                  );
                },
              );
            }
          } else {
            if(!notified) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                widget.notifyParent();
              });
              notified = true;
            }

            if(_provider.arePaired() && first) {
              _provider.paired(showCamera,dispose);
              first = false;
            }

            return const ChargingBolt();
           /* return FutureBuilder(
                future: _provider.awaitPairing(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(!snapshot.hasData) {
                  } else if (!snapshot.data) {
                    _provider.awaitPairing();
                  } else {
                    _provider.acceptPairing();
                    widget.disposeSuper();
                  }

                  return const ChargingBolt();
                }
            );*/
          }
        },
      ),
    );
  }
}


