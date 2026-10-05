import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';

enum BlockType { forward, back, turnLeft, turnRight, loop, led }

class CodeBlock {
  final BlockType type;
  final String label;
  final Color color;
  final IconData icon;
  const CodeBlock(this.type, this.label, this.color, this.icon);
}

const _availableBlocks = [
  CodeBlock(BlockType.forward, 'Avanzar', AppTheme.primaryBlue, Icons.arrow_upward_rounded),
  CodeBlock(BlockType.back, 'Retroceder', AppTheme.accentOrange, Icons.arrow_downward_rounded),
  CodeBlock(BlockType.turnLeft, 'Girar Izq.', AppTheme.accentPurple, Icons.turn_left_rounded),
  CodeBlock(BlockType.turnRight, 'Girar Der.', AppTheme.accentCyan, Icons.turn_right_rounded),
  CodeBlock(BlockType.loop, 'Repetir x3', AppTheme.accentGold, Icons.loop_rounded),
  CodeBlock(BlockType.led, 'Encender LED', AppTheme.accentGreen, Icons.lightbulb_rounded),
];

String _codeFor(BlockType t) {
  switch (t) {
    case BlockType.forward:
      return 'robot.avanzar()';
    case BlockType.back:
      return 'robot.retroceder()';
    case BlockType.turnLeft:
      return 'robot.girar_izquierda()';
    case BlockType.turnRight:
      return 'robot.girar_derecha()';
    case BlockType.led:
      return 'robot.encender_led()';
    case BlockType.loop:
      return 'for i in range(3):';
  }
}

String _explainFor(BlockType t) {
  switch (t) {
    case BlockType.forward:
      return 'El robot avanza una casilla en la dirección a la que mira.';
    case BlockType.back:
      return 'El robot retrocede una casilla.';
    case BlockType.turnLeft:
      return 'El robot gira 90° hacia la izquierda (no se mueve de casilla).';
    case BlockType.turnRight:
      return 'El robot gira 90° hacia la derecha.';
    case BlockType.led:
      return 'Se enciende la luz LED del robot.';
    case BlockType.loop:
      return 'Repite la acción anterior 3 veces sin escribirla 3 veces.';
  }
}

/// One compiled instruction (a block, with how many times it repeats).
class _Instr {
  final BlockType type;
  final int repeat;
  const _Instr(this.type, this.repeat);
}

class CodingChallenge {
  final String id, title, instruction, hint;
  final int startX, startY, startDir, goalX, goalY;
  final bool needLed;
  final int difficulty;
  const CodingChallenge({
    required this.id,
    required this.title,
    required this.instruction,
    required this.hint,
    required this.startX,
    required this.startY,
    required this.startDir,
    required this.goalX,
    required this.goalY,
    this.needLed = false,
    this.difficulty = 1,
  });
}

const List<CodingChallenge> codingChallenges = [
  CodingChallenge(
    id: 'c1',
    title: 'Primeros pasos',
    instruction: 'Lleva al robot 🤖 hasta la bandera 🏁. El robot mira hacia la derecha.',
    hint: 'Arrastra 3 bloques "Avanzar" y pulsa Ejecutar.',
    startX: 0,
    startY: 2,
    startDir: 1,
    goalX: 3,
    goalY: 2,
    difficulty: 1,
  ),
  CodingChallenge(
    id: 'c2',
    title: 'Aprende a girar',
    instruction: 'La bandera está más arriba. Avanza, gira y sigue avanzando.',
    hint: 'Avanzar x2, Girar Izq., Avanzar x1.',
    startX: 0,
    startY: 4,
    startDir: 1,
    goalX: 2,
    goalY: 3,
    difficulty: 2,
  ),
  CodingChallenge(
    id: 'c3',
    title: 'Repite con bucles',
    instruction: 'La meta está lejos. Usa "Repetir x3" para repetir el bloque anterior y usar menos bloques.',
    hint: '"Avanzar" + "Repetir x3" avanza 3 veces.',
    startX: 0,
    startY: 0,
    startDir: 2,
    goalX: 0,
    goalY: 3,
    difficulty: 2,
  ),
  CodingChallenge(
    id: 'c4',
    title: 'Llega y enciende',
    instruction: 'Lleva al robot a la bandera y ENCIENDE su LED con el bloque verde.',
    hint: 'Avanza hasta la meta y al final "Encender LED".',
    startX: 0,
    startY: 2,
    startDir: 1,
    goalX: 3,
    goalY: 2,
    needLed: true,
    difficulty: 3,
  ),
];

