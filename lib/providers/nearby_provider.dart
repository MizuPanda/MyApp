import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/models/friend_request.dart';

import '../models/friendships.dart';
import '../models/myuser.dart';

class NearbyProvider extends ChangeNotifier {
  final _ble = FlutterReactiveBle();
  final _scannedDevices = <ScannedDevice>[];
  static const app = "myapp0";
  static const taken = 'TAKEN';
  static const chosen = 'CHOSEN:';
  bool _isAwaitingPairing = false;
  static ScannedDevice? _lastDevice;
  static bool _userPaired = false;
  static bool _friendPaired = false;
  late StreamSubscription<DocumentSnapshot> _userStream;
  late StreamSubscription<DocumentSnapshot> _friendStream;

  NearbyProvider() {
    FriendRequest.removeFriendRequest();
  }

  bool isAwaitingPairing() {
    return _isAwaitingPairing;
  }

  void _setAwaitingPairing(bool boolean) {
    _isAwaitingPairing = boolean;
    notifyListeners();
  }

  String _getAppCode() {
    String base = '';
    for (int i = 0; i < app.length; i++) {
      base += app.codeUnitAt(i).toString();
    }

    return base;
  }

  String _getAppUuid() {
    String base = _getAppCode();

    String first = '${base.substring(0, 8)}-';
    String middle = '${base.substring(8, 12)}-';
    String last = base.substring(12, 16);

    return first + middle + last;
  }

  StreamSubscription? _scanSubscription;

  String _serviceUuid(int counter) {
    String base = _getAppCode();

    int numberOfZeros = 32 - base.length - counter.toString().length;

    for (int i = 0; i < numberOfZeros; i++) {
      base += '0';
    }

    base += counter.toString();
    String first = '${base.substring(0, 8)}-';
    String second = '${base.substring(8, 12)}-';
    String third = '${base.substring(12, 16)}-';
    String fourth = '${base.substring(16, 20)}-';
    String fifth = base.substring(20, 32);

    return first + second + third + fourth + fifth;
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
    final advertiser = AdvertiseData(serviceUuid: serviceUuid);

// Start advertising the service
    await peripheral.start(advertiseData: advertiser);
  }

  Future<void> startScanning() async {
      await _startAdvertising();
      String appUuid = _getAppUuid();

      if(!arePaired()) {
        _scanSubscription = _ble
            .scanForDevices(
          requireLocationServicesEnabled: true,
          withServices: [],
          scanMode: ScanMode.balanced,
        )
            .listen((scanResult) async {
          if (scanResult.serviceUuids.isNotEmpty) {
            String uuid = scanResult.serviceUuids.first.toString();
            if (uuid.contains(appUuid)) {
              if (_scannedDevices.every((element) =>
              element.device.serviceUuids.first.toString() != uuid)) {
                String string = uuid.substring(19).replaceFirst('-', '');
                int counter = int.parse(string);
                debugPrint('counter is $counter');
                DocumentSnapshot? scannedUserData =
                await MyUser.getUserByCounter(counter);

                if (scannedUserData != null) {
                  ScannedDevice scannedDevice = ScannedDevice(
                      userData: scannedUserData, device: scanResult);
                  if (_scannedDevices.every(
                          (element) =>
                      element.username != scannedDevice.username)) {
                    _scannedDevices.add(scannedDevice);
                    notifyListeners();
                  }
                }
              }
            }
          }
        });
      }
    if (_scanSubscription != null) {
      await Future.delayed(const Duration(seconds: 7), () async {
        if (_scanSubscription != null) {
          debugPrint('Timeout');
          _scanSubscription?.cancel();
          _scanSubscription = null;
          final peripheral = FlutterBlePeripheral();
          peripheral.stop();

          await startScanning();
        }
      });
    }
  }

  void stopScanning() async {
    _scannedDevices.clear();

    await _scanSubscription?.cancel();
    _scanSubscription = null;
    final peripheral = FlutterBlePeripheral();
    await peripheral.stop();
    notifyListeners();
    if (_isAwaitingPairing && _lastDevice != null) {
      FriendRequest.removeFriendRequest();
      _lastDevice = null;
      _setAwaitingPairing(false);
      _userPaired = false;
      _friendPaired = false;
      await _friendStream.cancel();
      await _userStream.cancel();
      notifyListeners();
    }
  }

  Future<void> onTap(int index) async {
    _userPaired = false;
    _friendPaired = false;
    _lastDevice = _scannedDevices[index];
    Friendship.removePictureTaker(_getIds().first + _getIds().last);
    FriendRequest.sendFriendRequest(_lastDevice!.userData.id);
    _setAwaitingPairing(true);
    _awaitPairing();
    _userStream.resume();
    _friendStream.resume();
    notifyListeners();
  }

