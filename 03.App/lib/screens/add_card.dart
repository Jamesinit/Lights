import 'package:ble_lights/models/selected_modle.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble_lights/models/card_modle.dart';
import 'package:ble_lights/models/cards_modle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({
    super.key,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _nameCrontroller = TextEditingController();

  String inputName = "defalult";
  int on_servo1Degree = 90;
  int on_servo2Degree = 180;

  int off_servo1Degree = 90;
  int off_servo2Degree = 180;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameCrontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BluetoothCharacteristic? bluetoothCharacteristic =
        context.read<SelectDevice>().bluetoothCharacteristic;
    BluetoothDevice selectBluethDevice =
        context.read<SelectDevice>().bluetoothDevice;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adad Card"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("CardName: "),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _nameCrontroller,
                      decoration: const InputDecoration(hintText: "Enter Name"),
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          // Show a SnackBar or some other form of feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a valid name')),
                          );
                        } else {
                          setState(() {
                            inputName = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const Divider(),
                  Center(
                      child: Text(
                    "开灯",
                    style: GoogleFonts.maShanZheng(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                  Row(
                    children: [
                      const Text("Servo1"),
                      const SizedBox(width: 50),
                      Text(on_servo1Degree.toString()),
                      const SizedBox(width: 50),
                      Column(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                var oldevalue = on_servo1Degree;
                                setState(() {
                                  if (on_servo1Degree < 180) {
                                    on_servo1Degree += 10;
                                  }
                                });
                                bluetoothCharacteristic?.write(utf8.encode(
                                    "Servo1-$oldevalue-$on_servo1Degree;"));
                              },
                              child: const Icon(
                                Icons.arrow_drop_up_outlined,
                                size: 60,
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  var oldevalue = on_servo1Degree;
                                  if (on_servo1Degree > 0) {
                                    on_servo1Degree -= 10;
                                  }
                                  bluetoothCharacteristic?.write(utf8.encode(
                                      "Servo1-$oldevalue-$on_servo1Degree;"));
                                });
                              },
                              child: const Icon(
                                Icons.arrow_drop_down_outlined,
                                size: 60,
                              ))
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Servo2"),
                      const SizedBox(width: 50),
                      Text(on_servo2Degree.toString()),
                      const SizedBox(width: 50),
                      Column(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  var oldevalue = on_servo2Degree;
                                  if (on_servo2Degree < 180) {
                                    on_servo2Degree += 10;
                                  }

                                  bluetoothCharacteristic?.write(utf8.encode(
                                      "Servo2-$oldevalue-$on_servo2Degree;"));
                                });
                              },
                              child: const Icon(
                                Icons.arrow_drop_up_outlined,
                                size: 60,
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  var oldevalue = on_servo2Degree;
                                  if (on_servo2Degree >= 10) {
                                    on_servo2Degree -= 10;
                                  }

                                  bluetoothCharacteristic?.write(utf8.encode(
                                      "Servo2-$oldevalue-$on_servo2Degree;"));
                                });
                              },
                              child: const Icon(
                                Icons.arrow_drop_down_outlined,
                                size: 60,
                              ))
                        ],
                      )
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  const Divider(),
                  Center(
                      child: Text(
                    "关灯",
                    style: GoogleFonts.maShanZheng(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                  Row(
                    children: [
                      const Text("Servo1"),
                      const SizedBox(width: 50),
                      Text(off_servo1Degree.toString()),
                      const SizedBox(width: 50),
                      Column(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                var oldevalue = off_servo1Degree;
                                setState(() {
                                  if (off_servo1Degree < 180) {
                                    off_servo1Degree += 10;
                                  }
                                });
                                bluetoothCharacteristic?.write(utf8.encode(
                                    "Servo1-$oldevalue-$off_servo1Degree;"));
                              },
                              child: const Icon(
                                Icons.arrow_drop_up_outlined,
                                size: 60,
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  var oldevalue = off_servo1Degree;
                                  if (off_servo1Degree > 0) {
                                    off_servo1Degree -= 10;
                                  }
                                  bluetoothCharacteristic?.write(utf8.encode(
                                      "Servo1-$oldevalue-$off_servo1Degree;"));
                                });
                              },
                              child: const Icon(
                                Icons.arrow_drop_down_outlined,
                                size: 60,
                              ))
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Servo2"),
                      const SizedBox(width: 50),
                      Text(off_servo2Degree.toString()),
                      const SizedBox(width: 50),
                      Column(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  var oldevalue = off_servo2Degree;
                                  if (off_servo2Degree < 180) {
                                    off_servo2Degree += 10;
                                  }

                                  bluetoothCharacteristic?.write(utf8.encode(
                                      "Servo2-$oldevalue-$off_servo2Degree;"));
                                });
                              },
                              child: const Icon(
                                Icons.arrow_drop_up_outlined,
                                size: 60,
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  var oldevalue = off_servo2Degree;
                                  if (off_servo2Degree >= 10) {
                                    off_servo2Degree -= 10;
                                  }

                                  bluetoothCharacteristic?.write(utf8.encode(
                                      "Servo2-$oldevalue-$off_servo2Degree;"));
                                });
                              },
                              child: const Icon(
                                Icons.arrow_drop_down_outlined,
                                size: 60,
                              ))
                        ],
                      )
                    ],
                  )
                ],
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text("取消")),
                  ElevatedButton(
                      onPressed: () {
                        var card = context.read<CardsModle>();
                        card.add(CardModel(
                            cardName: _nameCrontroller.text,
                            cardId: card.len,
                            onServo1Degree: on_servo1Degree,
                            onServo2Degree: on_servo2Degree,
                            offServo1Degree: off_servo1Degree,
                            offServo2Degree: off_servo2Degree,
                            remoteId: selectBluethDevice.remoteId.toString()));
                        card.saveCards();
                        Navigator.pop(context);
                      },
                      child: const Text("确认"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
