library spitoshare;

import 'dart:html';
import 'package:spitoshare/expiry_handler.dart';
import 'package:spitoshare/spito_api.dart';
import 'package:spitoshare/spito_router.dart';

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

  SpitoRouter router = new SpitoRouter(window.location.pathname);
  router.OnViewHandler = (String id) => viewPageHandler(spitoApi, id);
  router.OnHomeHandler = homePageHandler;
  router.OnAnyHandler = anyPageHandler;
  router.listen();
  router.handle(window.location.pathname + window.location.hash);
}

viewPageHandler(SpitoAPI spitoApi, String id) {
  window.console.info('main controller:: view :: ${id}');
  spitoApi.GetSpit(id).then((SpitoAPIResult result) {
    window.console.info(result);
  }).catchError((SpitoAPIResult result) {
    window.console.error(result);
  });
}

homePageHandler(String path) {
  window.console.info('main controller:: home :: ${path}');
}

anyPageHandler (String path) {
  window.console.info('main controller:: any :: ${path}');
}

void handleNewSpitResult(SpitoAPIResult result) {
  window.console.info(result);
  window.alert('Created: ${result.Spit.Id} ${result.Spit.Content}');
}

void handleNewSpitResultError(SpitoAPIResult result) {
  window.console.error(result);
}
