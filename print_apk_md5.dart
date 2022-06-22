import 'dart:io';
import 'package:crypto/crypto.dart';

void main() async {
  var file = File("./build/app/outputs/flutter-apk/app-release.apk");
  print(md5.convert(file.readAsBytesSync()));
}
