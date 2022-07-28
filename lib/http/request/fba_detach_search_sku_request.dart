import 'package:wms_app/http/request/base_request.dart';

// FBA移除-查询sku数据(含测量数据, 所属用户)
class FbaDetachSearchSkuRequest extends BaseRequest {
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
    return "/api/v1.0/inbound_idle_parcels/search_sku_spec";
  }
}
