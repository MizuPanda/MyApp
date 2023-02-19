import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class NearbyProvider extends ChangeNotifier {
  final _ble = FlutterReactiveBle();
  final _scanResults = <DiscoveredDevice>[];
  StreamSubscription? _scanSubscription;

  int length() {
    return _scanResults.length;
  }

  DiscoveredDevice device(int index) {
    return _scanResults[index];
  }

  void onTap(int index) {
    DiscoveredDevice device = _scanResults[index];
    // Inside the onTap function of your list item:
    _ble.connectToAdvertisingDevice(
      id: device.id,
      withServices: [],
      connectionTimeout: const Duration(seconds:  2),
      prescanDuration: const Duration(seconds: 5),
    ).listen((connection) {
      if (connection.connectionState == DeviceConnectionState.connected) {
        // The device is now connected, you can proceed with sending data to it
        // or do other operations as needed.
        // ...
        debugPrint(connection.connectionState.name);
      } else if (connection.connectionState == DeviceConnectionState.disconnected) {
        // The device has been disconnected. You may want to show a message
        // to the user or attempt to reconnect.
        // ...
      }
    }
    );

  }

  void startScanning() {
    debugPrint('Start scanning: ${_ble.status}');
    _scanSubscription = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((scanResult) {
      if (_scanResults.every((element) => element.id != scanResult.id)) {
        if(scanResult.name.isNotEmpty) {
            _scanResults.add(scanResult);
            notifyListeners();
        }
      }
    });
  }

  void stopScanning() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }
}