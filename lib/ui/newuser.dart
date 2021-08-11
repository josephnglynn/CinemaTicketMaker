import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/ui/homepage.dart';
import 'package:cinema_ticket_maker/ui/settingspage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewUser extends StatelessWidget {
  const NewUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Center(
          child: Text(
            "Hi, before you get started, we suggest you go to the settings page to setup some key settings, such as ticket sizes and colors, your cinema name and more!",
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(20),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                primary: Colors.white,
              ),
              onPressed: () async {
                await Settings.setIfNewUser(false);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                        (route) => false);
              },
              child: const Text("Nah, I'm fine"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                primary: Colors.white,
              ),
              onPressed: () async {
                await Settings.setIfNewUser(false);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                        (route) => false);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              child: const Text("Ok, lets go"),
            ),
          ],
        ),
      ),
    );
  }
}
