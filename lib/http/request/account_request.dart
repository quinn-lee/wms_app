// 获取账户信息请求
import 'package:wms_app/http/request/base_request.dart';

class AccountRequest extends BaseRequest {
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
    return "/oauth2/current_account";
  }
}
