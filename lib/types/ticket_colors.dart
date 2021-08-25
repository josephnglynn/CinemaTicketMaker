import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:flutter/material.dart';

class TicketColors {
  static late Color firstColorBackground;
  static late Color lastColorBackground;
  static late Color primaryText;
  static late Color secondaryText;

  static Future setFirstColorBackground(Color c) async {
    firstColorBackground = c;
    await Settings.setString(_firstColorBackgroundLocation, colorToJson(c));
  }

  static Future setLastColorBackground(Color c) async {
    lastColorBackground = c;
    await Settings.setString(_lastColorBackgroundLocation, colorToJson(c));
  }

  static Future setPrimaryTextColorBackground(Color c) async {
    primaryText = c;
    await Settings.setString(_primaryTextLocation, colorToJson(c));
  }

  static Future setSecondaryTextColorBackground(Color c) async {
    secondaryText = c;
    await Settings.setString(_secondaryTextLocation, colorToJson(c));
  }

  static String colorToJson(Color value) {
    Map<String, dynamic> map = {
      "r": value.red,
      "g": value.green,
      "b": value.blue,
      "o": value.opacity,
    };
    return jsonEncode(map);
  }

  static Color colorFromJson(String value) {
    Map<String, dynamic> map = jsonDecode(value);
    return Color.fromRGBO(map["r"], map["g"], map["b"], map["o"]);
  }

  static Paint generateBackground(Rect rect) {
    Paint paint = Paint();
    paint.shader = ui.Gradient.linear(
      Offset(rect.top, rect.left),
      Offset(rect.right, rect.bottom),
      [
        firstColorBackground,
        lastColorBackground,
      ],
    );

    return paint;
  }

  static Future init() async {
    var files = Settings.getString(_firstColorBackgroundLocation);

    if (files != null) {
      firstColorBackground = colorFromJson(files);
    } else {
      firstColorBackground = const Color.fromRGBO(232, 139, 58, 1);
    }

    files = Settings.getString(_lastColorBackgroundLocation);

    if (files != null) {
      lastColorBackground = colorFromJson(files);
    } else {
      lastColorBackground = const Color.fromRGBO(170, 54, 232, 1);
    }

    files = Settings.getString(_primaryTextLocation);

    if (files != null) {
      primaryText = colorFromJson(files);
    } else {
      primaryText = Colors.black;
    }

    files = Settings.getString(_secondaryTextLocation);

    if (files != null) {
      secondaryText = colorFromJson(files);
    } else {
      secondaryText = Colors.white;
    }
  }

  static const _firstColorBackgroundLocation = "first-color-background";
  static const _lastColorBackgroundLocation = "last-color-background";
  static const _primaryTextLocation = "primaryText";
  static const _secondaryTextLocation = "secondaryText";
}