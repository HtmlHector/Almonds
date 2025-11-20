import 'package:flutter/material.dart';

class NutritionalInfo extends StatelessWidget {
  const NutritionalInfo(this.title, this.value, {super.key});

  final String title;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18),
            ),
            Text(value.toString()),
          ],
        ),
        Container(
          height: 1,
          color: Colors.grey,
        ),
      ],
    );
  }
}
