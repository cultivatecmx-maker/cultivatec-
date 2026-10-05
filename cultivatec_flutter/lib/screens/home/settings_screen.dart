import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/core/widgets/blue_header.dart';
import 'package:cultivatec_flutter/core/widgets/animated_background.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
import 'package:cultivatec_flutter/screens/robot/robot_skin_editor_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = SoundService.isEnabled;
  bool _showLogoutConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final profile = auth.profile;
        return Scaffold(
          body: AnimatedBackground(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  BlueHeader(
                    title: 'Configuración',
                    subtitle: 'Sonido, meta diaria, cuenta y más',
                    trailing: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
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
                    mascot: const SizedBox(
                      width: 84,
                      height: 84,
                      child: WokovMascot(pose: WokovPose.think, size: 84, floating: false, tappable: false),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Profile card
                          _buildProfileCard(profile)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                          const SizedBox(height: 20),
                          // Sound toggle
                          _settingsTile(
                            icon: Icons.volume_up,
                            iconColor: AppTheme.toneAzure,
                            title: 'Sonido',
                            subtitle: _soundEnabled ? 'Activado' : 'Desactivado',
                            trailing: Switch(
                              value: _soundEnabled,
                              activeThumbColor: AppTheme.primaryBlue,
                              onChanged: (v) {
                                setState(() => _soundEnabled = v);
                                SoundService.setEnabled(v);
                                if (v) SoundService.playClick();
                              },
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideX(begin: 0.05, end: 0),
                          const SizedBox(height: 10),
                          // Reducir movimiento
                          ValueListenableBuilder<bool>(
                            valueListenable: MotionSettings.reduce,
                            builder: (context, reduce, _) => _settingsTile(
                              icon: Icons.slow_motion_video_rounded,
                              iconColor: AppTheme.primaryBlue,
                              title: 'Reducir movimiento',
                              subtitle: reduce ? 'Sin confeti ni animaciones llamativas' : 'Animaciones activadas',
                              trailing: Switch(
                                value: reduce,
                                activeThumbColor: AppTheme.primaryBlue,
                                onChanged: (v) => MotionSettings.setReduce(v),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Meta diaria
                          _buildGoalPicker(),
                          const SizedBox(height: 10),
                          // Edit robot
                          _settingsTile(
                            icon: Icons.smart_toy,
                            iconColor: AppTheme.toneIndigo,
                            title: 'Editar Robot',
                            subtitle: 'Personaliza tu compañero',
                            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                            onTap: () {
                              Navigator.push(context, AppTheme.smoothRoute(const RobotSkinEditorScreen()));
                            },
                          ),
                          const SizedBox(height: 10),
                          // Licenses
                          _settingsTile(
                            icon: Icons.description,
                            iconColor: const Color(0xFF1F6FEB),
                            title: 'Licencias',
                            subtitle: 'Software de código abierto',
                            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                            onTap: () {
                              showLicensePage(
                                context: context,
                                applicationName: 'Wokov',
                                applicationVersion: '1.0.0',
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          // App version
                          _settingsTile(
                            icon: Icons.info_outline,
                            iconColor: AppTheme.toneNavy,
                            title: 'Versión',
                            subtitle: 'Wokov v1.0.0',
                          ),
                          const SizedBox(height: 24),
                          // Logout
                          GestureDetector(
                            onTap: () => setState(() => _showLogoutConfirm = true),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout, color: AppTheme.accentRed, size: 18),
                                  SizedBox(width: 8),
                                  Text('Cerrar Sesión',
                                      style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.accentRed)),
                                ],
                              ),
                            ),
                          ),
                          if (_showLogoutConfirm) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => setState(() => _showLogoutConfirm = false),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.bgSecondary,
                                      foregroundColor: AppTheme.textPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      auth.logout();
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentRed,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          if (profile?.robotConfig != null)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.bgTertiary,
                border: Border.all(color: AppTheme.primaryBlue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RobotMiniWidget(config: profile?.robotConfig, size: 48),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.smart_toy, size: 28)),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.username ?? 'Explorador',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  profile?.email ?? '',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('⭐ ${profile?.totalPoints ?? 0} XP',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFFFC800))),
                    const SizedBox(width: 12),
                    Text('📚 ${profile?.modulesCompleted ?? 0} módulos',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: AppTheme.primaryBlue),
              SizedBox(width: 10),
              Text('Meta diaria',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('¿Cuánta XP quieres ganar cada día?',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          ValueListenableBuilder<int>(
            valueListenable: DailyGoalService.goalXp,
            builder: (context, goal, _) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DailyGoalService.goalOptions.map((xp) {
                final sel = xp == goal;
                final label = xp <= 20 ? 'Relajada' : (xp <= 30 ? 'Normal' : (xp <= 50 ? 'Seria' : 'Intensa'));
                return GestureDetector(
                  onTap: () {
                    SoundService.playClick();
                    DailyGoalService.setGoal(xp);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.iceBlue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: sel ? AppTheme.primaryBlue : AppTheme.borderColor, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$xp XP',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: sel ? AppTheme.primaryBlue : AppTheme.textPrimary)),
                        Text(label,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
