import 'package:wms_app/http/request/base_request.dart';

class ReturnedRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.GET;
  }

  @override
  bool needLogin() {
    return true;
  }

  @override
  String path() {
    return "/api/v1.0/returned_orders/wait_to_operate";
  }
}
