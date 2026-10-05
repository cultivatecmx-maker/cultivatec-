import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/screens/robot/block_coding_screen.dart';

/// "Taller de Código": list of block-programming challenges, each opening the
/// drag-and-drop block simulator where kids run their code.
class CodingChallengesScreen extends StatelessWidget {
  const CodingChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration:
                            BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.shadowSm),
                        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text('Taller de Código',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                              letterSpacing: -0.5)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    // Intro card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(color: Color.lerp(AppTheme.accentCyan, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.extension_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Arrastra bloques para programar al robot y pulsa "Ejecutar" para verlo moverse. ¡Resuelve cada reto!',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 18),
                    const Text('Retos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    ...List.generate(codingChallenges.length, (i) {
                      final ch = codingChallenges[i];
                      return _challengeCard(context, ch, i + 1)
                          .animate()
                          .fadeIn(delay: (70 * i).ms, duration: 300.ms)
                          .slideX(begin: 0.06, end: 0);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _challengeCard(BuildContext context, CodingChallenge ch, int number) {
    return GestureDetector(
      onTap: () => Navigator.push(context, AppTheme.smoothRoute(BlockCodingScreen(challengeId: ch.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.shadowSm),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text('$number',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(ch.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                      ),
                      Row(
                        children: List.generate(
                          3,
                          (s) => Icon(Icons.bolt_rounded,
                              size: 14, color: s < ch.difficulty ? AppTheme.accentGold : AppTheme.borderColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(ch.instruction,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                  Text('Jugar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
