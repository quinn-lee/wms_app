bool isNotEmpty(String? text) {
  return text?.isNotEmpty ?? false;
}

bool isEmpty(String? text) {
  return text?.isEmpty ?? false;
}

// 验证dhl校验位
String matchShipmentNum(String shipmentNum) {
  String num = shipmentNum.trim();
  if (num.substring(0, 1) == '%') {
    if (num.length >= 22) {
      return num.substring(8, 22);
    }
  }
  if (num.length == 12) {
    int sum = 0;
    for (var i in [0, 2, 4, 6, 8, 10]) {
      sum = sum + int.parse(num[i]) * 3;
    }
    for (var i in [1, 3, 5, 7, 9]) {
      sum = sum + int.parse(num[i]);
    }
    sum = sum + 1;
    String checkNum = (10 - int.parse(sum.toString().split('').last))
        .toString()
        .split('')
        .last;
    if (checkNum == num[num.length - 1]) {
      return num.substring(0, 12);
    }

    sum = 0;
    for (var i in [0, 2, 4, 6, 8, 10]) {
      sum = sum + int.parse(num[i]) * 4;
    }
    for (var i in [1, 3, 5, 7, 9]) {
      sum = sum + int.parse(num[i]) * 9;
    }
    sum = sum + 1;
    checkNum = (10 - int.parse(sum.toString().split('').last))
        .toString()
        .split('')
        .last;
    if (checkNum == num[num.length - 1]) {
      return num.substring(0, 12);
    }
  }
  return num;
}
