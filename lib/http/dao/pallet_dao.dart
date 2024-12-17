import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/delete_parcel_pallets_request.dart';
import 'package:wms_app/http/request/pallet_info_request.dart';
import 'package:wms_app/http/request/scanning_pallet_request.dart';

class PalletDao {
  // 扫描
  static Future<Map> scanning(
      String palletNum, String parcelNum1, String parcelNum2) async {
    BaseRequest request = ScanningPalletRequest();
    request.add("pallet_num", palletNum);
    request.add("parcel_num1", parcelNum1);
    request.add("parcel_num2", parcelNum2);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 删除包裹
  static deleteParcel(
      String palletNum, String parcelNum1, String parcelNum2) async {
    BaseRequest request = DeleteParcelPalletsRequest();
    request.pathParams =
        "$palletNum/delete_parcel_by_num/$parcelNum1/$parcelNum2";
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }

  // 获取托盘信息
  static getPalletInfo(String palletNum) async {
    BaseRequest request = PalletInfoRequest();
    request.pathParams = "$palletNum/pallet_info";
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