CodingChallenge _challengeById(String id) =>
    codingChallenges.firstWhere((c) => c.id == id, orElse: () => codingChallenges.first);

class BlockCodingScreen extends StatefulWidget {
  final String challengeId;
  const BlockCodingScreen({super.key, required this.challengeId});

  @override
  State<BlockCodingScreen> createState() => _BlockCodingScreenState();
}

class _BlockCodingScreenState extends State<BlockCodingScreen> {
  final List<CodeBlock> _sequence = [];
  bool _isRunning = false;
  int _view = 0; // 0 = blocks, 1 = code
  late CodingChallenge _challenge;

  int _robotX = 0, _robotY = 0, _robotDir = 1;
  bool _ledOn = false;

  // Execution highlight + caption.
  int _activeInstr = -1;
  String _caption = '';
  String _captionCode = '';

  static const int _gridSize = 5;
  static const double _cell = 44;

  @override
  void initState() {
    super.initState();
    _challenge = _challengeById(widget.challengeId);
    _resetRobot();
  }

  void _resetRobot() {
    setState(() {
      _robotX = _challenge.startX;
      _robotY = _challenge.startY;
      _robotDir = _challenge.startDir;
      _ledOn = false;
      _isRunning = false;
      _activeInstr = -1;
      _caption = '';
      _captionCode = '';
    });
  }

  List<_Instr> _compile() {
    final out = <_Instr>[];
    for (final b in _sequence) {
      if (b.type == BlockType.loop) {
        if (out.isNotEmpty) {
          final last = out.removeLast();
          out.add(_Instr(last.type, last.repeat * 3));
        }
      } else {
        out.add(_Instr(b.type, 1));
      }
    }
    return out;
  }

  void _applyMove(BlockType t) {
    if (t == BlockType.forward) {
      if (_robotDir == 0 && _robotY > 0) _robotY--;
      if (_robotDir == 1 && _robotX < _gridSize - 1) _robotX++;
      if (_robotDir == 2 && _robotY < _gridSize - 1) _robotY++;
      if (_robotDir == 3 && _robotX > 0) _robotX--;
    } else if (t == BlockType.back) {
      if (_robotDir == 0 && _robotY < _gridSize - 1) _robotY++;
      if (_robotDir == 1 && _robotX > 0) _robotX--;
      if (_robotDir == 2 && _robotY > 0) _robotY--;
      if (_robotDir == 3 && _robotX < _gridSize - 1) _robotX++;
    } else if (t == BlockType.turnLeft) {
      _robotDir = (_robotDir - 1) % 4;
      if (_robotDir < 0) _robotDir += 4;
    } else if (t == BlockType.turnRight) {
      _robotDir = (_robotDir + 1) % 4;
    } else if (t == BlockType.led) {
      _ledOn = true;
    }
  }

