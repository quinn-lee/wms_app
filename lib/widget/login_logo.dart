import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15),
      // decoration: const BoxDecoration(
      //     color: Colors.white,
      //     border: Border(bottom: BorderSide(color: Colors.white))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Image(
            image: AssetImage('images/ndlogo.png'),
            fit: BoxFit.scaleDown,
            height: 76 / 1.6,
            width: 208 / 1.6,
          ),
        ],
      ),
    );
  }
}
