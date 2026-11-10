import 'package:flutter/material.dart';

import 'engine/generator.dart';
import 'theme/tokens.dart';

void main() => runApp(const UmiSudokuApp());

/// Fase 1: tela provisória que apenas mostra um puzzle gerado pelo motor,
/// para confirmar que ele roda no aparelho. A interface real entra na Fase 2.
class UmiSudokuApp extends StatelessWidget {
  const UmiSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Umi Sudoku',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(UmiPalette.umi),
      home: const _PreviewScreen(),
    );
  }
}

class _PreviewScreen extends StatefulWidget {
  const _PreviewScreen();

  @override
  State<_PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<_PreviewScreen> {
  int _seed = 1;
  late Puzzle _puzzle = generatePuzzle(Difficulty.easy, _seed);

  void _next() {
    setState(() {
      _seed++;
      _puzzle = generatePuzzle(Difficulty.easy, _seed);
    });
  }

  @override
  Widget build(BuildContext context) {
    const p = UmiPalette.umi;
    return Scaffold(
      appBar: AppBar(title: const Text('Umi Sudoku · prévia do motor')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(UmiMetrics.gap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: GridView.count(
                  crossAxisCount: 9,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var c = 0; c < 81; c++)
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ((c ~/ 27) + (c % 9) ~/ 3).isEven
                              ? p.background
                              : p.surface,
                          border: Border.all(
                              color: p.ink.withAlpha(60), width: 0.5),
                        ),
                        child: Text(
                          _puzzle.givens[c] == 0 ? '' : '${_puzzle.givens[c]}',
                          style: TextStyle(fontSize: 20, color: p.ink),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: UmiMetrics.gap),
              FilledButton(
                onPressed: _next,
                child: const Text('Gerar outro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
