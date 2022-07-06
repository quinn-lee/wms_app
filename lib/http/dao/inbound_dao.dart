import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/identifier_request.dart';

class InboundDao {
  // 收货扫描
  static Future<Map> receive(String num) async {
    BaseRequest request = IdentifierRequest();
    request.add("num", num);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
