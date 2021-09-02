import 'package:cinema_ticket_maker/types/ticket_colors.dart';
import 'package:cinema_ticket_maker/ui/homepage.dart';
import 'package:cinema_ticket_maker/ui/new_user.dart';
import 'package:flutter/material.dart';
import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.init();
  await TicketColors.init();

  runApp(
    MaterialApp(
      title: "Cinema Ticket Maker",
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),

      ),
      themeMode: ThemeMode.system,
      home: Settings.newUser ? const NewUser() : const HomePage(),
    ),
  );
}
