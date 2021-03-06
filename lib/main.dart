import 'package:flutter/material.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/db/hi_cache.dart';
import 'package:wms_app/http/core/hi_error.dart';
import 'package:wms_app/http/core/hi_net.dart';
import 'package:wms_app/http/dao/login_dao.dart';
import 'package:wms_app/model/fba_detach_parcel.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/page/detail_page.dart';
import 'package:wms_app/page/fba_detach_current_page.dart';
import 'package:wms_app/page/fba_detach_scan_page.dart';
import 'package:wms_app/page/fba_detach_scan_sku_page.dart';
import 'package:wms_app/page/home_page.dart';
import 'package:wms_app/page/inbound_page.dart';
import 'package:wms_app/page/inbound_receive_page.dart';
import 'package:wms_app/page/login_page.dart';
import 'package:wms_app/page/outbound_check_multiple_page.dart';
import 'package:wms_app/page/outbound_check_page.dart';
import 'package:wms_app/page/outbound_page.dart';
import 'package:wms_app/page/returned_need_photo_page.dart';
import 'package:wms_app/page/returned_need_process_page.dart';
import 'package:wms_app/page/returned_page.dart';
import 'package:wms_app/page/returned_photo_page.dart';
import 'package:wms_app/page/returned_scan_page.dart';
import 'package:wms_app/page/returned_shelf_page.dart';
import 'package:wms_app/page/unknown_packs_page.dart';
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
        //???????????????
        future: HiCache.preInit(),
        builder: (BuildContext context, AsyncSnapshot<HiCache> snapshot) {
          //??????route
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

  //?????????XUpdate
  void initXUpdate() {
    FlutterXUpdate.init(
            //??????????????????
            debug: true,
            //????????????post??????
            isPost: false,
            //post?????????????????????json
            isPostJson: false,
            //????????????????????????
            timeout: 25000,
            //????????????????????????
            isWifiOnly: false,
            //????????????????????????
            isAutoMode: false,
            //???????????????????????????
            supportSilentInstall: false,
            //??????????????????????????????????????????????????????????????????????????????????????????????????????
            enableRetry: false)
        .then((value) {
      print("???????????????: $value");
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
  String? photoFrom;
  String? unknownPageFrom;
  String? returnPageFrom;
  ReturnedParcel? reshelfParcel;
  FbaDetachParcel? fbaDetachParcel;
  List<MaterialPage> pages = [];

  //???Navigator????????????key??????????????????????????????navigatorKey.currentState????????????NavigatorState??????
  EtRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    //????????????????????????
    RouteJumpListener rjl =
        RouteJumpListener(onJumpTo: (RouteStatus routeStatus, {Map? args}) {
      _routeStatus = routeStatus;
      if (routeStatus == RouteStatus.detail) {
        rParcel = args!['rparcel'];
      } else if (routeStatus == RouteStatus.returnedPhoto) {
        needPhotoParcel = args!['needPhotoParce'];
        photoFrom = args['photoFrom'];
      } else if (routeStatus == RouteStatus.returnedNeedReshelf) {
        reshelfParcel = args!['needReshelParcel'];
      } else if (routeStatus == RouteStatus.unknownPacks) {
        unknownPageFrom = args!['unknownPageFrom'] ?? "";
      } else if (routeStatus == RouteStatus.returnedScan) {
        returnPageFrom = args!['returnPageFrom'] ?? "";
      } else if (routeStatus == RouteStatus.fbaDetachScanSku) {
        fbaDetachParcel = args!['fbaDetachParcel'];
      }
      notifyListeners();
    });
    HiNavigator.getInstance().registerRouteJump(rjl);
    //???????????????????????????
    HiNet.getInstance().setErrorInterceptor((error) {
      if (error is NeedLogin) {
        //???????????????????????????
        HiCache.getInstance().remove(LoginDao.TOKEN);
        //????????????
        HiNavigator.getInstance().onJumpTo(RouteStatus.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var index = getPageIndex(pages, routeStatus);
    List<MaterialPage> tempPages = pages;
    if (index != -1) {
      //?????????????????????????????????????????????????????????????????????????????????????????????
      //tips ?????????????????????????????????????????????????????????????????????????????????????????????????????????
      tempPages = tempPages.sublist(0, index);
    }
    dynamic page;
    if (routeStatus == RouteStatus.home) {
      //???????????????????????????????????????????????????????????????????????????
      pages.clear();
      page = pageWrap(const HomePage());
    } else if (routeStatus == RouteStatus.detail) {
      page = pageWrap(DetailPage(rParcel!));
    } else if (routeStatus == RouteStatus.login) {
      page = pageWrap(const LoginPage());
    } else if (routeStatus == RouteStatus.returnedPage) {
      page = pageWrap(const ReturnedPage());
    } else if (routeStatus == RouteStatus.inboundPage) {
      page = pageWrap(const InboundPage());
    } else if (routeStatus == RouteStatus.outboundPage) {
      page = pageWrap(const OutboundPage());
    } else if (routeStatus == RouteStatus.returnedScan) {
      page = pageWrap(ReturnedScanPage(returnPageFrom!));
    } else if (routeStatus == RouteStatus.inboundReceive) {
      page = pageWrap(const InboundReceivePage());
    } else if (routeStatus == RouteStatus.unknownPacks) {
      page = pageWrap(UnknownPacksPage(unknownPageFrom!));
    } else if (routeStatus == RouteStatus.returnedNeedPhoto) {
      page = pageWrap(const ReturnedNeedPhotoPage());
    } else if (routeStatus == RouteStatus.returnedNeedProcess) {
      page = pageWrap(const ReturnedNeedProcessPage());
    } else if (routeStatus == RouteStatus.returnedPhoto) {
      page = pageWrap(ReturnedPhotoPage(needPhotoParcel!, photoFrom!));
    } else if (routeStatus == RouteStatus.returnedNeedReshelf) {
      page = pageWrap(ReturnedShelfPage(reshelfParcel!));
    } else if (routeStatus == RouteStatus.outboundCheck) {
      page = pageWrap(const OutboundCheckPage());
    } else if (routeStatus == RouteStatus.outboundCheckMultiple) {
      page = pageWrap(const OutboundCheckMultiplePage());
    } else if (routeStatus == RouteStatus.fbaDetachScan) {
      page = pageWrap(const FbaDetachScanPage());
    } else if (routeStatus == RouteStatus.fbaDetachCurrent) {
      page = pageWrap(const FbaDetachCurrentPage());
    } else if (routeStatus == RouteStatus.fbaDetachScanSku) {
      page = pageWrap(FbaDetachScanSkuPage(fbaDetachParcel!));
    }
    //?????????????????????????????????pages???????????????????????????????????????
    tempPages = [...tempPages, page];
    //????????????????????????
    HiNavigator.getInstance().notify(tempPages, pages);
    pages = tempPages;
    return WillPopScope(
      //fix Android?????????????????????????????????????????????@https://github.com/flutter/flutter/issues/66349
      onWillPop: () async =>
          !(await navigatorKey.currentState?.maybePop() ?? false),
      child: Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (route, result) {
          if (route.settings is MaterialPage) {
            //??????????????????????????????
            if ((route.settings as MaterialPage).child is LoginPage) {
              if (!hasLogin) {
                showWarnToast("????????????");
                return false;
              }
            }
          }
          //??????????????????
          if (!route.didPop(result)) {
            return false;
          }
          var tempPages = [...pages];
          pages.removeLast();
          //????????????????????????
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

// ?????????????????????path
class EtRoutePath {
  final String location;

  EtRoutePath.home() : location = "/";
  EtRoutePath.detail() : location = "/detail";
}
