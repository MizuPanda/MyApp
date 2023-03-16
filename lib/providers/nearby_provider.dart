import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:myapp/models/friend_request.dart';
import 'package:myapp/providers/friends_provider.dart';

import '../models/friendships.dart';
import '../models/myuser.dart';

class NearbyProvider extends ChangeNotifier {
  final _ble = FlutterReactiveBle();
  final _scannedDevices = <ScannedDevice>[];
  static const app = "myapp0";
  static const taken = 'TAKEN';
  static const abandoned = 'ABANDONED';
  bool _isAwaitingPairing = false;
  static ScannedDevice? _lastDevice;
  static bool _userPaired = false;
  late StreamSubscription<DocumentSnapshot> _userStream;
  late StreamSubscription<DocumentSnapshot> _pictureStream;

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

    if (!arePaired()) {
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
                    (element) => element.username != scannedDevice.username)) {
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

  Future<void> removePictureTaker() async {
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(getFriendshipId())
        .update({'pictureTaker': ''});
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
      _pictureStream.cancel();
      _lastDevice = null;
      _setAwaitingPairing(false);
      _userPaired = false;
      await _userStream.cancel();
      await _pictureStream.cancel();
      notifyListeners();
    }
  }

  Future<void> onTap(int index) async {
    _userPaired = false;
    _lastDevice = _scannedDevices[index];
    await removePictureTaker();
    FriendRequest.sendFriendRequest(_lastDevice!.userData.id);
    _setAwaitingPairing(true);
    _awaitPairing();
    _userStream.resume();
    notifyListeners();
  }

  bool arePaired() {
    return _userPaired;
  }

  void _awaitPairing() {
    String friendId = _lastDevice!.userData.id;
    String userId = MyUser.getUser()!.uid;
    debugPrint('first values ${[friendId, userId]}');

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
        if (requestId == friendId) {
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
    await _userStream.cancel();
    final peripheral = FlutterBlePeripheral();
    await peripheral.stop();
    notifyListeners();


    int userIndex = Friendship(ids: _getIds()).userIndex;

    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(getFriendshipId())
        .collection('values')
        .doc('ready')
        .update({'ready$userIndex': true});

    // User is waiting for the other user to take the picture.
    _pictureStream = _startPictureTakerListener(showCamera, disposeAll);

    _pictureStream.resume();
  }

  ///Return a list of the ids of the two users of the current friendship. It sorts automatically the ids in the list.
  static List<String> _getIds() {
    String userId = MyUser.getUser()!.uid;
    String friendId = _lastDevice!.userData.id;
    List<String> usersId = [userId, friendId];
    usersId.sort();

    return usersId;
  }

  ///Return the ID of the friendship associated to the two users.
  static String getFriendshipId() {
    final List<String> ids = _getIds();
    return ids.first + ids.last;
  }

  /// This function sets up a listener on the "pictureTaker"
  /// field in the friendship document.
  /// When the listener is triggered, it checks which user is supposed to take the picture
  /// and prompts them to do so.
  StreamSubscription<DocumentSnapshot> _startPictureTakerListener(
      Function showCamera, Function dispose) {
    String friendshipId = getFriendshipId();

    String? taker;
    return FirebaseFirestore.instance
        .collection('friendships')
        .doc(friendshipId)
        .snapshots()
        .listen((snapshot) {
      final pictureTaker = snapshot.data()!.containsKey('pictureTaker')
          ? snapshot.get('pictureTaker')
          : '';
      debugPrint('PictureTaker is : $pictureTaker');
      if (pictureTaker == MyUser.getUser()!.uid) {
        debugPrint('Selected!');
        taker = pictureTaker;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          showCamera();
        });
      } else if (pictureTaker == taken || pictureTaker == abandoned) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          dispose();
          if (taker == MyUser.getUser()!.uid) {
            dispose();
          }
          if (pictureTaker == taken) {
            await FriendProvider().refresh();
          }
        });
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
