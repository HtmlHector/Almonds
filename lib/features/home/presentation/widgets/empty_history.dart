import 'package:flutter/material.dart';

class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        spacing: 18,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Saved Products",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          Text(
            "Any products you save from the scanner will appear here.",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(onPressed: () {}, child: Text("Scan Product Now")),
        ],
      ),
    );
  }
}
