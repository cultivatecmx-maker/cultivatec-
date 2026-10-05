import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_states.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/core/widgets/blue_header.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/data/static/stem_content.dart';
import 'package:cultivatec_flutter/core/widgets/themed_background.dart';
import 'package:cultivatec_flutter/screens/learning/quiz_screen.dart';
import 'package:cultivatec_flutter/screens/robot/circuit_builder_screen.dart';
import 'package:cultivatec_flutter/screens/robot/block_coding_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/ohms_law_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/diode_rectifier_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/transistor_switch_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/timer555_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/arm_kinematics_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/pid_simulator_screen.dart';

/// Maps a lesson id to the hands-on simulator that reinforces it, when one
/// exists. Not every lesson has a matching simulator yet — this grows as
/// more simulators get built.
final Map<String, Widget Function()> _lessonSimulators = {
  'mk_ohm': () => const OhmsLawSimulatorScreen(),
  'in_diodos': () => const DiodeRectifierSimulatorScreen(),
  'in_transistor': () => const TransistorSwitchSimulatorScreen(),
  'in_ci555': () => const Timer555SimulatorScreen(),
  'in_cinematica': () => const ArmKinematicsSimulatorScreen(),
  'in_pid': () => const PidSimulatorScreen(),
};

// We keep this class signature to avoid breaking any other rogue imports,
// but it is no longer used in the new STEM Area flow.
class ModuleListScreen extends StatelessWidget {
  const ModuleListScreen({super.key, int? worldIndex, Map? userScores});
  @override
  Widget build(BuildContext context) => const Scaffold();
}

/// Pantalla de lección: encabezado azul con Wokov (cambia de pose según el tipo
/// de tarjeta), progreso por segmentos, tarjetas deslizables y navegación.
class LessonScreen extends StatefulWidget {
  final String stemAreaId;
  final String moduleId; // This is the lesson.id

