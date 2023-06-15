import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/check_add_shelf_num_request.dart';
import 'package:wms_app/http/request/check_operate_request.dart';

// 盘点相关接口
class CheckDao {
  // 添加货架号
  // @param - { shelf_num: 'DUI-xxx' }
  static addShelfNum(String shelfNum) async {
    BaseRequest request = CheckAddShelfNumRequest();
    request.add("shelf_num", shelfNum);

    var result = await HiNet.getInstance().fire(request);
    // print(result);
    return result;
  }

  // 提交更新单个货架的SKU信息
  // @param - {
  //   shelf_num: 'DUI-xxx',
  //   skus: [
  //     { sku_code: 'SKU编码', quantity: 88 }, ...
  //   ]
  // }
  static operate(String shelfNum, List skus) async {
    BaseRequest request = CheckOperateRequest();
    request.add("shelf_num", shelfNum);
    request.add("skus", skus);

    var result = await HiNet.getInstance().fire(request);
    // print(result);
    return result;
  }
}
