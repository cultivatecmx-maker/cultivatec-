import 'package:cultivatec_flutter/core/widgets/wokov_states.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/data/models/tournament_models.dart';
import 'package:cultivatec_flutter/data/services/tournament_service.dart';
import 'package:cultivatec_flutter/data/static/tournament_questions.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';

/// Live weekly-league leaderboard, with a STEM category selector.
class LeagueLeaderboardScreen extends StatefulWidget {
  final String categoryId;
  const LeagueLeaderboardScreen({super.key, required this.categoryId});

  @override
  State<LeagueLeaderboardScreen> createState() => _LeagueLeaderboardScreenState();
}

class _LeagueLeaderboardScreenState extends State<LeagueLeaderboardScreen> {
  final TournamentService _service = TournamentService();
  late String _categoryId = widget.categoryId;

  @override
  Widget build(BuildContext context) {
    final myUid = context.watch<AuthProvider>().user?.uid;

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
                      child: Text('Liga semanal',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                              letterSpacing: -0.5)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppTheme.shadowSm),
                      child: Text(currentWeekKey(),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                    ),
                  ],
                ),
              ),
              // Category selector
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: stemCategories.length,
                  itemBuilder: (context, i) {
                    final cat = stemCategories[i];
                    final active = cat.id == _categoryId;
                    return GestureDetector(
                      onTap: () => setState(() => _categoryId = cat.id),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: active ? cat.color : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 16, color: active ? Colors.white : cat.color),
                            const SizedBox(width: 6),
                            Text(cat.name,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: active ? Colors.white : AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<LeagueEntry>>(
                  stream: _service.topEntries(_categoryId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const WokovLoading(message: 'Cargando puntajes…');
                    }
                    final entries = snap.data ?? const [];
                    if (entries.isEmpty) {
                      return _empty();
                    }
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      itemCount: entries.length,
                      itemBuilder: (context, i) => _row(i + 1, entries[i], entries[i].uid == myUid)
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

  Widget _empty() {
    return WokovEmptyState(
      pose: WokovPose.excited,
      title: 'Aún no hay puntajes esta semana',
      message: '¡Sé el primero en jugar ${categoryById(_categoryId).name}!',
    );
  }

  Widget _row(int rank, LeagueEntry e, bool isMe) {
    final podium = rank <= 3;
    final podiumColor =
        rank == 1 ? AppTheme.accentGold : (rank == 2 ? const Color(0xFF94A3B8) : const Color(0xFFCD7F32));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryBlue.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: podium
            ? [BoxShadow(color: Color.lerp(podiumColor, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))]
            : AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: podium
                ? Icon(Icons.emoji_events_rounded, color: podiumColor, size: 26)
                : Text('$rank',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textMuted)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isMe ? '${e.username} (tú)' : e.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: isMe ? AppTheme.primaryBlue : AppTheme.textPrimary),
            ),
          ),
          Text('${e.correct}/${e.total}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AppTheme.accentGreen.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
            child: Text('${e.score}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF15803D))),
          ),
        ],
      ),
    );
  }
}
