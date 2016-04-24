library spito_router;

import 'dart:html';
import 'package:route/url_pattern.dart';
import 'package:route/client.dart';

class SpitoRouter {

  UrlPattern _mHomeUrl, _mHomeStrippedUrl, _mHomeRootUrl;
  UrlPattern _mViewSpitUrl, _mFAQUrl, _mAboutUrl;
  final UrlPattern anyUrl = new UrlPattern(r'(.*)');

  // this is the path for our application root
  String _mRootPath;

  Router _mRouter;

  Function _fnOnViewHandler, _fnOnHomeHandler, _fnOnAnyHandler,
           _fnOnFAQHandler, _fnOnAboutHandler;

  SpitoRouter(this._mRootPath) {
    _mHomeUrl = new UrlPattern(_mRootPath + r'#/(.*)');
    _mHomeStrippedUrl = new UrlPattern(_mRootPath + r'/');
    _mHomeRootUrl = new UrlPattern(_mRootPath);
    _mViewSpitUrl = new UrlPattern(_mRootPath + r'#/view/(\w*)');
    _mFAQUrl = new UrlPattern(_mRootPath + r'#/faq/');
    _mAboutUrl = new UrlPattern(_mRootPath + r'#/about/');
  }

  set OnViewHandler(void fn(String id)) => this._fnOnViewHandler = fn;
  set OnHomeHandler(void fn(String path)) => this._fnOnHomeHandler = fn;
  set OnFAQHandler(void fn()) => this._fnOnFAQHandler = fn;
  set OnAboutHandler(void fn()) => this._fnOnAboutHandler = fn;
  set OnAnyHandler(void fn(String path)) => this._fnOnAnyHandler = fn;

  void listen() {
    _mRouter = new Router()
      ..addHandler(_mFAQUrl, _showFAQ)
      ..addHandler(_mAboutUrl, _showAbout)
      ..addHandler(_mViewSpitUrl, _showView)
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
    //window.console.log('home: ${path} redirecting to proper home');
    gotoHome();
  }

  void _showView(String path) {
    //window.console.log('view: ${path}');
    var id = _mViewSpitUrl.parse(path)[0];
    //window.console.log(id);
    if (_fnOnViewHandler != null) _fnOnViewHandler(id);
  }

  void _showHome(String path) {
    //window.console.log('home: ${path}');
    var actualHash = _mHomeUrl.parse(path);
    //window.console.log('home: ${actualHash}');
    //window.console.log('home: ${actualHash[0]}');
    if (_fnOnHomeHandler != null) _fnOnHomeHandler(path);
  }

  void _showFAQ(String path) {
    //window.console.log('faq: ${path}');
    if (_fnOnFAQHandler != null) _fnOnFAQHandler();
  }

  void _showAbout(String path) {
    //window.console.log('about: ${path}');
    if (_fnOnAboutHandler != null) _fnOnAboutHandler();
  }

  void _showAny(String path) {
    //window.console.log('any: ${path}');
    if (_fnOnAnyHandler != null) _fnOnAnyHandler(path);
  }

}

