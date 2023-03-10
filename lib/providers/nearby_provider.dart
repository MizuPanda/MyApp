import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/models/friend_request.dart';

import '../models/myuser.dart';


class NearbyProvider extends ChangeNotifier {
  final _ble = FlutterReactiveBle();
  final _scannedDevices = <ScannedDevice>[];
  final app = "myapp0";
  bool _isAwaitingPairing = false;
  ScannedDevice? _lastDevice;

  bool isAwaitingPairing() {
    return _isAwaitingPairing;
  }
  void _setAwaitingPairing(bool boolean) {
    _isAwaitingPairing = boolean;
    notifyListeners();
  }
  String _getAppCode() {
    String base = '';
    for(int i = 0; i < app.length; i++) {
      base+=app.codeUnitAt(i).toString();
    }

    return base;
  }

  String _getAppUuid() {
    String base = _getAppCode();

    String first = '${base.substring(0,8)}-';
    String middle = '${base.substring(8, 12)}-';
    String last = base.substring(12,16);


    return first+middle+last;
  }


  StreamSubscription? _scanSubscription;

  String _serviceUuid(int counter) {
    String base = _getAppCode();

    int numberOfZeros = 32 - base.length - counter.toString().length;

    for(int i = 0; i<numberOfZeros; i++) {
      base += '0';
    }

    base += counter.toString();
    String first = '${base.substring(0, 8)}-';
    String second = '${base.substring(8, 12)}-';
    String third = '${base.substring(12, 16)}-';
    String fourth = '${base.substring(16, 20)}-';
    String fifth = base.substring(20, 32);

    return first+second+third+fourth+fifth;
  }

  String name(int index) {
    return _scannedDevices[index].name;
  }
  String username(int index) {
    return _scannedDevices[index].username;
  }
  int socialLevel(int index) {
    return _scannedDevices[index].socialLevel;
  }
  bool isFriend(int index) {
    return _scannedDevices[index].alreadyFriend;
  }
  int length() {
    return _scannedDevices.length;
  }

  Future<void> _startAdvertising() async {
    final peripheral = FlutterBlePeripheral();
    final Player player = await MyUser.getInstance();

// Create a custom AdvertiseData
    String serviceUuid = _serviceUuid(player.counter);

    debugPrint("uuid: $serviceUuid");
    final advertiser = AdvertiseData(
      serviceUuid: serviceUuid
    );

// Start advertising the service
    await peripheral.start(advertiseData: advertiser);
  }

  Future<void> continueScanning() async {
  }

  Future<void> startScanning() async {
    await _startAdvertising();
    String appUuid = _getAppUuid();

    _scanSubscription = _ble.scanForDevices(
      requireLocationServicesEnabled: true,
      withServices: [],
      scanMode: ScanMode.balanced,
    ).listen((scanResult) async {
       // debugPrint('name: ${scanResult.name}');
        //debugPrint('uuid: ${scanResult.serviceUuids}');
        if(scanResult.serviceUuids.isNotEmpty) {
         // debugPrint('uuid: ${scanResult.serviceUuids}');

          String uuid = scanResult.serviceUuids.first.toString();
          if(uuid.contains(appUuid)) {
            if(_scannedDevices.every((element) => element.device.serviceUuids.first.toString() != uuid)) {
              String string = uuid.substring(19).replaceFirst('-', '');
              int counter = int.parse(string);
              debugPrint('counter is $counter');
              DocumentSnapshot? scannedUserData = await MyUser.getUserByCounter(
                  counter);

              if (scannedUserData != null) {
                ScannedDevice scannedDevice = ScannedDevice(
                    userData: scannedUserData, device: scanResult);
                if(_scannedDevices.every((element) => element.username != scannedDevice.username)) {
                  _scannedDevices.add(scannedDevice);
                  notifyListeners();
                }
              }
            }
          }
        }
    }
    );
      await Future.delayed(const Duration(seconds: 7), () {
        if (_scanSubscription != null) {
          debugPrint('Timeout');
          _scanSubscription?.cancel();
          _scanSubscription = null;
          final peripheral = FlutterBlePeripheral();
          peripheral.stop();

          startScanning();
        }
      }
      );

  }

  void stopScanning() {
    _scannedDevices.clear();

    _scanSubscription?.cancel();
    _scanSubscription = null;
    final peripheral = FlutterBlePeripheral();
    peripheral.stop();
    notifyListeners();
    if(_isAwaitingPairing && _lastDevice != null) {
      FriendRequest.removeFriendRequest();
      _lastDevice = null;
      _setAwaitingPairing(false);
      notifyListeners();
    }
  }


  Future<void> onTap(int index, BuildContext context) async {
    _lastDevice = _scannedDevices[index];
    String friendUsername = _lastDevice!.username;
    FriendRequest.sendFriendRequest(friendUsername);
    _setAwaitingPairing(true);
    notifyListeners();
  }

  Future<bool> awaitPairing() async {
    String friendUsername = _lastDevice!.username;

    return FriendRequest.verifyRequestId(friendUsername);
  }

  void acceptPairing() async {
    String friendUsername = _lastDevice!.username;
    await FriendRequest.acceptFriendRequest(friendUsername);
  }

}

class ScannedDevice {
  DocumentSnapshot userData;
  DiscoveredDevice device;

  late String name;
  late String username;
  late int socialLevel;
  late bool alreadyFriend;

  ScannedDevice({required this.userData, required this.device}) {
    name = userData.data().toString().contains('name') ? userData.get('name') : '';
    username = userData.data().toString().contains('username') ? userData.get('username') : '';
    socialLevel = userData.data().toString().contains('socialLevel') ? userData.get('socialLevel') : 0;
    List<dynamic> friendsId = userData.data().toString().contains('friends') ? userData.get('friends') : List.empty();
    alreadyFriend = false;
    for(String id in friendsId) {
      if(MyUser.getUser()!.uid.toString() == id) {
        alreadyFriend = true;
        break;
      }
    }
  }
}