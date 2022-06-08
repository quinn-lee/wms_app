import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/receive_request.dart';
import 'package:wms_app/http/request/returned_request.dart';

class ReturnedDao {
  // 扫描
  static Future<Map> scan(String num) async {
    BaseRequest request = ReceiveRequest();
    request.add("num", num);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 获取待处理
  static get(
      {String? shpmtNumCont,
      bool? takePhoto,
      int page = 1,
      int perPage = 10}) async {
    BaseRequest request = ReturnedRequest();
    request.add("page", page).add("per_page", perPage);
    Map query = {};
    if (shpmtNumCont != null) {
      query["shpmt_num_cont"] = shpmtNumCont;
    }
    if (takePhoto != null) {
      query["take_photo"] = takePhoto;
    }
    request.add("q", query);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
