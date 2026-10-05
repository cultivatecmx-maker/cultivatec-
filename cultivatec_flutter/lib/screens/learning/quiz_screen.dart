import 'package:cultivatec_flutter/core/widgets/wokov_props.dart';
import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';
import 'package:cultivatec_flutter/core/widgets/count_up_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
import 'package:cultivatec_flutter/core/widgets/themed_background.dart';
import 'package:cultivatec_flutter/data/static/stem_content.dart';
import 'package:cultivatec_flutter/core/widgets/robot_avatar.dart';
import 'package:cultivatec_flutter/data/models/robot_config.dart';
import 'package:cultivatec_flutter/data/services/tournament_service.dart';
import 'package:cultivatec_flutter/screens/tournaments/league_leaderboard_screen.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/core/widgets/blue_confetti.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';

class QuizScreen extends StatefulWidget {
  final String moduleId;
  final String worldKey; // e.g. 'w1'
  final List<QuizQuestionData> questions;
  final String title;

  /// When set, this quiz is a tournament round: the result is submitted to the
  /// weekly league for this STEM category and the leaderboard is offered.
  final String? leagueCategoryId;

  /// Optional: called once with the final percentage when the quiz finishes
  /// (used by friend duels to record the player's score).
  final void Function(int percentage, int correct, int total)? onResult;

  const QuizScreen({
    super.key,
    required this.moduleId,
    required this.worldKey,
    required this.questions,
    required this.title,
    this.leagueCategoryId,
    this.onResult,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class QuizQuestionData {
  final String id;
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;

  const QuizQuestionData({
    required this.id,
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });
}

class _QuizScreenState extends State<QuizScreen> {
  final DateTime _startedAt = DateTime.now();
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  int _streak = 0;
  int _maxStreak = 0;
  bool _finished = false;
  final List<bool> _results = [];

  // Vidas: solo en prácticas. En torneos y duelos nunca se limitan.
  // Cambia a `false` para desactivar las vidas en toda la app.
  static const bool _kHeartsEnabled = true;
  static const int _maxHearts = 5;
  int _hearts = _maxHearts;
  bool _noHearts = false;

  bool get _heartsActive => _kHeartsEnabled && widget.leagueCategoryId == null && widget.onResult == null;

  QuizQuestionData get _currentQuestion => widget.questions[_currentIndex];
  int get _totalQuestions => widget.questions.length;

  /// Elegir una opción (todavía no se califica; falta pulsar COMPROBAR).
  void _pick(int idx) {
    if (_answered) return;
    SoundService.hapticSelect();
    setState(() => _selectedAnswer = idx);
  }

  /// Calificar la opción elegida.
  void _check() {
    if (_answered || _selectedAnswer == null) return;
    final idx = _selectedAnswer!;
    final isCorrect = idx == _currentQuestion.correct;
    setState(() {
      _answered = true;
      _results.add(isCorrect);
      if (isCorrect) {
        _correctCount++;
        _streak++;
        if (_streak > _maxStreak) _maxStreak = _streak;
      } else {
        _streak = 0;
        if (_heartsActive && _hearts > 0) _hearts--;
      }
    });

    if (isCorrect) {
      SoundService.playCorrect();
      BlueConfetti.show(
        context,
        count: _streak >= 3 ? 70 : 38,
        origin: const Offset(0.5, 0.82),
        duration: const Duration(milliseconds: 1900),
      );
    } else {
      SoundService.playWrong();
    }
  }

  void _nextQuestion() {
    if (_heartsActive && _hearts == 0) {
      setState(() => _noHearts = true);
      return;
    }
    if (_currentIndex + 1 >= _totalQuestions) {
      _finishQuiz();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _finishQuiz() {
    setState(() => _finished = true);

    // Calculate score and save
    final percentage = (_correctCount / _totalQuestions * 100).round();
    final stars = percentage >= 90 ? 3 : (percentage >= 70 ? 2 : (percentage >= 50 ? 1 : 0));
    final xp = _correctCount * 10 + (_maxStreak >= 3 ? 15 : 0) + (percentage == 100 ? 25 : 0);
    final isPerfect = percentage == 100;

    // Friend-duel hook: report the score to whoever launched this quiz.
    widget.onResult?.call(percentage, _correctCount, _totalQuestions);

    final auth = context.read<AuthProvider>();
    auth.saveScore(
      '${widget.worldKey}_${widget.moduleId}',
      {
        'completed': true,
        'score': percentage,
        'stars': stars,
        'correctAnswers': _correctCount,
        'totalQuestions': _totalQuestions,
        'maxStreak': _maxStreak,
        'perfect': isPerfect,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    final isTournament = widget.leagueCategoryId != null;

    // Sync stats (tournament rounds count as quizzes/points, not as modules).
    auth.syncStats({
      'addPoints': xp,
      'addModulesCompleted': isTournament ? 0 : 1,
      'addQuizzesCompleted': 1,
      'addPerfectQuizzes': isPerfect ? 1 : 0,
    });

    // Tournament round: submit to the weekly league + unlock achievements.
    if (isTournament) {
      final timeMs = DateTime.now().difference(_startedAt).inMilliseconds;
      auth.unlockAchievement('tournament_first');
      if (isPerfect) auth.unlockAchievement('tournament_ace');
      TournamentService().submitLeagueScore(
        categoryId: widget.leagueCategoryId!,
        uid: auth.user?.uid ?? '',
        username: auth.profile?.username ?? 'Explorador',
        score: percentage,
        correct: _correctCount,
        total: _totalQuestions,
        timeMs: timeMs,
      );
    }

    // Celebración final con confeti azul.
    if (percentage >= 70) {
      SoundService.playVictory();
      BlueConfetti.show(
        context,
        style: isPerfect ? ConfettiStyle.cannons : ConfettiStyle.rain,
        count: isPerfect ? 140 : 90,
        duration: const Duration(milliseconds: 3200),
      );
      if (isPerfect) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) BlueConfetti.show(context, count: 90, origin: const Offset(0.5, 0.3));
        });
      }
    } else {
      SoundService.playXP();
    }
  }

  void _retryQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _correctCount = 0;
      _streak = 0;
      _maxStreak = 0;
      _finished = false;
      _noHearts = false;
      _hearts = _maxHearts;
      _results.clear();
    });
  }

