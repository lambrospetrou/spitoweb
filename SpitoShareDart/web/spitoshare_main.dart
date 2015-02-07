library spitoshare;

import 'dart:html';
import 'package:route/url_pattern.dart';
import 'package:route/client.dart';
import 'package:spitoshare/expiry_handler.dart';
import 'package:spitoshare/spito_api.dart';

void main() {

  ExpiryHandler expiryHandler = new ExpiryHandler(document.querySelector('#editor-exp'));

  SpitoAPI spitoApi = new SpitoAPI("http://localhost:40090/");

  Element btnEditorCreate = querySelector('#btnEditorCreate');
  btnEditorCreate.onClick.listen((data) {
    btnEditorCreate.setAttribute('disabled', 'true');
    spitoApi.CreateSpit('testing the Dart client', 'text', 60, 'd')
    .then(handleNewSpitResult)
    .catchError(handleNewSpitResultError)
    .whenComplete(() {
      btnEditorCreate.setAttribute('disabled', 'false');
    });
  });

  // setup routing to listen for changes to the URL.
  print('loc: ${window.location}');
  print('pathname: ${window.location.pathname}');

  var router = new Router()
    ..addHandler(viewUrl, showView)
    ..addHandler(homeUrl, showHome)
    ..addHandler(homeRootUrl, redirectToHome)
    ..addHandler(homeStrippedUrl, redirectToHome)
    ..addHandler(anyUrl, showAny)
    ..listen();
  router.handle(window.location.pathname + window.location.hash);
}

String path = window.location.pathname;
final homeUrl = new UrlPattern(path + r'#/(.*)');
final homeStrippedUrl = new UrlPattern(path + r'/');
final homeRootUrl = new UrlPattern(path);
final viewUrl = new UrlPattern(path + r'#/view/(\w+)');
final anyUrl = new UrlPattern(r'(.*)');

void showView(String path) {
  window.console.log('view: ${path}');
  SpitoAPI spitoApi = new SpitoAPI("http://localhost:40090/");
  var id = viewUrl.parse(path)[0];
  spitoApi.GetSpit(id).then((SpitoAPIResult result) {
    window.console.info(result);
  }).catchError((SpitoAPIResult result) {
    window.console.error(result);
  });
}

void showHome(String path) {
  window.console.log('home: ${path}');
  var actualHash = homeUrl.parse(path);
  window.console.log('home: ${actualHash}');
  window.console.log('home: ${actualHash[0]}');
}

void redirectToHome(String path) {
  window.console.log('home: ${path} redirecting to proper home');
  gotoHome();
}

void showAny(String path) {
  window.console.log('any: ${path}');
  gotoHome();
}

void gotoHome() {
  //window.location.pathname = '';
  window.location.hash = '#/';
}

void handleNewSpitResult(SpitoAPIResult result) {
  window.console.info(result);
  window.alert('Created: ${result.Spit.Id} ${result.Spit.Content}');
}

void handleNewSpitResultError(SpitoAPIResult result) {
  window.console.error(result);
}
