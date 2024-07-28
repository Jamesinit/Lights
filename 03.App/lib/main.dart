import 'dart:convert';
import 'dart:async';

import 'package:ble_lights/models/cards_modle.dart';
import 'package:ble_lights/models/selected_modle.dart';
import 'package:ble_lights/screens/add_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cardsModle = CardsModle();
  await cardsModle.loadCards();
  // FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  var selectedDevied = SelectDevice();
  if (cardsModle.len > 0) {
    var cardInfo = cardsModle.cardsList[0];
    if (cardInfo != null) {
      var tmp_device = BluetoothDevice.fromId(cardInfo.remoteId);
      await tmp_device.connect();
      selectedDevied.setDevice(tmp_device);
      var servers = await tmp_device.discoverServices();
      for (var element in servers) {
        for (var c in element.characteristics) {
          if (c.characteristicUuid == Guid('ffe1')) {
            selectedDevied.setCharacter(c);
            break;
          }
        }
      }
    }
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => cardsModle),
    ChangeNotifierProvider(
      create: (context) => selectedDevied,
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Provider Test",
      theme: ThemeData(useMaterial3: true),
      routes: {
        '/': (context) => const MyHomePage(title: "BLE Light"),
        '/addCardScreen': (context) => AddCardScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isCardEnabled = true;
  BluetoothDevice? selectedDevice;
  late BluetoothCharacteristic? selectedDeviceWC;
  List<BluetoothService> _services = [];
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  final FocusNode _dropdownFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _scanResults = results;
        });
      }
    }, onError: (e) {
      print("!!!ERROR!!! $e");
    });
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    selectedDevice?.disconnect();
    _dropdownFocusNode.dispose();
    super.dispose();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    _services = await device.discoverServices();
    selectedDeviceWC = foundWriteCharacteristic();
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景图片
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'), // 替换为你的图片路径
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "我的设备",
              style: GoogleFonts.maShanZheng(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                  onPressed: () {
                    if (context
                        .read<SelectDevice>()
                        .bluetoothDevice
                        .isConnected) {
                      Navigator.of(context).pushNamed(
                        '/addCardScreen',
                      );
                    } else if (selectedDevice != null) {
                      context.read<SelectDevice>().setDevice(selectedDevice!);
                      if (selectedDeviceWC != null) {
                        context
                            .read<SelectDevice>()
                            .setCharacter(selectedDeviceWC!);
                      }
                      Navigator.of(context).pushNamed(
                        '/addCardScreen',
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("请先选择设备"),
                        duration: Duration(milliseconds: 500),
                      ));
                      // 在SnackBar显示后，聚焦到DropdownButton
                      Future.delayed(const Duration(milliseconds: 500), () {
                        FocusScope.of(context).requestFocus(_dropdownFocusNode);
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 30,
                  )),
            ],
          ),
          body: Column(children: [
            DropdownButton<BluetoothDevice>(
              hint: const Text("选择蓝牙设备"),
              value: selectedDevice,
              items: _scanResults
                  .where((scanItem) => scanItem.device.platformName.isNotEmpty)
                  .map((scanItem) {
                return DropdownMenuItem<BluetoothDevice>(
                  value: scanItem.device,
                  child: Text(scanItem.device.platformName),
                );
              }).toList(),
              onTap: () {
                // FlutterBluePlus.startScan();
              },
              onChanged: (BluetoothDevice? device) {
                setState(() {
                  if (device != null) {
                    selectedDevice = device;

                    context.read<SelectDevice>().setDevice(device);
                    connectToDevice(device);

                    context.read<SelectDevice>().setCharacter(selectedDeviceWC);
                  }
                });
              },
              focusNode: _dropdownFocusNode,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("当前连接设备："),
                Text(context
                    .read<SelectDevice>()
                    .bluetoothDevice
                    .remoteId
                    .toString()),
              ],
            ),
            const _CardList()
          ]),
        )
      ],
    );
  }
}

class _CardList extends StatefulWidget {
  const _CardList({super.key});

  @override
  State<_CardList> createState() => _CardListState();
}

class _CardListState extends State<_CardList> {
  bool isLightOn = false;
  @override
  Widget build(BuildContext context) {
    var cardListModel = context.watch<CardsModle>();

    if (cardListModel.cardsList.isEmpty) {
      return Expanded(child: Center(child: Text("No have device")));
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: cardListModel.len,
          itemBuilder: (context, index) {
            var card = cardListModel.cardsList.values.elementAt(index);
            return Dismissible(
              key: Key(card.id.toString()), // 使用唯一的键
              onDismissed: (direction) {
                // 当项被滑动删除时调用
                cardListModel.remove(card.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${card.cardName} dismissed'),
                    duration: Duration(milliseconds: 300),
                  ),
                );
                cardListModel.saveCards();
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () {
                  print('Card ${card.cardName} tapped');
                  var on_s1 = card.onServo1Degree.toString().trim();
                  var on_s2 = card.onServo2Degree.toString().trim();
                  var off_s1 = card.offServo1Degree.toString().trim();
                  var off_s2 = card.offServo2Degree.toString().trim();
                  var ch = context.read<SelectDevice>().bluetoothCharacteristic;
                  if (ch != null) {
                    if (isLightOn) {
                      ch.write(utf8.encode("Servo2-180-$off_s2;"));
                      ch.write(utf8.encode("Servo1-90-$off_s1;"));
                      Future.delayed(Duration(seconds: 1));
                      ch.write(utf8.encode("Servo2-$off_s2-180;"));
                      ch.write(utf8.encode("Servo1-$off_s1-90;"));
                      isLightOn = !isLightOn;
                    } else {
                      ch.write(utf8.encode("Servo2-180-$on_s2;"));
                      ch.write(utf8.encode("Servo1-90-$on_s1;"));
                      Future.delayed(Duration(seconds: 1));
                      ch.write(utf8.encode("Servo2-$on_s2-180;"));
                      ch.write(utf8.encode("Servo1-$on_s1-90;"));
                      isLightOn = !isLightOn;
                    }
                  }
                },
                child: LightCard(
                  isCardEnabled: true,
                  cardName: card.cardName,
                ),
              ),
            );
          },
        ),
      );
    }
  }
}

class LightCard extends StatelessWidget {
  final String cardName;

  const LightCard({
    super.key,
    required this.isCardEnabled,
    required this.cardName,
  });

  final bool isCardEnabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCardEnabled ? Colors.white : Colors.grey[500], // 根据bool变量改变卡片颜色
      elevation: 4.0, // 卡片阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        width: 350,
        height: 100,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.lightbulb_outline, size: 40), // 图标
            Text(cardName, style: const TextStyle(fontSize: 18)), // 名称
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              onPressed: () {
                // 蓝牙断开逻辑
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