  Future<void> _run() async {
    if (_isRunning || _sequence.isEmpty) return;
    final program = _compile();
    setState(() {
      _isRunning = true;
      _robotX = _challenge.startX;
      _robotY = _challenge.startY;
      _robotDir = _challenge.startDir;
      _ledOn = false;
    });

    for (int i = 0; i < program.length; i++) {
      final instr = program[i];
      for (int r = 0; r < instr.repeat; r++) {
        if (!mounted) return;
        setState(() {
          _activeInstr = i;
          _captionCode = _codeFor(instr.type);
          _caption = instr.repeat > 1
              ? '${_explainFor(instr.type)}  (vuelta ${r + 1} de ${instr.repeat})'
              : _explainFor(instr.type);
        });
        await Future.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        setState(() => _applyMove(instr.type));
      }
    }

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _activeInstr = -1;
      _isRunning = false;
    });
    _checkWin();
  }

  void _checkWin() {
    final reached = _robotX == _challenge.goalX && _robotY == _challenge.goalY;
    final ledOk = !_challenge.needLed || _ledOn;
    if (reached && ledOk) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [
            Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 30),
            SizedBox(width: 10),
            Expanded(child: Text('¡Reto superado!', style: TextStyle(fontWeight: FontWeight.w900))),
          ]),
          content: const Text('¡Tu código llevó al robot a la meta! 🎉'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(reached && !ledOk
            ? '¡Llegaste! Pero falta encender el LED 💡'
            : 'No llegaste a la bandera. ¡Ajusta tu código!'),
      ));
      _resetRobot();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _challenge;
    final program = _compile();
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // dark "IDE" backdrop
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(c.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Borrar',
            onPressed: () {
              setState(() => _sequence.clear());
              _resetRobot();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Instruction banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: const Color(0xFF1E293B),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.flag_rounded, color: AppTheme.accentCyan, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(c.instruction,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12.5, height: 1.3, fontWeight: FontWeight.w600))),
                ]),
                const SizedBox(height: 4),
                Text('💡 ${c.hint}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11.5, fontStyle: FontStyle.italic)),
              ],
            ),
          ),

          // Simulator grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            width: double.infinity,
            color: const Color(0xFF0F172A),
            child: Center(child: _buildGrid()),
          ),

          // Live explanation caption
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color:
                  _caption.isEmpty ? Colors.white.withValues(alpha: 0.06) : AppTheme.accentCyan.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _caption.isEmpty ? Colors.white12 : AppTheme.accentCyan.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(_caption.isEmpty ? Icons.code_rounded : Icons.play_circle_fill_rounded,
                    color: _caption.isEmpty ? Colors.white38 : AppTheme.accentCyan, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: _caption.isEmpty
                      ? const Text('Arma tu programa y pulsa Ejecutar para ver el código en acción.',
                          style: TextStyle(color: Colors.white54, fontSize: 12))
                      : RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: '$_captionCode  ',
                                style: const TextStyle(
                                    color: Color(0xFF7DD3FC),
                                    fontFamily: 'monospace',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: '→ $_caption', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ]),
                        ),
                ),
              ],
            ),
          ),

          // Toggle Bloques / Código
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration:
                  BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                _toggle(0, Icons.extension_rounded, 'Bloques'),
                _toggle(1, Icons.terminal_rounded, 'Código real'),
              ]),
            ),
          ),
          const SizedBox(height: 8),

          // Body: blocks workspace OR code view
          Expanded(child: _view == 0 ? _blocksView() : _codeView(program)),

          // Run button
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _sequence.isEmpty || _isRunning ? null : _run,
                icon: Icon(_isRunning ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded, size: 26),
                label: Text(_isRunning ? 'EJECUTANDO…' : 'EJECUTAR CÓDIGO',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(int v, IconData icon, String label) {
    final active = _view == v;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _view = v),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: active ? Colors.white : Colors.white54),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.white : Colors.white54, fontWeight: FontWeight.w800, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  // ---- Grid ----------------------------------------------------------------
  Widget _buildGrid() {
    const dim = _cell * _gridSize;
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [const BoxShadow(color: AppTheme.borderColor, blurRadius: 0, offset: Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Checkerboard
            for (int r = 0; r < _gridSize; r++)
              for (int col = 0; col < _gridSize; col++)
                Positioned(
                  left: col * _cell,
                  top: r * _cell,
                  child: Container(
                    width: _cell,
                    height: _cell,
                    color: (r + col) % 2 == 0 ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                  ),
                ),
            // Goal
            Positioned(
              left: _challenge.goalX * _cell,
              top: _challenge.goalY * _cell,
              child: Container(
                width: _cell,
                height: _cell,
                alignment: Alignment.center,
                child: Container(
                  width: _cell - 10,
                  height: _cell - 10,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accentGreen, width: 2),
                  ),
                  child: const Icon(Icons.flag_rounded, color: AppTheme.accentGreen, size: 22),
                )
                    .animate(onPlay: (a) => a.repeat(reverse: true))
                    .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.06, 1.06)),
              ),
            ),
            // Robot
            AnimatedPositioned(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
              left: _robotX * _cell,
              top: _robotY * _cell,
              child: SizedBox(
                width: _cell,
                height: _cell,
                child: Center(
                  child: AnimatedRotation(
                    turns: _robotDir * 0.25,
                    duration: const Duration(milliseconds: 300),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/wokov/main.webp',
                            width: _cell - 6,
                            height: _cell - 6,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.smart_toy_rounded, color: AppTheme.primaryBlue, size: 28)),
                        if (_ledOn)
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle, boxShadow: [
                                BoxShadow(color: Colors.amber.withValues(alpha: 0.9), blurRadius: 8, spreadRadius: 1),
                              ]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Blocks view ---------------------------------------------------------
  Widget _blocksView() {
    return Column(
      children: [
        SizedBox(
          height: 74,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: _availableBlocks.length,
            itemBuilder: (context, idx) {
              final b = _availableBlocks[idx];
              return Draggable<CodeBlock>(
                data: b,
                feedback: Material(color: Colors.transparent, child: _blockUI(b)),
                childWhenDragging: Opacity(opacity: 0.4, child: _blockUI(b)),
                child: _blockUI(b),
              );
            },
          ),
        ),
        Expanded(
          child: DragTarget<CodeBlock>(
            onAcceptWithDetails: (d) => setState(() => _sequence.add(d.data)),
            builder: (context, candidate, rejected) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: candidate.isNotEmpty
                      ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(12),
                child: _sequence.isEmpty
                    ? const Center(
                        child: Text('⬇️ Arrastra bloques aquí',
                            style: TextStyle(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.bold)))
                    : ReorderableListView(
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            if (newIdx > oldIdx) newIdx -= 1;
                            final item = _sequence.removeAt(oldIdx);
                            _sequence.insert(newIdx, item);
                          });
                        },
                        children: [
                          for (int i = 0; i < _sequence.length; i++)
                            Container(
                              key: ValueKey('blk_$i'),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                SizedBox(
                                    width: 22,
                                    child: Text('${i + 1}',
                                        style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w900))),
                                Expanded(child: _blockUI(_sequence[i], expanded: true)),
                                IconButton(
                                    icon: const Icon(Icons.close_rounded, color: Colors.white38),
                                    onPressed: () => setState(() => _sequence.removeAt(i))),
                              ]),
                            ),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- Code view -----------------------------------------------------------
  Widget _codeView(List<_Instr> program) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: program.isEmpty
          ? const Center(
              child: Text('# Tu código aparecerá aquí\n# Arrastra bloques en la pestaña "Bloques"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontFamily: 'monospace', fontSize: 13)))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('# Programa del robot',
                      style: TextStyle(color: Color(0xFF64748B), fontFamily: 'monospace', fontSize: 12)),
                  const SizedBox(height: 4),
                  for (int i = 0; i < program.length; i++) ..._codeLines(program[i], i),
                ],
              ),
            ),
    );
  }

  List<Widget> _codeLines(_Instr instr, int index) {
    final active = _activeInstr == index;
    final lines = <Widget>[];
    if (instr.repeat > 1) {
      lines.add(_codeLine('for i in range(${instr.repeat}):', active, indent: 0));
      lines.add(_codeLine(_codeFor(instr.type), active, indent: 1));
    } else {
      lines.add(_codeLine(_codeFor(instr.type), active, indent: 0));
    }
    return lines;
  }

  Widget _codeLine(String text, bool active, {int indent = 0}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8.0 + indent * 22, 4, 8, 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.accentCyan.withValues(alpha: 0.22) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: active ? Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.6)) : null,
      ),
      child: Text(text,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF93C5FD),
            fontFamily: 'monospace',
            fontSize: 13.5,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          )),
    );
  }

  Widget _blockUI(CodeBlock b, {bool expanded = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: expanded ? 16 : 13, vertical: expanded ? 13 : 9),
      decoration: BoxDecoration(
        color: b.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Color.lerp(b.color, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))],
      ),
      child: Row(mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min, children: [
        Icon(b.icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(b.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    );
  }
}