  RobotConfig get _robot => context.watch<AuthProvider>().profile?.robotConfig ?? const RobotConfig();

  @override
  Widget build(BuildContext context) {
    final themeArea = areaById(widget.leagueCategoryId ?? widget.worldKey);
    if (widget.questions.isEmpty) {
      return Scaffold(
        body: ThemedBackground(
          color: themeArea.color,
          icon: themeArea.icon,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚧', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('Quiz no disponible',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                const SizedBox(height: 24),
                _PillButton(label: 'Volver', color: AppTheme.primaryBlue, onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: ThemedBackground(
        color: themeArea.color,
        icon: themeArea.icon,
        child: SafeArea(
          bottom: _finished || _noHearts,
          child: _noHearts ? _buildNoHearts() : (_finished ? _buildResults() : _buildQuestion()),
        ),
      ),
    );
  }

  // ==========================================================================
  // QUESTION
  // ==========================================================================
  Widget _buildQuestion() {
    final gotItRight = _answered && _selectedAnswer == _currentQuestion.correct;
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildQuestionColumn(),
        // "+10 XP" que sube y se desvanece al acertar
        if (gotItRight)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: const Alignment(0, 0.3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: AppTheme.primaryDark, offset: Offset(0, 4), blurRadius: 0)],
                  ),
                  child: const Text('⚡ +10 XP',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                )
                    .animate(key: ValueKey('xp_pop_$_currentIndex'))
                    .fadeIn(duration: 160.ms)
                    .scale(begin: const Offset(0.6, 0.6), duration: 320.ms, curve: Curves.easeOutBack)
                    .moveY(begin: 20, end: -60, duration: 1100.ms, curve: Curves.easeOut)
                    .fadeOut(delay: 800.ms, duration: 300.ms),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionColumn() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 10),
                if (_streak >= 2)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4D1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accentGold, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, size: 16, color: AppTheme.accentOrange)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(begin: const Offset(1, 1), end: const Offset(1.25, 1.25), duration: 450.ms, curve: Curves.easeInOut),
                          const SizedBox(width: 4),
                          Text('¡Racha de $_streak!',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
                        ],
                      ),
                    ),
                  ).animate(key: ValueKey('streak_$_streak')).scale(duration: 250.ms, curve: Curves.easeOutBack),
                // Pregunta y opciones: al cambiar de pregunta se deslizan.
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 340),
                    switchInCurve: Curves.easeOutCubic,
                    layoutBuilder: (current, previous) => Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [...previous, if (current != null) current],
                    ),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.18, 0), end: Offset.zero).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_currentIndex),
                      // ListView: si la pregunta es larga o la pantalla es chica, scrollea (sin overflow).
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 44, bottom: 12),
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                                decoration: AppTheme.cardDecoration(radius: 24),
                                child: Text(
                                  _currentQuestion.question,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -34,
                                right: 14,
                                child: IgnorePointer(
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: RobotAvatarWidget(config: _robot, size: 64),
                                  )
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .moveY(begin: 0, end: -6, duration: 1600.ms, curve: Curves.easeInOut),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          for (var i = 0; i < _currentQuestion.options.length; i++) _buildOption(i),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomPanel(),
      ],
    );
  }

  /// Cerrar · barra de progreso · vidas.
  Widget _buildTopBar() {
    final done = _currentIndex + (_answered ? 1 : 0);
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.close_rounded,
          onTap: () => _confirmExit(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  widthFactor: (done / _totalQuestions).clamp(0.04, 1.0),
                  child: Container(
                    decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 3, left: 8, right: 8),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_heartsActive) ...[
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(Icons.favorite_rounded, color: _hearts > 0 ? AppTheme.accentRed : AppTheme.textHint, size: 26)
                      .animate(key: ValueKey('heart_$_hearts'))
                      .scale(begin: const Offset(1.5, 1.5), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOutBack)
                      .shake(hz: 7, duration: 400.ms, offset: const Offset(3, 0)),
                  if (_answered && _selectedAnswer != _currentQuestion.correct)
                    const Text('-1',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.accentRed))
                        .animate(key: ValueKey('lose_$_currentIndex'))
                        .fadeIn(duration: 120.ms)
                        .moveY(begin: 0, end: 34, duration: 800.ms, curve: Curves.easeOut)
                        .fadeOut(delay: 450.ms, duration: 350.ms),
                ],
              ),
              const SizedBox(width: 4),
              Text('$_hearts',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900, color: _hearts > 0 ? AppTheme.accentRed : AppTheme.textMuted)),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _confirmExit() async {
    // Si todavía no ha respondido nada, sale directo.
    if (_results.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WokovMascot(pose: WokovPose.worried, size: 110, tappable: false),
              const SizedBox(height: 10),
              const Text('¿Quieres salir?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('Si sales ahora perderás el avance de esta práctica.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 18),
              CartoonButton(text: 'Seguir practicando', onPressed: () => Navigator.pop(ctx, false)),
              const SizedBox(height: 4),
              CartoonButton.secondary(text: 'Salir', onPressed: () => Navigator.pop(ctx, true)),
            ],
          ),
        ),
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  /// Panel inferior: COMPROBAR → (verde/rojo) CONTINUAR.
  Widget _buildBottomPanel() {
    final bottom = MediaQuery.of(context).padding.bottom;

    if (!_answered) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.borderColor, width: 2)),
        ),
        child: CartoonButton(text: 'Comprobar', onPressed: _selectedAnswer == null ? null : _check),
      );
    }

    final isCorrect = _selectedAnswer == _currentQuestion.correct;
    final color = isCorrect ? AppTheme.accentGreen : AppTheme.accentRed;
    final dark = isCorrect ? AppTheme.accentGreenDark : AppTheme.accentRedDark;
    final bg = isCorrect ? const Color(0xFFE9F9D8) : const Color(0xFFFFE9E9);
    final title = isCorrect ? (_streak >= 3 ? '¡Racha de $_streak! 🔥' : '¡Correcto!') : '¡Casi! Tú puedes';
    final isLast = _currentIndex + 1 >= _totalQuestions;
    final outOfHearts = _heartsActive && _hearts == 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottom),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: color, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                height: 72,
                child: WokovMascot(
                  pose: isCorrect ? (_streak >= 3 ? WokovPose.excited : WokovPose.cheer) : WokovPose.worried,
                  size: 64,
                  floating: false,
                  tappable: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 130),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: dark)),
                        if (!isCorrect) ...[
                          const SizedBox(height: 4),
                          Text('Respuesta correcta: ${_currentQuestion.options[_currentQuestion.correct]}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: dark)),
                        ],
                        const SizedBox(height: 4),
                        Text(_currentQuestion.explanation,
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: dark, height: 1.35)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CartoonButton(
            text: outOfHearts ? 'Continuar' : (isLast ? 'Ver resultados' : 'Continuar'),
            color: color,
            shadowColor: dark,
            onPressed: _nextQuestion,
          ),
        ],
      ),
    ).animate(key: ValueKey('panel_$_currentIndex')).slideY(begin: 0.3, end: 0, duration: 280.ms, curve: Curves.easeOutBack).fadeIn(duration: 180.ms);
  }

  /// Pantalla cuando se acaban las vidas (solo prácticas).
  Widget _buildNoHearts() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const WokovMascot(pose: WokovPose.sad, size: 190),
          const SizedBox(height: 12),
          const Text('¡Te quedaste sin vidas!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text('No pasa nada, los inventores aprenden de cada error. Repasa y vuelve a intentarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, height: 1.35)),
          const SizedBox(height: 28),
          CartoonButton(text: 'Intentar de nuevo', icon: Icons.refresh_rounded, onPressed: _retryQuiz),
          const SizedBox(height: 4),
          CartoonButton.secondary(text: 'Salir', onPressed: () => Navigator.pop(context)),
        ],
      ),
      ),
    );
  }

  Widget _buildOption(int idx) {
    final isSelected = _selectedAnswer == idx;
    final isCorrect = idx == _currentQuestion.correct;

    Color bg = Colors.white;
    Color border = AppTheme.borderColor;
    Color badgeBg = AppTheme.primaryBlue;
    Color textColor = AppTheme.textPrimary;

    if (_answered) {
      if (isCorrect) {
        bg = AppTheme.accentGreen;
        border = AppTheme.accentGreenDark;
        badgeBg = Colors.white.withValues(alpha: 0.28);
        textColor = Colors.white;
      } else if (isSelected && !isCorrect) {
        bg = AppTheme.accentRed;
        border = AppTheme.accentRedDark;
        badgeBg = Colors.white.withValues(alpha: 0.28);
        textColor = Colors.white;
      } else {
        bg = const Color(0xFFF3F7FD);
        border = AppTheme.borderLight;
        textColor = AppTheme.textMuted;
        badgeBg = AppTheme.textHint;
      }
    } else if (isSelected) {
      bg = AppTheme.iceBlue;
      border = AppTheme.primaryBlue;
    }

    final bubble = GestureDetector(
      onTap: () => _pick(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 2),
          boxShadow: [BoxShadow(color: border, blurRadius: 0, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + idx),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _currentQuestion.options[idx],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor, height: 1.25),
              ),
            ),
            if (_answered && isCorrect) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
            if (_answered && isSelected && !isCorrect) const Icon(Icons.cancel_rounded, color: Colors.white, size: 26),
          ],
        ),
      ),
    );

    // Pop the correct answer when revealed.
    if (_answered && isCorrect) {
      return bubble
          .animate()
          .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), duration: 280.ms, curve: Curves.easeOutBack);
    }
    return bubble;
  }

  // ==========================================================================
  // RESULTS
  // ==========================================================================
  Widget _buildResults() {
    final percentage = (_correctCount / _totalQuestions * 100).round();
    final stars = percentage >= 90 ? 3 : (percentage >= 70 ? 2 : (percentage >= 50 ? 1 : 0));
    final xp = _correctCount * 10 + (_maxStreak >= 3 ? 15 : 0) + (percentage == 100 ? 25 : 0);
    final ringColor =
        percentage >= 70 ? AppTheme.primaryBlue : (percentage >= 50 ? AppTheme.accentGold : AppTheme.accentRed);
    final title = percentage >= 90
        ? '¡Excelente!'
        : (percentage >= 70 ? '¡Muy bien!' : (percentage >= 50 ? '¡Buen intento!' : '¡Sigue practicando!'));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(title,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5))
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.2, end: 0),
          const SizedBox(height: 20),

          // Score ring with robot mascot peeking
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percentage / 100),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 18,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppTheme.iceBlue,
                    valueColor: AlwaysStoppedAnimation(ringColor),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountUpText(
                      value: percentage,
                      duration: const Duration(milliseconds: 1100),
                      style: const TextStyle(
                          fontSize: 64, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, height: 1)),
                  const Text('% correcto',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                ],
              ),
              Positioned(
                bottom: -22,
                right: -34,
                child: WokovSparkles(
                  size: 112,
                  child: WokovMascot(
                  size: 112,
                  tappable: false,
                  // 90%+ baila (secuencia); 70%+ emocionado; 50%+ aliviado; menos, pensativo.
                  sequence: percentage >= 90 ? WokovSequences.celebrate : null,
                  // 70–89%: Wokov animado por capas saltando; menos: pose fija.
                  idleAction: WokovAction.cheer,
                  actionInterval: const Duration(milliseconds: 1700),
                  pose: percentage >= 70
                      ? (percentage >= 90 ? WokovPose.excited : WokovPose.idle)
                      : (percentage >= 50 ? WokovPose.relieved : WokovPose.pondering),
                ),
                ).animate().scale(delay: 300.ms, duration: 600.ms, curve: Curves.elasticOut),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 18),

          Text('$_correctCount/$_totalQuestions respuestas correctas',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(Icons.star_rounded,
                        size: 46, color: i < stars ? AppTheme.accentGold : Colors.white.withValues(alpha: 0.8))
                    .animate()
                    .scale(delay: (400 + i * 150).ms, duration: 400.ms, curve: Curves.easeOutBack),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Stat chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _statChip('⚡', '+$xp XP', AppTheme.primaryBlue),
              _statChip('🔥', 'Racha: $_maxStreak', AppTheme.accentOrange),
              _statChip('📊', '$percentage%', AppTheme.brandBlue),
            ],
          ),
          const SizedBox(height: 30),

          if (widget.leagueCategoryId != null) ...[
            _PillButton(
              label: 'Ver clasificación',
              icon: Icons.leaderboard_rounded,
              color: AppTheme.accentGold,
              onTap: () => Navigator.push(
                context,
                AppTheme.smoothRoute(LeagueLeaderboardScreen(categoryId: widget.leagueCategoryId!)),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _PillButton(
              label: 'Reintentar',
              icon: Icons.refresh_rounded,
              color: Colors.white,
              textColor: AppTheme.textPrimary,
              onTap: _retryQuiz),
          const SizedBox(height: 12),
          _PillButton(
              label: 'Volver',
              icon: Icons.check_rounded,
              color: AppTheme.primaryBlue,
              onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: AppTheme.cardDecoration(radius: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

// Soft drop shadow used across the playful cards.
final List<BoxShadow> _softShadow = [
  const BoxShadow(color: AppTheme.borderColor, blurRadius: 0, offset: Offset(0, 4)),
];

/// Round white icon button (close / info) in the playful style.
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: _softShadow),
        child: Icon(icon, size: 22, color: AppTheme.textSecondary),
      ),
    );
  }
}

/// Big chunky pill button.
class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhite = color == Colors.white;
    return CartoonButton(
      text: label,
      icon: icon,
      onPressed: onTap,
      color: color,
      shadowColor: isWhite ? AppTheme.borderColor : Color.lerp(color, Colors.black, 0.25)!,
      textColor: textColor ?? (isWhite ? AppTheme.primaryBlue : Colors.white),
      borderColor: isWhite ? AppTheme.borderColor : null,
    );
  }
}
