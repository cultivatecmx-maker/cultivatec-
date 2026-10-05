import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/core/widgets/blue_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/data/static/tournament_questions.dart';
import 'package:cultivatec_flutter/data/services/tournament_service.dart';
import 'package:cultivatec_flutter/screens/learning/quiz_screen.dart';
import 'package:cultivatec_flutter/screens/tournaments/league_leaderboard_screen.dart';
import 'package:cultivatec_flutter/screens/tournaments/duels_screen.dart';

/// Online tournaments hub. Phase 0: the weekly league is playable locally
/// (answer STEM questions by category, earning XP via the shared quiz engine).
/// Friend duels and live matches are shown as "coming soon".
class TournamentsHubScreen extends StatelessWidget {
  const TournamentsHubScreen({super.key});

  Future<void> _playCategory(BuildContext context, StemCategory cat) async {
    // Load from Firestore question bank when available, else the local seed.
    final questions = await TournamentService().loadCategoryQuestions(cat.id);
    if (!context.mounted) return;
    Navigator.push(
      context,
      AppTheme.smoothRoute(QuizScreen(
        moduleId: 'liga_${cat.id}',
        worldKey: 'torneo',
        title: 'Liga · ${cat.name}',
        questions: questions,
        leagueCategoryId: cat.id,
      )),
    );
  }

  void _openLeaderboard(BuildContext context) {
    Navigator.push(
      context,
      AppTheme.smoothRoute(LeagueLeaderboardScreen(categoryId: stemCategories.first.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: BlueHeader(
            title: 'Torneos',
            subtitle: 'Compite respondiendo preguntas de robótica y STEM.',
            mascot: WokovMascot(pose: WokovPose.excited, size: 96, tappable: false),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modes
                const _ModeCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Liga semanal',
                  subtitle: 'Responde contra el reloj y sube en la tabla',
                  color: AppTheme.primaryBlue,
                  available: true,
                  ctaLabel: 'Elige categoría abajo',
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.12, end: 0),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, AppTheme.smoothRoute(const DuelsScreen())),
                        child: const _ModeCard(
                          icon: Icons.sports_kabaddi_rounded,
                          title: 'Reta a un amigo',
                          subtitle: 'Duelo 1 vs 1',
                          color: AppTheme.accentPurple,
                          available: true,
                          compact: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _ModeCard(
                        icon: Icons.bolt_rounded,
                        title: 'En vivo',
                        subtitle: 'Tiempo real',
                        color: AppTheme.accentPink,
                        available: false,
                        compact: true,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.12, end: 0),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _openLeaderboard(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.leaderboard_rounded, color: AppTheme.accentGold, size: 20),
                        SizedBox(width: 8),
                        Text('Ver clasificación semanal',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 26),

                const Text('Elige una categoría',
                    style: TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.4)),
                const SizedBox(height: 14),
                ...List.generate(stemCategories.length, (i) {
                  final cat = stemCategories[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoryRow(category: cat, onTap: () => _playCategory(context, cat))
                        .animate()
                        .fadeIn(delay: (200 + i * 70).ms, duration: 300.ms)
                        .slideX(begin: 0.08, end: 0),
                  );
                }),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool available;
  final bool compact;
  final String? ctaLabel;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.available,
    this.compact = false,
    this.ctaLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: available ? color : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: available
            ? [BoxShadow(color: Color.lerp(color, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))]
            : AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: available ? Colors.white.withValues(alpha: 0.25) : color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: available ? Colors.white : color, size: 24),
              ),
              const Spacer(),
              if (!available)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.bgSecondary, borderRadius: BorderRadius.circular(8)),
                  child: const Text('PRONTO',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textMuted)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  fontSize: compact ? 15 : 19,
                  fontWeight: FontWeight.w900,
                  color: available ? Colors.white : AppTheme.textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: available ? Colors.white.withValues(alpha: 0.85) : AppTheme.textMuted)),
          if (available && ctaLabel != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(ctaLabel!,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final StemCategory category;
  final VoidCallback onTap;
  const _CategoryRow({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.shadowSm),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
              child: Icon(category.icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  Text('${category.questions.length} preguntas',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Color.lerp(color, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 2),
                  Text('Jugar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
