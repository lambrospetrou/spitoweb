library spitoshare;

import 'dart:html';
import 'dart:async';
import 'package:spitoshare/spito_api.dart';
import 'package:spitoshare/spito_router.dart';
import 'package:spitoshare/spito_editor.dart';

void main() {

  SpitoAPI spitoApi = new SpitoAPI("http://localhost:40090/");
  SpitoEditor spitEditor = new SpitoEditor(querySelector('#home-page'), SpitoEditor.SPIT_URL);

  // CREATE SPIT - LISTENERS
  FormElement formNewSpit = querySelector('#new-spit-form');
  formNewSpit.onSubmit.listen((ev) {
    formNewSpit.setAttribute('disabled', 'true');
    ev.stopImmediatePropagation();
    _createNewSpit(spitoApi, spitEditor, () {
      formNewSpit.setAttribute('disabled', 'false');
    });
  });

  Element btnEditorClear = querySelector('#btnEditorClear');
  btnEditorClear.onClick.listen((ev) {
    spitEditor.clearContent();
  });

  Element radioGroupSpitType = querySelector('#spit-type-radio-group');
  radioGroupSpitType.children.forEach((radioButton) {
    radioButton.onChange.listen((ev){
      Element radioButton = ev.target;
      window.console.log(radioButton);
      spitEditor.setSpitType(radioButton.getAttribute('name'));
    });
  });

  // VIEW SPIT - PAGE LISTENERS
  FormElement formViewSpit = querySelector('#view-spit-form');
  formViewSpit.onSubmit.listen((ev) {
    formViewSpit.setAttribute('disabled', 'true');
    ev.stopImmediatePropagation();
    String id = (formViewSpit.querySelector('#spit-id') as InputElement).value;
    getAndShowSpit(spitoApi, id, () {
      formViewSpit.setAttribute('disabled', 'false');
    });
  });

  querySelector('#spit-header').onClick.listen((ev) {
    /* either this or the one liner below
    var range = document.createRange();
    range.selectNodeContents(ev.target);
    window.getSelection().addRange(range);
    */
    window.getSelection().selectAllChildren(ev.target);
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
  // show search page
  querySelector('#home-page').classes.add('disabled-element');
  querySelector('#view-page').classes.remove('disabled-element');
  getAndShowSpit(spitoApi, id, null);
}

homePageHandler(String path) {
  window.console.info('main controller:: home :: ${path}');
  querySelector('#home-page').classes.remove('disabled-element');
  querySelector('#view-page').classes.add('disabled-element');
}

anyPageHandler (String path) {
  window.console.info('main controller:: any :: ${path}');
}

void getAndShowSpit(SpitoAPI spitoApi, String id, Function whenCompleteCallback) {
  querySelector('#view-spit-information').classes.add('disabled-element');
  querySelector('#view-spit-errors').classes.add('disabled-element');
  if (id != null && !id.trim().isEmpty ) {
    spitoApi.GetSpit(id).then((SpitoAPIResult result) {
      window.console.log(result);

      // update the Spit information
      _fillSpitInformation(result.Spit);

      // update the URL hash to contain the newly fetched id
      window.location.hash = '#/view/${id}';

      querySelector('#view-spit-information').classes.remove('disabled-element');
    }).catchError((err) {
      window.console.info(err);
      if (err is SpitoAPIResult) {
        querySelector('#view-spit-errors').text = (err as SpitoAPIResult).Response.responseText;
      } else {
        querySelector('#view-spit-errors').text = err;
      }
      querySelector('#view-spit-errors').classes.remove('disabled-element');
    }).whenComplete((){
      if (whenCompleteCallback != null) whenCompleteCallback();
    });
  }
}

void _fillSpitInformation(Spit spit) {
  Element spitInfo = querySelector('#view-spit-information');
  spitInfo.querySelector('#spit-header').text = spit.AbsoluteURL;
  (spitInfo.querySelector('#spit-absurl') as AnchorElement).href = spit.AbsoluteURL;
  (spitInfo.querySelector('#spit-link-qr') as ImageElement).src =
  'http://chart.apis.google.com/chart?chs=100x100&cht=qr&choe=UTF-8&chl=${spit.AbsoluteURL}';

  //(spitInfo.querySelector('#spit-content') as TextAreaElement).text = spit.Content;
  (spitInfo.querySelector('#spit-content') as TextAreaElement).value = spit.Content;
  if (spit.Expiration > 0) {
    var second = const Duration(seconds: 1);
    new Timer.periodic(second, (Timer timer){
      int secs = new DateTime.now().difference(spit.DateCreated).inSeconds;
      secs = (spit.Expiration - secs);
      spitInfo.querySelector('#spit-exp-time').text = secs>0 ? secs.toString() : 'expired';
      if (secs <= 0) timer.cancel();
    });
  } else {
    spitInfo.querySelector('#spit-exp-time').text = 'never';
  }
  String dateStr = spit.DateCreated.toLocal().toString();
  spitInfo.querySelector('#spit-date').text = dateStr.substring(0, dateStr.lastIndexOf('.'));
  spitInfo.querySelector('#spit-clicks').text = 'coming soon';
}

void _createNewSpit(SpitoAPI spitoApi, SpitoEditor spitEditor, Function whenCompleteCallback) {
//  window.console.log('spito editor: ${spitEditor.SpitTypeEncoded}');
//  window.console.log('spito editor: ${spitEditor.SpitType}');
//  window.console.log('spito editor: ${spitEditor.Content}');
//  window.console.log('spito editor: ${spitEditor.ExpireTime}');
  String content = spitEditor.Content;
  if (content == null || content.trim().isEmpty) {
    spitEditor.clearContent();
    return;
  }

  String expirefull = spitEditor.ExpireTime;
  spitoApi.CreateSpit(spitEditor.Content,
                      spitEditor.SpitType,
                      int.parse(expirefull.substring(0, expirefull.length-1)),
                      expirefull.substring(expirefull.length-1, expirefull.length))
  //spitoApi.CreateSpit('testing the Dart client', 'text', 60, 's')
  .then(_handleNewSpitResult)
  .catchError(_handleNewSpitResultError)
  .whenComplete(() {
    if (whenCompleteCallback != null) whenCompleteCallback();
  });
}

void _handleNewSpitResult(SpitoAPIResult result) {
  window.console.info(result);
  window.alert('Created: ${result.Spit.Id} ${result.Spit.Content}');
  // update the URL hash to contain the newly fetched id
  window.location.hash = '#/view/${result.Spit.Id}';
}

void _handleNewSpitResultError(SpitoAPIResult result) {
  window.console.info(result);
}


