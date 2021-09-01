import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/ui/reference_number_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ReferenceContainerViewer extends StatefulWidget {
  const ReferenceContainerViewer({Key? key}) : super(key: key);

  @override
  _ReferenceContainerViewerState createState() =>
      _ReferenceContainerViewerState();
}

class _ReferenceContainerViewerState extends State<ReferenceContainerViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reference Number Selector"),
      ),
      body: SafeArea(
        child: Settings.referenceContainers.isEmpty
            ? const  Center(
                child: Text(
                  "Oops, you haven't made any tickets yet",
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: Settings.referenceContainers.length,
                itemBuilder: (context, index) => Slidable(
                  actionPane: const SlidableDrawerActionPane(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text(
                          Settings.referenceContainers[index].info,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReferenceNumberViewer(
                                rN: Settings
                                    .referenceContainers[index].refNumbers,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                        ),
                      )
                    ],
                  ),
                  secondaryActions: [
                    IconSlideAction(
                      caption: "Remove",
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () async {
                        setState(() {
                          Settings.referenceContainers.removeAt(index);
                        });
                        await Settings.updateRefContainers();
                      },
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
