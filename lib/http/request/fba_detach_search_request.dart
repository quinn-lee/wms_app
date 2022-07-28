import 'package:wms_app/http/request/base_request.dart';

// FBA移除-查询当前处理中的包裹实例, 适用于多个包裹相同运单号
class FbaDetachSearchRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.POST;
  }

  @override
  bool needLogin() {
    return true;
  }

  @override
  String path() {
    return "/api/v1.0/inbound_idle_parcels/fba_detach/wait_to_operate";
  }
}
