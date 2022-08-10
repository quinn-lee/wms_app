import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/identifier_request.dart';
import 'package:wms_app/http/request/unknown_pack_request.dart';
import 'package:wms_app/util/string_util.dart';

class InboundDao {
  // 收货扫描
  static Future<Map> receive(String num) async {
    BaseRequest request = IdentifierRequest();
    request.add("num", num);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  static Future<Map> registerUnknownParcel(
      String depotCode,
      String? serialNum,
      String identifier,
      String? category,
      String? accountId,
      int quantity,
      List attachment) async {
    BaseRequest request = UnknownPackRequest();
    request.add("depot_code", depotCode);
    request.add("identifier", identifier);
    request.add("quantity", quantity);
    if (isNotEmpty(serialNum)) {
      request.add("serial_number", serialNum!);
    }
    if (isNotEmpty(category)) {
      request.add("category", category!);
    }
    if (isNotEmpty(accountId)) {
      request.add("account_id", accountId!);
    }
    request.add("attachment", attachment);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
