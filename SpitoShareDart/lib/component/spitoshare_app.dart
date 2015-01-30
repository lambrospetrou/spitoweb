library spitoshare_app_component;

import 'package:angular/angular.dart';
import 'dart:js' as js;
import 'dart:html';

@Component(
    selector: 'spitoshare-app',
    templateUrl: 'spitoshare_app.html',
    cssUrl: 'spitoshare_app.css'
)
class SpitoShareComponent implements AttachAware, ShadowRootAware, ScopeAware {
  bool clicked = false;
  Scope _scope;
  ShadowRoot _shadowRoot;

  toggle() => clicked = !clicked;

  void attach() {

  }

  void onShadowRoot(ShadowRoot shadowRoot) {
    _shadowRoot = shadowRoot;
    DivElement sliderDiv = _shadowRoot.querySelector('#editor-exp-slider');
/*
    js.context.callMethod('jQuery', [sliderDiv]).callMethod('noUiSlider', [new js.JsObject.jsify({
        'start': [ 4000 ],
        'step': 1000,
        'range': {
            'min': [ 2000 ],
            'max': [ 10000 ]
        }
    })]);
*/
    js.context.callMethod('jQuery', [sliderDiv]).callMethod('slider', [new js.JsObject.jsify({

    })]);
    js.context['console'].callMethod('log', [js.context.callMethod('jQuery', [_shadowRoot.querySelector('.editor-exp-slider')]).callMethod('text',[])]);
  }

  void set scope(Scope scope) {
    _scope = scope;
  }


}
