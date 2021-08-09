import 'dart:io';

import 'package:cinema_ticket_maker/api/generatetickets.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/types/pagesize.dart';
import 'package:flutter/cupertino.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Tickets Before Printing"),
      ),
      body: SafeArea(
        child: FutureBuilder<List<ByteData>>(
          future: Tickets.generate(
            TicketData(widget.movieName, 100, Settings.cinemaLong,
                Settings.cinemaShort, DateTime.now()),
            "A4",
            2,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data!.length * 2,
                itemBuilder: (context, index) {
                  if (index % 2 == 0) {
                    return  SizedBox(
                      height: 20,
                      child: Text("Page ${index / 2}"),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Image(
                      image: MemoryImage(snapshot.data![(index - 1) ~/ 2].buffer
                          .asUint8List()),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text("Loading . . ."),
            );
          },
        ),
      ),
    );
  }
}
