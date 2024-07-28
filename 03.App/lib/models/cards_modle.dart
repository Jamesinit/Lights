import 'package:ble_lights/models/card_modle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class CardsModle extends ChangeNotifier {
  final Map<int, CardModel> cardsList = {};

  get len => cardsList.length;

  void add(CardModel cardData) {
    cardsList[cardData.id] = cardData;
    notifyListeners();
  }

  void remove(id) {
    cardsList.remove(id);
    notifyListeners();
  }

  Future<void> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString('cardsList');
    if (cardsJson != null) {
      final Map<String, dynamic> cardsMap = jsonDecode(cardsJson);
      cardsList.clear();
      cardsMap.forEach((key, value) {
        cardsList[int.parse(key)] = CardModel.fromJson(value);
      });
      notifyListeners();
    }
  }

  Future<void> saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> cardsMap = {};
    cardsList.forEach((key, value) {
      cardsMap[key.toString()] = value.toJson();
    });
    await prefs.setString('cardsList', jsonEncode(cardsMap));
  }
}
