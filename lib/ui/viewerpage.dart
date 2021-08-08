import 'package:cinema_ticket_maker/api/generatetickets.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

    Future.microtask(() async {
     //TODO final result = await Tickets.generate(ticketData, paperSize, scale)
    } );

    return Scaffold(
      body: SafeArea(
        child: CustomPaint(
          painter: CoolPainter(widget.movieName, widget.participants),
        ),
      ),
    );
  }
}

class CoolPainter extends CustomPainter {
  final String movieName;
  final int participants;

  CoolPainter(this.movieName, this.participants);

  @override
  void paint(Canvas canvas, Size size) {
    double x = 0, y = 0;
    Tickets.drawTicketComponent(
      canvas,
      x,
      y,
      Tickets.defaultTicketSize * 1,
      1,
      TicketData(
          movieName, participants, Settings.cinemaLong, Settings.cinemaShort, DateTime.now()),
      1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
