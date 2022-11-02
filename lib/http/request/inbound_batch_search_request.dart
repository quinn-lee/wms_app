import 'package:wms_app/http/request/base_request.dart';

class InboundBatchSearchRequest extends BaseRequest {
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
    return "/api/v1.0/inbound_batches/wait_to_operate";
  }
}
