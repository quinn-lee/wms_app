import 'package:flutter/material.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/db/hi_cache.dart';
import 'package:wms_app/http/core/hi_error.dart';
import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/dao/login_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/bottom_navigator.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/page/detail_page.dart';
import 'package:wms_app/page/login_page.dart';
import 'package:wms_app/page/returned_need_photo_page.dart';
import 'package:wms_app/page/returned_need_process_page.dart';
import 'package:wms_app/page/returned_photo_page.dart';
import 'package:wms_app/page/returned_scan_page.dart';
import 'package:wms_app/page/returned_shelf_page.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/toast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends HiState<MyApp> {
  final EtRouteDelegate _routeDelegate = EtRouteDelegate();

  @override
  void initState() {
    super.initState();
    initXUpdate();
    FlutterXUpdate.checkUpdate(
        url: "http://172.105.20.13:3006/api/v1.0/apk/apk_update_info",
        themeColor: "#ffff9db5",
        topImageRes: "white",
        buttonTextColor: "#ffffffff");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HiCache>(
        //进行初始化
        future: HiCache.preInit(),
        builder: (BuildContext context, AsyncSnapshot<HiCache> snapshot) {
          //定义route
          var widget = snapshot.connectionState == ConnectionState.done
              ? Router(routerDelegate: _routeDelegate)
              : const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
          return MaterialApp(
            home: widget,
            theme: ThemeData(primarySwatch: white),
            debugShowCheckedModeBanner: false,
          );
        });
  }

  //初始化XUpdate
  void initXUpdate() {
    FlutterXUpdate.init(
            //是否输出日志
            debug: true,
            //是否使用post请求
            isPost: false,
            //post请求是否是上传json
            isPostJson: false,
            //请求响应超时时间
            timeout: 25000,
            //是否开启自动模式
            isWifiOnly: false,
            //是否开启自动模式
            isAutoMode: false,
            //需要设置的公共参数
            supportSilentInstall: false,
            //在下载过程中，如果点击了取消的话，是否弹出切换下载方式的重试提示弹窗
            enableRetry: false)
        .then((value) {
      print("初始化成功: $value");
    }).catchError((error) {
      print(error);
    });

    FlutterXUpdate.setErrorHandler(
        onUpdateError: (Map<String, dynamic>? message) async {
      print(message);
    });
  }
}

class EtRouteDelegate extends RouterDelegate<EtRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<EtRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  RouteStatus _routeStatus = RouteStatus.home;
  ReturnedParcel? rParcel;
  ReturnedParcel? needPhotoParcel;
  ReturnedParcel? reshelfParcel;
  List<MaterialPage> pages = [];

  //为Navigator设置一个key，必要的时候可以通过navigatorKey.currentState来获取到NavigatorState对象
  EtRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    //实现路由跳转逻辑
    RouteJumpListener rjl =
        RouteJumpListener(onJumpTo: (RouteStatus routeStatus, {Map? args}) {
      _routeStatus = routeStatus;
      if (routeStatus == RouteStatus.detail) {
        rParcel = args!['rparcel'];
      } else if (routeStatus == RouteStatus.returnedPhoto) {
        needPhotoParcel = args!['needPhotoParce'];
      } else if (routeStatus == RouteStatus.returnedNeedReshelf) {
        reshelfParcel = args!['needReshelParcel'];
      }
      notifyListeners();
    });
    HiNavigator.getInstance().registerRouteJump(rjl);
    //设置网络错误拦截器
    HiNet.getInstance().setErrorInterceptor((error) {
      if (error is NeedLogin) {
        //清空失效的登录令牌
        HiCache.getInstance().remove(LoginDao.TOKEN);
        //拉起登录
        HiNavigator.getInstance().onJumpTo(RouteStatus.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var index = getPageIndex(pages, routeStatus);
    List<MaterialPage> tempPages = pages;
    if (index != -1) {
      //要打开的页面在栈中已存在，则将该页面和它上面的所有页面进行出栈
      //tips 具体规则可以根据需要进行调整，这里要求栈中只允许有一个同样的页面的实例
      tempPages = tempPages.sublist(0, index);
    }
    dynamic page;
    if (routeStatus == RouteStatus.home) {
      //跳转首页时将栈中其它页面进行出栈，因为首页不可回退
      pages.clear();
      page = pageWrap(const BottomNavigator());
    } else if (routeStatus == RouteStatus.detail) {
      page = pageWrap(DetailPage(rParcel!));
    } else if (routeStatus == RouteStatus.login) {
      page = pageWrap(const LoginPage());
    } else if (routeStatus == RouteStatus.returnedScan) {
      page = pageWrap(const ReturnedScanPage());
    } else if (routeStatus == RouteStatus.returnedNeedPhoto) {
      page = pageWrap(const ReturnedNeedPhotoPage());
    } else if (routeStatus == RouteStatus.returnedNeedProcess) {
      page = pageWrap(const ReturnedNeedProcessPage());
    } else if (routeStatus == RouteStatus.returnedPhoto) {
      page = pageWrap(ReturnedPhotoPage(needPhotoParcel!));
    } else if (routeStatus == RouteStatus.returnedNeedReshelf) {
      page = pageWrap(ReturnedShelfPage(reshelfParcel!));
    }
    //重新创建一个数组，否则pages因引用没有改变路由不会生效
    tempPages = [...tempPages, page];
    //通知路由发生变化
    HiNavigator.getInstance().notify(tempPages, pages);
    pages = tempPages;
    return WillPopScope(
      //fix Android物理返回键，无法返回上一页问题@https://github.com/flutter/flutter/issues/66349
      onWillPop: () async =>
          !(await navigatorKey.currentState?.maybePop() ?? false),
      child: Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (route, result) {
          if (route.settings is MaterialPage) {
            //登录页未登录返回拦截
            if ((route.settings as MaterialPage).child is LoginPage) {
              if (!hasLogin) {
                showWarnToast("请先登录");
                return false;
              }
            }
          }
          //执行返回操作
          if (!route.didPop(result)) {
            return false;
          }
          var tempPages = [...pages];
          pages.removeLast();
          //通知路由发生变化
          HiNavigator.getInstance().notify(pages, tempPages);
          return true;
        },
      ),
    );
  }

  RouteStatus get routeStatus {
    if (!hasLogin) {
      return _routeStatus = RouteStatus.login;
    } else {
      return _routeStatus;
    }
  }

  bool get hasLogin => LoginDao.getCacheToken() != null;

  @override
  Future<void> setNewRoutePath(EtRoutePath path) async {}
}

// 定义路由数据，path
class EtRoutePath {
  final String location;

  EtRoutePath.home() : location = "/";
  EtRoutePath.detail() : location = "/detail";
}
