import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bluetooth.dart';
import '../models/myuser.dart';

class DualProvider extends ChangeNotifier {
  static Selection _state = Selection.select;
  static const String _typeConstant = '1';

  static final DualProvider _dualProvider = DualProvider._internal();

  //region Singleton
  DualProvider._internal() {
    _state = Selection.select;
    notifyListeners();
  }

  factory DualProvider() {
    return _dualProvider;
  }
  //endregion

  Selection getState() {
    return _state;
  }

  void _setNewState(Selection selection) {
    _state = selection;
    notifyListeners();
  }

  Future<void> setStateHost() async {
    String palaceName = await getPalaceName();
    if (palaceName.isNotEmpty) {
      await _startAdvertisingHost();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(MyUser.getUser()!.uid)
          .update({'linked': List.empty()});
    }
    _setNewState(Selection.host);
  }

  Future<void> setStateJoiner() async {
    await _startScanning();
    _setNewState(Selection.joiner);
  }

  Future<void> setStateSelect() async {
    switch (_state) {
      case Selection.select:
        // TODO: Handle this case.
        break;
      case Selection.host:
        String palaceName = await getPalaceName();
        if (palaceName.isNotEmpty) {
          await _stopAdvertising();
        }
        break;
      case Selection.joiner:
        await _stopScanning();
        break;
    }
    _setNewState(Selection.select);
  }

  static Future<String> getPalaceName() async {
    Player player = await MyUser.getInstance();
    return player.palaceName;
  }

  //region HOST
  late StreamSubscription<DocumentSnapshot> _connectingStream;
  static List<ConnectedUser> _joiners = [];

  Future<void> _startAdvertisingHost() async {
    await Bluetooth.startAdvertising(_typeConstant);
    _connectingStream = _startListening();
    _connectingStream.resume();
  }

  Future<void> _stopAdvertising() async {
    await Bluetooth.stopAdvertising();
    await _connectingStream.cancel();
    _joiners.clear();
    notifyListeners();
  }

  StreamSubscription<DocumentSnapshot> _startListening() {
    String userId = MyUser.getUser()!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
      List<dynamic> connectedIds = snapshot.data()!.containsKey('linked')
          ? snapshot.get('linked')
          : List.empty();
      List<ConnectedUser> connectedUsers = [];
      for (String id in connectedIds) {
        DocumentSnapshot snapshot = await MyUser.getUserData(id);
        connectedUsers.add(ConnectedUser(data: snapshot));
      }

      _joiners = connectedUsers;
      notifyListeners();
    });
  }

//endregion

  //region JOINER
  final List<_HostDevices> _hosts = [];
  _HostDevices? _selectedHost;

  Future<void> _startScanning() async {
    Bluetooth.startScanning(_typeConstant, _hosts, (snapshot, device) async {
      /* THIS IS ON TAP AND DEFINE SELECTED HOST
      --> THEN HE JOINS THE LIST, MAYBE I CAN SHOW DIRECTLY THE CHARGING CLOUD ANIMATION
      await FirebaseFirestore.instance
          .collection('users')
          .doc(snapshot.id)
          .update({
        'linked': FieldValue.arrayUnion([MyUser.getUser()!.uid])
      });*/
      return _HostDevices(data: snapshot, device: device);
    }, notifyListeners);
  }

  Future<void> _stopScanning() async {
    await Bluetooth.cancelStream(devices: _hosts);


    if(_selectedHost != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedHost!.data.id)
          .update({
        'linked': FieldValue.arrayRemove([MyUser.getUser()!.uid])
      });
    }
    notifyListeners();
  }

  //endregion

  //region Data
  int length() {
    if(_state == Selection.host) {
      return _joiners.length;
    } else {
      return _hosts.length;
    }
  }
  String palace(int index) {
    return _hosts[index].palace;
  }
  String name(int index) {
    if(_state == Selection.host) {
      return _joiners[index].name;
    } else {
      return _hosts[index].name;
    }
  }
  String username(int index) {
    if(_state == Selection.host) {
      return _joiners[index].username;
    } else {
      return _hosts[index].username;
    }
  }
  ImageProvider avatar(int index) {
    if(_state == Selection.host) {
      return _joiners[index].avatar;
    } else {
      return _hosts[index].avatar;
    }
  }
  String power(int index) {
    String formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: 1,
      symbol: ''
    ).format(_hosts[index].power);

    return 'SP~$formattedNumber';
  }
//endregion
}

enum Selection { select, host, joiner }

class _HostDevices extends BluetoothDevice {
  late String palace;
  late double power;

  _HostDevices({
    required super.data,
    required super.device,
  }) {
    palace = data.data().toString().contains('palaceName')
        ? data.get('palaceName')
        : '';
    power = data.data().toString().contains('power') ? data.get('power') : 0;
  }
}
