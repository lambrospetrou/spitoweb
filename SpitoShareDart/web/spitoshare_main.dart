library spitoshare;

import 'dart:html';
import 'dart:js' as js;

void main() {

  DivElement sliderDiv = document.querySelector('#editor-exp-slider');
  js.JsObject sliderJsObj = js.context.callMethod('jQuery', [sliderDiv]);
  SpanElement expValValueElem = document.querySelector('#editor-exp-val-value');
  js.JsObject expValValueJsObj = js.context.callMethod('jQuery', [expValValueElem]);

  Element expValUnitElem = querySelector('#editor-exp-val-unit');
  Element expValTextElem = querySelector('#editor-exp-val-text');

/*
  sliderJsObj.callMethod('noUiSlider', [new js.JsObject.jsify({
      'start': [ 0 ],
      'step': 1000,
      'range': {
          'min': [ 2000 ],
          'max': [ 10000 ]
      }
  })]);
  (sliderJsObj.callMethod('Link', ['lower']) as js.JsObject).callMethod('to', [expValValueJsObj]);
*/

  js.context.callMethod('jQuery', [sliderDiv]).callMethod('slider', [new js.JsObject.jsify({
      'orientation': 'horizontal',
      'value':0,
      'min': 0,
      'max': 60,
      'step': 1,
      'slide': (event, ui) {
        int sliderVal = ui['value'];
        print(sliderVal);
        updateExpiryValue(sliderVal, expValUnitElem, expValValueElem, expValTextElem);
      },
      'change': (event, ui) {
      }
  })]);
  updateExpiryValue(sliderJsObj.callMethod('slider', ['value']), expValUnitElem, expValValueElem, expValTextElem);

  //js.context['console'].callMethod('log', [js.context.callMethod('jQuery', [window.document.querySelector('#editor-exp-slider')]).callMethod('text',[])]);
  //js.context['console'].callMethod('log', 'testing');
}

String _getExpiryText(int value) {
  if (value == 0) {
    return "never expiry";
  } else {
    return "expire in";
  }
}

void updateExpiryValue(int value, Element expValUnitElem, Element expValValueElem, Element expValTextElem) {
  if (value == 0) {
    expValUnitElem.classes.remove('editor-exp-val-visible');
    expValValueElem.classes.remove('editor-exp-val-visible');
  } else {
    expValUnitElem.classes.add('editor-exp-val-visible');
    expValValueElem.classes.add('editor-exp-val-visible');
  }
  expValValueElem.text = paddingLeadingZeros(value, 2);
  expValTextElem.text = _getExpiryText(value);
}

String paddingLeadingZeros(int value, int totalWidth) {
  String valStr = value.toString();
  StringBuffer sb = new StringBuffer();
  int i=valStr.length;
  for (;i<totalWidth; i++) {
    sb.write('0');
  }
  sb.write(valStr);
  return sb.toString();
}
