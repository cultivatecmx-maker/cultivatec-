import 'package:flutter/material.dart';

class LevelInfo {
  final int level;
  final String title;
  final IconData icon;
  final int maxLevel;
  final int currentXp;
  final int levelXp;
  final int nextLevelXp;
  final int xpInLevel;
  final int xpNeeded;
  final double progress;
  final bool isMaxLevel;

  const LevelInfo({
    required this.level,
    required this.title,
    required this.icon,
    required this.maxLevel,
    required this.currentXp,
    required this.levelXp,
    required this.nextLevelXp,
    required this.xpInLevel,
    required this.xpNeeded,
    required this.progress,
    required this.isMaxLevel,
  });
}

class LevelThreshold {
  final int level;
  final int xp;
  final String title;
  final IconData icon;

  const LevelThreshold({
    required this.level,
    required this.xp,
    required this.title,
    required this.icon,
  });
}

const List<LevelThreshold> levelThresholds = [
  LevelThreshold(level: 1, xp: 0, title: 'Cadete Espacial', icon: Icons.rocket_launch),
  LevelThreshold(level: 2, xp: 30, title: 'Aprendiz Novato', icon: Icons.grass),
  LevelThreshold(level: 3, xp: 80, title: 'Explorador Curioso', icon: Icons.star),
  LevelThreshold(level: 4, xp: 160, title: 'Técnico Básico', icon: Icons.build),
  LevelThreshold(level: 5, xp: 280, title: 'Constructor Inicial', icon: Icons.construction),
  LevelThreshold(level: 6, xp: 450, title: 'Ingeniero Junior', icon: Icons.settings),
  LevelThreshold(level: 7, xp: 680, title: 'Programador Espacial', icon: Icons.star),
  LevelThreshold(level: 8, xp: 980, title: 'Inventor Avanzado', icon: Icons.star),
  LevelThreshold(level: 9, xp: 1350, title: 'Científico Digital', icon: Icons.science),
  LevelThreshold(level: 10, xp: 1800, title: 'Maestro Robótico', icon: Icons.smart_toy),
  LevelThreshold(level: 11, xp: 2400, title: 'Estratega Técnico', icon: Icons.track_changes),
  LevelThreshold(level: 12, xp: 3150, title: 'Comandante de Circuitos', icon: Icons.bolt),
  LevelThreshold(level: 13, xp: 4100, title: 'Arquitecto de Sistemas', icon: Icons.star),
  LevelThreshold(level: 14, xp: 5300, title: 'Capitán Estelar', icon: Icons.security),
  LevelThreshold(level: 15, xp: 6800, title: 'Élite Robótica', icon: Icons.star),
  LevelThreshold(level: 16, xp: 8700, title: 'Visionario Tecnológico', icon: Icons.visibility),
  LevelThreshold(level: 17, xp: 11000, title: 'Almirante Espacial', icon: Icons.star_border),
  LevelThreshold(level: 18, xp: 14000, title: 'Genio Cuántico', icon: Icons.psychology),
  LevelThreshold(level: 19, xp: 17500, title: 'Leyenda Robótica', icon: Icons.emoji_events),
  LevelThreshold(level: 20, xp: 22000, title: 'Maestro Galáctico', icon: Icons.star),
  LevelThreshold(level: 21, xp: 28000, title: 'Oráculo Cibernético', icon: Icons.star),
  LevelThreshold(level: 22, xp: 35000, title: 'Titán Tecnológico', icon: Icons.star),
  LevelThreshold(level: 23, xp: 44000, title: 'Emperador Estelar', icon: Icons.workspace_premium),
  LevelThreshold(level: 24, xp: 55000, title: 'Trascendente Cósmico', icon: Icons.star),
  LevelThreshold(level: 25, xp: 70000, title: 'Omnisciente Galáctico', icon: Icons.star),
];

LevelInfo calculateLevel(int totalPoints) {
  LevelThreshold current = levelThresholds.first;
  for (int i = levelThresholds.length - 1; i >= 0; i--) {
    if (totalPoints >= levelThresholds[i].xp) {
      current = levelThresholds[i];
      break;
    }
  }

  final nextIdx = levelThresholds.indexWhere((t) => t.level == current.level + 1);
  final next = nextIdx >= 0 ? levelThresholds[nextIdx] : null;
  final prevXp = current.xp;
  final nextXp = next?.xp ?? current.xp;
  final xpInLevel = totalPoints - prevXp;
  final xpNeeded = next != null ? next.xp - prevXp : 0;
  final progress = next != null && xpNeeded > 0 ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 1.0;

  return LevelInfo(
    level: current.level,
    title: current.title,
    icon: current.icon,
    maxLevel: levelThresholds.length,
    currentXp: totalPoints,
    levelXp: prevXp,
    nextLevelXp: nextXp,
    xpInLevel: xpInLevel,
    xpNeeded: xpNeeded,
    progress: progress,
    isMaxLevel: next == null,
  );
}
