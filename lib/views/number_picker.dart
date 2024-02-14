import 'package:flutter/material.dart';

Widget numberPicker(int lowerBound, int upperBound, int Function() currentValue, void Function(int newValue) updateValue) {
  return Row(
    children: [
      const Text("Set word to"),
      IconButton(
        icon: Icon(
          Icons.remove,
          color: currentValue() == lowerBound ? Colors.grey : Colors.black,
        ),
        onPressed: currentValue() == lowerBound ? () {} : () {
          updateValue(currentValue() - 1);
        },
      ),
      Text(currentValue().toString()),
      IconButton(
        icon: Icon(
          Icons.add,
          color: currentValue() == upperBound ? Colors.grey : Colors.black,
        ),
        onPressed: currentValue() == upperBound ? () {} :() {
          int newValue = currentValue() + 1;
          updateValue(newValue);
        },
      ),
      const Text("characters"),
    ]
  );
}