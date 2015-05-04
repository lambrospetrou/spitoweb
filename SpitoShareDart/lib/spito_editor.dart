library spito_editor;

import 'dart:html';
import 'package:spitoshare/expiry_handler.dart';

class SpitoEditor {

  static const String SPIT_URL = 'url';
  static const String SPIT_TEXT = 'text';

  Element _mContainer;

  ExpiryHandler _mExpiryHandler;
  String _mSpitType;

  SpitoEditor(this._mContainer, this._mSpitType) {
    _mExpiryHandler = new ExpiryHandler(this._mContainer.querySelector('#editor-exp'));
    setSpitType(_mSpitType);
  }

  String get SpitTypeEncoded => 'spit_type=${_mSpitType}';
  String get SpitType => _mSpitType;

  String setSpitType(String type) {
    if (type == 'text') {
      _mContainer.querySelector('#editor-text').classes.remove('disabled-element');
      _mContainer.querySelector('#editor-url').classes.add('disabled-element');
      _mContainer.querySelector('#editor-text').attributes.remove('disabled');
      _mContainer.querySelector('#editor-url').attributes.putIfAbsent('disabled', () => 'disable');
    } else if (type == 'url') {
      _mContainer.querySelector('#editor-text').classes.add('disabled-element');
      _mContainer.querySelector('#editor-url').classes.remove('disabled-element');
      _mContainer.querySelector('#editor-url').attributes.remove('disabled');
      _mContainer.querySelector('#editor-text').attributes.putIfAbsent('disabled', () => 'disable');
    }
    _mSpitType = type;
    return _mSpitType;
  }

  String get Content {
    if (_mSpitType == 'text') {
      TextAreaElement txtarea = (_mContainer.querySelector('#editor-text') as TextAreaElement);
      return txtarea.value;
    } else if (_mSpitType == 'url') {
      InputElement inurl = (_mContainer.querySelector('#editor-url') as InputElement);
      return inurl.value;
    }
    return '';
  }

  String get ExpireTime => _mExpiryHandler.ExpireTime;

  void clearContent() {
    if (_mSpitType == 'text') {
      TextAreaElement txtarea = (_mContainer.querySelector('#editor-text') as TextAreaElement);
      txtarea.value = '';
    } else if (_mSpitType == 'url') {
      InputElement inurl = (_mContainer.querySelector('#editor-url') as InputElement);
      inurl.value = '';
    }
  }

  void focusInput() {
    if (_mSpitType == 'text') {
      (_mContainer.querySelector('#editor-text') as TextAreaElement).focus();
    } else if (_mSpitType == 'url') {
      (_mContainer.querySelector('#editor-url') as InputElement).focus();
    }
  }

}
