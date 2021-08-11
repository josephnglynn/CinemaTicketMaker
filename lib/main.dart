import 'package:cinema_ticket_maker/types/ticketcolors.dart';
import 'package:cinema_ticket_maker/ui/homepage.dart';
import 'package:cinema_ticket_maker/ui/newuser.dart';
import 'package:flutter/material.dart';

import 'api/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  await TicketColors.init();

  runApp(
    MaterialApp(
      title: "Cinema Ticket Maker",
      theme: ThemeData.light().copyWith(
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white)),
      darkTheme: ThemeData.dark().copyWith(
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black)),
      themeMode: ThemeMode.system,
      home: Settings.newUser ? const NewUser() : const HomePage(),
    ),
  );
}
