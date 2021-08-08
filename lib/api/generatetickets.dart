import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/pagesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TicketDrawReturnType {
  int count;
  ByteData? byteData;

  _TicketDrawReturnType(this.count, this.byteData);
}

class TicketSize {
  final double width;
  final double height;

  const TicketSize(this.width, this.height);

  @override
  TicketSize operator *(double scale) => TicketSize(
        width * scale,
        height * scale,
      );
}

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

class CustomTextPainter extends TextPainter {
  CustomTextPainter({
    InlineSpan? text,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
    double textScaleFactor = 1.0,
    int? maxLines,
    String? ellipsis,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
  }) : super(
          text: text,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          ellipsis: ellipsis,
          locale: locale,
          strutStyle: strutStyle,
          textHeightBehavior: textHeightBehavior,
          textWidthBasis: textWidthBasis,
        );

  void fitCertainWidth(double widthOfConstraint) {
    double decrease = 0.01;
    layout();
    if (width < widthOfConstraint) return;
    final content = text!.toPlainText();
    var style = text!.style ?? const TextStyle();
    double fontSize = style.fontSize ?? 30;
    while (width > widthOfConstraint) {
      fontSize -= decrease;
      style = style.copyWith(fontSize: fontSize);

      text = TextSpan(
        text: content,
        style: style,
      );

      layout();

      if (fontSize < 0.1) {
        return;
      }
    }
  }
}

class TicketData {
  final String movieName;
  final String cinemaName;
  final String cinemaNameShort;
  final DateTime date;
  final int participants;

  TicketData(this.movieName, this.participants, this.cinemaName,
      this.cinemaNameShort, this.date);
}

class Tickets {
  static const defaultTicketSize = TicketSize(350, 150);

  static double _radiansToDegrees(double radian) => radian * 180 / pi;

  static double _degreesToRadians(double degree) => degree * pi / 180;

  static String _generateRandomListOfNumbers(int length) {
    String value = "";
    Random rand = Random();
    while (value.length != length) {
      value += rand.nextInt(9).toString();
    }
    return value;
  }

