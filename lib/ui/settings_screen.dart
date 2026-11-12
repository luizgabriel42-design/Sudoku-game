/// Tela de configurações.
library;

import 'package:material_ui/material_ui.dart';

import '../data/settings.dart';
import '../theme/tokens.dart';
import 'strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final v = settings.value;
        final p = v.palette(MediaQuery.platformBrightnessOf(context));
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            backgroundColor: p.background,
            foregroundColor: p.ink,
            title: Text(S.settings),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _section(S.secHighlights, p),
              _toggle('highlightSame', S.setSame, S.setSameSub,
                  v.highlightSame, (x) => v.copyWith(highlightSame: x), p),
              _toggle('highlightRegion', S.setRegion, S.setRegionSub,
                  v.highlightRegion, (x) => v.copyWith(highlightRegion: x), p),
              _toggle('highlightNotes', S.setNotesHl, S.setNotesHlSub,
                  v.highlightNotes, (x) => v.copyWith(highlightNotes: x), p),
              _section(S.secMistakes, p),
              _toggle(
                  'mistakeLimit',
                  S.setLimit,
                  S.setLimitSub(v.mistakeLimit),
                  v.mistakeLimitEnabled,
                  (x) => v.copyWith(mistakeLimitEnabled: x),
                  p),
              if (v.mistakeLimitEnabled)
                _choices<int>(
                  S.setLimitValue,
                  const [3, 5, 10],
                  v.mistakeLimit,
                  (n) => '$n',
                  (n) => v.copyWith(mistakeLimit: n),
                  p,
                  'limit',
                ),
              _toggle('vibrate', S.setVibrate, null, v.vibrate,
                  (x) => v.copyWith(vibrate: x), p),
              _section(S.secGame, p),
              _toggle('showTimer', S.setTimer, null, v.showTimer,
                  (x) => v.copyWith(showTimer: x), p),
              _toggle('numberFirst', S.setNumberFirst, S.setNumberFirstSub,
                  v.numberFirst, (x) => v.copyWith(numberFirst: x), p),
              _toggle('showRemaining', S.setRemaining, S.setRemainingSub,
                  v.showRemaining, (x) => v.copyWith(showRemaining: x), p),
              _toggle('autoComplete', S.setAutoComplete, S.setAutoCompleteSub,
                  v.autoComplete, (x) => v.copyWith(autoComplete: x), p),
              _toggle(
                  'preventWrongNotes',
                  S.setPrevent,
                  S.setPreventSub,
                  v.preventWrongNotes,
                  (x) => v.copyWith(preventWrongNotes: x),
                  p),
              _toggle(
                  'autoRemoveNotes',
                  S.setAutoRemove,
                  S.setAutoRemoveSub,
                  v.autoRemoveNotes,
                  (x) => v.copyWith(autoRemoveNotes: x),
                  p),
              _section(S.secAppearance, p),
              _choices<ThemeChoice>(
                S.setTheme,
                ThemeChoice.values,
                v.theme,
                (t) => switch (t) {
                  ThemeChoice.umi => 'Umi',
                  ThemeChoice.sakura => 'Sakura',
                  ThemeChoice.dark => S.themeDark,
                  ThemeChoice.system => S.themeSystem,
                },
                (t) => v.copyWith(theme: t),
                p,
                'theme',
              ),
              _choices<AppLanguage>(
                S.setLanguage,
                AppLanguage.values,
                v.language,
                (l) => l == AppLanguage.pt ? 'Português' : 'English',
                (l) => v.copyWith(language: l),
                p,
                'language',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _section(String title, UmiPalette p) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: p.userDigit,
            fontSize: 13,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _toggle(String id, String title, String? subtitle, bool value,
      AppSettings Function(bool) apply, UmiPalette p) {
    return SwitchListTile(
      key: Key('set-$id'),
      value: value,
      onChanged: (x) => settings.update(apply(x)),
      activeTrackColor: p.userDigit,
      title: Text(title, style: TextStyle(color: p.ink, fontSize: 17)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle,
              style: TextStyle(color: p.ink.withAlpha(170), fontSize: 13)),
    );
  }

  Widget _choices<T>(String title, List<T> options, T current,
      String Function(T) label, AppSettings Function(T) apply, UmiPalette p,
      String id) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: p.ink, fontSize: 17)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final o in options)
                ChoiceChip(
                  key: Key('set-$id-$o'),
                  label: Text(label(o)),
                  selected: o == current,
                  onSelected: (_) => settings.update(apply(o)),
                  selectedColor: p.surface,
                  backgroundColor: p.board,
                  labelStyle: TextStyle(color: p.ink),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
