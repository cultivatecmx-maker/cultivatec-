import 'package:cultivatec_flutter/core/widgets/wokov_states.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
import 'package:cultivatec_flutter/data/models/tournament_models.dart';
import 'package:cultivatec_flutter/data/models/user_profile.dart';
import 'package:cultivatec_flutter/data/services/firestore_service.dart';
import 'package:cultivatec_flutter/data/services/tournament_service.dart';
import 'package:cultivatec_flutter/data/static/tournament_questions.dart';
import 'package:cultivatec_flutter/screens/learning/quiz_screen.dart';

/// Phase 2 — async 1v1 friend duels.
class DuelsScreen extends StatelessWidget {
  const DuelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid ?? '';
    final service = TournamentService();

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
                      child: Text('Reta a un amigo',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                              letterSpacing: -0.5)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: GestureDetector(
                  onTap: () => _startNewDuel(context, auth),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Color.lerp(AppTheme.accentPurple, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_kabaddi_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text('Nuevo duelo',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Duel>>(
                  stream: service.myDuels(uid),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const WokovLoading(message: 'Cargando duelos…');
                    }
                    final duels = snap.data ?? const [];
                    if (duels.isEmpty) return _empty();
                    // Your turn first, then waiting, then completed.
                    duels.sort((a, b) => _order(a, uid).compareTo(_order(b, uid)));
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      itemCount: duels.length,
                      itemBuilder: (context, i) => _duelCard(context, duels[i], uid, auth)
                          .animate()
                          .fadeIn(delay: (40 * i).ms, duration: 300.ms)
                          .slideX(begin: 0.06, end: 0),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _order(Duel d, String uid) {
    final yourTurn = d.status == 'pending' && d.opponentUid == uid;
    final waiting = d.status == 'pending' && d.challengerUid == uid;
    if (yourTurn) return 0;
    if (waiting) return 1;
    return 2;
  }

  Widget _empty() {
    return const WokovEmptyState(
      pose: WokovPose.explain,
      title: 'Aún no tienes duelos',
      message: '¡Reta a un amigo y compitan en STEM!',
    );
  }

  Widget _duelCard(BuildContext context, Duel d, String uid, AuthProvider auth) {
    final cat = categoryById(d.categoryId);
    final yourTurn = d.status == 'pending' && d.opponentUid == uid;
    final waiting = d.status == 'pending' && d.challengerUid == uid;
    final iAmChallenger = d.challengerUid == uid;
    final rivalName = iAmChallenger ? d.opponentName : d.challengerName;

    String statusText;
    Color statusColor;
    if (yourTurn) {
      statusText = '¡Tu turno!';
      statusColor = AppTheme.accentGreen;
    } else if (waiting) {
      statusText = 'Esperando a $rivalName';
      statusColor = AppTheme.accentOrange;
    } else {
      final myScore = iAmChallenger ? d.challengerScore : d.opponentScore;
      final rivalScore = iAmChallenger ? d.opponentScore : d.challengerScore;
      final won = d.winnerUid == uid;
      final tie = d.winnerUid == null;
      statusText = tie
          ? 'Empate ($myScore% - $rivalScore%)'
          : (won ? '¡Ganaste! ($myScore% - $rivalScore%)' : 'Perdiste ($myScore% - $rivalScore%)');
      statusColor = tie ? AppTheme.textMuted : (won ? AppTheme.accentGreen : AppTheme.accentRed);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.shadowSm),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(cat.icon, color: cat.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs $rivalName',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${cat.name} · $statusText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
              ],
            ),
          ),
          if (yourTurn)
            GestureDetector(
              onTap: () => _playDuel(context, d, auth),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: cat.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('Jugar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            )
          else if (waiting)
            const Icon(Icons.hourglass_top_rounded, color: AppTheme.accentOrange)
          else
            Icon(d.winnerUid == uid ? Icons.emoji_events_rounded : Icons.flag_rounded,
                color: d.winnerUid == uid ? AppTheme.accentGold : AppTheme.textHint),
        ],
      ),
    );
  }

  // --- Create a new duel: pick friend → pick category → play → store score ---
  Future<void> _startNewDuel(BuildContext context, AuthProvider auth) async {
    final uid = auth.user?.uid ?? '';
    final friends = await FirestoreService().getFriendsList(uid);
    if (!context.mounted) return;
    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Primero agrega amigos en la pestaña Social.'), backgroundColor: AppTheme.textPrimary),
      );
      return;
    }
    final friend = await _pickFromSheet<UserProfile>(
      context,
      title: 'Elige a tu rival',
      items: friends,
      label: (f) => f.username,
      icon: Icons.person_rounded,
    );
    if (friend == null || !context.mounted) return;

    final cat = await _pickFromSheet<StemCategory>(
      context,
      title: 'Elige la categoría',
      items: stemCategories,
      label: (c) => c.name,
      iconOf: (c) => c.icon,
      colorOf: (c) => c.color,
    );
    if (cat == null || !context.mounted) return;

    Navigator.push(
      context,
      AppTheme.smoothRoute(QuizScreen(
        moduleId: 'duel_${cat.id}',
        worldKey: 'duel',
        title: 'Duelo · ${cat.name}',
        questions: cat.questions,
        onResult: (pct, _, __) {
          TournamentService().createDuel(
            challengerUid: uid,
            challengerName: auth.profile?.username ?? 'Retador',
            opponentUid: friend.uid,
            opponentName: friend.username,
            categoryId: cat.id,
            challengerScore: pct,
          );
        },
      )),
    );
  }

  void _playDuel(BuildContext context, Duel d, AuthProvider auth) {
    final cat = categoryById(d.categoryId);
    Navigator.push(
      context,
      AppTheme.smoothRoute(QuizScreen(
        moduleId: 'duel_${cat.id}',
        worldKey: 'duel',
        title: 'Duelo · ${cat.name}',
        questions: cat.questions,
        onResult: (pct, _, __) {
          TournamentService().submitDuelResult(duelId: d.id, opponentScore: pct);
        },
      )),
    );
  }

  Future<T?> _pickFromSheet<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) label,
    IconData? icon,
    IconData Function(T)? iconOf,
    Color Function(T)? colorOf,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const SizedBox(height: 14),
              ...items.map((it) {
                final color = colorOf?.call(it) ?? AppTheme.primaryBlue;
                return GestureDetector(
                  onTap: () => Navigator.pop(ctx, it),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(iconOf?.call(it) ?? icon ?? Icons.circle, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(label(it),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppTheme.textHint),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