  static void drawTicketComponent(
    Canvas canvas,
    double x,
    double y,
    TicketSize ticketSize,
    double scale,
    TicketData ticketData,
    int indexOfParticipant,
  ) {
    //BACKGROUND
    final background = Rect.fromLTWH(
      x,
      y,
      ticketSize.width,
      ticketSize.height,
    );

    canvas.drawRect(
      background,
      TicketColors.generateBackground(background),
    );

    //MOVIE NAME
    double fontSize = 30 * scale;
    TextStyle style = TextStyle(
      color: TicketColors.primaryText,
      fontSize: fontSize,
    );

    final textPainter = CustomTextPainter(
      text: TextSpan(
        text: ticketData.movieName,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );

    if (ticketSize.width < 50) return;

    textPainter.fitCertainWidth(background.width - 20 * scale);
    textPainter.paint(canvas, const Offset(10, 10) * scale);

    //VALID
    textPainter.text = TextSpan(text: "VALID", style: style);
    textPainter.fitCertainWidth(background.width / 10);
    textPainter.paint(canvas, const Offset(10, 50) * scale);

    //VALID WHERE
    style = style.copyWith(fontSize: 20 * scale);
    textPainter.text =
        TextSpan(text: "AT ${ticketData.cinemaName}", style: style);
    textPainter.fitCertainWidth(background.width / 2);
    textPainter.paint(canvas, const Offset(10, 67) * scale);

    //COMMENCING
    textPainter.text = TextSpan(text: "COMMENCING", style: style);
    textPainter.fitCertainWidth(background.width / 4.5);
    textPainter.paint(canvas, const Offset(10, 100) * scale);

    //COMMENCING AT
    style = style.copyWith(fontSize: 20 * scale);
    textPainter.text = TextSpan(text: "AT ${ticketData.date}", style: style);
    textPainter.fitCertainWidth(background.width / 2);
    textPainter.paint(canvas, const Offset(10, 120) * scale);

    //DRAW SHORT NAME
    style =
        style.copyWith(fontSize: 30 * scale, color: TicketColors.secondaryText);
    textPainter.text = TextSpan(text: ticketData.cinemaNameShort, style: style);
    textPainter.fitCertainWidth(background.width / 4);
    textPainter.paint(
        canvas,
        Offset(
            225 * scale, ticketSize.height - textPainter.height - 10 * scale));

    //SERIAL NUMBER
    fontSize = 15 * scale;
    style = style.copyWith(fontSize: fontSize, color: TicketColors.primaryText);
    textPainter.text = TextSpan(children: [
      TextSpan(
        text: "REF:  ",
        style: style,
      ),
      TextSpan(
        text: _generateRandomListOfNumbers(10),
        style: style.copyWith(color: TicketColors.secondaryText),
      ),
    ], style: style);
    // textPainter.fitCertainWidth(background.width / 4);
    textPainter.layout();

    while (textPainter.width > ticketSize.height - 20) {
      style =
          style.copyWith(fontSize: fontSize, color: TicketColors.primaryText);
      fontSize -= 0.1;
      textPainter.text = TextSpan(
        children: [
          TextSpan(
            text: "REF:  ",
            style: style,
          ),
          TextSpan(
            text: _generateRandomListOfNumbers(10),
            style: style.copyWith(color: TicketColors.secondaryText),
          ),
        ],
        style: style,
      );
      textPainter.layout();
    }

    canvas.translate(textPainter.height, 0);
    canvas.rotate(_degreesToRadians(90));

    textPainter.paint(
        canvas,
        Offset((ticketSize.height - textPainter.width) / 2,
            -ticketSize.width + textPainter.height));
  }

  static Future<ByteData?> _draw(
    PageResolution pageResolution,
    bool isHorizontal,
    TicketSize ticketSize,
    double scale,
    TicketData ticketData,
  ) async {
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);

    double x = 0, y = 0;
    int i = 0;

    if (isHorizontal) {
      while (y + ticketSize.height < pageResolution.height &&
          i < ticketData.participants) {
        drawTicketComponent(canvas, x, y, ticketSize, scale, ticketData, i);
        x += ticketSize.width;
        if (x > pageResolution.width) {
          y += ticketSize.height;
          x = ticketSize.width;
        }
        ++i;
      }
    } else {
      while (y + ticketSize.width < pageResolution.height &&
          i < ticketData.participants) {
        drawTicketComponent(canvas, x, y, ticketSize, scale, ticketData, i);
        x += ticketSize.height;
        if (x > pageResolution.width) {
          y += ticketSize.width;
          x = ticketSize.height;
        }
        ++i;
      }
    }

    final ui.Picture result = pictureRecorder.endRecording();
    final image =
        await result.toImage(pageResolution.width, pageResolution.height);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData;
  }

  static Future<_TicketDrawReturnType> _workOutCount(
    TicketData ticketData,
    PageResolution pageResolution,
    TicketSize ticketSize,
    double scale,
  ) async {
    double x = 0;
    double y = 0;
    //try horizontally
    int horizontalCount = -1;
    while (y + ticketSize.height < pageResolution.height) {
      horizontalCount += 1;
      x += ticketSize.width;
      if (x > pageResolution.width) {
        y += ticketSize.height;
        x = ticketSize.width;
      }
    }

    //try vertically
    int verticalCount = -1;
    while (y + ticketSize.width < pageResolution.height) {
      verticalCount += 1;
      x += ticketSize.height;
      if (x > pageResolution.width) {
        y += ticketSize.width;
        x = ticketSize.height;
      }
    }

    bool horizontal = horizontalCount > verticalCount;
    int largeCount = horizontal ? horizontalCount : verticalCount;

    return _TicketDrawReturnType(
      largeCount,
      await _draw(pageResolution, horizontal, ticketSize, scale, ticketData),
    );
  }

  static Future<List<ByteData>> generate(
      TicketData ticketData, String paperSize, double scale) async {
    //Find Paper Size
    final pageResolution =
        pageSizes[paperSize] ?? const PageResolution(2480, 3508);
    int count = ticketData.participants;

    final TicketSize ticketSize = defaultTicketSize * scale;

    List<ByteData> images = [];

    while (count > 0) {
      _TicketDrawReturnType _ticketDrawReturnType =
          await _workOutCount(ticketData, pageResolution, ticketSize, scale);

      count -= _ticketDrawReturnType.count;
      if (_ticketDrawReturnType.byteData != null) {
        images.add(_ticketDrawReturnType.byteData!);
      }
    }
    return images;
  }
}
