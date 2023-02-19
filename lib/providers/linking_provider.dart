import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

class LinkingProvider extends ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  void enableBluetooth() {
    BluetoothEnable.enableBluetooth.then((result) {
      if (result == "true") {
          flutterBlue = flutterBlue;
          notifyListeners();
      } else if (result == "false") {
        // Bluetooth has not been enabled
      }
    });
  }
}
