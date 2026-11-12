/// Configurações do app e seu armazenamento.
library;

import 'dart:convert';
import 'dart:ui' show Brightness;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/game.dart';
import '../theme/tokens.dart';
import '../ui/strings.dart';

enum ThemeChoice { umi, sakura, dark, system }

class AppSettings {
  final bool highlightSame;
  final bool highlightRegion;
  final bool highlightNotes;
  final bool mistakeLimitEnabled;
  final int mistakeLimit;
  final bool showTimer;
  final bool numberFirst;
  final bool showRemaining;
  final bool autoComplete;
  final bool preventWrongNotes;
  final bool autoRemoveNotes;
  final bool vibrate;
  final ThemeChoice theme;
  final AppLanguage language;

  const AppSettings({
    this.highlightSame = true,
    this.highlightRegion = true,
    this.highlightNotes = true,
    this.mistakeLimitEnabled = true,
    this.mistakeLimit = 3,
    this.showTimer = true,
    this.numberFirst = true,
    this.showRemaining = true,
    this.autoComplete = true,
    this.preventWrongNotes = true,
    this.autoRemoveNotes = true,
    this.vibrate = true,
    this.theme = ThemeChoice.umi,
    this.language = AppLanguage.pt,
  });

  AppSettings copyWith({
    bool? highlightSame,
    bool? highlightRegion,
    bool? highlightNotes,
    bool? mistakeLimitEnabled,
    int? mistakeLimit,
    bool? showTimer,
    bool? numberFirst,
    bool? showRemaining,
    bool? autoComplete,
    bool? preventWrongNotes,
    bool? autoRemoveNotes,
    bool? vibrate,
    ThemeChoice? theme,
    AppLanguage? language,
  }) =>
      AppSettings(
        highlightSame: highlightSame ?? this.highlightSame,
        highlightRegion: highlightRegion ?? this.highlightRegion,
        highlightNotes: highlightNotes ?? this.highlightNotes,
        mistakeLimitEnabled: mistakeLimitEnabled ?? this.mistakeLimitEnabled,
        mistakeLimit: mistakeLimit ?? this.mistakeLimit,
        showTimer: showTimer ?? this.showTimer,
        numberFirst: numberFirst ?? this.numberFirst,
        showRemaining: showRemaining ?? this.showRemaining,
        autoComplete: autoComplete ?? this.autoComplete,
        preventWrongNotes: preventWrongNotes ?? this.preventWrongNotes,
        autoRemoveNotes: autoRemoveNotes ?? this.autoRemoveNotes,
        vibrate: vibrate ?? this.vibrate,
        theme: theme ?? this.theme,
        language: language ?? this.language,
      );

  /// Regras de partida derivadas das configurações.
  GameRules get rules => GameRules(
        mistakeLimitEnabled: mistakeLimitEnabled,
        mistakeLimit: mistakeLimit,
        autoRemoveNotes: autoRemoveNotes,
        preventWrongNotes: preventWrongNotes,
      );

  UmiPalette palette(Brightness platform) => switch (theme) {
        ThemeChoice.umi => UmiPalette.umi,
        ThemeChoice.sakura => UmiPalette.sakura,
        ThemeChoice.dark => UmiPalette.dark,
        ThemeChoice.system =>
          platform == Brightness.dark ? UmiPalette.dark : UmiPalette.umi,
      };

  Map<String, dynamic> toJson() => {
        'highlightSame': highlightSame,
        'highlightRegion': highlightRegion,
        'highlightNotes': highlightNotes,
        'mistakeLimitEnabled': mistakeLimitEnabled,
        'mistakeLimit': mistakeLimit,
        'showTimer': showTimer,
        'numberFirst': numberFirst,
        'showRemaining': showRemaining,
        'autoComplete': autoComplete,
        'preventWrongNotes': preventWrongNotes,
        'autoRemoveNotes': autoRemoveNotes,
        'vibrate': vibrate,
        'theme': theme.name,
        'language': language.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    T pick<T>(String key, T fallback) =>
        j[key] is T ? j[key] as T : fallback;
    return AppSettings(
      highlightSame: pick('highlightSame', d.highlightSame),
      highlightRegion: pick('highlightRegion', d.highlightRegion),
      highlightNotes: pick('highlightNotes', d.highlightNotes),
      mistakeLimitEnabled: pick('mistakeLimitEnabled', d.mistakeLimitEnabled),
      mistakeLimit: pick('mistakeLimit', d.mistakeLimit),
      showTimer: pick('showTimer', d.showTimer),
      numberFirst: pick('numberFirst', d.numberFirst),
      showRemaining: pick('showRemaining', d.showRemaining),
      autoComplete: pick('autoComplete', d.autoComplete),
      preventWrongNotes: pick('preventWrongNotes', d.preventWrongNotes),
      autoRemoveNotes: pick('autoRemoveNotes', d.autoRemoveNotes),
      vibrate: pick('vibrate', d.vibrate),
      theme: ThemeChoice.values.asNameMap()[j['theme']] ?? d.theme,
      language: AppLanguage.values.asNameMap()[j['language']] ?? d.language,
    );
  }
}

abstract class SettingsStore {
  Future<String?> load();
  Future<void> save(String json);
}

class PrefsSettingsStore implements SettingsStore {
  static const _key = 'settings_v1';

  @override
  Future<String?> load() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> save(String json) async {
    await (await SharedPreferences.getInstance()).setString(_key, json);
  }
}

/// Guarda as configurações atuais e avisa as telas quando mudam.
class SettingsController extends ChangeNotifier {
  SettingsController({this.store, AppSettings initial = const AppSettings()})
      : _value = initial {
    S.lang = initial.language;
  }

  final SettingsStore? store;
  AppSettings _value;

  AppSettings get value => _value;

  Future<void> load() async {
    try {
      final json = await store?.load();
      if (json == null) return;
      _value = AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
      S.lang = _value.language;
      notifyListeners();
    } catch (_) {
      // Configuração ilegível: mantém os padrões.
    }
  }

  void update(AppSettings next) {
    _value = next;
    S.lang = next.language;
    notifyListeners();
    store?.save(jsonEncode(next.toJson()));
  }
}
