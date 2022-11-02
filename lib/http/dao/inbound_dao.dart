import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/identifier_request.dart';
import 'package:wms_app/http/request/inbound_batch_search_request.dart';
import 'package:wms_app/http/request/mount_operate_request.dart';
import 'package:wms_app/http/request/mount_rollback_request.dart';
import 'package:wms_app/http/request/mount_search_request.dart';
import 'package:wms_app/http/request/not_measured_skus_search_request.dart';
import 'package:wms_app/http/request/sku_measurement_request.dart';
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

  // 待上架
  static waitToOperate() async {
    BaseRequest request = InboundBatchSearchRequest();
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 上架日志查询
  static mountSearch() async {
    BaseRequest request = MountSearchRequest();
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 上架操作
  // data = {'shelf_num': "DUI-E-01-01-01",'barcode': "882324455662",'quantity': 2,'operate_memo': ""}
  static mountOperate(int id, Map data) async {
    BaseRequest request = MountOperateReqeust();
    request.pathParams = "$id/operate";
    request.add("inbound_batch_sku", data);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 上架回退
  static mountRollback(int id) async {
    BaseRequest request = MountRollbackRequest();
    request.add("inventory_operation_log_id", id);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 待测量SKU
  static notMeasuredSkus() async {
    BaseRequest request = NotMeasuredSkusSearchRequest();
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // sku测量数据更新
  // data = {'measured_length': 10,'measured_width': 10,'measured_height': 10,'measured_weight': 10}
  static skuMeasurement(int id, double measuredLength, double measuredWidth,
      double measuredHeight, double measuredWeight) async {
    BaseRequest request = SkuMeasurementRequest();
    request.pathParams = "$id/sku_measurement";
    request.add("measured_length", measuredLength);
    request.add("measured_width", measuredWidth);
    request.add("measured_height", measuredHeight);
    request.add("measured_weight", measuredWeight);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
