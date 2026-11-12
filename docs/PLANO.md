# Umi Sudoku: plano e premissas

Aplicativo de Sudoku autoral em Flutter. A versão 1 é offline. O nome "Umi Sudoku" é provisório.

## Arquitetura

```
lib/
  engine/     Motor do jogo em Dart puro, sem Flutter (testável isolado)
  theme/      Tokens de design (cores, medidas)
  data/       (Fase 3-4) Repositórios e banco local
  ui/         (Fase 2+) Telas e componentes
  l10n/       (Fase 3) Textos em pt-BR e en
```

- **Motor** (`lib/engine`): gerador, solucionador lógico, dicas, estado da partida e desafio diário. Não conhece interface nem banco.
- **Dados**: as telas falam com interfaces de repositório (`GameRepository`, `StatsRepository`, `AchievementRepository`, `SettingsRepository`). Na v1 existe só a implementação local (SQLite). No futuro entra um `RemoteRepository` e um `SyncService` por trás das mesmas interfaces, sem mexer nas telas.
- **Pontos de sincronização futura**: IDs em UUID, `createdAt`/`updatedAt` e `version` em cada registro; eventos de partida gravados à parte das estatísticas agregadas; desafio diário determinístico pela data.

## Modelo de dados (SQLite, a partir da Fase 3)

| Tabela | Campos principais |
|---|---|
| `games` | id (UUID), difficulty, seed, givens, solution, state_json, status, mistakes, hints, elapsed_seconds, is_daily, daily_date, created_at, updated_at, version |
| `game_events` | id, game_id, type (start, move, hint, win, loss), payload_json, created_at |
| `stats` | difficulty, started, won, won_no_mistakes, best_time, total_time, current_streak, best_streak, updated_at |
| `achievements` | id, progress, unlocked_at, updated_at |
| `daily_results` | date, game_id, completed_at |
| `settings` | key, value, updated_at |

Backup: exporta e importa tudo em um único JSON.

## Telas

Início, Novo jogo, Jogo, Configurações, Estratégias, Como jogar, Histórico, Estatísticas, Conquistas, Prêmios, Diário.

## Tokens de design

Em `lib/theme/tokens.dart`: paletas Umi (padrão), Sakura e escuro; raios, espaçamentos, alvo mínimo de toque (48 dp) e opacidade das estampas (10%).

## Ilustrações a criar (vetoriais, originais)

- Estampas padrão: seigaiha, kasumi, ondas estilizadas.
- Motivos dos troféus: asanoha, bambu, kumo, carpa, garça.
- 12 animais: grou, coruja, borboleta, tartaruga, raposa, cervo, libélula, gato, andorinha, sapo, macaco, carpa-koi.
- 12 troféus mensais (motivo + animal), versão cinza e colorida.
- Logotipo, ícone do app, ilustração de vitória (grou).

## Fases

1. **Motor do jogo** (esta entrega): gerador, solucionador, dicas, partida, diário, testes.
2. Tela de jogo e Novo jogo, tema Umi.
3. Configurações e idiomas (pt-BR e en). O banco SQLite passa para a Fase 4, quando há dados em tabela (histórico e estatísticas); configurações e partida em andamento ficam no armazenamento simples do aparelho.
4. Diário com animais, conquistas, prêmios, estatísticas, histórico e estampas.
5. Estratégias, Como jogar, temas Sakura e escuro, polimento, backup.

## Premissas assumidas

1. **Compilação**: o ambiente de desenvolvimento não acessa os servidores do Flutter, então testes e APK rodam no GitHub Actions (`.github/workflows/ci.yml`). As pastas `android/` são geradas no CI por `flutter create`.
2. **Técnicas**: o menu tem 18 entradas. "Last Remaining Cell" é o dígito que só cabe em uma célula do bloco; "Hidden Single" é o mesmo raciocínio em linha ou coluna. 17 estão implementadas; **XCycle fica para a fase 2** (aparece no menu como "Em breve").
3. **Dificuldade** = técnica mais avançada exigida:
   - Casual e Fácil: Last Blank Cell e Last Remaining Cell (Casual com 46+ pistas, Fácil com 38+).
   - Médio: Single Candidate e Hidden Single.
   - Difícil: Naked Pair, Hidden Pair, Intersection Removal.
   - Expert: trincas, quadras, X-Wing, XY-Wing.
   - Pesadelo: XYZ-Wing, Swordfish, Jellyfish, Simple Coloring. Desbloqueado desde o início.
   Se o gerador não achar um puzzle do nível exato dentro do limite de tentativas, entrega o mais difícil que encontrou.
4. **Solução única**: o gerador só remove uma pista se o puzzle continuar resolvível pelas técnicas do nível. Como elas nunca chutam, a solução é única; os testes conferem isso por força bruta.
5. **Dicas**: sempre preenchem um único quadrado. Usam os candidatos reais do tabuleiro, não as anotações do jogador, e ignoram valores errados. Quando é preciso eliminar candidatos antes, a dica mostra só as eliminações de que o preenchimento depende. Se nenhuma técnica se aplica, revela o valor ("Solução direta") e registra na partida.
6. **Quantidade de dicas**: 1 gratuita por partida; dicas extras ilimitadas e sem anúncio, mas contadas nas estatísticas e impedem conquistas "sem dicas". (A confirmar na Fase 2.)
7. **Erros**: valor errado conta um erro e fica marcado em coral até ser apagado. Acertos e pistas ficam travados. Desfazer não devolve erros já contados. Com limite ativo (padrão 3), a partida termina ao atingi-lo.
8. **Casual**: mais pistas e sem limite de erros, independentemente da configuração.
9. **Completar automaticamente**: quando todas as células vazias têm um único valor possível, o app preenche o restante de uma vez.
10. **Prevenção de notas erradas**: recusa anotar um dígito que já aparece na linha, coluna ou bloco.
11. **Desafio diário**: semente = data (AAAAMMDD). Dificuldade por dia da semana: seg Médio, ter Difícil, qua Médio, qui Difícil, sex Expert, sáb Médio, dom Difícil.
12. **Animais**: o troféu do mês usa o animal do mês; o desafio de cada dia mostra um animal em sequência fixa de 12 dias.
13. **Gerador aleatório próprio** (xorshift32) em vez do `Random` do Dart, para a mesma semente gerar o mesmo puzzle em qualquer versão do app.
14. **Especial, Aventuras, Eventos, compartilhar, login**: só placeholders na v1.

## Decisões tomadas durante a implementação

- **Sem SQLite na v1.** Com a versão web, o banco SQLite deixaria de funcionar no navegador. Partidas, configurações e histórico ficam em JSON no armazenamento local, atrás das interfaces `GameStore`, `SettingsStore` e `ProgressStore`, que continuam sendo o ponto de entrada da sincronização futura.
- **Estatísticas e conquistas são calculadas a partir do histórico**, em vez de gravadas à parte. Assim nunca ficam inconsistentes e a sincronização futura só precisa transportar o histórico.
- **Animais como selos (hanko)** com o ideograma de cada animal e o nome por extenso ao lado. Ilustrações desenhadas ficam para a Fase 5.
- **Troféu do mês** exige todos os desafios diários daquele mês. Dias passados continuam jogáveis; dias futuros ficam bloqueados.
- **Nova tentativa após derrota** conta como uma nova partida nas estatísticas.
