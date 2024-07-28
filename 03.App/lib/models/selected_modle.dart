import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class SelectDevice extends ChangeNotifier {
  late BluetoothCharacteristic? bluetoothCharacteristic;
  late BluetoothDevice bluetoothDevice;
  void setDevice(BluetoothDevice device) {
    bluetoothDevice = device;
    notifyListeners();
  }

  void setCharacter(BluetoothCharacteristic? ch) {
    bluetoothCharacteristic = ch;
    notifyListeners();
  }
}
