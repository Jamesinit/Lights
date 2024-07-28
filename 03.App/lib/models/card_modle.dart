import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

class CardModel extends ChangeNotifier {
  late String cardName;
  late int cardId;
  String remoteId;
  BluetoothCharacteristic? ch;
  CardModel(
      {required this.cardName,
      required this.cardId,
      required this.onServo1Degree,
      required this.onServo2Degree,
      required this.offServo1Degree,
      required this.offServo2Degree,
      required this.remoteId});
  int onServo1Degree = 0;
  int onServo2Degree = 0;
  int offServo1Degree = 0;
  int offServo2Degree = 0;
  Icon lightIcon = const Icon(Icons.lightbulb_outline);

  String get name => cardName;
  int get id => cardId;

  set name(String value) {
    cardName = value;
    notifyListeners();
  }

  set id(int value) {
    cardId = value;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'cardName': cardName,
        'cardId': cardId,
        'onServo1Degree': onServo1Degree,
        'onServo2Degree': onServo2Degree,
        'offServo1Degree': offServo1Degree,
        'offServo2Degree': offServo2Degree,
        'remoteId': remoteId.toString(),
      };

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        cardName: json['cardName'],
        cardId: json['cardId'],
        onServo1Degree: json['onServo1Degree'],
        onServo2Degree: json['onServo2Degree'],
        offServo1Degree: json['offServo1Degree'],
        offServo2Degree: json['offServo2Degree'],
        remoteId: json['remoteId'],
      );
}
