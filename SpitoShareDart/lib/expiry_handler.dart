library expiry_handler;

import 'dart:html';
import 'dart:js' as js;

class ExpiryHandler {

  // contains all the slider elements
  Element _mContainer;

  DivElement _mSliderDiv;
  js.JsObject _mSliderJsObj;

  SpanElement _mExpValValueElem;
  js.JsObject _mExpValValueJsObj;

  Element _mExpValUnitElem;
  Element _mExpValTextElem;

  ExpiryHandler(Element container) {
    _mContainer = container;
    _init(_mContainer);
  }

  void _init(Element container) {
    _mSliderDiv = container.querySelector('#editor-exp-slider');
    _mSliderJsObj = js.context.callMethod('jQuery', [_mSliderDiv]);
    _mExpValValueElem = container.querySelector('#editor-exp-val-value');
    _mExpValValueJsObj = js.context.callMethod('jQuery', [_mExpValValueElem]);

    _mExpValUnitElem = container.querySelector('#editor-exp-val-unit');
    _mExpValTextElem = container.querySelector('#editor-exp-val-text');

    js.context.callMethod('jQuery', [_mSliderDiv]).callMethod('slider', [new js.JsObject.jsify({
        'orientation': 'horizontal',
        'value':0,
        'min': 0,
        'max': 60,
        'step': 1,
        'slide': (event, ui) {
          int sliderVal = ui['value'];
          _updateExpiryValue(sliderVal, _mExpValUnitElem, _mExpValValueElem, _mExpValTextElem);
        },
        'change': (event, ui) {
        }
    })]);
    _updateExpiryValue(_mSliderJsObj.callMethod('slider', ['value']), _mExpValUnitElem, _mExpValValueElem, _mExpValTextElem);
  }

  String _getExpiryText(int value) {
    if (value == 0) {
      return "never expires";
    } else {
      return "expire in";
    }
  }

  void _updateExpiryValue(int value, Element expValUnitElem, Element expValValueElem, Element expValTextElem) {
    if (value == 0) {
      expValUnitElem.classes.remove('editor-exp-val-visible');
      expValValueElem.classes.remove('editor-exp-val-visible');
    } else {
      expValUnitElem.classes.add('editor-exp-val-visible');
      expValValueElem.classes.add('editor-exp-val-visible');
    }
    expValValueElem.text = _paddingLeadingZeros(value, 2);
    expValTextElem.text = _getExpiryText(value);
  }

  String _paddingLeadingZeros(int value, int totalWidth) {
    String valStr = value.toString();
    StringBuffer sb = new StringBuffer();
    int i=valStr.length;
    for (;i<totalWidth; i++) {
      sb.write('0');
    }
    sb.write(valStr);
    return sb.toString();
  }


}
