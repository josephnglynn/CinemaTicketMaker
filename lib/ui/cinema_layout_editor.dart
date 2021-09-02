import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cinema_row_dialog.dart';



class CinemaLayoutEditor extends StatefulWidget {
  const CinemaLayoutEditor({Key? key}) : super(key: key);

  @override
  _CinemaLayoutEditorState createState() => _CinemaLayoutEditorState();
}

class _CinemaLayoutEditorState extends State<CinemaLayoutEditor> {
  List<Widget> workOutChildren() {
    List<Widget> widgets = [];

    widgets.add(
      LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                "Cinema Screen",
                textAlign: TextAlign.center,
              ),
              width: constraints.maxWidth,
              color: Colors.grey,
            ),
            padding: const EdgeInsets.all(20),
          );
        },
      ),
    );

    int maxSize =1 ;
    for (int i = 0 ; i < Settings.cinemaLayout.rows.length; ++i) {
      if (Settings.cinemaLayout.rows[i].length > maxSize) maxSize = Settings.cinemaLayout.rows[i].length;
    }


    widgets.addAll(
      Settings.cinemaLayout.rows
          .map(
            (e) => LayoutBuilder(
              builder: (context, constraints) {
                List<Widget> contents = [];

                double pad = constraints.maxWidth * 0.01;
                double value = constraints.maxWidth / maxSize - pad * 2;

                contents.add(
                  Padding(
                    padding: const EdgeInsets.all(1),
                    child: Text(e.rowIdentifier),
                  ),
                );

                for (int i = 0; i < e.length; ++i) {
                  contents.add(
                    SizedBox(
                      width: value + pad,
                      height: value + pad,
                      child: const Padding(
                        padding: EdgeInsets.all(1),
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                contents.add(
                  Padding(
                    padding: const EdgeInsets.all(1),
                    child: Text(e.rowIdentifier),
                  ),
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: contents,
                );
              },
            ),
          )
          .toList(),
    );
    return widgets;
  }

  bool edit = false;

  Widget floatingBarNavigation() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: edit ? 0 : 1, end: edit ? 1 : 0),
      duration: const Duration(milliseconds: 200),
      builder: (_, double value, __) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: Offset(0, 190 * value),
              child: Opacity(
                opacity: 1 - value,
                child: Padding(
                  child: FloatingActionButton(
                    heroTag: "btn1",
                    child: const Icon(Icons.add),
                    backgroundColor: Colors.lightGreenAccent,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context1) => newRowForLayoutDialog(context1),
                      ).then(
                        (value) => setState(() {
                          edit = !edit;
                        }),
                      );
                    },
                  ),
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, 95 * value),
              child: Opacity(
                opacity: 1 - value,
                child: Padding(
                  child: FloatingActionButton(
                    heroTag: "btn2",
                    backgroundColor: Colors.redAccent.shade200,
                    child: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context1) => deleteRowForLayoutDialog(context1),
                      ).then(
                            (value) => setState(() {
                          edit = !edit;
                        }),
                      );
                    },
                  ),
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
            Padding(
              child: FloatingActionButton(
                heroTag: "btn3",
                child: Icon(edit ? Icons.edit : Icons.cancel),
                backgroundColor:
                    Color.lerp(Colors.orange, Colors.lightBlueAccent, value),
                onPressed: () {
                  setState(() => edit = !edit);
                },
              ),
              padding: const EdgeInsets.all(20),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cinema Layout View"),
      ),
      body: SafeArea(
        child: Settings.cinemaLayout.rows.isEmpty
            ? const Center(
                child: Text(
                  "No layout data",
                  textAlign: TextAlign.center,
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: workOutChildren(),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: floatingBarNavigation(),
    );
  }
}
