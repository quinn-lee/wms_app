import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/outbound_check_multiple_request.dart';
import 'package:wms_app/http/request/outbound_check_request.dart';
import 'package:wms_app/http/request/scan_log_request.dart';

class OutboundDao {
  // 一件代发出库核对
  static Future<Map> check(String shpmtNum, String barcode) async {
    BaseRequest request = OutboundCheckRequest();
    request.add("shpmt_num", shpmtNum);
    request.add("barcode", barcode);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 一件代发出库核对Multiple
  // sku_info = []
  // sku_codes.each do |code|
  //     sku_info << {barcode: params["sku_code_#{code}"], quantity: params["quantity_#{code}"]}
  // end
  static Future<Map> checkMultiple(String shpmtNum, List skus) async {
    BaseRequest request = OutboundCheckMultipleRequest();
    request.add("shpmt_num", shpmtNum);
    request.add("skus", skus);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 通用记录接口
  static Future<Map> scanLog(List nums, {String description = "缺货登记"}) async {
    BaseRequest request = ScanLogRequest();
    request.add("nums", nums);
    request.add("description", description);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
