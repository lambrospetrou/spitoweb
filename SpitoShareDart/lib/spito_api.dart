library spito_api;

import 'dart:html';
import 'dart:convert';
import 'dart:async';

class SpitoAPI {

  static const int RES_OK = 1;
  static const int RES_FAIL = 2;

  String _mRootDomain;

  SpitoAPI(String rootDomain) {
    this._mRootDomain = rootDomain.endsWith('/') ? rootDomain.substring(0, rootDomain.length - 1) : rootDomain;
  }

  Future<SpitoAPIResult> CreateSpit(String content, String spit_type, int exp, String expMode) {
    int millis = new DateTime.now().millisecondsSinceEpoch;

    //window.console.log('expiration: ${_expireTime(exp, expMode)}');
    exp = _expireTime(exp, expMode);

    FormData formData = new FormData()
      ..append('spit_type', spit_type)
      ..append('exp', exp.toString())
      ..append('content', content);

    var completer = new Completer<SpitoAPIResult>();
    HttpRequest request = new HttpRequest()
      ..open('POST', this._mRootDomain + '/api/v1/spits')
      //..setRequestHeader("Content-type", "application/json")
      ..onLoadEnd.listen((e) {
        int duration = (new DateTime.now().millisecondsSinceEpoch) - millis;
        // e.target is the HttpRequest object
        HttpRequest res = e.target as HttpRequest;
        if (res.status == 200) {
          SpitoAPIResult apiResult = new SpitoAPIResult(
            RES_OK, 'Successfully created new Spit!', new Spit.fromJson(res.responseText), res
          )..Duration = duration;
          completer.complete(apiResult);
        } else {
          SpitoAPIResult apiResult = new SpitoAPIResult(
              RES_FAIL, 'The response is not OK:200 [${res.responseText}}]', null, res
          )..Duration = duration;
          completer.completeError(apiResult);
        }
      })
      ..send(formData);
    return completer.future;
  }

  Future<SpitoAPIResult> GetSpit(String id) {
    int millis = new DateTime.now().millisecondsSinceEpoch;

    var completer = new Completer<SpitoAPIResult>();
    HttpRequest request = new HttpRequest()
      ..open('GET', this._mRootDomain + '/api/v1/spits/${id}')
      ..onLoadEnd.listen((e) {
        int duration = (new DateTime.now().millisecondsSinceEpoch) - millis;
        // e.target is the HttpRequest object
        HttpRequest res = e.target as HttpRequest;
        if (res.status == 200) {
          SpitoAPIResult apiResult = new SpitoAPIResult(
              RES_OK, 'Successfully fetched Spit ${id}!', new Spit.fromJson(res.responseText), res
          )..Duration = duration;
          completer.complete(apiResult);
        } else {
          SpitoAPIResult apiResult = new SpitoAPIResult(
              RES_FAIL, 'The response is not OK:200 [${res.responseText}]', null, res
          )..Duration = duration;
          completer.completeError(apiResult);
        }
      })
      ..send();
    return completer.future;
  }

  int _expireTime(int _mExpiryValue, String _mExpiryUnit) {
    if (_mExpiryUnit == 's') return _mExpiryValue;
    else if (_mExpiryUnit == 'm') return _mExpiryValue * 60;
    else if (_mExpiryUnit == 'h') return _mExpiryValue * 3600;
    else if (_mExpiryUnit == 'd') return _mExpiryValue * 24 * 3600;
    else if (_mExpiryUnit == 'M') return _mExpiryValue * 30 * 24 * 3600;
    return 60; // default
  }
}

class Spit {
  String _mId;
  String _mContent;
  String _mSpitType;
  String _mDateExpiration;
  String _mDateCreated;
  bool _mIsUrl;
  String _mAbsUrl;
  int _mClicks;

  /*
{
    "id": "ag",
    "expiration": 30,
    "content": "this is another core api add test",
    "spit_type": "text",
    "date_created": "2015-02-06T22:19:40.555783416Z",
    "date_created_fmt": "February 06, 2015 | Friday",
    "is_url": false,
    "absolute_url": "http://spi.to/ag",
    "Message": "Successfully added new Spit!"
}
  */
  Spit.fromJson(String json) {
    Map jsonMap = JSON.decode(json);
    this._mId = jsonMap['id'];
    this._mDateExpiration = jsonMap['date_expiration'];
    this._mDateCreated = jsonMap['date_created'];
    this._mContent = jsonMap['content'];
    this._mSpitType = jsonMap['spit_type'];
    this._mIsUrl = jsonMap['is_url'];
    this._mAbsUrl = jsonMap['absolute_url'];
    this._mClicks = jsonMap['clicks'];
  }

  String get Id => this._mId;
  String get Content => this._mContent;
  String get SpitType => this._mSpitType;
  int get Clicks => this._mClicks;
  DateTime get DateExpiration => DateTime.parse(this._mDateExpiration);
  DateTime get DateCreated => DateTime.parse(this._mDateCreated);
  bool get IsUrl => this._mIsUrl;
  String get AbsoluteURL => this._mAbsUrl;
}

class SpitoAPIResult {
  SpitoAPIResult(this._mStatus, this._mMsg, this._mSpit, this._mResponse) {}

  HttpRequest _mResponse;

  HttpRequest get Response => this._mResponse;

  int _mStatus;

  int get Status => this._mStatus;

  String _mMsg;

  String get Message => this._mMsg;

  Spit _mSpit;

  Spit get Spit => this._mSpit;

  int _mDuration;
  int get Duration => this._mDuration;
  set Duration(int d) => this._mDuration = d;
}
