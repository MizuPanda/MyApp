import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/friend_request.dart';
import 'package:myapp/providers/friends_provider.dart';

import '../models/bluetooth.dart';
import '../models/friendships.dart';
import '../models/myuser.dart';

class NearbyProvider extends ChangeNotifier {
  final _scannedDevices = <_ScannedDevice>[];
  static const _typeConstant = '0';
  static const taken = 'TAKEN';
  static const abandoned = 'ABANDONED';
  bool _isAwaitingPairing = false;
  static _ScannedDevice? _lastDevice;
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

  String username(int index) {
    return _scannedDevices[index].username;
  }

  int socialLevel(int index) {
    return _scannedDevices[index].socialLevel;
  }

  bool isFriend(int index) {
    return _scannedDevices[index].alreadyFriend;
  }

  ImageProvider avatar(int index) {
    return _scannedDevices[index].avatar;
  }

  int length() {
    return _scannedDevices.length;
  }

  static bool doesLastDeviceExist() {
    return _lastDevice != null;
  }

  Future<void> startScanning() async {
    Bluetooth.startScanning(_typeConstant, _scannedDevices,
        (userData, device) async {
      return _ScannedDevice(data: userData, device: device);
    }, notifyListeners, advertise: true);
  }

  Future<void> removePictureTaker() async {
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(getFriendshipId())
        .update({'pictureTaker': ''});
  }

  Future<void> stopScanning() async {
    await Bluetooth.cancelStream(devices: _scannedDevices);
    await Bluetooth.stopAdvertising();

    if (_isAwaitingPairing && _lastDevice != null) {
      FriendRequest.removeFriendRequest();
      _pictureStream.cancel();
      _lastDevice = null;
      _setAwaitingPairing(false);
      _userPaired = false;
      await _userStream.cancel();
      await _pictureStream.cancel();
    }

    notifyListeners();
  }

  Future<void> onTap(int index) async {
    _userPaired = false;
    _lastDevice = _scannedDevices[index];
    await removePictureTaker();
    FriendRequest.sendFriendRequest(_lastDevice!.data.id);
    _setAwaitingPairing(true);
    _awaitPairing();
    _userStream.resume();
    notifyListeners();
  }

  bool arePaired() {
    return _userPaired;
  }

  void _awaitPairing() {
    String friendId = _lastDevice!.data.id;
    String userId = MyUser.id();
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
    await Bluetooth.cancelStream();
    await _userStream.cancel();
    await Bluetooth.stopAdvertising();
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
    String userId = MyUser.id();
    String friendId = _lastDevice!.data.id;
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
      if (pictureTaker == MyUser.id()) {
        debugPrint('Selected!');
        taker = pictureTaker;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          showCamera();
        });
      } else if (pictureTaker == taken || pictureTaker == abandoned) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          dispose();
          if (taker == MyUser.id()) {
            dispose();
          }
          if (pictureTaker == taken) {
            FriendProvider().refresh();
          }
        });
      }
    });
  }
}

class _ScannedDevice extends BluetoothDevice {
  late int socialLevel;
  late bool alreadyFriend;
  final String id = MyUser.id();

  _ScannedDevice({required super.data, required super.device}) {
    List<dynamic> friendsId = data.data().toString().contains('friends')
        ? data.get('friends')
        : List.empty();
    alreadyFriend = !(friendsId.every((friendId) => friendId != id));
  }

  @override
  Future<void> awaitDevice() async {
    if (alreadyFriend) {
      Friendship friendship = Friendship(ids: [id, data.id]);
      await friendship.awaitFriendship();
      socialLevel = friendship.level;
    }
  }
}
