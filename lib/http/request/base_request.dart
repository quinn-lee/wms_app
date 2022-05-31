enum HttpMethod { GET, POST, DELETE }

// 基础请求
abstract class BaseRequest {
  var pathParams; // path参数
  var useHttps = true; // 默认使用https
  Map<String, String> params = {}; // 查询参数
  Map<String, dynamic> header = {}; // 鉴权参数

  // 域名
  String authority() {
    return "api.devio.org";
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
      uri = Uri.https(authority(), pathStr, params);
    } else {
      uri = Uri.http(authority(), pathStr, params);
    }
    print('url:${uri.toString()}');
    return uri.toString();
  }

  // 接口是否需要登录
  bool needLogin();

  // 添加参数
  BaseRequest add(String k, Object v) {
    params[k] = v.toString();
    return this;
  }

  // 添加鉴权参数
  BaseRequest addHeader(String k, Object v) {
    header[k] = v.toString();
    return this;
  }
}
