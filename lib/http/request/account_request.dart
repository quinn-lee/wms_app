// 获取账户信息请求
import 'package:wms_app/http/request/base_request.dart';

class AccountRequest extends BaseRequest {
  @override
  HttpMethod httpMethod() {
    return HttpMethod.POST;
  }

  @override
  bool needLogin() {
    return false; // token获取到后 直接传值，此处改为false，防止异步时token还未获取到
  }

  @override
  String path() {
    return "/oauth2/current_account";
  }
}
