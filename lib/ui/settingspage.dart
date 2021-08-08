import 'package:cinema_ticket_maker/api/generatetickets.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/pagesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  double ticketScale = Settings.getTicketScale();
  final shortNameController = TextEditingController(text: Settings.cinemaShort);
  final longNameController = TextEditingController(text: Settings.cinemaLong);

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
                        ticketScale),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () async {
                    setState(() {
                      ticketScale -= 0.01;
                    });
                    await Settings.setTicketScale(ticketScale);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                Text("Scale: $ticketScale"),
                IconButton(
                  onPressed: () async {
                    setState(() {
                      ticketScale += 0.01;
                    });
                    await Settings.setTicketScale(ticketScale);
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
            const SizedBox(
              height: 100,
            ),
            const Text(
              "Ticket background colors",
              style: headerStyle,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                ],
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
        TicketData("Star Wars", 1, Settings.cinemaLong,
            Settings.cinemaShort, DateTime.now()),
        1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
