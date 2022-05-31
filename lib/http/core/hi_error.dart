// 需要登陆的异常
class NeedLogin extends HiNetError {
  NeedLogin({int code = 401, String message = "Login please"})
      : super(code, message);
}

// 需要授权的异常
class NeedAuth extends HiNetError {
  NeedAuth(String message, {int code = 403, dynamic data})
      : super(code, message, data: data);
}

// 网络异常统一格式类
class HiNetError implements Exception {
  late final int code;
  late final String message;
  late final dynamic data;

  HiNetError(this.code, this.message, {this.data});
}