  const LessonScreen({
    super.key,
    required this.stemAreaId,
    required this.moduleId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  /// Lecciones sobre armar cosas: muestran a Wokov ensamblándose.
  static const _assemblyLessons = {'ch_arma', 'mk_ensamblaje', 'ch_brazo'};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  WokovPose _poseFor(Lesson lesson) {
    if (_currentIndex >= lesson.cards.length) return WokovPose.armsUp; // «paso» virtual al quiz
    switch (lesson.cards[_currentIndex].type) {
      case CardType.concept:
        return WokovPose.explain;
      case CardType.example:
        return WokovPose.pointSide;
      case CardType.funFact:
        return WokovPose.excited;
      case CardType.tip:
        return WokovPose.pointUp;
    }
  }

  void _onNext(StemArea area, Lesson lesson) {
    if (_currentIndex < lesson.cards.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else if (_currentIndex == lesson.cards.length - 1 && lesson.practiceType != PracticeType.none) {
      // Ir primero a la práctica; al volver se pasa al quiz.
      if (lesson.practiceType == PracticeType.electronics) {
        Navigator.of(context).push(AppTheme.smoothRoute(CircuitBuilderScreen(challengeId: lesson.challengeId)));
      } else if (lesson.practiceType == PracticeType.coding) {
        Navigator.of(context)
            .push(AppTheme.smoothRoute(BlockCodingScreen(challengeId: lesson.challengeId ?? 'c1')));
      }
      setState(() => _currentIndex++); // avanza al «paso» virtual del quiz
    } else {
      Navigator.of(context).pushReplacement(
        AppTheme.smoothRoute(QuizScreen(
          moduleId: lesson.id,
          worldKey: area.id,
          title: lesson.title,
          questions: lesson.questions,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final area = areaById(widget.stemAreaId);
    final lesson = area.lessons.firstWhere((l) => l.id == widget.moduleId, orElse: () => area.lessons.first);
    final isLastCard = _currentIndex >= lesson.cards.length - 1;
    final goesToPractice = _currentIndex == lesson.cards.length - 1 && lesson.practiceType != PracticeType.none;

    final String nextLabel = !isLastCard
        ? 'Siguiente'
        : (goesToPractice ? '¡Ir a Práctica!' : '¡Empezar Quiz!');
    final IconData? nextIcon = !isLastCard
        ? null
        : (goesToPractice ? Icons.science_rounded : Icons.rocket_launch_rounded);

    return Scaffold(
      body: ThemedBackground(
        color: area.color,
        icon: area.icon,
        child: Column(
          children: [
            BlueHeader(
              title: lesson.title,
              subtitle: '${area.name.toUpperCase()} · ${lesson.subtitle}',
              trailing: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                ),
              ),
              mascot: _assemblyLessons.contains(lesson.id)
                  ? const SizedBox(height: 100, child: WokovAssembly(height: 100))
                  : SizedBox(
                      width: 86,
                      height: 86,
                      child: WokovMascot(pose: _poseFor(lesson), size: 86, floating: false, tappable: false),
                    ),
            ),

            // Progreso por segmentos
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
              child: Row(
                children: List.generate(lesson.cards.length, (i) {
                  final on = i <= _currentIndex;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 9,
                      margin: EdgeInsets.only(right: i == lesson.cards.length - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: on ? AppTheme.primaryBlue : AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Tarjetas
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemCount: lesson.cards.length,
                itemBuilder: (context, idx) {
                  final card = lesson.cards[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _buildLessonCard(card, area),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
                },
              ),
            ),

            // Acceso al simulador de la lección (si existe)
            if (_lessonSimulators.containsKey(widget.moduleId))
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
                child: CartoonButton.secondary(
                  text: 'Pruébalo en el simulador',
                  icon: Icons.science_rounded,
                  onPressed: () =>
                      Navigator.of(context).push(AppTheme.smoothRoute(_lessonSimulators[widget.moduleId]!())),
                ),
              ),

            // Navegación
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 14 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(
                color: AppTheme.bgSurface,
                border: Border(top: BorderSide(color: AppTheme.borderColor, width: 2)),
              ),
              child: Row(
                children: [
                  if (_currentIndex > 0) ...[
                    GestureDetector(
                      onTap: () {
                        SoundService.playClick();
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
                      },
                      child: Container(
                        width: 56,
                        height: 54,
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderColor, width: 2),
                          boxShadow: const [BoxShadow(color: AppTheme.borderColor, offset: Offset(0, 5), blurRadius: 0)],
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryBlue),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: isLastCard
                        ? CartoonButton.success(text: nextLabel, icon: nextIcon, onPressed: () => _onNext(area, lesson))
                        : CartoonButton(text: nextLabel, onPressed: () => _onNext(area, lesson)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(LessonCard card, StemArea area) {
    IconData icon;
    String label;
    Color color;
    Color onColor = Colors.white;

    switch (card.type) {
      case CardType.concept:
        icon = Icons.lightbulb_rounded;
        label = 'CONCEPTO';
        color = AppTheme.primaryBlue;
        break;
      case CardType.example:
        icon = Icons.visibility_rounded;
        label = 'EJEMPLO';
        color = AppTheme.toneIndigo;
        break;
      case CardType.funFact:
        icon = Icons.star_rounded;
        label = 'DATO CURIOSO';
        color = AppTheme.accentGold; // recompensa → dorado
        onColor = AppTheme.navy;
        break;
      case CardType.tip:
        icon = Icons.tips_and_updates_rounded;
        label = 'TIP';
        color = AppTheme.toneAzure;
        break;
    }
    final dark = Color.lerp(color, Colors.black, 0.3)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 2.5),
        boxShadow: [BoxShadow(color: dark, offset: const Offset(0, 6), blurRadius: 0)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        // Todo dentro de un scroll: nunca hay overflow, aunque la pantalla sea chica.
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                color: color,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: onColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Icon(icon, color: onColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900, color: onColor, letterSpacing: 1.3)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      card.body,
                      style: const TextStyle(
                        fontSize: 17.5,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
