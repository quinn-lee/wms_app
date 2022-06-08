import 'package:flutter/material.dart';
import 'package:wms_app/util/color.dart';

class ScanInput extends StatefulWidget {
  final String title;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? focusChanged;
  final bool lineStretch;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FocusNode focusNode;
  final TextEditingController textEditingController;

  const ScanInput(
      this.title, this.hint, this.focusNode, this.textEditingController,
      {Key? key,
      this.onChanged,
      this.focusChanged,
      this.onSubmitted,
      this.lineStretch = false,
      this.obscureText = false,
      this.keyboardType})
      : super(key: key);

  @override
  State<ScanInput> createState() => _ScanInputState();
}

class _ScanInputState extends State<ScanInput> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      print("Has focus: ${widget.focusNode.hasFocus}");
      if (widget.focusChanged != null) {
        widget.focusChanged!(widget.focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    widget.focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15),
              width: 100,
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            _input()
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: !widget.lineStretch ? 15 : 0),
            child: const Divider(
              height: 1,
              thickness: 0.5,
            ))
      ],
    );
  }

  _input() {
    return Expanded(
        child: TextField(
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      autofocus: !widget.obscureText,
      cursorColor: primary,
      controller: widget.textEditingController,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
      //输入框的样式
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 15, color: Colors.grey)),
    ));
  }
}
