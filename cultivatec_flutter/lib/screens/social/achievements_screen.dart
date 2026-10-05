import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/data/models/user_profile.dart';
import 'package:cultivatec_flutter/data/models/module_models.dart';

class AchievementsScreen extends StatelessWidget {
  final UserProfile? profile;
  final bool embedded;

  const AchievementsScreen({super.key, this.profile, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final earned = profile?.achievementsUnlocked ?? [];

    return Container(
      color: embedded ? Colors.transparent : AppTheme.bgPrimary,
      child: SafeArea(
        top: !embedded,
        child: Column(
          children: [
            if (!embedded) _buildHeader(earned.length),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: allAchievements.length,
                itemBuilder: (context, idx) {
                  final achievement = allAchievements[idx];
                  final isEarned = earned.contains(achievement.id);
                  return _AchievementCard(
                    achievement: achievement,
                    earned: isEarned,
                    onTap: () => _showDetail(context, achievement, isEarned),
                  )
                      .animate()
                      .fadeIn(delay: (50 + idx * 40).ms, duration: 350.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutCubic);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int earnedCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('🏅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Logros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$earnedCount/${allAchievements.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Achievement achievement, bool earned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.bgSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(achievement.icon, size: 48),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _rarityColor(achievement.rarity).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                achievement.rarity.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _rarityColor(achievement.rarity),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (earned)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 18),
                  SizedBox(width: 6),
                  Text('¡Desbloqueado!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.accentGreen)),
                ],
              )
            else
              const Text('🔒 No desbloqueado', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return const Color(0xFF94A3B8);
      case 'uncommon':
        return const Color(0xFF22C55E);
      case 'rare':
        return const Color(0xFF1F6FEB);
      case 'epic':
        return const Color(0xFF5B7CFA);
      case 'legendary':
        return const Color(0xFFFFC800);
      default:
        return AppTheme.textSecondary;
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool earned;
  final VoidCallback onTap;

  const _AchievementCard({
    required this.achievement,
    required this.earned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: earned ? AppTheme.bgSurface : AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned ? _rarityColor(achievement.rarity).withValues(alpha: 0.4) : AppTheme.borderColor,
            width: earned ? 2 : 1,
          ),
          boxShadow: earned ? AppTheme.shadowSm : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              achievement.icon,
              size: 28,
              color: earned ? null : AppTheme.textHint,
            ),
            const SizedBox(height: 6),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: earned ? AppTheme.textPrimary : AppTheme.textHint,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (!earned) const Icon(Icons.lock, size: 12, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return const Color(0xFF94A3B8);
      case 'uncommon':
        return const Color(0xFF22C55E);
      case 'rare':
        return const Color(0xFF1F6FEB);
      case 'epic':
        return const Color(0xFF5B7CFA);
      case 'legendary':
        return const Color(0xFFFFC800);
      default:
        return AppTheme.textSecondary;
    }
  }
}
