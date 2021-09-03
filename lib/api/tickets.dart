import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/cinema_layout.dart';
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
  static const newTicketSize = TicketSize(230, 100);

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

  static void drawTicketComponentOld(
      Canvas canvas,
      double moveXBy,
      double moveYBy,
      TicketSize ticketSize,
      double scale,
      TicketData ticketData,
      String? name,
      {String? refNumber,
      String? row,
      String? number}) {
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
      TicketColors.theme.generateBackgroundGradient(background),
    );

    //MOVIE NAME
    double fontSize = 30 * scale;
    TextStyle style = TextStyle(
      color: TicketColors.theme.primaryText,
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

    textPainter.fitCertainWidth(ticketSize.width * 0.8);

    textPainter.paint(canvas, const Offset(10, 10) * scale);

    //VALID
    style = style.copyWith(fontSize: 12.52 * scale);
    textPainter.text = TextSpan(text: "VALID", style: style);
    textPainter.fitCertainWidth(background.width / 10);
    textPainter.paint(canvas, const Offset(10, 50) * scale);

    //VALID WHERE
    style = style.copyWith(fontSize: 16 * scale);
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
    style = style.copyWith(fontSize: 11 * scale);
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
              Rect.fromLTWH(xForShort, y * scale * _qrCodeScale + 10 * scale,
                  scale * _qrCodeScale, scale * _qrCodeScale),
              Paint()..color = TicketColors.theme.primaryText);
        }
      }
    }

    //DRAW SHORT NAME
    style = style.copyWith(
        fontSize: 20 * scale, color: TicketColors.theme.secondaryText);
    textPainter.text = TextSpan(text: ticketData.cinemaNameShort, style: style);
    textPainter.fitCertainWidth(background.width / 4);
    textPainter.paint(
      canvas,
      Offset(xForShort! - textPainter.width,
          -textPainter.height / 2 + 127.5 * scale),
    );

    if (Settings.addSeatAndRowNumbers) {
      //VALID
      style = style.copyWith(
          fontSize: 12.52 * scale, color: TicketColors.theme.primaryText);
      textPainter.text = TextSpan(text: "SEAT", style: style);
      textPainter.fitCertainWidth(background.width / 10);
      textPainter.paint(
          canvas, Offset(xForShort - textPainter.width, 67 * scale));

      style = style.copyWith(
          fontSize: 18.4 * scale, color: TicketColors.theme.primaryText);
      textPainter.text = TextSpan(text: "$row$number", style: style);
      textPainter.fitCertainWidth(background.width / 4);
      textPainter.paint(
          canvas, Offset(xForShort - textPainter.width, 84 * scale));
    }
  }

  static const _qrCodeScale = 1.75;

  static List<RefNumber>? currentRefNumbers;

  static void drawTicketComponentNew(
    Canvas canvas,
    double moveXBy,
    double moveYBy,
    TicketSize ticketSize,
    double scale,
    TicketData ticketData,
    String? name, {
    String? refNumber,
    String? row,
    String? number,
    TicketSize ts = Tickets.defaultTicketSize,
  }) {
    refNumber ??=
        _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);

    //Set Ticket Paints
    final pFirstBackground = Paint()
      ..color = TicketColors.theme.firstColorBackground;
    final pSecondBackground = Paint()
      ..color = TicketColors.theme.secondColorBackground;

    double aThird = ticketSize.width * 0.3;

    double aThirdPaddingW = aThird * 0.1;
    double aThirdWithPaddingW = aThird * 0.80;
    double aThirdH = ticketSize.height * 0.1;

    canvas.drawRRect(
        RRect.fromLTRBR(
            0, 0, aThird + 25, ticketSize.height, const Radius.circular(25)),
        pFirstBackground);
    canvas.drawRect(
        Rect.fromLTRB(aThird, 0, ticketSize.width - 25, ticketSize.height),
        pSecondBackground);
    canvas.drawRRect(
        RRect.fromLTRBR(ticketSize.width - 50, 0, ticketSize.width,
            ticketSize.height, const Radius.circular(25)),
        pSecondBackground);
    canvas.drawRect(
        Rect.fromLTWH(aThirdPaddingW, aThirdH, aThirdWithPaddingW,
            ticketSize.height * 0.05),
        pSecondBackground);

    final painter = CustomTextPainter(
      textDirection: TextDirection.ltr,
    );

    TextStyle style = TextStyle(
        fontSize: 4.95 * scale,
        color: TicketColors.theme.secondColorBackground);
    painter.text = TextSpan(text: ticketData.cinemaNameShort, style: style);
    painter.fitCertainWidth(aThirdWithPaddingW);
    painter.paint(
        canvas,
        Offset(aThirdPaddingW + (aThirdWithPaddingW - painter.width) / 2,
            ticketSize.height * 0.22));

    canvas.drawLine(
        Offset(aThirdPaddingW, ticketSize.height * 0.35),
        Offset(aThirdPaddingW + aThirdWithPaddingW, ticketSize.height * 0.35),
        pSecondBackground);
    canvas.drawLine(
        Offset(aThirdPaddingW, ticketSize.height * 0.7),
        Offset(aThirdPaddingW + aThirdWithPaddingW, ticketSize.height * 0.7),
        pSecondBackground);

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

    double center = ((qrCode.moduleCount - 1) * scale) + aThirdPaddingW * 2;
    for (double x = 0; x < qrCode.moduleCount; x++) {
      for (double y = 0; y < qrCode.moduleCount; y++) {
        if (qrCode.isDark(y.toInt(), x.toInt())) {
          canvas.drawRect(
              Rect.fromLTWH(x * scale + aThirdPaddingW,
                  y * scale + ticketSize.height * 0.75, scale, scale),
              Paint()..color = TicketColors.theme.primaryText);
        }
      }
    }

    style = style.copyWith(fontSize: 2.55 * scale);
    painter.text = TextSpan(text: "Reference Number:       ", style: style);
    painter.fitCertainWidth(aThirdWithPaddingW / 2);
    painter.paint(canvas, Offset(center, ticketSize.height * 0.875));

    style = style.copyWith(fontSize: 4.1 * scale);
    painter.text = TextSpan(text: "# $refNumber", style: style);
    painter.fitCertainWidth(aThirdWithPaddingW / 2);
    painter.paint(canvas, Offset(center, ticketSize.height * 0.92));

    if (Settings.addSeatAndRowNumbers) {
      double by5 = aThirdWithPaddingW / 3.575;

      painter.text = TextSpan(text: "ROW", style: style);
      painter.fitCertainWidth(by5);
      painter.paint(
          canvas,
          Offset(
              aThirdPaddingW + (aThirdWithPaddingW - painter.width) / 2 - by5,
              ticketSize.height * 0.58));

      painter.text = TextSpan(text: "SEAT", style: style);
      painter.fitCertainWidth(by5);
      painter.paint(
          canvas,
          Offset(
              aThirdPaddingW + (aThirdWithPaddingW - painter.width) / 2 + by5,
              ticketSize.height * 0.58));

      style = style.copyWith(
          fontSize: 16.50 * scale, color: TicketColors.theme.alt);
      painter.text = TextSpan(text: row, style: style);
      painter.fitCertainWidth(by5);
      painter.paint(
          canvas,
          Offset(
              aThirdPaddingW + (aThirdWithPaddingW - painter.width) / 2 - by5,
              ticketSize.height * 0.4));

      painter.text = TextSpan(text: number, style: style);
      painter.fitCertainWidth(by5);
      painter.paint(
          canvas,
          Offset(
              aThirdPaddingW + (aThirdWithPaddingW - painter.width) / 2 + by5,
              ticketSize.height * 0.4));
    }
  }

  static Future<List<ByteData>> _generateTicketsToShare(
    TicketData ticketData,
    double scale,
    List<String>? name,
  ) async {
    List<ByteData> result = [];
    currentRefNumbers = [];

    final CinemaLayout cinemaLayout = CinemaLayout.fromJson(
      Settings.cinemaLayout.toJson(),
    );

    final tSize = Settings.oldTheme
        ? Tickets.defaultTicketSize
        : Tickets.newTicketSize * scale;

    String refNumber =
        _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);

    while (ticketData.participants > 0) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      Settings.oldTheme
          ? Tickets.drawTicketComponentOld(
              canvas,
              0,
              0,
              tSize,
              scale,
              ticketData,
              name != null ? name[ticketData.participants - 1] : null,
              refNumber: refNumber,
              row: cinemaLayout.rows.isEmpty
                  ? "Stan"
                  : cinemaLayout.rows[0].rowIdentifier,
              number: cinemaLayout.rows.isEmpty
                  ? "ding"
                  : cinemaLayout.rows[0].length.toString(),
            )
          : Tickets.drawTicketComponentNew(
              canvas,
              0,
              0,
              tSize,
              scale,
              ticketData,
              name != null ? name[ticketData.participants - 1] : null,
              refNumber: refNumber,
              row: cinemaLayout.rows.isEmpty
                  ? "Stan"
                  : cinemaLayout.rows[0].rowIdentifier,
              number: cinemaLayout.rows.isEmpty
                  ? "ding"
                  : cinemaLayout.rows[0].length.toString(),
            );

      if (Settings.addSeatAndRowNumbers && cinemaLayout.rows.isNotEmpty) {
        if (cinemaLayout.rows[0].length <= 1) {
          cinemaLayout.rows.removeAt(0);
        } else if (cinemaLayout.rows.isNotEmpty) {
          cinemaLayout.rows[0].length--;
        }
      }

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

  static Future<List<ByteData>> _generateTicketsToPrint(
    TicketData ticketData,
    String paperSize,
    double scale,
    List<String>? name,
  ) async {
    List<ByteData> result = [];
    currentRefNumbers = []; //reset any previous ones

    final CinemaLayout cinemaLayout = CinemaLayout.fromJson(
      Settings.cinemaLayout.toJson(),
    );

    //Find Paper Size
    final pageResolution = pageSizes[paperSize] ??
        const PageResolution(
          2480,
          3508,
        );

    final tSize = Settings.oldTheme
        ? Tickets.defaultTicketSize
        : Tickets.newTicketSize * scale;

    while (ticketData.participants > 0) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      double x = 0, y = 0, pX = 0, pY = 0;

      String refNumber =
          _generateRandomListOfNumbers(Settings.digitsForReferenceNumber);

      while (ticketData.participants > 0) {
        Settings.oldTheme
            ? Tickets.drawTicketComponentOld(
                canvas,
                0,
                0,
                tSize,
                scale,
                ticketData,
                name != null ? name[ticketData.participants - 1] : null,
                refNumber: refNumber,
                row: cinemaLayout.rows.isEmpty
                    ? "Stan"
                    : cinemaLayout.rows[0].rowIdentifier,
                number: cinemaLayout.rows.isEmpty
                    ? "ding"
                    : cinemaLayout.rows[0].length.toString(),
              )
            : Tickets.drawTicketComponentNew(
                canvas,
                0,
                0,
                tSize,
                scale,
                ticketData,
                name != null ? name[ticketData.participants - 1] : null,
                refNumber: refNumber,
                row: cinemaLayout.rows.isEmpty
                    ? "Stan"
                    : cinemaLayout.rows[0].rowIdentifier,
                number: cinemaLayout.rows.isEmpty
                    ? "ding"
                    : cinemaLayout.rows[0].length.toString(),
              );

        if (Settings.addSeatAndRowNumbers && cinemaLayout.rows.isNotEmpty) {
          if (cinemaLayout.rows[0].length <= 1) {
            cinemaLayout.rows.removeAt(0);
          } else if (cinemaLayout.rows.isNotEmpty) {
            cinemaLayout.rows[0].length--;
          }
        }

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

    String seatNumber = "";
    int i = 0;
    int indexOfLoop = 0;
    while (true) {
      if (Settings.cinemaLayout.rows.length == indexOfLoop) break;
      i += Settings.cinemaLayout.rows[indexOfLoop].length;
      if (i > index) {
        seatNumber =
            "${Settings.cinemaLayout.rows[indexOfLoop].rowIdentifier}${Settings.cinemaLayout.rows[indexOfLoop].length}";
      }
      indexOfLoop++;
    }

    final textPainter = CustomTextPainter(
      text: TextSpan(
        text: "$movieName - $time - $seatNumber",
        style: const TextStyle(color: Colors.black, fontSize: 30),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.fitCertainWidth(size.width - 2 * marginForQrCodeExtra);

    double whatByWhat = (size.width > size.height ? size.height : size.width) +
        marginForQrCodeExtra * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, whatByWhat, whatByWhat + textPainter.height),
        Paint()..color = Colors.white);

    i = 1;
    QrCode qrCode;

    while (true) {
      qrCode = QrCode(i, QrErrorCorrectLevel.L);
      qrCode.addData(currentRefNumbers![index].name +
          uniqueSplitter +
          currentRefNumbers![index].number);
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

    textPainter.paint(
        canvas, Offset(whatByWhat / 2 - textPainter.width / 2, 20));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
        whatByWhat.toInt(), whatByWhat.toInt() + textPainter.height.toInt());
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
        (await _generateExtraQrCode(index, movieName, time))
            .buffer
            .asInt8List(),
      );
    }

    try {
      Share.shareFiles(filePaths,
          text: ticketNumber, subject: "Sharing cinema ticket");
    } catch (e) {
      if (kDebugMode) print("Error: ${e.toString()}");
      print("Saving files instead to $filePaths");
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
