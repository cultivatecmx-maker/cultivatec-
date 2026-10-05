import 'package:cultivatec_flutter/core/widgets/blue_header.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';
import 'package:cultivatec_flutter/core/widgets/celebration_host.dart';
import 'package:cultivatec_flutter/core/widgets/daily_goal_card.dart';
import 'package:cultivatec_flutter/screens/learning/match_pairs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
import 'package:cultivatec_flutter/providers/learning_provider.dart';
import 'package:cultivatec_flutter/data/static/stem_content.dart';
import 'package:cultivatec_flutter/data/models/level_system.dart';
import 'package:cultivatec_flutter/data/models/robot_config.dart';
import 'package:cultivatec_flutter/core/widgets/robot_avatar.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/screens/learning/lesson_path_screen.dart';
import 'package:cultivatec_flutter/screens/learning/stem_area_select_screen.dart';
import 'package:cultivatec_flutter/screens/social/ranking_screen.dart';
import 'package:cultivatec_flutter/screens/social/achievements_screen.dart';
import 'package:cultivatec_flutter/screens/social/friends_screen.dart';
import 'package:cultivatec_flutter/screens/home/settings_screen.dart';
import 'package:cultivatec_flutter/screens/robot/robot_skin_editor_screen.dart';
import 'package:cultivatec_flutter/screens/learning/classroom_screen.dart';
import 'package:cultivatec_flutter/screens/learning/glossary_screen.dart';
import 'package:cultivatec_flutter/screens/robot/coding_challenges_screen.dart';
import 'package:cultivatec_flutter/screens/tournaments/tournaments_hub_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/simulators_hub_screen.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';

