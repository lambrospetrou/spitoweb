library spito_editor;

import 'dart:html';
import 'package:spitoshare/expiry_handler.dart';

class SpitoEditor {

  Element _mContainer;
  Element _mSpitTypeGroup;

  ExpiryHandler _mExpiryHandler;

  SpitoEditor(this._mContainer) {
    this._mSpitTypeGroup = this._mContainer.querySelector('#spit-type-radio-group');
    _mExpiryHandler = new ExpiryHandler(this._mContainer.querySelector('#editor-exp'));
  }

  String get SpitInfoURLEncoded {
    String spitType = this._mSpitTypeGroup.getAttribute('selected');
    this._mSpitTypeGroup.children.forEach((el) {
      window.console.log(el.attributes);
      if (el.attributes.containsKey('checked')) spitType = el.getAttribute('value');
    });
    return 'spit_type=${spitType}';
  }

}
