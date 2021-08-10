import 'package:cinema_ticket_maker/api/generatetickets.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewerPage extends StatefulWidget {
  final String movieName;
  final int participants;

  const ViewerPage(this.movieName, this.participants, {Key? key})
      : super(key: key);

  @override
  _ViewerPageState createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async => await generateTickets());
  }

  List<ByteData>? data;

  Future<void> generateTickets() async {
    data = await Tickets.generate(
      TicketData(
        widget.movieName,
        widget.participants,
        Settings.cinemaLong,
        Settings.cinemaShort,
        DateTime.now(),
      ),
      "A4",
      2,
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
                      child: Text("Page ${index / 2 + 1}"),
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
            onPressed: () {},
            child: const Text("Print"),
          )
        ],
      ),
    );
  }
}