/// Top-level navigation destinations (learning-first information architecture).
enum _Tab { home, learn, tournaments, social, profile }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  _Tab _currentTab = _Tab.home;
  late final AnimationController _tabAnim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 280), value: 1);

  @override
  void dispose() {
    _tabAnim.dispose();
    super.dispose();
  }

  void _select(_Tab tab) {
    if (tab != _currentTab && !MotionSettings.shouldReduce(context)) _tabAnim.forward(from: 0);
    setState(() => _currentTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LearningProvider>(
      builder: (context, auth, learning, _) {
        final profile = auth.profile;
        final levelInfo = calculateLevel(profile?.totalPoints ?? 0);

        return Scaffold(
          extendBody: true,
          body: AnimatedBackground(
            child: Stack(
              children: [
                // La pestaña nueva aparece con un fundido y un pequeño deslizamiento.
                AnimatedBuilder(
                  animation: _tabAnim,
                  builder: (context, child) {
                    final v = Curves.easeOutCubic.transform(_tabAnim.value);
                    return Opacity(
                      opacity: 0.25 + 0.75 * v,
                      child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
                    );
                  },
                  child: IndexedStack(
                    index: _currentTab.index,
                    children: [
                      _HomeTab(auth: auth, levelInfo: levelInfo, onSelectTab: _select),
                      _buildLearnTab(auth, learning),
                      const TournamentsHubScreen(),
                      _SocialHubTab(profile: profile, pendingRequests: auth.pendingRequests.length),
                      _ProfileTab(auth: auth, levelInfo: levelInfo),
                    ],
                  ),
                ),
                Positioned(bottom: 0, left: 0, right: 0, child: _buildFloatingDock(auth)),
                const CelebrationHost(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearnTab(AuthProvider auth, LearningProvider learning) {
    return learning.showAreaSelector
        ? StemAreaSelectScreen(onSelectArea: learning.enterStemArea, userScores: auth.userScores)
        : LessonPathScreen(
            stemAreaId: learning.currentStemAreaId ?? stemAreas.first.id,
            onBack: learning.exitToAreaSelector,
            userScores: auth.userScores,
            friendsCount: auth.profile?.friendsCount ?? 0,
          );
  }

  Widget _buildFloatingDock(AuthProvider auth) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.navy,
        border: Border(top: BorderSide(color: Color(0xFF2A5BC4), width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(_Tab.home, Icons.home_rounded, 'Inicio'),
              _navItem(_Tab.learn, Icons.rocket_launch_rounded, 'Aprender'),
              _navItem(_Tab.tournaments, Icons.sports_esports_rounded, 'Torneos'),
              _navItem(_Tab.social, Icons.groups_rounded, 'Social', badge: auth.pendingRequests.length),
              _navItem(_Tab.profile, Icons.person_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(_Tab tab, IconData icon, String label, {int badge = 0}) {
    final isActive = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentTab != tab) SoundService.playTab();
          _select(tab);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? AppTheme.primaryLight : Colors.transparent, width: 2),
            boxShadow: isActive ? const [BoxShadow(color: AppTheme.navyDeep, offset: Offset(0, 3), blurRadius: 0)] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.18 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: Icon(icon, color: isActive ? Colors.white : const Color(0xFF8DB8FF), size: 27),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.navy, width: 2),
                        ),
                        child: Text('$badge',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : const Color(0xFF8DB8FF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// INICIO — pixel-matched to the reference dashboard.
// ============================================================================
class _HomeTab extends StatelessWidget {
  final AuthProvider auth;
  final LevelInfo levelInfo;
  final ValueChanged<_Tab> onSelectTab;

  const _HomeTab({required this.auth, required this.levelInfo, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final profile = auth.profile;
    final robot = profile?.robotConfig ?? const RobotConfig();
    final pending = auth.pendingRequests.length;
    final modules = profile?.modulesCompleted ?? 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _heroHeader(context, profile, robot, pending)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.06, end: 0),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DailyGoalCard(
                  streak: profile?.currentStreak ?? 0,
                  onStartLesson: () => onSelectTab(_Tab.learn),
                ).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(begin: 0.12, end: 0),
                const SizedBox(height: 16),
                _missionCarousel(context, robot)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 350.ms)
                    .slideY(begin: 0.12, end: 0),
                const SizedBox(height: 24),
                _quickTiles(context).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                const SizedBox(height: 26),
                const Text('Rutas de Aprendizaje',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.4)),
                const SizedBox(height: 18),
                _pathSection(modules).animate().fadeIn(delay: 380.ms, duration: 300.ms),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---- Encabezado azul del inicio -------------------------------------------
  Widget _heroHeader(BuildContext context, dynamic profile, RobotConfig robot, int pending) {
    final top = MediaQuery.of(context).padding.top;
    final name = profile?.username ?? 'Explorador';
    final points = profile?.totalPoints ?? 0;
    final streak = profile?.currentStreak ?? 0;
    final modules = profile?.modulesCompleted ?? 0;
    final lv = levelInfo;
    final pct = lv.isMaxLevel ? 1.0 : lv.progress.clamp(0.0, 1.0);

    Widget bubble(double size, double alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
        );

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
        boxShadow: [BoxShadow(color: AppTheme.navyDeep, offset: Offset(0, 6), blurRadius: 0)],
      ),
      child: Stack(
        children: [
          Positioned(top: -60, right: -40, child: bubble(200, 0.08)),
          Positioned(bottom: -80, left: -60, child: bubble(180, 0.06)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onSelectTab(_Tab.profile),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.skyBlue, width: 3),
                        ),
                        child: RobotAvatarWidget(config: robot, size: 40),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¡Hola, $name!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                          Row(
                            children: [
                              Icon(lv.icon, size: 14, color: AppTheme.accentGold),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(lv.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFBFDDFF))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onSelectTab(_Tab.social),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                          ),
                          if (pending > 0)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.navy, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text('${lv.level}',
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.navy)),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Tu nivel',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Barra de XP: la recompensa va en dorado.
                          Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: pct <= 0 ? 0.04 : pct,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lv.isMaxLevel ? '¡Nivel máximo!' : '${lv.xpInLevel} / ${lv.xpNeeded} XP al nivel ${lv.level + 1}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFBFDDFF)),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _heroChip(Icons.local_fire_department_rounded, AppTheme.accentOrange,
                                  '$streak ${streak == 1 ? 'día' : 'días'}'),
                              _heroChip(Icons.bolt_rounded, AppTheme.accentGold, '$points XP'),
                              _heroChip(Icons.assignment_turned_in_rounded, AppTheme.skyBlue, '$modules misiones'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const WokovMascot(
                      pose: WokovPose.idle,
                      size: 116,
                      idleAction: WokovAction.wave,
                      actionInterval: Duration(seconds: 7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  // ---- Mission carousel ----------------------------------------------------
  Widget _missionCarousel(BuildContext context, RobotConfig robot) {
    final width = MediaQuery.of(context).size.width;
    final mainW = width * 0.82;
    return SizedBox(
      height: 246,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        children: [
          _heroMission(width: mainW, robot: robot, onTap: () => onSelectTab(_Tab.learn)),
          const SizedBox(width: 14),
          _infoCard(
            width: mainW * 0.58,
            colors: const [Color(0xFF1F6FEB), Color(0xFF5AA7FF)],
            icon: Icons.build_rounded,
            title: 'Inventor\nde Piezas',
            subtitle: 'Arma tu robot',
            cta: 'Ver',
            onTap: () => onSelectTab(_Tab.learn),
          ),
          const SizedBox(width: 14),
          _infoCard(
            width: mainW * 0.58,
            colors: const [Color(0xFF0958C2), Color(0xFF1CB0F6)],
            icon: Icons.sports_esports_rounded,
            title: 'Torneo\nsemanal',
            subtitle: 'Compite STEM',
            cta: 'Jugar',
            onTap: () => onSelectTab(_Tab.tournaments),
          ),
        ],
      ),
    );
  }

  /// Main "Misión del Día" card: blue top + robot poking out the top, with a
  /// white bottom band (lesson, progress, start button).
  Widget _heroMission({required double width, required RobotConfig robot, required VoidCallback onTap}) {
    final progress = levelInfo.progress.clamp(0.0, 1.0);
    final pct = (progress * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: width,
              height: 246,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(color: Color.lerp(AppTheme.primaryBlue, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  children: [
                    // Blue top zone
                    Container(
                      height: 132,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 8, 12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Misión del Día:',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Text('Continuar\naprendiendo',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                      ),
                    ),
                    // White bottom band
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Siguiente Lección',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 9,
                                backgroundColor: AppTheme.bgSecondary,
                                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text('$pct% Completado',
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                                  child: const Text('¡Comenzar Misión!',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Robot mascot poking above the blue zone — now alive and tappable
            Positioned(
              right: 4,
              top: -22,
              child: SizedBox(
                width: 138,
                height: 158,
                child: WokovMascot(
                  pose: WokovPose.idle,
                  size: 150,
                  idleAction: WokovAction.wave,
                  actionInterval: const Duration(seconds: 7),
                  fallback: FittedBox(fit: BoxFit.contain, child: RobotAvatarWidget(config: robot, size: 150)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required double width,
    required List<Color> colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required String cta,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.first,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(color: Color.lerp(colors.last, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration:
                  BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, height: 1.05, letterSpacing: -0.4)),
            const SizedBox(height: 3),
            Text(subtitle,
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Text(cta, style: TextStyle(color: colors.last, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Quick tiles ---------------------------------------------------------
  Widget _quickTiles(BuildContext context) {
    return Column(
      children: [
        Row(
      children: [
        Expanded(
          child: _squareTile(Icons.smart_toy_rounded, 'Mis Robots', AppTheme.primaryBlue, Colors.white,
              () => Navigator.push(context, AppTheme.smoothRoute(const RobotSkinEditorScreen()))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _squareTile(Icons.code_rounded, 'Taller de Código', AppTheme.accentCyan, Colors.white,
              () => Navigator.push(context, AppTheme.smoothRoute(const CodingChallengesScreen()))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _squareTile(Icons.emoji_events_rounded, 'Desafíos Semanales', AppTheme.primaryBlue,
              AppTheme.accentGold, () => onSelectTab(_Tab.tournaments)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _squareTile(Icons.science_rounded, 'Simuladores', AppTheme.toneIndigo, Colors.white,
              () => Navigator.push(context, AppTheme.smoothRoute(const SimulatorsHubScreen()))),
        ),
      ],
    ),
        const SizedBox(height: 14),
        _matchPairsBanner(context),
      ],
    );
  }

  Widget _matchPairsBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        Navigator.push(context, AppTheme.smoothRoute(const MatchPairsScreen()));
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: AppTheme.primaryDark, offset: Offset(0, 5), blurRadius: 0)],
        ),
        child: Row(
          children: [
            const Icon(Icons.extension_rounded, color: Colors.white, size: 34),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Une los pares',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('Relaciona términos con su definición y gana XP',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFFDCEBFF))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _squareTile(IconData icon, String label, Color color, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Color.lerp(color, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, height: 1.1)),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Learning path -------------------------------------------------------
  Widget _pathSection(int modules) {
    const names = ['Robótica', 'Programación', 'Electrónica'];
    const icons = [Icons.smart_toy_rounded, Icons.code_rounded, Icons.bolt_rounded];
    const colors = [AppTheme.accentPurple, AppTheme.primaryBlue, AppTheme.accentCyan];
    final done = [modules >= 3, modules >= 6, modules >= 9];
    bool unlocked(int i) => i == 0 || done[i - 1];

    final children = <Widget>[];
    for (int i = 0; i < 3; i++) {
      children.add(_pathNode(names[i], icons[i], colors[i], done[i], unlocked(i)));
      if (i < 2) children.add(_connector(done[i]));
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _connector(bool active) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 27),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (_) => Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: active ? AppTheme.accentGreen : AppTheme.borderColor, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pathNode(String name, IconData icon, Color color, bool done, bool unlocked) {
    final bg = done ? AppTheme.accentGreen : (unlocked ? color : const Color(0xFFE2E8F0));
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          GestureDetector(
            onTap: unlocked ? () => onSelectTab(_Tab.learn) : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: unlocked
                        ? [BoxShadow(color: Color.lerp(bg, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))]
                        : [],
                  ),
                  child: Icon(
                    unlocked ? icon : Icons.lock_rounded,
                    color: unlocked ? Colors.white : AppTheme.textMuted,
                    size: 27,
                  ),
                ),
                if (done) Positioned(right: -2, top: -2, child: _badge(Icons.check_rounded, AppTheme.accentGreen)),
                if (!unlocked) Positioned(right: -2, top: -2, child: _badge(Icons.lock_rounded, AppTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: unlocked ? AppTheme.textPrimary : AppTheme.textMuted,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
      child: Icon(icon, color: Colors.white, size: 12),
    );
  }
}

// ============================================================================
// SOCIAL — Hub with a segmented control over Ranking / Logros / Amigos.
// ============================================================================
class _SocialHubTab extends StatefulWidget {
  final dynamic profile;
  final int pendingRequests;
  const _SocialHubTab({required this.profile, required this.pendingRequests});

  @override
  State<_SocialHubTab> createState() => _SocialHubTabState();
}

class _SocialHubTabState extends State<_SocialHubTab> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlueHeader(
          title: 'Social',
          subtitle: 'Ranking, logros y amigos',
          bottom: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.5),
            ),
            child: Row(
              children: [
                _segmentBtn(0, Icons.emoji_events_rounded, 'Ranking'),
                _segmentBtn(1, Icons.military_tech_rounded, 'Logros'),
                _segmentBtn(2, Icons.people_rounded, 'Amigos', badge: widget.pendingRequests),
              ],
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _segment,
            children: [
              const RankingScreen(embedded: true),
              AchievementsScreen(profile: widget.profile, embedded: true),
              const FriendsScreen(embedded: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _segmentBtn(int idx, IconData icon, String label, {int badge = 0}) {
    final isActive = _segment == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _segment = idx),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isActive ? const [BoxShadow(color: AppTheme.navyDeep, blurRadius: 0, offset: Offset(0, 3))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 18, color: isActive ? AppTheme.primaryBlue : Colors.white),
                  if (badge > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppTheme.accentRed, shape: BoxShape.circle)),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isActive ? AppTheme.primaryBlue : Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PERFIL — Account home.
// ============================================================================
class _ProfileTab extends StatelessWidget {
  final AuthProvider auth;
  final LevelInfo levelInfo;
  const _ProfileTab({required this.auth, required this.levelInfo});

  @override
  Widget build(BuildContext context) {
    final profile = auth.profile;
    final lv = levelInfo;
    final pct = lv.isMaxLevel ? 1.0 : lv.progress.clamp(0.0, 1.0);
    final trophies = profile?.achievementsUnlocked.length ?? 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: BlueHeader(
            title: profile?.username ?? 'Explorador',
            subtitle: profile?.email ?? '',
            mascot: SizedBox(
              width: 88,
              height: 88,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: v <= 0 ? 0.02 : v,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                      ),
                    ),
                    child!,
                  ],
                ),
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Center(
                    child: RobotAvatarWidget(config: profile?.robotConfig ?? const RobotConfig(), size: 54),
                  ),
                ),
              ),
            ),
            bottom: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text('${lv.level}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.navy)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lv.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text(
                          lv.isMaxLevel ? '¡Nivel máximo!' : '${lv.xpInLevel} / ${lv.xpNeeded} XP al nivel ${lv.level + 1}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFBFDDFF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _statCard(Icons.local_fire_department_rounded, AppTheme.accentOrange,
                        '${profile?.currentStreak ?? 0}', 'Racha'),
                    const SizedBox(width: 10),
                    _statCard(Icons.bolt_rounded, AppTheme.accentGold, '${profile?.totalPoints ?? 0}', 'XP total'),
                    const SizedBox(width: 10),
                    _statCard(Icons.emoji_events_rounded, AppTheme.toneAzure, '$trophies', 'Logros'),
                  ],
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                _profileTile(
                    context,
                    Icons.smart_toy_rounded,
                    AppTheme.accentPurple,
                    'Editar Robot',
                    'Personaliza tu compañero',
                    () => Navigator.push(context, AppTheme.smoothRoute(const RobotSkinEditorScreen()))),
                const SizedBox(height: 12),
                _profileTile(
                    context,
                    Icons.menu_book_rounded,
                    AppTheme.toneAzure,
                    'Glosario',
                    'Conceptos clave de robótica',
                    () => Navigator.push(context, AppTheme.smoothRoute(const GlossaryScreen()))),
                const SizedBox(height: 12),
                _profileTile(context, Icons.school_rounded, AppTheme.toneSky, 'Mi clase', 'Conecta con tu grupo',
                    () => Navigator.push(context, AppTheme.smoothRoute(const ClassroomScreen()))),
                const SizedBox(height: 12),
                _profileTile(
                    context,
                    Icons.settings_rounded,
                    AppTheme.toneNavy,
                    'Configuración',
                    'Sonido, cuenta y más',
                    () => Navigator.push(context, AppTheme.smoothRoute(const SettingsScreen()))),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: AppTheme.cardDecoration(radius: 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            ),
            Text(label,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(
      BuildContext context, IconData icon, Color color, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.cardDecoration(radius: 22),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryLight),
          ],
        ),
      ),
    );
  }
}
