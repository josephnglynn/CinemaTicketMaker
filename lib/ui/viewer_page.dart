import 'package:cinema_ticket_maker/api/tickets.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/ticket_data.dart';
import 'package:cinema_ticket_maker/ui/homepage.dart';
import 'package:cinema_ticket_maker/ui/reference_number_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget afterOutput(BuildContext context, List<ByteData> data) {
  final action = Settings.shareInsteadOfPrint ? "Share" : "Print";
  return AlertDialog(
    title: Text("${action}ing now"),
    content: Text(
      "Would you like to either: \nView reference number ( and optionally $action them ), $action again or restart?",
    ),
    actionsAlignment: MainAxisAlignment.spaceBetween,
    actionsPadding: const EdgeInsets.all(10),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReferenceNumberViewer(),
            ),
          );
        },
        child: const Text("View reference Number"),
        style: TextButton.styleFrom(
            backgroundColor: Colors.green, primary: Colors.white),
      ),
      TextButton(
        onPressed: () async => Settings.shareInsteadOfPrint
            ? () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => shareDialog(context, data),
                );
              }
            : await Tickets.printTickets(data),
        child: Text("$action again"),
        style: TextButton.styleFrom(
            backgroundColor: Colors.orange, primary: Colors.white),
      ),
      TextButton(
        onPressed: () {
          Tickets.currentRefNumbers = null;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (route) => false);
        },
        child: const Text("Restart"),
        style: TextButton.styleFrom(
            backgroundColor: Colors.red, primary: Colors.white),
      ),
    ],
  );
}

Widget shareDialog(BuildContext context, List<ByteData> data) {
  int index = 0;
  return StatefulBuilder(
    builder: (context, setState) => AlertDialog(
      title: Text("Sharing Tickets - Ticket ${index + 1}"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_sharp),
            onPressed: () {
              if (index != 0) setState(() => index--);
            },
          ),
          Image(
            image: MemoryImage(data[index].buffer.asUint8List()),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_sharp),
            onPressed: () {
              if (index < data.length - 1) setState(() => index++);
            },
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: const Text("Share"),
              onPressed: () => Tickets.shareTickets(
                  data[index], context, "Ticket ${index + 1}"),
            ),
          ],
        )
      ],
    ),
  );
}

class ViewerPage extends StatefulWidget {
  final String movieName;
  final int participants;
  final List<String>? participantNames;
  final DateTime dateTime;

  const ViewerPage(this.movieName, this.participants, this.dateTime,
      {Key? key, this.participantNames})
      : super(key: key);

  @override
  _ViewerPageState createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () async => await generateTickets(),
    );
  }

  List<ByteData>? data;

  Future<void> generateTickets() async {
    data = await Tickets.generate(
      TicketData(
        widget.movieName,
        widget.participants,
        Settings.cinemaLong,
        Settings.cinemaShort,
        widget.dateTime,
      ),
      "A4",
      Settings.ticketScale,
      widget.participantNames,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Tickets Before Printing"),
      ),
      body: SafeArea(
        child: data != null
            ? ListView.builder(
                itemCount: data!.length * 2,
                itemBuilder: (context, index) {
                  if (index % 2 == 0) {
                    return SizedBox(
                      height: 20,
                      child: Text(
                          "${Settings.shareInsteadOfPrint ? "Ticket" : "Page"} ${index ~/ 2 + 1}"),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Image(
                      image: MemoryImage(
                        data![(index - 1) ~/ 2].buffer.asUint8List(),
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text("Loading . . ."),
              ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              if (data == null) return;
              if (Settings.shareInsteadOfPrint) {
                showDialog(
                  context: context,
                  builder: (context) => shareDialog(context, data!),
                );
                return;
              }
              await Tickets.printTickets(data!);
              showDialog(
                context: context,
                builder: (context) => afterOutput(context, data!),
              );
            },
            child: Text(Settings.shareInsteadOfPrint ? "Share" : "Print"),
          )
        ],
      ),
    );
  }
}
