library flutter_vortezz_base;

import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vortezz_base/enum/app_theme.dart';
import 'package:flutter_vortezz_base/struct/event_emitter.dart';
import 'package:flutter_vortezz_base/struct/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Client with EventEmitter {
  Map<String, Map<String, String>> translations = {};

  bool _loaded = false;

  AppTheme _appTheme = AppTheme.dark;
  bool systemTheme = false;

  String _systemLanguage = "en";
  Language _language = Language.system;

  bool _dyslexicFont = false;
  bool _biggerText = false;

  final String appName;

  Client({required this.appName}) {
    load();
  }

  late SharedPreferences preferences;

  Language get language => _language;

  set language(Language language) {
    _language = language;
    preferences.setString(
        "$appName.language", language.toString().split(".")[1]);
  }

  bool get isDyslexicFont => _dyslexicFont;

  set isDyslexicFont(bool isDyslexicFont) {
    _dyslexicFont = isDyslexicFont;
    preferences.setBool("$appName.dyslexic_font", isDyslexicFont);
  }

  bool get isBiggerText => _biggerText;

  set isBiggerText(bool isBiggerText) {
    _biggerText = isBiggerText;
    preferences.setBool("$appName.bigger_text", isBiggerText);
  }

  AppTheme get appTheme => _appTheme;

  set appTheme(AppTheme appTheme) {
    _appTheme = appTheme;

    if (_appTheme == AppTheme.system) {
      _appTheme = AppTheme.system;
      systemTheme = SchedulerBinding.instance.window.platformBrightness ==
          Brightness.dark;
    }

    preferences.setString("molkky.theme", _appTheme.name);
  }

  bool get darkTheme =>
      _appTheme == AppTheme.dark || _appTheme == AppTheme.system && systemTheme;

  Future<void> load() async {
    for (String lang in ["en", "fr", "de", "es"]) {
      String translationJson =
          await rootBundle.loadString("assets/lang/$lang.json");

      Map<String, dynamic> json = jsonDecode(translationJson);

      Map<String, String> translation = {};

      for (MapEntry entry in json.entries) {
        translation[entry.key] = entry.value as String;
      }

      translations[lang] = translation;
    }

    preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey("$appName.dyslexic_font")) {
      preferences.setBool("$appName.dyslexic_font", false);
    }

    _dyslexicFont = preferences.getBool("$appName.dyslexic_font") ?? false;

    if (!preferences.containsKey("$appName.bigger_text")) {
      preferences.setBool("$appName.bigger_text", false);
    }

    _biggerText = preferences.getBool("$appName.bigger_text") ?? false;

    if (!preferences.containsKey("$appName.theme")) {
      preferences.setString("$appName.theme", "system");
    }

    switch (preferences.getString("$appName.theme")) {
      case "system":
        _appTheme = AppTheme.system;
        systemTheme = SchedulerBinding.instance.window.platformBrightness ==
            Brightness.dark;
        break;
      case "dark":
        _appTheme = AppTheme.dark;
        break;
      case "light":
        _appTheme = AppTheme.light;
        break;
      default:
        _appTheme = AppTheme.system;
        systemTheme = SchedulerBinding.instance.window.platformBrightness ==
            Brightness.dark;
        preferences.setString("$appName.theme", "system");
        break;
    }

    if (!preferences.containsKey("$appName.language")) {
      preferences.setString("$appName.language", "system");
    }

    switch (preferences.getString("$appName.language")) {
      case "system":
        language = Language.system;
        _systemLanguage = SchedulerBinding.instance.window.locale.languageCode;

        if (!translations.containsKey(_systemLanguage)) {
          _systemLanguage = "en";
        }
        break;
      case "en":
        language = Language.en;
        break;
      case "fr":
        language = Language.fr;
        break;
      case "de":
        language = Language.de;
        break;
      case "es":
        language = Language.es;
        break;
      default:
        language = Language.system;
        _systemLanguage = SchedulerBinding.instance.window.locale.languageCode;

        if (!translations.containsKey(_systemLanguage)) {
          _systemLanguage = "en";
        }
        preferences.setString("$appName.language", "system");
        break;
    }
  }

  bool get loaded => _loaded;

  set loaded(bool isLoaded) {
    _loaded = isLoaded;
  }

  String getLanguage() {
    switch (language) {
      case Language.en:
        return "en";
      case Language.fr:
        return "fr";
      case Language.de:
        return "de";
      case Language.es:
        return "es";
      default:
        return _systemLanguage;
    }
  }

  double getTextScale() {
    return isBiggerText ? 1.2 : 1;
  }

  String translate(String key, [Map<String, String>? replacements]) {
    replacements ??= Map.identity();

    String text = key;
    if (translations[getLanguage()] != null &&
        translations[getLanguage()]!.containsKey(key)) {
      text = translations[getLanguage()]![key] ?? key;
    }

    for (MapEntry entry in replacements.entries) {
      text = text.replaceAll("{${entry.key}}", entry.value);
    }

    return text;
  }
}
