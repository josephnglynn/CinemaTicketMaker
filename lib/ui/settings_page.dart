import 'package:cinema_ticket_maker/api/tickets.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/page_resolution.dart';
import 'package:cinema_ticket_maker/types/page_size.dart';
import 'package:cinema_ticket_maker/types/ticket_colors.dart';
import 'package:cinema_ticket_maker/types/ticket_data.dart';
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
  final digitForRefController =
      TextEditingController(text: Settings.digitsForReferenceNumber.toString());

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
            TicketColors.firstColorBackground,
            (value) => setState(() {
              TicketColors.setFirstColorBackground(value);
            }),
          );
        },
        child: Text(
          "Change first color",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.firstColorBackground,
        ),
      ),
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.lastColorBackground,
            (value) => setState(() {
              TicketColors.setLastColorBackground(value);
            }),
          );
        },
        child: Text(
          "Change second color",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.lastColorBackground,
        ),
      ),
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.primaryText,
            (value) => setState(() {
              TicketColors.setPrimaryTextColorBackground(value);
            }),
          );
        },
        child: const Text(
          "Change primary text color",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.primaryText,
        ),
      ),
      TextButton(
        onPressed: () {
          getColor(
            TicketColors.secondaryText,
            (value) => setState(() {
              TicketColors.setSecondaryTextColorBackground(value);
            }),
          );
        },
        child: const Text(
          "Change secondary text color",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: TicketColors.secondaryText,
        ),
      ),
    ];

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
                    painter: TicketPainter(constraints.maxWidth /
                        (pageSizes["A4"] ??
                                const PageResolution(
                                  1,
                                  1,
                                ))
                            .width *
                        Settings.ticketScale),
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
                      Settings.ticketScale -= 0.02;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  onLongPress: () async {
                    setState(() {
                      Settings.ticketScale -= 0.2;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).textTheme.bodyText1!.color,
                  ),
                ),
                Text("Scale: ${Settings.ticketScale}"),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      Settings.ticketScale += 0.02;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  onLongPress: () async {
                    setState(() {
                      Settings.ticketScale += 0.2;
                    });
                    await Settings.setTicketScale(Settings.ticketScale);
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).textTheme.bodyText1!.color,
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
                  "Same reference number for each ticket",
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
            const Text(
              "Number of digits for reference number",
              style: headerStyle,
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

  TicketPainter(this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    double x = 0, y = 0;
    Tickets.drawTicketComponent(
      canvas,
      x,
      y,
      Tickets.defaultTicketSize * scale,
      scale,
      TicketData(
        "Star Wars",
        1,
        Settings.cinemaLong,
        Settings.cinemaShort,
        DateTime.now(),
      ),
      "John Smith",
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
