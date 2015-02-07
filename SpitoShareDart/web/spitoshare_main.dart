library spitoshare;

import 'dart:html';
import 'package:spitoshare/expiry_handler.dart';
import 'package:spitoshare/spito_api.dart';

void main() {

  ExpiryHandler expiryHandler = new ExpiryHandler(document.querySelector('#editor-exp'));

  SpitoAPI spitoApi = new SpitoAPI("http://localhost:40090/");

  Element btnEditorCreate = querySelector('#btnEditorCreate');
  btnEditorCreate.onClick.listen((data) {
    btnEditorCreate.setAttribute('disabled', 'true');
    spitoApi.CreateSpit('testing the Dart client', 'text', 60, 'd').then((SpitAPIResult result) {
      window.console.info(result);
      window.alert('Created: ${result.Spit.Id} ${result.Spit.Content}');
    })
    .catchError((SpitAPIResult result) {
      window.console.error(result);
    }).whenComplete(() {
      btnEditorCreate.setAttribute('disabled', 'false');
    });
  });

}

