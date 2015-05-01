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
          )..Duration = duration;;
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
          )..Duration = duration;;
          completer.completeError(apiResult);
        }
      })
      ..send();
    return completer.future;
  }

}

class Spit {
  String _mId;
  String _mContent;
  int _mExp;
  String _mSpitType;
  DateTime _mDateCreated;
  bool _mIsUrl;
  String _mAbsUrl;

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
    this._mExp = jsonMap['expiration'];
    this._mContent = jsonMap['content'];
    this._mSpitType = jsonMap['spit_type'];
    this._mIsUrl = jsonMap['is_url'];
    this._mAbsUrl = jsonMap['absolute_url'];
    // date is taken by GO server as: 2015-02-07 00:06:00.44145677Z
    // but Dart DateTime can only parse 3 digits of milliseconds
    String dateStr = jsonMap['date_created'];
    int lastDot = dateStr.lastIndexOf('.');
    String dateMillis = dateStr.substring(lastDot+1);
    dateMillis = dateMillis.length > 3 ? dateMillis.substring(0,3) : dateMillis;
    dateStr = dateStr.substring(0, lastDot+1) + dateMillis + 'Z';
    this._mDateCreated = DateTime.parse(dateStr);
  }

  String get Id => this._mId;
  String get Content => this._mContent;
  String get SpitType => this._mSpitType;
  int get Expiration => this._mExp;
  DateTime get DateCreated => this._mDateCreated;
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
