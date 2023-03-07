import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/finish_returned_request.dart';
import 'package:wms_app/http/request/receive_request.dart';
import 'package:wms_app/http/request/recive_and_finish_request.dart';
import 'package:wms_app/http/request/returned_request.dart';
import 'package:wms_app/http/request/returned_sku_request.dart';
import 'package:wms_app/http/request/upload_picture_request.dart';

class ReturnedDao {
  // 扫描
  static Future<Map> scan(String num, String receiveDepotCode,
      {bool skipDispose = false}) async {
    BaseRequest request = ReceiveRequest();
    request.add("num", num);
    request.add("receive_depot_code", receiveDepotCode);
    request.add("skip_dispose", skipDispose);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 获取sku信息
  static getReturnedSkus(String num) async {
    BaseRequest request = ReturnedSkuRequest();
    request.add("num", num);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 获取待处理
  static get(
      {String? shpmtNumCont,
      List? status,
      int page = 1,
      int perPage = 10}) async {
    BaseRequest request = ReturnedRequest();
    request.add("page", page).add("per_page", perPage);
    Map query = {};
    if (shpmtNumCont != null) {
      query["shpmt_num_cont"] = shpmtNumCont;
    }
    if (status != null) {
      query["status"] = status;
    }
    request.add("q", query);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 上传图片
  static uploadPictures(
      int id, List attachment, bool isBroken, bool isOpen) async {
    BaseRequest request = UploadPictureRequest();
    request.pathParams = "$id/take_photo";
    request.add("attachment", attachment);
    request.add("is_broken", isBroken);
    request.add("is_open", isOpen);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  static finish(int id, String disposalResult, {String? shelfNum}) async {
    BaseRequest request = FinishReturnedReqeust();
    request.pathParams = "$id/finish";
    request.add("disposal_result", disposalResult);
    if (shelfNum != null) {
      request.add("shelf_num", shelfNum);
    }
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  static receiveAndFinish(
      String num, String receiveDepotCode, String disposalResult,
      {String? disposalMemo, String? shelfNum, List? attachment}) async {
    BaseRequest request = ReceiveAndFinishRequest();
    request.add("num", num);
    request.add("receive_depot_code", receiveDepotCode);
    request.add("disposal_result", disposalResult);
    if (shelfNum != null) {
      request.add("shelf_num", shelfNum);
    }
    if (disposalMemo != null) {
      request.add("disposal_memo", disposalMemo);
    }
    if (attachment != null) {
      request.add("attachment", attachment);
    }
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
