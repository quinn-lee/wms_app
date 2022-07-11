import 'package:flutter/material.dart';

class SelectInput extends StatefulWidget {
  const SelectInput({Key? key}) : super(key: key);

  @override
  State<SelectInput> createState() => _SelectInputState();
}

class _SelectInputState extends State<SelectInput> {
  String dropdownValue = 'one';
  final List<String> items = <String>['One', 'Two', 'Three', 'Four'];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15),
              width: 100,
              child: const Text(
                // widget.title,
                "test",
                style: TextStyle(fontSize: 16),
              ),
            ),
            _select()
          ],
        ),
        const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Divider(
              height: 1,
              thickness: 0.5,
            ))
      ],
    );
  }

  _select() {
    return Expanded(
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 12,
                elevation: 12,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                iconEnabledColor: Colors.red,
                onChanged: (newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: const [
          DropdownMenuItem(value: 'one', child: Text('One')),
          DropdownMenuItem(value: 'two', child: Text('Two')),
        ])));
  }
}
