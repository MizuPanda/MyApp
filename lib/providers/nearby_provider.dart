import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/models/friend_request.dart';

import '../models/myuser.dart';


class NearbyProvider extends ChangeNotifier {
  final _ble = FlutterReactiveBle();
  final _scannedDevices = <ScannedDevice>[];
  final app = "myapp0";
  bool isAwaitingPairing = false;
  ScannedDevice? _lastDevice;

  String _getAppCode() {
    String base = '';
    for(int i = 0; i < app.length; i++) {
      base+=app.codeUnitAt(i).toString();
    }

    return base;
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

  void _startAdvertising() async {
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

  void startScanning() {
    _startAdvertising();
    _scanSubscription = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowPower,
    ).listen((scanResult) async {
      if (_scannedDevices.every((element) => element.device.id != scanResult.id)) {
        if(scanResult.serviceUuids.isNotEmpty) {
          String uuid = scanResult.serviceUuids.first.toString();
          if(uuid.contains(_getAppCode())) {
            String string = uuid.substring(19).replaceFirst('-', '');
            int counter = int.parse(string);
            DocumentSnapshot? scannedUserData = await MyUser.getUserByCounter(counter);

            if(scannedUserData != null) {
              ScannedDevice scannedDevice = ScannedDevice(userData: scannedUserData, device: scanResult);
              _scannedDevices.add(scannedDevice);
              notifyListeners();
            }
          }
        }
      }
    });
  }

  void stopScanning() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    final peripheral = FlutterBlePeripheral();
    peripheral.stop();
    if(isAwaitingPairing && _lastDevice != null) {
      FriendRequest.removeFriendRequest();
      _lastDevice = null;
      isAwaitingPairing = false;
      notifyListeners();
    }
  }

  Future<void> onTap(int index) async {
    _lastDevice = _scannedDevices[index];
    String friendUsername = _lastDevice!.username;
    FriendRequest.sendFriendRequest(friendUsername);
    isAwaitingPairing = true;
    notifyListeners();
  }

  Future<bool> awaitPairing() async {
    String friendUsername = _lastDevice!.username;

    return FriendRequest.verifyRequestId(friendUsername);
  }

  void acceptPairing() async {
    await FriendRequest.acceptFriendRequest();
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
    name = userData.get('name');
    username = userData.get('username');
    socialLevel = userData.get('socialLevel');
    List<dynamic> friendsId = userData.get('friends');
    alreadyFriend = false;
    for(int id in friendsId) {
      if(MyUser.getUser()!.uid == id.toString()) {
        alreadyFriend = true;
        break;
      }
    }
  }
}