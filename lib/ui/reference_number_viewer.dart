import 'package:cinema_ticket_maker/api/tickets.dart';
import 'package:cinema_ticket_maker/types/ref_number.dart';
import 'package:cinema_ticket_maker/ui/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ReferenceNumberViewer extends StatefulWidget {
  late final List<RefNumber>? refNumber;
  late final List<Map<String, dynamic>> copy;

  ReferenceNumberViewer({Key? key, List<RefNumber>? rN}) : super(key: key) {
    rN != null ? refNumber = rN : refNumber = Tickets.currentRefNumbers;
    copy = refNumber!.map((e) => e.toJson()).toList();
  }

  @override
  _ReferenceNumberViewerState createState() => _ReferenceNumberViewerState();
}

class _ReferenceNumberViewerState extends State<ReferenceNumberViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reference Number Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                widget.refNumber!.removeWhere((element) => true);
                widget.refNumber!.addAll(
                  widget.copy.map((e) => RefNumber.fromJson(e)).toList(),
                );
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: widget.refNumber!.isEmpty
            ? const Center(
                child: Padding(
                  child: Text(
                    "We're good to go, there are no more tickets to check.",
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(20),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(30),
                itemCount: widget.refNumber!.length + 1,
                itemBuilder: (context, index) => index == 0
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Name"),
                            Text("Ref number"),
                            Text("Scanned"),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.refNumber![index - 1].name),
                          Text(widget.refNumber![index - 1].number),
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              setState(() {
                                widget.refNumber!.removeAt(index - 1);
                              });
                            },
                          )
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
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Tickets.currentRefNumbers = null;
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                    (route) => false);
              },
              child: const Text("Exit"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.blue,
              ),
              onPressed: () async {
                final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                  "#ff6666",
                  "Cancel",
                  false,
                  ScanMode.DEFAULT,
                );
                final data = barcodeScanRes.split(Tickets.uniqueSplitter);
                if (data.length != 2) {
                  return showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Error"),
                      backgroundColor: Colors.red,
                      content: const Text(
                          "There was an issue scanning that QR code"),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green),
                        )
                      ],
                    ),
                  );
                }
                try {
                  final entity = widget.refNumber!
                      .firstWhere((element) => element.name == data[0]);
                  if (entity.number != data[1]) {
                    throw "Hmm this QR code is faulty";
                  }

                  setState(() {
                    widget.refNumber!.remove(entity);
                  });

                  return showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Success"),
                      backgroundColor: Colors.green,
                      content: Text(
                        "Ticket is correct for ${data[0]}",
                        textAlign: TextAlign.center,
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blue),
                        )
                      ],
                    ),
                  );
                } catch (e) {
                  return showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Error"),
                      backgroundColor: Colors.red,
                      content: const Text(
                          "Can't find this ticket in system, try again"),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.green),
                        )
                      ],
                    ),
                  );
                }
              },
              child: const Text("Scan"),
            ),
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
                      itemCount: widget.refNumber!.length,
                      itemBuilder: (context, index) => pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(widget.refNumber![index].name),
                          pw.Text(widget.refNumber![index].number),
                        ],
                      ),
                    ),
                  ),
                );

                await Printing.layoutPdf(
                  onLayout: (format) async => doc.save(),
                );
              },
              child: const Text("Print"),
            ),
          ],
        ),
      ),
    );
  }
}
