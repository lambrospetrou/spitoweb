library spito_router;

import 'dart:html';
import 'package:route/url_pattern.dart';
import 'package:route/client.dart';

class SpitoRouter {

  UrlPattern _mHomeUrl, _mHomeStrippedUrl, _mHomeRootUrl;
  UrlPattern _mViewUrl;
  final UrlPattern anyUrl = new UrlPattern(r'(.*)');

  // this is the path for our application root
  String _mRootPath;

  Router _mRouter;

  Function _fnOnViewHandler, _fnOnHomeHandler, _fnOnAnyHandler;

  SpitoRouter(this._mRootPath) {
    _mHomeUrl = new UrlPattern(_mRootPath + r'#/(.*)');
    _mHomeStrippedUrl = new UrlPattern(_mRootPath + r'/');
    _mHomeRootUrl = new UrlPattern(_mRootPath);
    _mViewUrl = new UrlPattern(_mRootPath + r'#/view/(\w+)');
  }

  set OnViewHandler(void fn(String id)) => this._fnOnViewHandler = fn;
  set OnHomeHandler(void fn(String path)) => this._fnOnHomeHandler = fn;
  set OnAnyHandler(void fn(String path)) => this._fnOnAnyHandler = fn;

  void listen() {
    _mRouter = new Router()
      ..addHandler(_mViewUrl, _showView)
      ..addHandler(_mHomeUrl, _showHome)
      ..addHandler(_mHomeRootUrl, _redirectToHome)
      ..addHandler(_mHomeStrippedUrl, _redirectToHome)
      ..addHandler(anyUrl, _showAny)
      ..listen();
  }

  void handle(String path) {
    this._mRouter.handle(path);
  }

  void gotoHome() {
    //window.location.pathname = this._mRootPath;
    window.location.hash = '#/';
  }

  void _redirectToHome(String path) {
    window.console.log('home: ${path} redirecting to proper home');
    gotoHome();
  }

  void _showView(String path) {
    window.console.log('view: ${path}');
    var id = _mViewUrl.parse(path)[0];
    if (_fnOnViewHandler != null) _fnOnViewHandler(id);
  }

  void _showHome(String path) {
    window.console.log('home: ${path}');
    var actualHash = _mHomeUrl.parse(path);
    window.console.log('home: ${actualHash}');
    window.console.log('home: ${actualHash[0]}');
    if (_fnOnHomeHandler != null) _fnOnHomeHandler(path);
  }

  void _showAny(String path) {
    window.console.log('any: ${path}');
    if (_fnOnAnyHandler != null) _fnOnAnyHandler(path);
  }

}