  bool arePaired() {
    return _userPaired && _friendPaired;
  }

  void _awaitPairing() {
    String friendId = _lastDevice!.userData.id;
    String userId = MyUser.getUser()!.uid;
    debugPrint('first values ${[friendId, userId]}');
    _friendStream = FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .snapshots()
        .listen((snapshot) {
      debugPrint('listening friend with snapshot ${snapshot.data()}');

      if (snapshot.data() != null) {
        String requestId = snapshot.data()!.containsKey('requestId')
            ? snapshot.get('requestId')
            : '';
        if (requestId == userId) {
          _friendPaired = true;
          debugPrint('true friend');
          notifyListeners();
        }
      }
    });
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      debugPrint('listening user with snapshot ${snapshot.data()}');
      if (snapshot.data() != null && _lastDevice != null) {
        String requestId = snapshot.data()!.containsKey('requestId')
            ? snapshot.get('requestId')
            : '';
        if (requestId ==  friendId) {
          _userPaired = true;
          debugPrint('true user');
          notifyListeners();
        }
      }
    });
    notifyListeners();
  }

  Future<void> paired(Function showCamera, Function disposeAll) async {
    debugPrint('Pairing');
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _friendStream.cancel();
    await _userStream.cancel();
    final peripheral = FlutterBlePeripheral();
    await peripheral.stop();
    notifyListeners();
    final String userId =
        MyUser.getUser()!.uid; // replace with the ID of the current user
    DocumentSnapshot docs = await FirebaseFirestore.instance.collection('friendships').doc(_getIds().first + _getIds().last).get();
    String actualTaker = docs.data().toString().contains('pictureTaker')? docs.get('pictureTaker'): '';
    String pictureTaker;
    if(!actualTaker.contains(chosen)) {
      pictureTaker = await _selectPictureTaker();
    } else {
      pictureTaker = actualTaker;
    }

    pictureTaker = pictureTaker.replaceFirst(chosen, '');
    debugPrint(pictureTaker);
    if (pictureTaker == userId) {
      // User is the one taking the picture, prompt them to do so.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showCamera();
      });
    } else {
      // User is waiting for the other user to take the picture.
      _startPictureTakerListener((pictureTaker) {
        if (pictureTaker == userId) {
          // User is the one taking the picture, prompt them to do so.
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            showCamera();
          });
        } else if (pictureTaker == taken) {
          disposeAll();
        }
      });
    }
  }

  static List<String> _getIds() {
    String userId = MyUser.getUser()!.uid;
    String friendId = _lastDevice!.userData.id;
    List<String> usersId = [userId, friendId];
    usersId.sort();

    return usersId;
  }

  static String getFriendshipId() {
    final List<String> ids = _getIds();
    return ids.first + ids.last;
  }

  /// This function randomly selects one of the users to take the picture.
  ///  Returns the user ID of the picture taker.
  Future<String> _selectPictureTaker() async {
    List<String> usersId = _getIds();
    String docId = usersId.first + usersId.last;

    final random = Random();
    final index = random.nextDouble() < 0.5 ? 0 : 1;
    final pictureTaker = usersId[index];
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(docId)
        .update({'pictureTaker': chosen+pictureTaker});
    return pictureTaker;
  }

  /// This function sets up a listener on the "pictureTaker" field in the friendship document.
  /// When the listener is triggered, it checks which user is supposed to take the picture
  /// and prompts them to do so.
  StreamSubscription<DocumentSnapshot> _startPictureTakerListener(
      Function(String) onPictureTakerSelected) {
    String friendshipId = getFriendshipId();

    return FirebaseFirestore.instance
        .collection('friendships')
        .doc(friendshipId)
        .snapshots()
        .listen((snapshot) {
      final pictureTaker = snapshot.data()!.containsKey('pictureTaker')
          ? snapshot.get('pictureTaker')
          : '';
      if (pictureTaker == MyUser.getUser()!.uid) {
        onPictureTakerSelected(friendshipId);
      }
    });
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
    name =
        userData.data().toString().contains('name') ? userData.get('name') : '';
    username = userData.data().toString().contains('username')
        ? userData.get('username')
        : '';
    socialLevel = userData.data().toString().contains('socialLevel')
        ? userData.get('socialLevel')
        : 0;
    List<dynamic> friendsId = userData.data().toString().contains('friends')
        ? userData.get('friends')
        : List.empty();
    alreadyFriend = false;
    for (String id in friendsId) {
      if (MyUser.getUser()!.uid.toString() == id) {
        alreadyFriend = true;
        break;
      }
    }
  }
}
