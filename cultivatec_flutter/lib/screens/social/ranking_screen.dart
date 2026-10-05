import 'package:cultivatec_flutter/core/widgets/wokov_states.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/data/services/firestore_service.dart';
import 'package:cultivatec_flutter/data/models/level_system.dart';
import 'package:cultivatec_flutter/core/widgets/robot_avatar.dart';
import 'package:cultivatec_flutter/data/models/robot_config.dart';

class RankingScreen extends StatefulWidget {
  final bool embedded;
  const RankingScreen({super.key, this.embedded = false});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final FirestoreService _firestore = FirestoreService();
  StreamSubscription? _rankingSub;
  List<Map<String, dynamic>> _ranking = [];
  bool _loading = true;
  int _tab = 0; // 0=global, 1=friends

  @override
  void initState() {
    super.initState();
    _rankingSub = _firestore.onRankingChange().listen((list) {
      if (mounted) {
        setState(() {
          _ranking = list;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _rankingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.embedded ? Colors.transparent : AppTheme.bgPrimary,
      child: SafeArea(
        top: !widget.embedded,
        child: Column(
          children: [
            if (!widget.embedded) _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _loading
                  ? const WokovLoading(message: 'Cargando ranking…')
                  : _ranking.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _ranking.length,
                          itemBuilder: (context, idx) => _buildRankCard(idx)
                              .animate()
                              .fadeIn(delay: (50 + idx * 60).ms, duration: 350.ms)
                              .slideX(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Ranking Global',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _loading = true),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: AppTheme.textMuted, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabButton(0, Icons.public, 'Global'),
          const SizedBox(width: 8),
          _tabButton(1, Icons.people, 'Amigos'),
        ],
      ),
    );
  }

  Widget _tabButton(int idx, IconData icon, String label) {
    final active = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppTheme.primaryBlue : AppTheme.borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? AppTheme.primaryBlue : AppTheme.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: active ? AppTheme.primaryBlue : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const WokovEmptyState(
      pose: WokovPose.curious,
      title: 'No hay jugadores aún',
      message: '¡Completa una lección y sé el primero en el ranking!',
    );
  }

  Widget _buildRankCard(int idx) {
    final player = _ranking[idx];
    final rank = idx + 1;
    final robotConfig = player['robotConfig'];
    final config = robotConfig is Map<String, dynamic> ? RobotConfig.fromMap(robotConfig) : null;
    final levelInfo = calculateLevel(player['totalPoints'] ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: rank <= 3 ? _podiumColor(rank).withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: rank <= 3
            ? [BoxShadow(color: _podiumColor(rank).withValues(alpha: 0.22), blurRadius: 16, offset: const Offset(0, 7))]
            : AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Rank badge
          _buildRankBadge(rank),
          const SizedBox(width: 10),
          // Avatar
          if (config != null)
            RobotMiniWidget(config: config, size: 36)
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Center(child: Icon(Icons.smart_toy, size: 18)),
            ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['username'] ?? 'Anónimo',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${levelInfo.icon} Nv.${levelInfo.level} • ${levelInfo.title}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player['totalPoints'] ?? 0}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: rank <= 3 ? _podiumColor(rank) : const Color(0xFF22C55E),
                ),
              ),
              const Text(
                'XP',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFC800), Color(0xFFFF9600)]),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.workspace_premium, size: 16)),
      );
    }
    if (rank == 2) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFC0C0C0), Color(0xFFA0A0A0)]),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.looks_two, size: 16)),
      );
    }
    if (rank == 3) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFFA0522D)]),
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.looks_3, size: 16)),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted),
        ),
      ),
    );
  }

  Color _podiumColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFC800);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.white;
    }
  }
}
