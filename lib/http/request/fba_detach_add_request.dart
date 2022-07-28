import 'package:wms_app/http/request/base_request.dart';

// FBA移除-往包裹实例中添加sku信息
class FbaDetachAddReqeust extends BaseRequest {
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
    return "/api/v1.0/inbound_idle_parcels/fba_detach";
  }
}
