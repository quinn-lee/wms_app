import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/fba_detach_add_request.dart';
import 'package:wms_app/http/request/fba_detach_current_request.dart';
import 'package:wms_app/http/request/fba_detach_delete_request.dart';
import 'package:wms_app/http/request/fba_detach_new_request.dart';
import 'package:wms_app/http/request/fba_detach_search_request.dart';
import 'package:wms_app/http/request/fba_detach_search_sku_request.dart';

class FbaDetachDao {
  // FBA移除-查询当前处理中的包裹实例, 适用于多个包裹相同运单号
  static search(String shipmentNum) async {
    BaseRequest request = FbaDetachSearchRequest();
    request.add("num", shipmentNum);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // FBA移除-新增包裹实例
  static newIdentifier(String shipmentNum) async {
    BaseRequest request = FbaDetachNewRequest();
    request.add("num", shipmentNum);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // FBA移除-查询sku数据(含测量数据, 所属用户)
  static searchSku(String barcode) async {
    BaseRequest request = FbaDetachSearchSkuRequest();
    request.add("barcode", barcode);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // FBA移除-往包裹实例中添加sku信息
  // {
  //  data: [
  //    { barcode: '条码1', account_id: 1, quantity: 10, length: 1.0, width: 1.0, height: 1.0, weight: 1.0 },
  //    { barcode: '条码2', account_id: 1, quantity: 10, length: 1.0, width: 1.0, height: 1.0, weight: 1.0 }
  //  ]
  // }
  static addSku(int id, Map data) async {
    BaseRequest request = FbaDetachAddReqeust();
    request.pathParams = "$id/add_sku";
    request.add("data", [data]);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  static current({String? shipmentNum}) async {
    BaseRequest request = FbaDetachCurrentRequest();
    if (shipmentNum != null) {
      request.add("num", shipmentNum);
    }
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  static delete(int id) async {
    BaseRequest request = FbaDetachDeleteRequest();
    request.pathParams = "$id/delete";
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
