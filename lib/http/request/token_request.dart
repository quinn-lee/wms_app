// 获取Token请求
import 'package:wms_app/http/request/base_request.dart';

class TokenRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.POST;
  }

  @override
  bool needLogin() {
    return false;
  }

  @override
  String path() {
    return "/oauth2/token";
  }
}
