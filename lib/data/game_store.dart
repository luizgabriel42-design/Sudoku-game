/// Armazenamento das partidas em andamento.
///
/// Várias partidas podem ficar salvas ao mesmo tempo; cada uma tem seu id.
/// As telas dependem só desta interface. No futuro ela ganha uma
/// implementação remota para sincronização.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class GameStore {
  /// JSON de todas as partidas salvas.
  Future<List<String>> loadAll();
  Future<void> save(String id, String json);
  Future<void> delete(String id);
}

/// Guarda as partidas no armazenamento local do aparelho.
class PrefsGameStore implements GameStore {
  static const _key = 'games_v2';
  static const _legacyKey = 'current_game_v1';

  Future<Map<String, String>> _read(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    final map = <String, String>{};
    if (raw != null) {
      try {
        (jsonDecode(raw) as Map<String, dynamic>)
            .forEach((k, v) => map[k] = v as String);
      } catch (_) {
        // Dado ilegível: começa do zero.
      }
    }
    // Migra a partida única das versões anteriores.
    final legacy = prefs.getString(_legacyKey);
    if (legacy != null) {
      try {
        final j = jsonDecode(legacy) as Map<String, dynamic>;
        j['id'] = 'legacy';
        map['legacy'] = jsonEncode(j);
      } catch (_) {
        // Partida antiga ilegível: descarta.
      }
      await prefs.remove(_legacyKey);
      await prefs.setString(_key, jsonEncode(map));
    }
    return map;
  }

  @override
  Future<List<String>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return (await _read(prefs)).values.toList();
  }

  @override
  Future<void> save(String id, String json) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _read(prefs);
    map[id] = json;
    await prefs.setString(_key, jsonEncode(map));
  }

  @override
  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _read(prefs);
    map.remove(id);
    await prefs.setString(_key, jsonEncode(map));
  }
}

/// Só em memória: usado nos testes.
class MemoryGameStore implements GameStore {
  final Map<String, String> games = {};

  @override
  Future<List<String>> loadAll() async => games.values.toList();

  @override
  Future<void> save(String id, String json) async => games[id] = json;

  @override
  Future<void> delete(String id) async => games.remove(id);
}
