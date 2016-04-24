library nav_drawer;

import 'dart:html';

class NavDrawer {

  Element _mMenuTrigger;
  Element _mMenuDrawer;
  Element _mMenuShadow;

  bool _mIsMenuOpen;

  NavDrawer(this._mMenuTrigger, this._mMenuDrawer, this._mMenuShadow) {
    _mIsMenuOpen = false;

    _mMenuTrigger.onClick.listen((evt) {
      evt.stopImmediatePropagation();
      evt.preventDefault();
      if (this._mIsMenuOpen) {
        this._closeMenu();
      } else {
        this._openMenu();
        document.onClick.first.then((evt2) {
          this._closeMenu();
        });
      }
    });

    _mMenuDrawer.onClick.listen((evt) {
      // stop propagating down the DOM
      evt.stopImmediatePropagation();
    });

    this._mMenuShadow.classes.add('display-none');
  }

  void _openMenu() {
    if (this._mIsMenuOpen) return;
    this._mMenuShadow.classes.add('gn-shadow-open');
    this._mIsMenuOpen = true;
    this._mMenuDrawer.classes.add('gn-open-all');
  }

  void _closeMenu() {
    if (!this._mIsMenuOpen) return;
    this._mMenuShadow.classes.remove('gn-shadow-open');
    this._mIsMenuOpen = false;
    this._mMenuDrawer.classes.remove('gn-open-all');
  }

}
