# Umi Sudoku

Sudoku autoral, offline, em Flutter. Plano, premissas e fases em [docs/PLANO.md](docs/PLANO.md).

## Estado atual: Fase 1 (motor do jogo)

Implementado em `lib/engine` (Dart puro), com testes em `test/engine`:

- Gerador de puzzles com solução única em 6 níveis (Casual, Fácil, Médio, Difícil, Expert, Pesadelo).
- Solucionador lógico com 17 técnicas (XCycle fica para a fase 2).
- Dicas que preenchem um único quadrado e informam a técnica usada.
- Regras da partida: erros, limite, notas, notas avançadas, desfazer, completar automaticamente, salvar em JSON.
- Desafio diário determinístico pela data, com animal do dia e troféu do mês.

O app ainda mostra só uma tela provisória com um puzzle gerado.

## Como obter o APK

A cada envio ao GitHub, o fluxo **CI** (aba *Actions*) roda os testes e gera o APK. Abra a execução mais recente e baixe o artefato `umi-sudoku-apk`.

## Rodar no computador (opcional)

Com o Flutter instalado:

```
flutter create --platforms=android --org br.com.umisudoku --project-name umi_sudoku .
flutter pub get
flutter test
flutter run            # emulador ou aparelho conectado
flutter build apk
```
