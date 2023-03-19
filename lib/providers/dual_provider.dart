import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/bluetooth.dart';
import '../models/myuser.dart';
import '../models/user_data.dart';
import '../pages/screens/camera_screen.dart';
import 'friends_provider.dart';

class DualProvider extends ChangeNotifier {
  static Selection _state = Selection.select;
  static const String _typeConstant = '1';
  static const List<String> linked = ['LINKED'];
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

  Future<void> setStateHost(BuildContext context) async {
    String palaceName = await getPalaceName();
    if (palaceName.isNotEmpty) {
      if (context.mounted) {
        await _startAdvertisingHost(context);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(MyUser.id())
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
        break;
      case Selection.host:
        String palaceName = await getPalaceName();
        if (palaceName.isNotEmpty) {
          await _stopAdvertising();
        }
        break;
      case Selection.joiner:
        if (_selectedHost == null) {
          await _stopScanning();
        } else {
          await _removeLinked();
        }
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

  static List<String> getConnectedIDS() {
    List<String> ids = [];
    for (ConnectedUser connected in _joiners) {
      ids.add(connected.data.id);
    }

    return ids;
  }

  Future<void> _startAdvertisingHost(BuildContext context) async {
    await Bluetooth.startAdvertising(_typeConstant);
    if (context.mounted) {
      _connectingStream = _startListening(context);
    }
    _connectingStream.resume();
  }

  void startLinking(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shadowColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const CameraScreen(
            disableSkip: true,
          ),
        );
      },
    );
  }

  Future<void> deleteUser(int index) async {
    String userId = _joiners[index].data.id;

    _joiners.removeAt(index);
    FirebaseFirestore.instance.collection('users').doc(MyUser.id()).update({
      'linked': FieldValue.arrayRemove([userId])
    });

    notifyListeners();
  }

  Future<void> _stopAdvertising() async {
    await Bluetooth.stopAdvertising();
    await _connectingStream.cancel();
    _joiners.clear();
    notifyListeners();
  }

  StreamSubscription<DocumentSnapshot> _startListening(BuildContext context) {
    String userId = MyUser.id();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
      List<dynamic> connectedIds = snapshot.data()!.containsKey('linked')
          ? snapshot.get('linked')
          : List.empty();
      if (connectedIds.toString() == linked.toString()) {
        await setStateSelect();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(MyUser.id())
            .update({'linked': List.empty()});
        if (context.mounted) {
          context.pop();
          context.pop();
        }

        FriendProvider().refresh();
      } else {
        List<ConnectedUser> connectedUsers = [];
        for (String id in connectedIds) {
          DocumentSnapshot snapshot = await UserData.getData(id: id);
          connectedUsers.add(ConnectedUser(data: snapshot));
        }

        _joiners = connectedUsers;
      }
      notifyListeners();
    });
  }

//endregion

  //region JOINER
  final List<_HostDevices> _hosts = [];
  _HostDevices? _selectedHost;

  List<ConnectedUser>? getConnectedUsers() {
    return _selectedHost?.connectedUsers;
  }

  int hostLength() {
    return _selectedHost!.connectedUsers!.length;
  }

  String hostPalace() {
    return _selectedHost!.palace;
  }

  ImageProvider hostAvatar(int index) {
    return _selectedHost!.connectedUsers![index].avatar;
  }

  String hostName(int index) {
    return _selectedHost!.connectedUsers![index].name;
  }

  String hostUsername(int index) {
    return _selectedHost!.connectedUsers![index].username;
  }

  Future<void> _startScanning() async {
    Bluetooth.startScanning(_typeConstant, _hosts, (snapshot, device) async {
      return _HostDevices(data: snapshot, device: device);
    }, notifyListeners);
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _hostStream;

  Future<StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
      _startListeningHost(BuildContext context) async {
    String hostId = _selectedHost!.data.id;
    ConnectedUser host = ConnectedUser(data: _selectedHost!.data);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(hostId)
        .snapshots()
        .listen((snapshot) async {
      List<dynamic> connectedIds = snapshot.data()!.containsKey('linked')
          ? snapshot.get('linked')
          : List.empty();
      if (connectedIds.toString() == linked.toString()) {
        _state = Selection.select;
        _hosts.clear();
        FriendProvider().refresh();
        if (context.mounted) {
          context.pop();
        }
      } else {
        if (connectedIds.every((id) => id != MyUser.id())) {
          _selectedHost = null;
          await setStateSelect();
        } else {
          List<ConnectedUser> connectedUsers = [host];
          for (String id in connectedIds) {
            DocumentSnapshot snapshot = await UserData.getData(id: id);
            connectedUsers.add(ConnectedUser(data: snapshot));
          }

          _selectedHost?.connectedUsers = connectedUsers;
        }
      }

      notifyListeners();
    });
  }

  Future<void> onTap(int index, BuildContext context) async {
    await Bluetooth.cancelStream();
    _selectedHost = _hosts[index];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_selectedHost!.data.id)
        .update({
      'linked': FieldValue.arrayUnion([MyUser.id()])
    });
    if (context.mounted) {
      _hostStream = await _startListeningHost(context);
    }
    _hostStream!.resume();
    notifyListeners();
  }

  Future<void> _removeLinked() async {
    if (_selectedHost != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedHost!.data.id)
          .update({
        'linked': FieldValue.arrayRemove([MyUser.id()])
      });
    }
    _selectedHost = null;
    if (_hostStream != null) {
      _hostStream!.cancel();
    }
    _hosts.clear();
  }

  Future<void> _stopScanning() async {
    await Bluetooth.cancelStream(devices: _hosts);

    await _removeLinked();
    notifyListeners();
  }

  //endregion

  //region Data
  int length() {
    if (_state == Selection.host) {
      return _joiners.length;
    } else {
      return _hosts.length;
    }
  }

  String palace(int index) {
    return _hosts[index].palace;
  }

  String name(int index) {
    if (_state == Selection.host) {
      return _joiners[index].name;
    } else {
      return _hosts[index].name;
    }
  }

  String username(int index) {
    if (_state == Selection.host) {
      return _joiners[index].username;
    } else {
      return _hosts[index].username;
    }
  }

  ImageProvider avatar(int index) {
    if (_state == Selection.host) {
      return _joiners[index].avatar;
    } else {
      return _hosts[index].avatar;
    }
  }

  String power(int index) {
    String formattedNumber =
        NumberFormat.compactCurrency(decimalDigits: 1, symbol: '')
            .format(_hosts[index].power);

    return 'SP~$formattedNumber';
  }
//endregion
}

enum Selection { select, host, joiner }

class _HostDevices extends BluetoothDevice {
  late String palace;
  late double power;
  List<ConnectedUser>? connectedUsers;

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
