import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        child: Text("WHOA"),
      ),
    );
  }
}
