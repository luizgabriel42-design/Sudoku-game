# Umi Sudoku

Sudoku autoral, offline, em Flutter. Plano, premissas e fases em [docs/PLANO.md](docs/PLANO.md).

## Estado atual: Fases 1 a 4 concluídas

**Fase 1, motor do jogo** (`lib/engine`, Dart puro):

- Gerador de puzzles com solução única em 6 níveis (Casual, Fácil, Médio, Difícil, Expert, Pesadelo).
- Solucionador lógico com 17 técnicas (XCycle fica para a fase 2 das técnicas).
- Dicas que preenchem um único quadrado e explicam a técnica usada.
- Regras da partida: erros, limite, notas, notas avançadas, desfazer, completar automaticamente, salvar em JSON.
- Desafio diário determinístico pela data, com animal do dia e troféu do mês.

**Fase 2, telas** (`lib/ui`), com o tema Umi:

- Início: continuar partida, novo jogo e desafio diário, com estampas seigaiha, kasumi e ondas.
- Novo jogo: os seis níveis, todos desbloqueados.
- Jogo: tabuleiro com destaques, erros, cronômetro e pausa, notas, notas avançadas, desfazer, apagar, dica com explicação, entrada número-primeiro (toque longo no número), contagem de números restantes e telas de vitória e derrota.
- A partida é salva a cada jogada.

**Fase 3, configurações e idiomas**:

- Tela de configurações: destaques, limite de erros, cronômetro, entrada número-primeiro, números restantes, completar automaticamente, notas, vibração, tema (Umi, Sakura, escuro, sistema) e idioma (português e inglês).
- Tocar em um número do teclado destaca os iguais no tabuleiro; o teclado fica logo abaixo do tabuleiro.
- Versão web publicada no ramo `gh-pages`.

**Fase 4, progresso**:

- Abas Início, Diário e Estatísticas.
- Diário: calendário mensal dos desafios diários, com o animal de cada dia (selo), dias concluídos, dias futuros bloqueados, meses anteriores jogáveis e troféu do mês.
- Estatísticas por dificuldade (jogos, tempo, sequências) e histórico de partidas.
- 22 conquistas com raridade e progresso; as desbloqueadas aparecem na tela de vitória.
- Prêmios: troféus mensais com o motivo e o animal de cada mês.
- Várias partidas em andamento, com lista para continuar ou apagar; o tempo pausa quando o app é suspenso.

Próxima fase (5): menu de estratégias, como jogar, backup, animações, efeitos sonoros, técnica XCycle e ilustrações dos animais.

## Como instalar no celular

A cada envio ao GitHub, o fluxo **CI** roda os testes e publica o APK mais recente em um link fixo:

https://github.com/luizgabriel42-design/Sudoku-game/releases/download/latest/umi-sudoku.apk

Abra o link no celular Android, baixe e autorize a instalação de apps desta fonte. Para aparelhos antigos de 32 bits, use `umi-sudoku-32bit.apk` na mesma página de Releases.

As versões de teste são assinadas com a chave em `ci/debug.keystore`, que é pública. Para publicar em loja será preciso uma chave privada própria.

As capturas de tela geradas pelos testes ficam no ramo `screens`.

## Rodar no computador (opcional)

Com o Flutter instalado:

```
flutter create --platforms=android --org br.com.umisudoku --project-name umi_sudoku .
flutter pub get
flutter test
flutter run            # emulador ou aparelho conectado
flutter build apk
```
