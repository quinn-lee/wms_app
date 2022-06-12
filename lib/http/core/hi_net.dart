import 'package:wms_app/http/core/dio_adapter.dart';
import 'package:wms_app/http/core/hi_error.dart';
import 'package:wms_app/http/core/hi_interceptor.dart';
import 'package:wms_app/http/core/hi_net_adapter.dart';
//import 'package:wms_app/http/core/mock_adapter.dart';
import 'package:wms_app/http/request/base_request.dart';

class HiNet {
  HiNet._();
  HiErrorInterceptor? _hiErrorInterceptor;
  static HiNet? _instance;
  static HiNet getInstance() {
    return _instance ??= HiNet._();
  }

  Future fire(BaseRequest request) async {
    HiNetResponse? response;
    dynamic error;
    try {
      response = await send(request);
    } on HiNetError catch (e) {
      error = e;
      response = e.data;
      printLog(e.message);
    } catch (e) {
      // 其他异常
      error = e;
      printLog(e);
    }
    print(response);
    if (response == null) {
      printLog(error);
    }

    // TODO
    var result = response?.data;
    print(result);
    int? status = response?.statusCode;
    dynamic hiError;
    switch (status) {
      case 200:
        return result;
      case 400:
        return result; //登录获取接口如果登录失败会返回400
      case 401:
        hiError = NeedLogin();
        break;
      case 403:
        hiError = NeedAuth(result.toString(), data: result);
        break;
      default:
        hiError =
            error ?? HiNetError(status ?? -1, result.toString(), data: result);
        break;
    }
    //交给拦截器处理错误
    if (_hiErrorInterceptor != null) {
      _hiErrorInterceptor!(hiError);
    }
    throw hiError;
  }

  Future<dynamic> send<T>(BaseRequest request) async {
    printLog('url: ${request.url()}');
    //使用Dio发送请求
    HiNetAdapter adapter = DioAdapter();
    return adapter.send(request);
  }

  void setErrorInterceptor(HiErrorInterceptor interceptor) {
    _hiErrorInterceptor = interceptor;
  }

  void printLog(log) {
    print('hi_net: ${log.toString()}');
  }
}
