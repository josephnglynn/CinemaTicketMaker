import 'dart:ui' as ui;
import 'package:async/async.dart';
import 'package:cinema_ticket_maker/api/tickets.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/page_resolution.dart';
import 'package:cinema_ticket_maker/types/page_size.dart';
import 'package:cinema_ticket_maker/types/ticket_colors.dart';
import 'package:cinema_ticket_maker/types/ticket_data.dart';
import 'package:cinema_ticket_maker/ui/cinema_layout_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const headerStyle = TextStyle(
    fontSize: 30,
  );

  final shortNameController = TextEditingController(text: Settings.cinemaShort);
  final longNameController = TextEditingController(text: Settings.cinemaLong);
  final digitForRefController = TextEditingController(
    text: Settings.digitsForReferenceNumber.toString(),
  );

  ui.Image? img;
  bool updateScale = true;
  CancelableOperation? cancelableOperation;
  double previous= 0;
  bool executingUpdate = false;

  void getColor(Color value, Function(Color) func) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pick a new color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: value,
            onColorChanged: (Color color) => func(color),
            showLabel: true,
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Finished!"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.theme.firstColorBackground,
            (value) async {
              await TicketColors.updateTheme();
              setState(() {});
            },
          );
        },
        child: Text(
          "Change first color",
          style: TextStyle(
            color: TicketColors.theme.primaryText,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.theme.firstColorBackground,
        ),
      ),
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.theme.secondColorBackground,
            (value) async {
              await TicketColors.updateTheme();
              setState(() {});
            },
          );
        },
        child: Text(
          "Change second color",
          style: TextStyle(
            color: TicketColors.theme.secondaryText,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.theme.secondColorBackground,
        ),
      ),
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.theme.alt,
            (value) async {
              await TicketColors.updateTheme();
              setState(() {});
            },
          );
        },
        child: Text(
          "Change alternative color",
          style: TextStyle(
            color: TicketColors.theme.firstColorBackground,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.theme.alt,
        ),
      ),
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.theme.primaryText,
            (value) async {
              await TicketColors.updateTheme();
              setState(() {});
            },
          );
        },
        child: Text(
          "Change primary text color",
          style: TextStyle(
            color: TicketColors.theme.firstColorBackground,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.theme.primaryText,
        ),
      ),
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.theme.secondaryText,
            (value) async {
              await TicketColors.updateTheme();
              setState(() {});
            },
          );
        },
        child: Text(
          "Change secondary text color",
          style: TextStyle(
            color: TicketColors.theme.secondColorBackground,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.theme.secondaryText,
        ),
      ),
    ];

    final width = MediaQuery.of(context).size.width;
    final scale = width /
        (pageSizes["A4"] ??
                const PageResolution(
                  1,
                  1,
                ))
            .width *
        Settings.ticketScale;


    if (updateScale) {
      if (cancelableOperation != null) cancelableOperation!.cancel();
      cancelableOperation = CancelableOperation.fromFuture(
        Future(() async {
          img = await Tickets.loadIcon(scale);
          setState(() {
            updateScale = false;
          });
        }),
      );
    }


    if ( previous != width && !executingUpdate ) {
      executingUpdate = true;
      Future.delayed(const Duration(seconds: 1), () async {
        img = await Tickets.loadIcon(scale);
        setState(() {
          updateScale = false;
          executingUpdate = false;
          previous = width;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Ticket Scale",
              style: headerStyle,
            ),
            const Padding(
              child: Text("Long side of A4 below"),
              padding: EdgeInsets.only(left: 10, top: 10),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: Colors.purple,
                  ),
                  child: CustomPaint(
                    painter: TicketPainter(scale, img),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    setState(() {
                      Settings.ticketScale -= 1;
                      updateScale = true;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  onLongPress: () async {
                    setState(() {
                      Settings.ticketScale -= 0.2;
                      updateScale = true;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: TicketColors.theme.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      Settings.ticketScale += 1;
                      updateScale = true;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  onLongPress: () async {
                    setState(() {
                      Settings.ticketScale += 0.2;
                      updateScale = true;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: TicketColors.theme.primaryText,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50 * Settings.ticketScale,
            ),
            const Text(
              "Ticket background colors",
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: children,
                    )
                  : Column(
                      children: children,
                    ),
            ),
            const Text(
              "Cinema short name",
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: shortNameController,
              onChanged: (value) async {
                await Settings.setCinemaShort(value);
                setState(() {});
              },
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Cinema long name",
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: longNameController,
              onChanged: (value) async {
                await Settings.setCinemaLong(value);
                setState(() {});
              },
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Number of digits for reference number",
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
            TextField(
              textAlign: TextAlign.center,
              controller: digitForRefController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) async {
                if (value.isEmpty) return;
                int parsed = int.parse(value);
                if (parsed < 1) return;
                await Settings.setDigitsForReferenceNumber(parsed);
                setState(() {});
              },
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add people's name to ticket",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Switch(
                  value: Settings.includeNames,
                  onChanged: (value) async {
                    await Settings.setIncludeNamesLocation(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Same ref number for each ticket",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Switch(
                  value: Settings.sameRefForEachTicket,
                  onChanged: (value) async {
                    await Settings.setSameRefForEachTicket(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Share instead of print",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Switch(
                  value: Settings.shareInsteadOfPrint,
                  onChanged: (value) async {
                    await Settings.setShareInsteadOfPrint(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add extra qr code when sharing",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Switch(
                  value: Settings.extraQrCode,
                  onChanged: (value) async {
                    await Settings.setExtraQrCodes(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Use old ticket style",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Switch(
                  value: Settings.oldTheme,
                  onChanged: (value) async {
                    await Settings.setOldTheme(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add seat and row numbers to each ticket",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                Switch(
                  value: Settings.addSeatAndRowNumbers,
                  onChanged: (value) async {
                    await Settings.setAddSeatAndRowNumbers(value);
                    setState(() {});
                  },
                ),
              ],
            ),
            Settings.addSeatAndRowNumbers
                ? Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: TextButton(
                      child: const Text("Edit cinema layout"),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CinemaLayoutEditor(),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "Copyright (c) 2021 Joseph Glynn",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

class TicketPainter extends CustomPainter {
  final double scale;
  final ui.Image? image;

  TicketPainter(this.scale, this.image);

  final data = TicketData(
    "Star Wars: Episode V - The Empire Strikes Back",
    1,
    Settings.cinemaLong,
    Settings.cinemaShort,
    DateTime.now(),
  );

  @override
  void paint(Canvas canvas, Size size) async {
    double x = 0, y = 0;
    Settings.oldTheme
        ? Tickets.drawTicketComponentOld(
            canvas,
            x,
            y,
            Tickets.defaultTicketSize * scale,
            scale,
            data,
            "John Smith",
            row: "A",
            number: "2",
          )
        : Tickets.drawTicketComponentNew(
            canvas,
            x,
            y,
            Tickets.newTicketSize * scale,
            scale,
            data,
            "John Smith",
            image,
            row: "A",
            number: "2",
          );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
