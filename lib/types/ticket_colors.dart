import 'dart:convert';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:flutter/material.dart';

class TicketColors {


  static TicketColor newThemeDefault() => const TicketColor(
        Colors.white,
        Colors.blueGrey,
        Colors.blueGrey,
        Colors.white,
        Colors.deepOrange,
      );

  static Future updateTheme() async {
    Settings.setString(
      _themeLocation,
      jsonEncode(
        theme.toJson(),
      ),
    );
  }

  static Future init() async {
    final themeStorage = Settings.getString(_themeLocation);
    if (themeStorage == null) {
      theme = newThemeDefault();
      return;
    }
    theme = TicketColor.fromJson(jsonDecode(themeStorage));
  }

  static late TicketColor theme;

  static const _themeLocation = "old-theme";
}

class TicketColor {
  final Color firstColorBackground;
  final Color secondColorBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color alt;

 const TicketColor(this.firstColorBackground, this.secondColorBackground,
      this.primaryText, this.secondaryText, this.alt);

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

  Paint generateBackgroundGradient(Rect rect) {
    Paint paint = Paint();
    paint.shader = ui.Gradient.linear(
      Offset(rect.top, rect.left),
      Offset(rect.right, rect.bottom),
      [
        firstColorBackground,
        secondColorBackground,
      ],
    );

    return paint;
  }

  Map<String, dynamic> toJson() => {
        "firstColorBackground": colorToJson(firstColorBackground),
        "lastColorBackground": colorToJson(secondColorBackground),
        "primaryText": colorToJson(primaryText),
        "secondaryText": colorToJson(secondaryText),
        "alt": colorToJson(alt),
      };

  static TicketColor fromJson(Map<String, dynamic> map) => TicketColor(
        map["firstColorBackground"],
        map["secondColorBackground"],
        map["primaryText"],
        map["secondaryText"],
        map["alt"],
      );
}
