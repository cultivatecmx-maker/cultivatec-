import 'package:flutter/material.dart';

class ModuleData {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String color;
  final List<LessonItem> lessons;
  final String? funFact;

  const ModuleData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lessons,
    this.funFact,
  });
}

class LessonItem {
  final String type; // 'text', 'funFact', 'tip', 'challenge', 'quiz', 'diagram'
  final String? title;
  final String? body;
  final List<String>? bullets;
  final String? image;

  const LessonItem({
    required this.type,
    this.title,
    this.body,
    this.bullets,
    this.image,
  });
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correct;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correct: map['correct'] ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }
}

class QuizData {
  final String title;
  final String description;
  final List<QuizQuestion> questions;

  const QuizData({
    required this.title,
    required this.description,
    required this.questions,
  });
}

class ModuleScore {
  final int score;
  final int total;
  final double percentage;
  final DateTime completedAt;
  final int attemptCount;

  const ModuleScore({
    required this.score,
    required this.total,
    required this.percentage,
    required this.completedAt,
    required this.attemptCount,
  });

  factory ModuleScore.fromMap(Map<String, dynamic> map) {
    return ModuleScore(
      score: map['score'] ?? 0,
      total: map['total'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      attemptCount: map['attemptCount'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'total': total,
      'percentage': percentage,
      'completedAt': completedAt.toIso8601String(),
      'attemptCount': attemptCount,
    };
  }
}

class WorldConfig {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color accentColor;
  final Color accentDark;
  final List<WorldSection> sections;
  final String bgPattern;
  final String? unlockType; // null = sequential, 'friends' = friend-based
  final int unlockRequirement;
  // modules loaded dynamically

  const WorldConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.accentColor,
    required this.accentDark,
    required this.sections,
    required this.bgPattern,
    this.unlockType,
    this.unlockRequirement = 0,
  });
}

class WorldSection {
  final int startIdx;
  final String title;
  final String subtitle;
  final Color color;
  final Color colorLight;
  final IconData icon;

  const WorldSection({
    required this.startIdx,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.colorLight,
    required this.icon,
  });
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final int points;
  final String rarity;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.points,
    required this.rarity,
  });
}

