// 登录
import 'package:wms_app/db/hi_cache.dart';
import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/request/account_request.dart';
import 'package:wms_app/http/request/base_request.dart';
import 'package:wms_app/http/request/token_request.dart';
import 'package:wms_app/util/authority.dart';

class LoginDao {
  static const TOKEN = "access_token";
  static Future<Map> getToken(String username, String password) async {
    BaseRequest request = TokenRequest();
    request.isLoginApi = true;
    request
        .add("client_id", clientId)
        .add("client_secret", clientSecret)
        .add("grant_type", grantType)
        .add("username", username)
        .add("password", password);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    if (result[TOKEN] != null) {
      //保存登录令牌
      HiCache.getInstance().setString(TOKEN, result[TOKEN]);
      //保存登录邮箱
      HiCache.getInstance().setString("login_email", username);
    } else {
      //登录失败
      HiCache.getInstance().setString(TOKEN, "");
    }
    return result;
  }

  static getCacheToken() {
    return HiCache.getInstance().get(TOKEN);
  }

  static Future<Map> getAccountInfo(token) async {
    BaseRequest request = AccountRequest();
    request.add("access_token", token);
    var result = await HiNet.getInstance().fire(request);
    print(result);
    return result;
  }
}
