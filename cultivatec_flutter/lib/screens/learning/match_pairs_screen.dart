import 'package:cultivatec_flutter/core/widgets/wokov_props.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/blue_confetti.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
import 'package:cultivatec_flutter/screens/learning/glossary_screen.dart';

/// Ejercicio "Unir pares": relaciona cada término con su definición.
/// Usa el glosario de la app y da XP al terminar (cuenta para la meta diaria).
class MatchPairsScreen extends StatefulWidget {
  const MatchPairsScreen({super.key});

  @override
  State<MatchPairsScreen> createState() => _MatchPairsScreenState();
}

class _MatchPairsScreenState extends State<MatchPairsScreen> {
  static const int _pairs = 5;
  final _rng = Random();

  late List<Map<String, String>> _round;
  late List<int> _termOrder;
  late List<int> _defOrder;

  int? _selTerm;
  int? _selDef;
  int? _wrongTerm;
  int? _wrongDef;
  bool _locked = false;
  final Set<int> _matched = {};
  int _mistakes = 0;
  bool _finished = false;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final all = List<Map<String, String>>.from(glossaryTerms)..shuffle(_rng);
    _round = all.take(_pairs).toList();
    _termOrder = List.generate(_pairs, (i) => i)..shuffle(_rng);
    _defOrder = List.generate(_pairs, (i) => i)..shuffle(_rng);
    _selTerm = _selDef = _wrongTerm = _wrongDef = null;
    _locked = false;
    _matched.clear();
    _mistakes = 0;
    _finished = false;
    _xp = 0;
  }

  void _tapTerm(int i) {
    if (_locked || _matched.contains(i)) return;
    SoundService.hapticSelect();
    setState(() => _selTerm = i);
    _evaluate();
  }

  void _tapDef(int i) {
    if (_locked || _matched.contains(i)) return;
    SoundService.hapticSelect();
    setState(() => _selDef = i);
    _evaluate();
  }

  void _evaluate() {
    final t = _selTerm, d = _selDef;
    if (t == null || d == null) return;

    if (t == d) {
      SoundService.playCorrect();
      setState(() {
        _matched.add(t);
        _selTerm = _selDef = null;
      });
      if (_matched.length == _pairs) _finish();
    } else {
      SoundService.playWrong();
      setState(() {
        _mistakes++;
        _wrongTerm = t;
        _wrongDef = d;
        _locked = true;
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        setState(() {
          _selTerm = _selDef = _wrongTerm = _wrongDef = null;
          _locked = false;
        });
      });
    }
  }

  void _finish() {
    final xp = (25 - 5 * _mistakes).clamp(5, 25);
    setState(() {
      _xp = xp;
      _finished = true;
    });
    context.read<AuthProvider>().syncStats({'addPoints': xp});
    SoundService.playVictory();
    BlueConfetti.show(context,
        style: _mistakes == 0 ? ConfettiStyle.cannons : ConfettiStyle.rain, count: _mistakes == 0 ? 130 : 80);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(child: _finished ? _buildResults() : _buildGame()),
    );
  }

  Widget _buildGame() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderColor, width: 2),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 16,
                    color: AppTheme.borderColor,
                    alignment: Alignment.centerLeft,
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      widthFactor: (_matched.length / _pairs).clamp(0.04, 1.0),
                      child: Container(color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_matched.length}/$_pairs',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Une los pares',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          ),
          const SizedBox(height: 2),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Toca un término y luego su definición.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      for (final i in _termOrder)
                        Expanded(
                          child: _tile(
                            text: _round[i]['term']!,
                            isTerm: true,
                            selected: _selTerm == i,
                            matched: _matched.contains(i),
                            wrong: _wrongTerm == i,
                            onTap: () => _tapTerm(i),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      for (final i in _defOrder)
                        Expanded(
                          child: _tile(
                            text: _round[i]['def']!,
                            isTerm: false,
                            selected: _selDef == i,
                            matched: _matched.contains(i),
                            wrong: _wrongDef == i,
                            onTap: () => _tapDef(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required String text,
    required bool isTerm,
    required bool selected,
    required bool matched,
    required bool wrong,
    required VoidCallback onTap,
  }) {
    Color bg = Colors.white;
    Color border = AppTheme.borderColor;
    Color fg = AppTheme.textPrimary;
    if (matched) {
      bg = const Color(0xFFF3F7FD);
      border = AppTheme.borderLight;
      fg = AppTheme.textMuted;
    } else if (wrong) {
      bg = const Color(0xFFFFE9E9);
      border = AppTheme.accentRed;
      fg = AppTheme.accentRedDark;
    } else if (selected) {
      bg = AppTheme.iceBlue;
      border = AppTheme.primaryBlue;
      fg = AppTheme.primaryBlue;
    }

    Widget tile = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: isTerm ? 8 : 12, vertical: 6),
        alignment: isTerm ? Alignment.center : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
          boxShadow: matched ? const [] : [BoxShadow(color: border, offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Text(
          text,
          maxLines: isTerm ? 2 : 5,
          overflow: TextOverflow.ellipsis,
          textAlign: isTerm ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isTerm ? 15 : 11.5,
            fontWeight: isTerm ? FontWeight.w900 : FontWeight.w700,
            color: fg,
            height: 1.2,
          ),
        ),
      ),
    );
    if (wrong) {
      tile = tile.animate(key: ValueKey('wrong_${text.hashCode}_$_mistakes')).shake(hz: 6, duration: 380.ms, offset: const Offset(4, 0));
    }
    return tile;
  }

  Widget _buildResults() {
    final perfect = _mistakes == 0;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WokovSparkles(
            size: 200,
            child: WokovMascot(
              size: 200,
              tappable: false,
              sequence: perfect ? WokovSequences.celebrate : null,
              pose: perfect ? WokovPose.victory : WokovPose.relieved,
            ),
          ),
          const SizedBox(height: 12),
          Text(perfect ? '¡Perfecto!' : '¡Muy bien!',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(perfect ? 'Uniste todos los pares sin equivocarte.' : 'Te equivocaste $_mistakes ${_mistakes == 1 ? 'vez' : 'veces'}. ¡La práctica hace al inventor!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: AppTheme.cardDecoration(radius: 18, border: AppTheme.primaryBlue),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('+$_xp XP',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
              ],
            ),
          ).animate().scale(delay: 300.ms, duration: 450.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 30),
          CartoonButton(text: 'Jugar otra vez', icon: Icons.refresh_rounded, onPressed: () => setState(_newRound)),
          const SizedBox(height: 4),
          CartoonButton.secondary(text: 'Volver', onPressed: () => Navigator.pop(context)),
        ],
      ),
      ),
    );
  }
}
