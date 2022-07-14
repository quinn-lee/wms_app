import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/depot_request.dart';

class DepotDao {
  static getDepotList() async {
    BaseRequest request = DepotRequest();
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
