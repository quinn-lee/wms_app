import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  final String title;
  final bool enable;
  final VoidCallback? onPressed;
  final double widthFactor;

  const CancelButton(this.title, this.widthFactor,
      {Key? key, this.enable = true, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        height: 45,
        onPressed: enable ? onPressed : null,
        disabledColor: Colors.grey[500],
        color: Colors.grey[500],
        child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
