import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double realHeight;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    final appBarHeight = AppBar().preferredSize.height;
    realHeight =
        screenHeight - appBarHeight - MediaQuery.of(context).padding.top;
  }
}
