import 'package:flutter/material.dart';

enum LightState {
  ON,
  OFF,
}

enum Servos {
  Servo1,
  Servo2,
}

class CardSetting {
  final String cardTitle;

  Map<String, Map<LightState, List<int>>>? light;
  List<Map<Servos, int>>? initServosList;

  CardSetting({required this.cardTitle});
}

class LightCard extends StatefulWidget {
  const LightCard(
      {super.key, this.onTap, this.onDoubleTap, required this.title});
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  final String title;

  @override
  State<LightCard> createState() => _LightCardState();
}

class _LightCardState extends State<LightCard> {
  bool _isLightOn = true;

  void _toggleLight() {
    setState(() {
      _isLightOn = !_isLightOn;
    });
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Placeholder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.8; // 设置为屏幕宽度的80%
    return GestureDetector(
      onTap: widget.onTap?.call ?? _toggleLight,
      onDoubleTap: () =>
          widget.onDoubleTap?.call ?? _navigateToSettings(context),
      child: Container(
        width: cardWidth, // 设置固定宽度
        height: 200, // 设置固定高度
        alignment: Alignment.center,
        child: Card(
          color: _isLightOn ? Colors.white : Colors.grey[800],
          elevation: 8, // 增加阴影以突出卡片
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 圆角边框
          ),
          margin: const EdgeInsets.all(10.0), // 增加外边距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: _isLightOn ? Colors.black : Colors.white,
                  fontSize: 24, // 增加字体大小
                  fontWeight: FontWeight.bold, // 加粗字体
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _isLightOn ? '开灯中' : '关灯中',
                    style: TextStyle(
                      color: _isLightOn ? Colors.black : Colors.white,
                      fontSize: 24, // 增加字体大小
                      fontWeight: FontWeight.bold, // 加粗字体
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
