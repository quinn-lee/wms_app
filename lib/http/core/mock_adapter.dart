import 'package:wms_app/http/core/hi_net_adapter.dart';
import 'package:wms_app/http/request/base_request.dart';

class MockAdapter extends HiNetAdapter {
  @override
  Future<HiNetResponse<T>> send<T>(BaseRequest request) {
    return Future<HiNetResponse<T>>.delayed(const Duration(milliseconds: 500),
        () {
      return HiNetResponse(
          data: {"code": 0, "message": "success"} as T, statusCode: 200);
    });
  }
}
