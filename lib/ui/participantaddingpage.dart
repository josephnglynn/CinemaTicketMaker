import 'package:cinema_ticket_maker/ui/viewerpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ParticipantAddingPage extends StatefulWidget {
  final String movieName;

  const ParticipantAddingPage(this.movieName, {Key? key}) : super(key: key);

  @override
  _ParticipantAddingPageState createState() => _ParticipantAddingPageState();
}

class _ParticipantAddingPageState extends State<ParticipantAddingPage> {
  int participants = 0;
  final controller = TextEditingController();

  void onSubmit(String value) {
    if (value.isEmpty) return;
    setState(() {
      participants = int.parse(value);
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ViewerPage(widget.movieName, participants),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double calculations = width > 400 ? width / 2 : width - 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Input number of participants"),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Please enter number of participants for ${widget.movieName}",
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text (
                    "Only numbers!",
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: calculations,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      onSubmitted: onSubmit,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: const Text("Continue"),
              onPressed: () => onSubmit(controller.text),
            ),
          ],
        ),
      ),
    );
  }
}
