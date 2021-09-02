import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/custom_text_painter.dart';
import 'package:cinema_ticket_maker/types/page_resolution.dart';
import 'package:cinema_ticket_maker/types/page_size.dart';
import 'package:cinema_ticket_maker/types/ref_number.dart';
import 'package:cinema_ticket_maker/types/ref_number_container.dart';
import 'package:cinema_ticket_maker/types/ticket_colors.dart';
import 'package:cinema_ticket_maker/types/ticket_data.dart';
import 'package:cinema_ticket_maker/types/ticket_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as utils;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr/qr.dart';

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
    String? name, {
    String? refNumber,
  }) {
    refNumber ??=
        _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);
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
    style = style.copyWith(fontSize: 12.52 * scale);
    textPainter.text = TextSpan(text: "VALID", style: style);
    textPainter.fitCertainWidth(background.width / 10);
    textPainter.paint(canvas, const Offset(10, 50) * scale);

    //VALID WHERE
    style = style.copyWith(fontSize: 18.4 * scale);
    textPainter.text =
        TextSpan(text: "AT ${ticketData.cinemaName}", style: style);
    textPainter.fitCertainWidth(background.width / 2);
    textPainter.paint(canvas, const Offset(10, 67) * scale);

    //COMMENCING
    style = style.copyWith(fontSize: 11.5 * scale);
    textPainter.text = TextSpan(text: "COMMENCING", style: style);
    textPainter.fitCertainWidth(background.width / 4.5);
    textPainter.paint(canvas, const Offset(10, 100) * scale);

    //COMMENCING AT
    style = style.copyWith(fontSize: 12.17 * scale);
    textPainter.text = TextSpan(
        text: "On ${utils.DateFormat().format(ticketData.date)}", style: style);
    textPainter.fitCertainWidth(background.width / 2);
    textPainter.paint(canvas, const Offset(10, 120) * scale);


    if (Settings.includeNames && name != null) {
      style = style.copyWith(fontSize: 12.95 * scale);
      textPainter.text = TextSpan(text: "Name", style: style);
      textPainter.fitCertainWidth(background.width / 10);
      textPainter.paint(canvas, const Offset(225, 49) * scale);

      style = style.copyWith(fontSize: 17.05 * scale);
      textPainter.text = TextSpan(text: name, style: style);
      textPainter.fitCertainWidth(background.width / 4);
      textPainter.paint(canvas, const Offset(225, 68) * scale);
    }

    double? xForShort;

    if (Settings.useQrCodes) {

      int i = 1;
      QrCode qrCode;

      while (true) {
        qrCode = QrCode(i, QrErrorCorrectLevel.L);
        qrCode.addData(name ?? "" + uniqueSplitter + refNumber);
        try {
          qrCode.make();
          break;
        } catch (e) {
          i++;
        }
      }

      for (double x = 0; x < qrCode.moduleCount; x++) {
        for (double y = 0; y < qrCode.moduleCount; y++) {
          if (qrCode.isDark(y.toInt(), x.toInt())) {
            xForShort = x * scale * _qrCodeScale + 305 * scale;
            canvas.drawRect(
                Rect.fromLTWH(
                    xForShort,
                    y * scale * _qrCodeScale + 10 * scale,
                    scale * _qrCodeScale,
                    scale * _qrCodeScale),
                Paint()..color = TicketColors.primaryText);
          }
        }
      }
    } else {
      //SERIAL NUMBER
      style = style.copyWith(
        fontSize: 15 * scale,
        color: TicketColors.primaryText,
      );
      textPainter.text = TextSpan(children: [
        TextSpan(
          text: "REF:  ",
          style: style,
        ),
        TextSpan(
          text: refNumber,
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
              text: refNumber,
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

    //DRAW SHORT NAME
    style = style.copyWith(
        fontSize: 24.55 * scale, color: TicketColors.secondaryText);
    textPainter.text = TextSpan(text: ticketData.cinemaNameShort, style: style);
    textPainter.fitCertainWidth(background.width / 4);
    textPainter.paint(
      canvas,
      Settings.useQrCodes ? Offset(xForShort! - textPainter.width, -textPainter.height / 2 + 127.5 * scale) :Offset(225 * scale, -textPainter.height / 2 + 127.5 * scale),
    );
  }

  static const _qrCodeScale = 1.75;

  static List<RefNumber>? currentRefNumbers;

  static Future<List<ByteData>> _generateTicketsToShare(
      TicketData ticketData, double scale, List<String>? name) async {
    List<ByteData> result = [];
    currentRefNumbers = [];

    final tSize = Tickets.defaultTicketSize * scale;

    String refNumber =
        _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);

    while (ticketData.participants > 0) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      Tickets.drawTicketComponent(
        canvas,
        0,
        0,
        tSize,
        scale,
        ticketData,
        name != null ? name[ticketData.participants - 1] : null,
        refNumber: refNumber,
      );

      currentRefNumbers!.add(
        RefNumber(
          name != null ? name[ticketData.participants - 1] : "",
          refNumber,
        ),
      );

      ticketData.participants -= 1;

      if (!Settings.sameRefForEachTicket) {
        refNumber =
            _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);
      }

      final picture = recorder.endRecording();

      final image = await picture.toImage(
        tSize.width.toInt(),
        tSize.height.toInt(),
      );

      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data != null) result.add(data);
    }
    return result;
  }

  static Future<List<ByteData>> _generateTicketsToPrint(TicketData ticketData,
      String paperSize, double scale, List<String>? name) async {
    List<ByteData> result = [];
    currentRefNumbers = []; //reset any previous ones

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

      String refNumber =
          _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);

      while (ticketData.participants > 0) {
        Tickets.drawTicketComponent(
          canvas,
          x - pX,
          y - pY,
          tSize,
          scale,
          ticketData,
          name != null ? name[ticketData.participants - 1] : null,
          refNumber: refNumber,
        );

        currentRefNumbers!.add(
          RefNumber(
            name != null ? name[ticketData.participants - 1] : "",
            refNumber,
          ),
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

        if (!Settings.sameRefForEachTicket) {
          refNumber =
              _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);
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

  static Future<List<ByteData>> generate(TicketData ticketData,
      String paperSize, double scale, List<String>? name) async {
    final result = Settings.shareInsteadOfPrint
        ? await _generateTicketsToShare(ticketData, scale, name)
        : await _generateTicketsToPrint(ticketData, paperSize, scale, name);

    await Settings.setRefContainers(
      RefContainer(
        currentRefNumbers!,
        "${ticketData.movieName} - ${utils.DateFormat().format(ticketData.date)}",
      ),
    );
    return result;
  }

  static const uniqueSplitter = "*#*";

  static Future<ByteData> _generateExtraQrCode(
      int index, String movieName, String time) async {
    final size = SchedulerBinding.instance!.window.physicalSize;
    final marginForQrCodeExtra =
        (size.width > size.height ? size.height : size.width) / 10;

    final textPainter = CustomTextPainter(
      text: TextSpan(
        text: "$movieName - $time",
        style: const TextStyle(color: Colors.black, fontSize: 30),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.fitCertainWidth(size.width - 2 * marginForQrCodeExtra);


    double whatByWhat = (size.width > size.height ? size.height : size.width) +
        marginForQrCodeExtra * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(Rect.fromLTWH(0, 0, whatByWhat, whatByWhat + textPainter.height),
        Paint()..color = Colors.white);

    int i = 1;
    QrCode qrCode;

    while (true) {
      qrCode = QrCode(i, QrErrorCorrectLevel.L);
      qrCode.addData(currentRefNumbers![index].name + uniqueSplitter + currentRefNumbers![index].number);
      try {
        qrCode.make();
        break;
      } catch (e) {
        i++;
      }
    }




    double scale =
        (whatByWhat - (marginForQrCodeExtra * 2)) / qrCode.moduleCount;

    for (double x = 0; x < qrCode.moduleCount; x++) {
      for (double y = 0; y < qrCode.moduleCount; y++) {
        if (qrCode.isDark(y.toInt(), x.toInt())) {
          canvas.drawRect(
              Rect.fromLTWH(
                x * scale + marginForQrCodeExtra,
                y * scale + marginForQrCodeExtra + textPainter.height,
                scale,
                scale,
              ),
              Paint()..color = Colors.black);
        }
      }
    }

    textPainter.paint(canvas,  Offset( whatByWhat / 2 - textPainter.width / 2, 20));

    final picture = recorder.endRecording();
    final image = await picture.toImage(whatByWhat.toInt(), whatByWhat.toInt() + textPainter.height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!;
  }

  static Future<bool> shareTickets(ByteData data, BuildContext context,
      String ticketNumber, int index, String movieName, String time) async {
    if ((Platform.isAndroid || Platform.isIOS) &&
        !await Permission.storage.request().isGranted) {
      return false;
    }

    final tempDir = await getTemporaryDirectory();
    final filePaths = ["${tempDir.path}/image$ticketNumber.png"];

    if (Settings.extraQrCode) {
      filePaths.add("${tempDir.path}/extraQR$ticketNumber.png");
    }

    final List<File> files = [];
    for (int i = 0; i < filePaths.length; ++i) {
      files.add(File(filePaths[i]));
      if (await files[i].exists()) {
        await files[i].delete();
        await files[i].create();
      } else {
        await files[i].create();
      }
    }

    await files[0].writeAsBytes(data.buffer.asInt8List());
    if (Settings.extraQrCode) {
      await files[1].writeAsBytes(
        (await _generateExtraQrCode(index, movieName, time)).buffer.asInt8List(),
      );
    }

    try {
      Share.shareFiles(filePaths,
          text: ticketNumber, subject: "Sharing cinema ticket");
    } catch (e) {
      if (kDebugMode) print("Error: ${e.toString()}");
      print("Saving files instead to ${filePaths}");
    }
    return true;
  }

  static Future printTickets(List<ByteData> data) async {
    final doc = pw.Document();

    for (var element in data) {
      final image = pw.MemoryImage(element.buffer.asUint8List());
      doc.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(image));
          },
          pageTheme: const pw.PageTheme(
            orientation: pw.PageOrientation.landscape,
            margin: pw.EdgeInsets.zero,
          ),
        ),
      );
    }

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
      );
    } catch (e) {
      return false;
    }

    return true;
  }
}
