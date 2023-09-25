import 'package:wms_app/http/request/base_request.dart';

class UnknownReciveAndFinishRequest extends BaseRequest {
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
    return "/api/v1.0/returned_orders/wuzhu/receive_and_finish";
  }
}
