import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import '../widgets/service_tile.dart';
import '../widgets/characteristic_tile.dart';
import '../widgets/descriptor_tile.dart';
import '../utils/snackbar.dart';
import '../utils/extra.dart';
import 'dart:developer';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  final TextEditingController _servo1S = TextEditingController();
  final TextEditingController _servo1E = TextEditingController();

  final TextEditingController _servo2S = TextEditingController();
  final TextEditingController _servo2E = TextEditingController();

  List<String> _degrees = ["0", "0", "0", "0"];
  String _initServo1State = "90";
  String _initServo2State = "0";
  String _cureentServo1Degree = "0";
  String _cureentServo2Degree = "0";

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        onDiscoverServicesPressed();
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });

    _mtuSubscription = widget.device.mtu.listen((value) {
      _mtuSize = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e),
            success: false);
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e),
          success: false);
    }
  }

  Future onDiscoverServicesPressed() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }
    try {
      _services = await widget.device.discoverServices();
      Snackbar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Discover Services Error:", e),
          success: false);
    }
    if (mounted) {
      setState(() {
        _isDiscoveringServices = false;
      });
    }
  }

  Future onRequestMtuPressed() async {
    try {
      await widget.device.requestMtu(223, predelay: 0);
      Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e),
          success: false);
    }
  }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => _buildCharacteristicTile(c))
                .toList(),
          ),
        )
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles:
          c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(),
    );
  }

  Widget buildSpinner(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${widget.device.remoteId}'),
    );
  }

  Widget buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
            style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }

  Widget buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      children: <Widget>[
        TextButton(
          onPressed: onDiscoverServicesPressed,
          child: const Text("Get Services"),
        ),
        const IconButton(
          icon: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(Color.fromARGB(255, 234, 46, 46)),
            ),
          ),
          onPressed: null,
        )
      ],
    );
  }

  Widget buildMtuTile(BuildContext context) {
    return ListTile(
        title: const Text('MTU Size'),
        subtitle: Text('$_mtuSize bytes'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onRequestMtuPressed,
        ));
  }

  Widget buildConnectButton(BuildContext context) {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(context),
      TextButton(
          onPressed: _isConnecting
              ? onCancelPressed
              : (isConnected ? onDisconnectPressed : onConnectPressed),
          child: Text(
            _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge
                ?.copyWith(color: const Color.fromARGB(255, 101, 206, 205)),
          ))
    ]);
  }

  List<Container> buildDisDegree() {
    List<Container> containerList = [];

    for (var i in [0, 1, 2, 3]) {
      final container = Container(
        width: 50, // 每个子组件的宽度为50像素
        height: 50, // 每个子组件的高度为50像素
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
        child: Center(child: Text(_degrees[i])),
      );
      containerList.add(container);
    }

    return containerList;
  }

  BluetoothCharacteristic? foundWriteCharacteristic() {
    for (BluetoothService item in _services) {
      for (BluetoothCharacteristic c in item.characteristics) {
        if (c.characteristicUuid == Guid('ffe1')) {
          return c;
        }
      }
    }
  }

  void getDegrees() {
    for (BluetoothService item in _services) {
      for (BluetoothCharacteristic c in item.characteristics) {
        if (c.characteristicUuid == Guid('ffe1')) {
          var s1_s = _servo1S.text;
          var s1_e = _servo1E.text;

          var s2_s = _servo2S.text;
          var s2_e = _servo2E.text;
          if (s1_s.isNotEmpty && s1_e.isNotEmpty) {
            c.write(utf8.encode("Servo1-$s1_s-$s1_e;"));
          }
          if (s2_s.isNotEmpty && s2_e.isNotEmpty) {
            c.write(utf8.encode("Servo2-$s2_s-$s2_e;"));
          }
        }
      }
    }
    Snackbar.show(ABC.c, "pressed Set", success: true);
  }

  resetServo1() {
    BluetoothCharacteristic? _wServer = foundWriteCharacteristic();

    if (_wServer != null) {
      _wServer.write(
          utf8.encode("Servo1-$_cureentServo1Degree-$_initServo1State;"));
      _cureentServo1Degree = _initServo1State;
    }
  }

  resetServo2() {
    BluetoothCharacteristic? _wServer = foundWriteCharacteristic();

    if (_wServer != null) {
      _wServer.write(
          utf8.encode("Servo2-$_cureentServo2Degree-$_initServo2State;"));
      _cureentServo2Degree = _initServo2State;
    }
  }

  void pressOpenLight1() {
    String s1End = "135";
    BluetoothCharacteristic? _wServer = foundWriteCharacteristic();

    if (_wServer != null) {
      _wServer.write(utf8.encode("Servo1-$_initServo1State-$s1End;"));
      _cureentServo1Degree = s1End;
    }
    resetServo1();
  }

  pressCloseLight1() {
    String s1End = "45";
    BluetoothCharacteristic? _wServer = foundWriteCharacteristic();

    if (_wServer != null) {
      _wServer.write(utf8.encode("Servo1-$_initServo1State-$s1End;"));
      _cureentServo1Degree = s1End;
    }
    resetServo1();
  }

  pressOpenLight2() {
    String s2End = "180";
    BluetoothCharacteristic? _wServer = foundWriteCharacteristic();

    if (_wServer != null) {
      _wServer.write(utf8.encode("Servo2-$_initServo2State-$s2End;"));
      _cureentServo2Degree = s2End;
    }
    pressOpenLight1();
    resetServo2();
  }

  pressCloseLight2() {
    String s2End = "180";
    BluetoothCharacteristic? _wServer = foundWriteCharacteristic();

    if (_wServer != null) {
      _wServer.write(utf8.encode("Servo2-$_initServo2State-$s2End;"));
      _cureentServo2Degree = s2End;
    }
    pressCloseLight1();
    resetServo2();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName),
          actions: [buildConnectButton(context)],
        ),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            buildRemoteId(context),
            ListTile(
              leading: buildRssiTile(context),
              title: Text(
                  'Device is ${_connectionState.toString().split('.')[1]}.'),
              // trailing: buildGetServices(context),
            ),
            // buildMtuTile(context),
            // ..._buildServiceTiles(context, widget.device),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _servo1S,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'S1 start °',
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                      controller: _servo1E,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'S1 start °',
                      )),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _servo2S,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'S2 start °',
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                      controller: _servo2E,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'S2 End °',
                      )),
                )
              ],
            ),
            ElevatedButton(
              onPressed: getDegrees,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[400]),
              child: const Text("Set",
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            const Divider(
              color: Color.fromARGB(255, 179, 168, 168),
              height: 1.0,
            ),
            const SizedBox(
              height: 10,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [...buildDisDegree()],
            // ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: pressCloseLight1,
                    child: const Text("Colse Light1")),
                ElevatedButton(
                    onPressed: pressOpenLight1,
                    child: const Text("Open Light1"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: pressCloseLight2,
                    child: const Text("Colse Light2")),
                ElevatedButton(
                    onPressed: pressOpenLight2,
                    child: const Text("Open Light2"))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
