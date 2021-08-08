import 'package:cinema_ticket_maker/api/generatetickets.dart';
import 'package:cinema_ticket_maker/ui/homepage.dart';
import 'package:flutter/material.dart';

import 'api/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  await TicketColors.init();

  runApp(
    const MaterialApp(
      title: "Cinema Ticket Maker",
      home: HomePage(),
    ),
  );
}
