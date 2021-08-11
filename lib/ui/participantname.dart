import 'package:cinema_ticket_maker/ui/viewerpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ParticipantNamePage extends StatefulWidget {
  final String movieName;

  const ParticipantNamePage(this.movieName, {Key? key}) : super(key: key);

  @override
  _ParticipantNamePageState createState() => _ParticipantNamePageState();
}

class _ParticipantNamePageState extends State<ParticipantNamePage> {
  List<String> participants = [];
  final controller = TextEditingController();
  final focusNode = FocusNode();

  void onSubmit(String value) {
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Can't be empty"),
          backgroundColor: Colors.red,
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
      return;
    }
    setState(() {
      participants.add(value);
      controller.clear();
      focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double calculations = width > 400 ? width / 2 : width - 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Input participants names"),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Please add the participants for ${widget.movieName}",
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: calculations,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      onSubmitted: onSubmit,
                      focusNode: focusNode,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onSubmit(controller.text),
                  child: const Text("Add Participant"),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        actionPane: const SlidableDrawerActionPane(),
                        child: SizedBox(
                          height: 30,
                          child: Text(
                            participants[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                        secondaryActions: [
                          IconSlideAction(
                            color: Colors.red,
                            icon: Icons.restore_from_trash,
                            onTap: () => setState(() {
                              participants.removeAt(index);
                            }),
                          )
                        ],
                      );
                    },
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
              onPressed: () => DatePicker.showDateTimePicker(
                context,
                onConfirm: (value) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewerPage(
                      widget.movieName,
                      participants.length,
                      value,
                      participantNames: participants,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
