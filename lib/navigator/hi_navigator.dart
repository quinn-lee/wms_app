import 'package:flutter/material.dart';
import 'package:wms_app/page/detail_page.dart';
import 'package:wms_app/page/fba_detach_current_page.dart';
import 'package:wms_app/page/fba_detach_scan_page.dart';
import 'package:wms_app/page/fba_detach_scan_sku_page.dart';
import 'package:wms_app/page/home_page.dart';
import 'package:wms_app/page/inbound_page.dart';
import 'package:wms_app/page/inbound_receive_page.dart';
import 'package:wms_app/page/inventory_check_operate_page.dart';
import 'package:wms_app/page/inventory_check_scan_page.dart';
import 'package:wms_app/page/inventory_page.dart';
// import 'package:wms_app/page/home_page.dart';

import 'package:wms_app/page/login_page.dart';
import 'package:wms_app/page/outbound_check_multiple_page.dart';
import 'package:wms_app/page/outbound_check_page.dart';
import 'package:wms_app/page/outbound_oos_registration_page.dart';
import 'package:wms_app/page/outbound_page.dart';
import 'package:wms_app/page/returned_broken_package_page.dart';
import 'package:wms_app/page/returned_need_photo_page.dart';
import 'package:wms_app/page/returned_need_process_page.dart';
import 'package:wms_app/page/returned_new_scan_page.dart';
import 'package:wms_app/page/returned_new_shelf_page.dart';
import 'package:wms_app/page/returned_page.dart';
import 'package:wms_app/page/returned_photo_page.dart';
import 'package:wms_app/page/returned_scan_page.dart';
import 'package:wms_app/page/returned_shelf_page.dart';
import 'package:wms_app/page/returned_unknown_handle_page.dart';
import 'package:wms_app/page/scanning_pallet_page.dart';
import 'package:wms_app/page/unknown_packs_page.dart';

typedef RouteChangeListener(RouteStatusInfo current, RouteStatusInfo? pre);

pageWrap(Widget child) {
  return MaterialPage(key: ValueKey(child.hashCode), child: child);
}

// 获取routeStatus在页面栈中的位置
int getPageIndex(List<MaterialPage> pages, RouteStatus routeStatus) {
  for (int i = 0; i < pages.length; i++) {
    MaterialPage page = pages[i];
    if (getStatus(page) == routeStatus) {
      return i;
    }
  }
  return -1;
}

// 自定义路由封装，路由状态
enum RouteStatus {
  login,
  home,
  detail,
  unknown,
  returnedPage,
  inboundPage,
  outboundPage,
  returnedScan,
  returnedNewScan,
  returnedPhoto,
  returnedNeedPhoto,
  returnedNeedProcess,
  returnedNeedReshelf,
  returnedNewShelf,
  returnedBrokenPackage,
  inboundReceive,
  unknownPacks,
  outboundCheck,
  outboundCheckMultiple,
  outboundOosRegistration,
  fbaDetachScan,
  fbaDetachScanSku,
  fbaDetachCurrent,
  inventoryPage,
  inventoryCheckScan,
  inventoryCheckOperate,
  returnedUnknownHandle,
  scanningPalletPage
}

