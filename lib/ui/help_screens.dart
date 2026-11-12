/// Telas de ajuda: Como jogar e Backup.
library;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/game_store.dart';
import '../data/progress.dart';
import '../data/settings.dart';
import '../engine/game.dart';
import 'strings.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final p = settings.value.palette(MediaQuery.platformBrightnessOf(context));
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        title: Text(S.howToPlay),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          for (final (title, body) in S.howToPlaySections)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.board,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: p.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(body,
                      style: TextStyle(
                          color: p.ink.withAlpha(210),
                          fontSize: 15,
                          height: 1.4)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Monta o backup completo em JSON.
Future<String> buildBackup(
    GameStore store, SettingsController settings, ProgressController progress) async {
  return jsonEncode({
    'app': 'umi-sudoku',
    'schema': 1,
    'settings': settings.value.toJson(),
    'progress': jsonDecode(progress.exportJson()),
    'games': [for (final g in await store.loadAll()) jsonDecode(g)],
  });
}

/// Restaura um backup. Retorna falso se o texto não for um backup válido;
/// nesse caso nada é alterado.
Future<bool> restoreBackup(String text, GameStore store,
    SettingsController settings, ProgressController progress) async {
  try {
    final j = jsonDecode(text) as Map<String, dynamic>;
    if (j['app'] != 'umi-sudoku') return false;
    // Valida tudo antes de gravar qualquer coisa.
    final newSettings =
        AppSettings.fromJson(Map<String, dynamic>.from(j['settings'] as Map));
    final progressJson = jsonEncode(j['progress']);
    final check = ProgressController();
    if (!check.importJson(progressJson)) return false;
    final games = [
      for (final g in j['games'] as List)
        SudokuGame.fromJson(Map<String, dynamic>.from(g as Map)),
    ];

    for (final old in await store.loadAll()) {
      final id = (jsonDecode(old) as Map<String, dynamic>)['id'] as String?;
      if (id != null) await store.delete(id);
    }
    for (final g in games) {
      await store.save(g.id, jsonEncode(g.toJson()));
    }
    progress.importJson(progressJson);
    settings.update(newSettings);
    return true;
  } catch (_) {
    return false;
  }
}

class BackupScreen extends StatefulWidget {
  const BackupScreen({
    super.key,
    required this.settings,
    required this.progress,
    required this.store,
  });

  final SettingsController settings;
  final ProgressController progress;
  final GameStore store;

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  String? _export;
  final _input = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    buildBackup(widget.store, widget.settings, widget.progress).then((v) {
      if (mounted) setState(() => _export = v);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final ok = await restoreBackup(
        _input.text.trim(), widget.store, widget.settings, widget.progress);
    if (!mounted) return;
    setState(() => _message = ok ? S.backupOk : S.backupBad);
  }

  @override
  Widget build(BuildContext context) {
    final p =
        widget.settings.value.palette(MediaQuery.platformBrightnessOf(context));
    final export = _export ?? '';
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        title: Text(S.backup),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(S.backupExport,
              style: TextStyle(
                  color: p.ink, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(S.backupExportBody, style: TextStyle(color: p.ink)),
          const SizedBox(height: 10),
          Container(
            height: 110,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: p.board, borderRadius: BorderRadius.circular(14)),
            child: SingleChildScrollView(
              child: Text(export,
                  key: const Key('backup-text'),
                  style: TextStyle(
                      color: p.ink.withAlpha(190),
                      fontSize: 11,
                      fontFamily: 'monospace')),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const Key('backup-copy'),
              onPressed: export.isEmpty
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: export));
                      if (mounted) setState(() => _message = S.copied);
                    },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(S.copy),
            ),
          ),
          const SizedBox(height: 24),
          Text(S.backupImport,
              style: TextStyle(
                  color: p.ink, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(S.backupImportBody, style: TextStyle(color: p.ink)),
          const SizedBox(height: 10),
          TextField(
            key: const Key('backup-input'),
            controller: _input,
            maxLines: 4,
            style: TextStyle(color: p.ink, fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: p.board,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const Key('backup-restore'),
              onPressed: _restore,
              child: Text(S.backupImport),
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_message!,
                  key: const Key('backup-message'),
                  style: TextStyle(
                      color: p.userDigit, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}
