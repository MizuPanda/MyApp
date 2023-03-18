import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:myapp/models/user_data.dart';
import 'package:myapp/models/uuid_service.dart';

import 'myuser.dart';

class Bluetooth {
  static Future<void> startAdvertising(String typeConstant) async {
    final peripheral = FlutterBlePeripheral();
    final Player player = await MyUser.getInstance();

// Create a custom AdvertiseData
    String serviceUuid = UuidService.serviceUuid(player.counter, typeConstant);

    debugPrint("uuid: $serviceUuid");
    final advertiser = AdvertiseData(serviceUuid: serviceUuid);

// Start advertising the service
    await peripheral.start(advertiseData: advertiser);
  }

  static StreamSubscription? _scanSubscription;
  static final FlutterReactiveBle _ble = FlutterReactiveBle();

  static Future<void> startScanning(
      String typeConstant,
      List<BluetoothDevice> devices,
      Future<BluetoothDevice> Function(DocumentSnapshot, DiscoveredDevice)
          newDevice,
      Function notifyListeners,
      {bool? advertise}) async {
    if (advertise != null && advertise) {
      await Bluetooth.startAdvertising(typeConstant);
    }
    String appUuid = UuidService.getAppUuid(typeConstant);
    debugPrint(appUuid);
    _scanSubscription = _ble
        .scanForDevices(
      requireLocationServicesEnabled: true,
      withServices: [],
      scanMode: ScanMode.lowLatency,
    )
        .listen((scanResult) async {
      if (scanResult.serviceUuids.isNotEmpty) {
        String uuid = scanResult.serviceUuids.first.toString();
        if (uuid.contains(appUuid)) {
          if (devices.every((element) =>
              element.device.serviceUuids.first.toString() != uuid)) {
            String string = uuid.substring(19).replaceFirst('-', '');
            int counter = int.parse(string);
            debugPrint('counter is $counter');
            DocumentSnapshot? scannedUserData =
                await UserData.getData(counter: counter);

            BluetoothDevice device =
                await newDevice(scannedUserData, scanResult);
            await device.awaitDevice();

            if (devices
                .every((element) => element.username != device.username)) {
              devices.add(device);
              notifyListeners();
            }
          }
        }
      }
    });
    if (_scanSubscription != null) {
      await Future.delayed(const Duration(seconds: 7), () async {
        if (_scanSubscription != null) {
          debugPrint('Timeout');
          _scanSubscription?.cancel();
          _scanSubscription = null;
          if (advertise != null && advertise) {
            await Bluetooth.stopAdvertising();
          }

          await startScanning(typeConstant, devices, newDevice, notifyListeners,
              advertise: advertise);
        }
      });
    }
  }

  ///Cancel the scan. If no device is specified, then it doesn't clear.
  static Future<void> cancelStream({List<BluetoothDevice>? devices}) async {
    if (devices != null) {
      devices.clear();
    }
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  static Future<void> stopAdvertising() async {
    final peripheral = FlutterBlePeripheral();
    await peripheral.stop();
  }
}

class BluetoothDevice extends ConnectedUser {
  DiscoveredDevice device;

  BluetoothDevice({required super.data, required this.device});

  Future<void> awaitDevice() async {}
}

class ConnectedUser {
  DocumentSnapshot data;
  late String username;
  late String name;
  late ImageProvider avatar;

  ConnectedUser({required this.data}) {
    username =
        data.data().toString().contains('username') ? data.get('username') : '';
    name = data.data().toString().contains('name') ? data.get('name') : '';
    avatar = const NetworkImage('https://picsum.photos/200');
  }
}
