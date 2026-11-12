/// Armazenamento da partida em andamento.
///
/// As telas dependem só desta interface. Na Fase 3 ela ganha uma
/// implementação em SQLite; no futuro, uma remota para sincronização.
library;

import 'package:shared_preferences/shared_preferences.dart';

abstract class GameStore {
  Future<String?> load();
  Future<void> save(String json);
  Future<void> clear();
}

/// Guarda a partida no armazenamento local do aparelho.
class PrefsGameStore implements GameStore {
  static const _key = 'current_game_v1';

  @override
  Future<String?> load() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> save(String json) async {
    await (await SharedPreferences.getInstance()).setString(_key, json);
  }

  @override
  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_key);
  }
}

/// Só em memória: usado nos testes.
class MemoryGameStore implements GameStore {
  String? value;

  @override
  Future<String?> load() async => value;

  @override
  Future<void> save(String json) async => value = json;

  @override
  Future<void> clear() async => value = null;
}
