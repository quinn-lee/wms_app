import 'package:wms_app/http/dao/login_dao.dart';
import 'package:wms_app/util/authority.dart';

enum HttpMethod { POST, DELETE } // 框架原因，不支持get方法

// 基础请求
abstract class BaseRequest {
  var pathParams; // path参数
  var useHttps = false; // 默认不使用https
  var isLoginApi = false; // 登录获取token接口特殊处理，需要把参数放到url后
  Map<String, dynamic> params = {}; // 查询参数
  Map<String, dynamic> header = {}; // 鉴权参数

  // 域名
  String authority() {
    return auth;
  }

  HttpMethod httpMethod();

  String path();

  String url() {
    Uri uri;
    var pathStr = path();
    // 拼接path参数
    if (pathParams != null) {
      if (path().endsWith("/")) {
        pathStr = "${path()}$pathParams";
      } else {
        pathStr = "${path()}/$pathParams";
      }
    }

    // http和https切换
    if (useHttps) {
      if (isLoginApi) {
        uri = Uri.https(
            authority(), pathStr, params); //这样会把参数拼接到url中, 非string参数会有问题
      } else {
        uri = Uri.https(authority(), pathStr);
      }
    } else {
      if (isLoginApi) {
        uri = Uri.http(
            authority(), pathStr, params); //这样会把参数拼接到url中, 非string参数会有问题
      } else {
        uri = Uri.http(authority(), pathStr);
      }
    }
    if (needLogin()) {
      // 给需要登录的接口设置access_token
      if (LoginDao.getCacheToken() != null) {
        add(LoginDao.TOKEN, LoginDao.getCacheToken());
      } else {
        print("TODO");
      }
    }
    print('url:${uri.toString()}');
    return uri.toString();
  }

  // 接口是否需要登录
  bool needLogin();

  // 添加参数
  BaseRequest add(String k, Object v) {
    params[k] = v;
    return this;
  }

  // 添加鉴权参数
  BaseRequest addHeader(String k, Object v) {
    header[k] = v;
    return this;
  }
}
