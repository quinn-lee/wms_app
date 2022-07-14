import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/consignor_request.dart';
import 'package:wms_app/http/request/role_request.dart';

class AccountDao {
  static getRoleList() async {
    BaseRequest request = RoleRequest();
    var result = await HiNet.getInstance().fire(request);
    // print(result);
    return result;
  }

  static getConsignorList() async {
    // var result = await RoleDao.getRoleList();
    // if (result['status'] == "succ") {
    //   var rs = result['data']
    //       .where((role) => role['name'] == 'consignor')
    //       .map((role) {
    //     return [role['name'], role['id']];
    //   });
    //   print(rs);
    //   BaseRequest request = ConsignorRequest();
    //   Map roles = {
    //     "id_in": rs.map((r) {
    //       return r[1];
    //     })
    //   };
    //   Map q = {"confirmed_at_gt": "2000-01-01", "roles": roles};
    //   request.add("q", q);
    //   request.add("per_page", 200);
    //   var res = await HiNet.getInstance().fire(request);
    //   return res;
    // } else {
    //   return {
    //     'status': 'fail',
    //     'reason': ['get roles fail']
    //   };
    // }
    BaseRequest request = ConsignorRequest();
    var result = await HiNet.getInstance().fire(request);
    return result;
  }
}
