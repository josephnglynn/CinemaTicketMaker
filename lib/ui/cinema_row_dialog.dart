import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget newRowForLayoutDialog(BuildContext context) {
  final TextEditingController rowIdentifier = TextEditingController();
  final TextEditingController numberOfSeats = TextEditingController(text: "1");

  return Scaffold(
    appBar: AppBar(
      title: const Text("Add new row"),
    ),
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(
            height: 80,
          ),
          const Text("Row identifier"),
          TextField(
            controller: rowIdentifier,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 80,
          ),
          const Text("Number of seats"),
          TextField(
            controller: numberOfSeats,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ),
    bottomSheet: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () async {
              if (rowIdentifier.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("The row identifier cannot be empty"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              int nS = int.parse(numberOfSeats.text);

              if (numberOfSeats.text.isEmpty || nS <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("The number of seats cannot be empty  or <= 0"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Settings.cinemaLayout.addRow(
                rowIdentifier.text,
                nS,
              );

              await Settings.updateCinemaLayout();

              Navigator.of(context).pop();
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget deleteRowForLayoutDialog(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Delete a row"),
    ),
    body: SafeArea(
      child: StatefulBuilder(
        builder: (context, setState) => Settings.cinemaLayout.rows.isEmpty
            ? const Center(
                child: Text("Oops there aren't any rows"),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: Settings.cinemaLayout.rows
                    .map(
                      (e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Row identifier: ${e.rowIdentifier}"),
                          Text("Row length: ${e.length}"),
                          IconButton(
                            onPressed: () async {
                              Settings.cinemaLayout.rows.remove(e);
                              await Settings.updateCinemaLayout();
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
      ),
    ),
  );
}
