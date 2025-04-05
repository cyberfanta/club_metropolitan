import 'package:flutter/material.dart';

import 'ui_text_en.dart';
import 'ui_text_es.dart';

class UiTexts extends ChangeNotifier {
  UiTexts(this._locale);

  Locale _locale;

  set locale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  String get title {
    return UiTextEn().title;
  }

  String get yes {
    if (_locale.languageCode == 'es') {
      return UiTextEs().yes;
    }

    return UiTextEn().yes;
  }

  String get no {
    if (_locale.languageCode == 'es') {
      return UiTextEs().no;
    }

    return UiTextEn().no;
  }

  String get appCloseTitleText {
    if (_locale.languageCode == 'es') {
      return UiTextEs().appCloseTitleText;
    }

    return UiTextEn().appCloseTitleText;
  }

  String get appCloseSubText {
    if (_locale.languageCode == 'es') {
      return UiTextEs().appCloseSubText;
    }

    return UiTextEn().appCloseSubText;
  }

  String get appCloseContext {
    if (_locale.languageCode == 'es') {
      return UiTextEs().appCloseContext;
    }

    return UiTextEn().appCloseContext;
  }
}
