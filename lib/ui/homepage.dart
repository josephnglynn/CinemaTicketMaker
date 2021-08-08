import 'package:cinema_ticket_maker/ui/participantaddingpage.dart';
import 'package:cinema_ticket_maker/ui/settingspage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();

  void onSubmit(String value, {bool ignoreEmpty = false}) {
    if (value.isEmpty && !ignoreEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("Are you sure you want the movie name to be empty?"),
          action: SnackBarAction(
            label: "Yes",
            onPressed: () => onSubmit(value, ignoreEmpty: true),
            textColor: Colors.green,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ParticipantAddingPage(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Welcome To Cinema Ticket Maker",
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
            const Text(
              "Please enter the name of the movie below",
              textAlign: TextAlign.center,
            ),
            Padding(
              child: Center(
                child: SizedBox(
                  width: width > 400 ? width / 2 : width - 40,
                  child: TextField(
                    controller: textController,
                    onSubmitted: onSubmit,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(10),
            )
          ],
        ),
      ),
      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            child: TextButton(
              onPressed: () => onSubmit(textController.text),
              child: const Text("Continue"),
            ),
            padding: const EdgeInsets.all(10),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
        },
        child: Icon(
          Icons.settings,
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