const List<Achievement> allAchievements = [
  Achievement(
      id: 'first_module',
      name: 'Primer Paso',
      description: 'Completa tu primer módulo',
      icon: Icons.directions_walk,
      category: 'Aprendizaje',
      points: 10,
      rarity: 'common'),
  Achievement(
      id: 'electrician',
      name: 'Electricista Junior',
      description: 'Aprueba el Quiz de Electricidad >70%',
      icon: Icons.bolt,
      category: 'Aprendizaje',
      points: 25,
      rarity: 'rare'),
  Achievement(
      id: 'bookworm',
      name: 'Ratón de Biblioteca',
      description: 'Visita 5 módulos diferentes',
      icon: Icons.menu_book,
      category: 'Aprendizaje',
      points: 15,
      rarity: 'common'),
  Achievement(
      id: 'scholar',
      name: 'Erudito Digital',
      description: 'Completa módulos básicos (1-6)',
      icon: Icons.school,
      category: 'Aprendizaje',
      points: 50,
      rarity: 'epic'),
  Achievement(
      id: 'quiz_starter',
      name: 'Inquisitivo',
      description: 'Completa tu primer Quiz',
      icon: Icons.help_outline,
      category: 'Quiz',
      points: 10,
      rarity: 'common'),
  Achievement(
      id: 'perfect_score',
      name: 'Puntuación Perfecta',
      description: 'Obtén 100% en cualquier Quiz',
      icon: Icons.verified,
      category: 'Quiz',
      points: 50,
      rarity: 'legendary'),
  Achievement(
      id: 'quiz_streak',
      name: 'Racha Imparable',
      description: '5 preguntas correctas seguidas',
      icon: Icons.local_fire_department,
      category: 'Quiz',
      points: 30,
      rarity: 'rare'),
  Achievement(
      id: 'speed_demon',
      name: 'Rayo Veloz',
      description: 'Responde correcta en <5 segundos',
      icon: Icons.bolt,
      category: 'Quiz',
      points: 20,
      rarity: 'rare'),
  Achievement(
      id: 'first_code',
      name: 'Programador Novato',
      description: 'Ejecuta tu primer código',
      icon: Icons.laptop,
      category: 'Programación',
      points: 10,
      rarity: 'common'),
  Achievement(
      id: 'ai_coder',
      name: 'Asistido por IA',
      description: 'Genera código con el Asistente IA',
      icon: Icons.smart_toy,
      category: 'Programación',
      points: 15,
      rarity: 'common'),
  Achievement(
      id: 'bug_free',
      name: 'Libre de Bugs',
      description: '3 programas sin errores seguidos',
      icon: Icons.bug_report,
      category: 'Programación',
      points: 25,
      rarity: 'rare'),
  Achievement(
      id: 'code_master',
      name: 'Maestro del Código',
      description: 'Ejecuta 10 programas',
      icon: Icons.developer_mode,
      category: 'Programación',
      points: 30,
      rarity: 'epic'),
  Achievement(
      id: 'first_challenge',
      name: 'Primer Reto',
      description: 'Completa tu primer reto de código',
      icon: Icons.extension,
      category: 'Retos',
      points: 10,
      rarity: 'common'),
  Achievement(
      id: 'five_challenges',
      name: 'Racha de 5',
      description: 'Completa 5 retos de programación',
      icon: Icons.local_fire_department,
      category: 'Retos',
      points: 20,
      rarity: 'rare'),
  Achievement(
      id: 'twelve_challenges',
      name: 'Media Docena x2',
      description: 'Completa 12 retos (la mitad)',
      icon: Icons.bolt,
      category: 'Retos',
      points: 35,
      rarity: 'epic'),
  Achievement(
      id: 'all_challenges',
      name: 'Maestro de Retos',
      description: 'Completa los 24 retos',
      icon: Icons.emoji_events,
      category: 'Retos',
      points: 75,
      rarity: 'legendary'),
  Achievement(
      id: 'python_master',
      name: 'Pythonista',
      description: 'Completa todos los retos de Python',
      icon: Icons.pest_control,
      category: 'Retos',
      points: 30,
      rarity: 'epic'),
  Achievement(
      id: 'arduino_hero',
      name: 'Héroe Arduino',
      description: 'Completa todos los retos de Arduino',
      icon: Icons.diamond,
      category: 'Retos',
      points: 30,
      rarity: 'epic'),
  Achievement(
      id: 'beginner_done',
      name: 'Base Sólida',
      description: 'Completa todos los retos de Principiante',
      icon: Icons.grass,
      category: 'Retos',
      points: 15,
      rarity: 'rare'),
  Achievement(
      id: 'advanced_done',
      name: 'Nivel Experto',
      description: 'Completa todos los retos Avanzados',
      icon: Icons.military_tech,
      category: 'Retos',
      points: 50,
      rarity: 'legendary'),
  Achievement(
      id: 'led_builder',
      name: 'Constructor de LED',
      description: 'Completa la guía de LED',
      icon: Icons.lightbulb,
      category: 'Práctica',
      points: 20,
      rarity: 'rare'),
  Achievement(
      id: 'class_regular',
      name: 'Alumno Dedicado',
      description: 'Asiste a 10 clases',
      icon: Icons.school,
      category: 'Práctica',
      points: 30,
      rarity: 'rare'),
  Achievement(
      id: 'explorer',
      name: 'Explorador Total',
      description: 'Usa todas las secciones',
      icon: Icons.map,
      category: 'Especial',
      points: 25,
      rarity: 'rare'),
  Achievement(
      id: 'points_100',
      name: 'Centurión',
      description: 'Acumula 100 puntos',
      icon: Icons.diamond,
      category: 'Especial',
      points: 0,
      rarity: 'epic'),
  Achievement(
      id: 'tournament_first',
      name: 'Competidor',
      description: 'Juega tu primer torneo STEM',
      icon: Icons.sports_esports,
      category: 'Torneos',
      points: 15,
      rarity: 'common'),
  Achievement(
      id: 'tournament_ace',
      name: 'Imbatible',
      description: 'Obtén 100% en un torneo',
      icon: Icons.emoji_events,
      category: 'Torneos',
      points: 50,
      rarity: 'epic'),
  Achievement(
      id: 'league_top3',
      name: 'Podio Semanal',
      description: 'Llega al top 3 de una liga semanal',
      icon: Icons.workspace_premium,
      category: 'Torneos',
      points: 60,
      rarity: 'legendary'),
];
