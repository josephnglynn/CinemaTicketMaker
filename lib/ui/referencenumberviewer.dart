import 'package:cinema_ticket_maker/api/settings.dart';
import 'package:cinema_ticket_maker/api/tickets.dart';
import 'package:cinema_ticket_maker/ui/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReferenceNumberViewer extends StatefulWidget {
  const ReferenceNumberViewer({Key? key}) : super(key: key);

  @override
  _ReferenceNumberViewerState createState() => _ReferenceNumberViewerState();
}

class _ReferenceNumberViewerState extends State<ReferenceNumberViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reference Number Viewer"),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(30),
          itemCount: Tickets.refNumbers!.length,
          itemBuilder: (context, index) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Tickets.refNumbers![index].name),
              Text(Tickets.refNumbers![index].number),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                final doc = pw.Document();

                doc.addPage(
                  pw.Page(
                    build: (context) => pw.ListView.builder(
                      itemCount: Tickets.refNumbers!.length,
                      itemBuilder: (context, index) => pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(Tickets.refNumbers![index].name),
                          pw.Text(Tickets.refNumbers![index].number),
                        ],
                      ),
                    ),
                  ),
                );

                if (Settings.shareInsteadOfPrint) {
                  await Printing.sharePdf(
                    bytes: await doc.save(),
                    filename: "Cinema tickets",
                  );
                  return;
                }

                await Printing.layoutPdf(
                  onLayout: (format) async => doc.save(),
                );
              },
              child: const Text("Print"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Tickets.refNumbers = null;
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                    (route) => false);
              },
              child: const Text("Exit"),
            ),
          ],
        ),
      ),
    );
  }
}