// 获取page 对应的RouteStatus
RouteStatus getStatus(MaterialPage page) {
  if (page.child is LoginPage) {
    return RouteStatus.login;
  } else if (page.child is HomePage) {
    return RouteStatus.home;
  } else if (page.child is DetailPage) {
    return RouteStatus.detail;
  } else if (page.child is ReturnedPage) {
    return RouteStatus.returnedPage;
  } else if (page.child is InboundPage) {
    return RouteStatus.inboundPage;
  } else if (page.child is OutboundPage) {
    return RouteStatus.outboundPage;
  } else if (page.child is ReturnedScanPage) {
    return RouteStatus.returnedScan;
  } else if (page.child is ReturnedNewScanPage) {
    return RouteStatus.returnedNewScan;
  } else if (page.child is InboundReceivePage) {
    return RouteStatus.inboundReceive;
  } else if (page.child is ReturnedPhotoPage) {
    return RouteStatus.returnedPhoto;
  } else if (page.child is ReturnedNeedPhotoPage) {
    return RouteStatus.returnedNeedPhoto;
  } else if (page.child is ReturnedNeedProcessPage) {
    return RouteStatus.returnedNeedProcess;
  } else if (page.child is ReturnedShelfPage) {
    return RouteStatus.returnedNeedReshelf;
  } else if (page.child is ReturnedBrokenPackagePage) {
    return RouteStatus.returnedBrokenPackage;
  } else if (page.child is ReturnedNewShelfPage) {
    return RouteStatus.returnedNewShelf;
  } else if (page.child is UnknownPacksPage) {
    return RouteStatus.unknownPacks;
  } else if (page.child is OutboundCheckPage) {
    return RouteStatus.outboundCheck;
  } else if (page.child is OutboundCheckMultiplePage) {
    return RouteStatus.outboundCheckMultiple;
  } else if (page.child is OutboundOosRegistrationPage) {
    return RouteStatus.outboundOosRegistration;
  } else if (page.child is FbaDetachScanPage) {
    return RouteStatus.fbaDetachScan;
  } else if (page.child is FbaDetachScanSkuPage) {
    return RouteStatus.fbaDetachScanSku;
  } else if (page.child is FbaDetachCurrentPage) {
    return RouteStatus.fbaDetachCurrent;
  } else if (page.child is InventoryPage) {
    return RouteStatus.inventoryPage;
  } else if (page.child is InventoryCheckScanPage) {
    return RouteStatus.inventoryCheckScan;
  } else if (page.child is InventoryCheckOperatePage) {
    return RouteStatus.inventoryCheckOperate;
  } else if (page.child is ReturnedUnknownHandlePage) {
    return RouteStatus.returnedUnknownHandle;
  } else if (page.child is ScanningPalletPage) {
    return RouteStatus.scanningPalletPage;
  } else {
    return RouteStatus.unknown;
  }
}

// 路由信息
class RouteStatusInfo {
  final RouteStatus routeStatus;
  final Widget page;

  RouteStatusInfo(this.routeStatus, this.page);
}

///监听路由页面跳转
///感知当前页面是否压后台
class HiNavigator extends _RouteJumpListener {
  static HiNavigator? _instance;

  RouteJumpListener? _routeJump;
  List<RouteChangeListener> _listeners = [];
  RouteStatusInfo? _current;

  //首页底部tab
  RouteStatusInfo? _bottomTab;

  HiNavigator._();

  static HiNavigator getInstance() {
    return _instance ??= HiNavigator._();
  }

  // 首页底部tab切换监听
  void onBottomTabChange(int index, Widget page) {
    _bottomTab = RouteStatusInfo(RouteStatus.home, page);
    _notify(_bottomTab!);
  }

  ///注册路由跳转逻辑
  void registerRouteJump(RouteJumpListener routeJumpListener) {
    _routeJump = routeJumpListener;
  }

  ///监听路由页面跳转
  void addListener(RouteChangeListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  ///移除监听
  void removeListener(RouteChangeListener listener) {
    _listeners.remove(listener);
  }

  @override
  void onJumpTo(RouteStatus routeStatus, {Map? args}) {
    _routeJump?.onJumpTo(routeStatus, args: args);
  }

  ///通知路由页面变化
  void notify(List<MaterialPage> currentPages, List<MaterialPage> prePages) {
    if (currentPages == prePages) return;
    var current =
        RouteStatusInfo(getStatus(currentPages.last), currentPages.last.child);
    _notify(current);
  }

  void _notify(RouteStatusInfo current) {
    // if (current.page is BottomNavigator && _bottomTab != null) {
    //   //如果打开的是首页，则明确到首页具体的tab
    //   current = _bottomTab!;
    // }
    print('hi_navigator:current:${current.page}');
    print('hi_navigator:pre:${_current?.page}');
    _listeners.forEach((listener) {
      listener(current, _current!);
    });
    _current = current;
  }
}

///抽象类供HiNavigator实现
abstract class _RouteJumpListener {
  void onJumpTo(RouteStatus routeStatus, {Map args});
}

typedef OnJumpTo = void Function(RouteStatus routeStatus, {Map? args});

///定义路由跳转逻辑要实现的功能
class RouteJumpListener {
  final OnJumpTo onJumpTo;

  RouteJumpListener({required this.onJumpTo});
}
