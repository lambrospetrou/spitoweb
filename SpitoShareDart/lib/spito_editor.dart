library spito_editor;

import 'dart:html';
import 'package:spitoshare/expiry_handler.dart';

class SpitoEditor {

  static const String SPIT_URL = 'url';
  static const String SPIT_SRC = 'src';

  Element _mContainer;
  Element _mSpitTypeGroup;

  ExpiryHandler _mExpiryHandler;

  String _mSpitType;

  SpitoEditor(this._mContainer, this._mSpitType) {
    this._mSpitTypeGroup = this._mContainer.querySelector('#spit-type-radio-group');
    _mExpiryHandler = new ExpiryHandler(this._mContainer.querySelector('#editor-exp'));
    setSpitType(_mSpitType);
  }

  String get SpitInfoURLEncoded {
    String spitType = this._mSpitTypeGroup.getAttribute('selected');
    /*
    this._mSpitTypeGroup.children.forEach((el) {
      window.console.log(el.attributes);
      if (el.attributes.containsKey('checked')) spitType = el.getAttribute('value');
    });
    */
    return 'spit_type=${spitType}';
  }

  String setSpitType(String type) {
    if (type == 'src') {
      _mContainer.querySelector('#editor-text').classes.remove('disabled-element');
      _mContainer.querySelector('#editor-url').classes.add('disabled-element');
    } else if (type == 'url') {
      _mContainer.querySelector('#editor-text').classes.add('disabled-element');
      _mContainer.querySelector('#editor-url').classes.remove('disabled-element');
    }
    _mSpitType = type;
    return _mSpitType;
  }

}
