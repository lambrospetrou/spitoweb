library spitoshare;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:spitoshare/spito_api.dart';
import 'package:spitoshare/spito_router.dart';
import 'package:spitoshare/spito_editor.dart';
import 'package:spitoshare/nav_drawer.dart';

void main() {

  NavDrawer menuDrawer = new NavDrawer(querySelector('#site-header-drawer'),
      querySelector('.gn-menu-wrapper'), querySelector('.gn-menu-shadow'));

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
    spitEditor.focusInput();
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
  router.OnViewHandler = (String id) => _viewPageHandler(spitoApi, id);
  router.OnHomeHandler = _homePageHandler;
  router.OnAboutHandler = _aboutPageHandler;
  router.OnFAQHandler = _faqPageHandler;
  router.OnAnyHandler = anyPageHandler;
  router.listen();
  router.handle(window.location.pathname + window.location.hash);
}

void _viewPageHandler(SpitoAPI spitoApi, String id) {
  window.console.info('main controller:: view :: ${id}');
  // show search page
  _hideCurrentContent();
  _setCurrentContent(querySelector('#view-page'));
  getAndShowSpit(spitoApi, id, null);
}

void _homePageHandler(String path) {
  window.console.info('main controller:: home :: ${path}');
  _hideCurrentContent();
  _setCurrentContent(querySelector('#home-page'));
}

void _aboutPageHandler() {
  _hideCurrentContent();
  _setCurrentContent(querySelector('#about-page'));
}

void _faqPageHandler() {
  _hideCurrentContent();
  _setCurrentContent(querySelector('#faq-page'));
}

void _hideCurrentContent() {
  Element el = querySelector('.content-selected');
  if (el != null) el.classes.remove('content-selected');
}
void _setCurrentContent(Element el) {
  el.classes.add('content-selected');
}

void anyPageHandler (String path) {
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
  ImageElement qrcode = (spitInfo.querySelector('#spit-link-qr') as ImageElement);
  if (qrcode != null) qrcode.src =
  'http://chart.apis.google.com/chart?chs=100x100&cht=qr&choe=UTF-8&chl=${spit.AbsoluteURL}';

  //(spitInfo.querySelector('#spit-content') as TextAreaElement).text = spit.Content;
  (spitInfo.querySelector('#spit-content') as TextAreaElement).value = spit.Content;
  if (spit.Expiration > 0) {
    var second = const Duration(seconds: 1);
    new Timer.periodic(second, (Timer timer){
      int secs = new DateTime.now().difference(spit.DateCreated).inSeconds;
      //window.console.log('${secs} ${new DateTime.now().toIso8601String()} ${spit.DateCreated}');
      if (spit.Expiration > secs) {
        spitInfo.querySelector('#spit-exp-time').text = (spit.Expiration-secs).toString();
      } else {
        spitInfo.querySelector('#spit-exp-time').text = 'expired';
        timer.cancel();
      }
    });
  } else {
    spitInfo.querySelector('#spit-exp-time').text = 'never';
  }
  String dateStr = spit.DateCreated.toLocal().toString();
  spitInfo.querySelector('#spit-date').text = dateStr.substring(0, dateStr.lastIndexOf('.'));
  //spitInfo.querySelector('#spit-clicks').text = 'coming soon';
  spitInfo.querySelector('#spit-clicks').text = spit.Clicks.toString();
}

void _createNewSpit(SpitoAPI spitoApi, SpitoEditor spitEditor, Function whenCompleteCallback) {
  querySelector('#new-spit-errors').classes.add('disabled-element');
//  window.console.log('spito editor: ${spitEditor.SpitTypeEncoded}');
//  window.console.log('spito editor: ${spitEditor.SpitType}');
//  window.console.log('spito editor: ${spitEditor.Content}');
//  window.console.log('spito editor: ${spitEditor.ExpireTime}');
  String content = spitEditor.Content;
  String expirefull = spitEditor.ExpireTime;
  spitoApi.CreateSpit(content,
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
  //window.console.info(result);
  //window.alert('Created: ${result.Spit.Id} ${result.Spit.Content} ${result.Spit.Expiration}');
  // update the URL hash to contain the newly fetched id
  window.location.hash = '#/view/${result.Spit.Id}';
}

void _handleNewSpitResultError(SpitoAPIResult err) {
  window.console.error(err.Message);
  try {
    Map errJson = JSON.decode(err.Response.responseText);
    StringBuffer sb = new StringBuffer();
    for (String msg in errJson['errors']) { sb.write(msg); }
    querySelector('#new-spit-errors').text = sb.toString();
  } on FormatException catch (e) {
    querySelector('#new-spit-errors').text = err.Message;
  } catch (e, stackTrace) {
    querySelector('#new-spit-errors').text = 'Unrecognized error: ${e}';
    window.console.error(stackTrace);
  }
  querySelector('#new-spit-errors').classes.remove('disabled-element');
}

///////////////////////////////////
///////////////////////////////////
///////////////////////////////////









