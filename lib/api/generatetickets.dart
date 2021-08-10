import 'dart:math';
import 'dart:ui' as ui;
import 'package:cinema_ticket_maker/types/pagesize.dart';
import 'package:cinema_ticket_maker/types/ticketcolors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TicketSize {
  final double width;
  final double height;

  const TicketSize(this.width, this.height);

  TicketSize operator *(double scale) => TicketSize(
        width * scale,
        height * scale,
      );
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
  int participants;

  TicketData(this.movieName, this.participants, this.cinemaName,
      this.cinemaNameShort, this.date);
}

class Tickets {
  static const defaultTicketSize = TicketSize(350, 150);

  //static double _radiansToDegrees(double radian) => radian * 180 / pi;

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
    double moveXBy,
    double moveYBy,
    TicketSize ticketSize,
    double scale,
    TicketData ticketData,
  ) {
    canvas.translate(moveXBy, moveYBy);

    //BACKGROUND
    final background = Rect.fromLTWH(
      0,
      0,
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

    canvas.rotate(_degreesToRadians(-90));
    canvas.translate(-textPainter.height, 0);
  }

  static Future<List<ByteData>> generate(
      TicketData ticketData, String paperSize, double scale) async {
    List<ByteData> result = [];

    //Find Paper Size
    final pageResolution = pageSizes[paperSize] ??
        const PageResolution(
          2480,
          3508,
        );

    final tSize = Tickets.defaultTicketSize * scale;

    while (ticketData.participants > 0) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      double x = 0, y = 0, pX = 0, pY = 0;

      while (ticketData.participants > 0) {
        Tickets.drawTicketComponent(
          canvas,
          x - pX,
          y - pY,
          tSize,
          scale,
          ticketData,
        );

        ticketData.participants -= 1;

        pX = x;
        pY = y;

        x += tSize.width;
        if (x + tSize.width > pageResolution.width) {
          x = 0;
          y += tSize.height;
          if (y + tSize.height > pageResolution.height) {
            break;
          }
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(
        pageResolution.width,
        pageResolution.height,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data != null) result.add(data);
    }

    return result;
  }
}
