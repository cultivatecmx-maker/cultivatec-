import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cultivatec_flutter/data/models/robot_config.dart';

class UserProfile {
  final String uid;
  final String username;
  final String usernameLower;
  final String fullName;
  final String email;
  final RobotConfig? robotConfig;
  final String robotName;
  final int level;
  final String levelTitle;
  final int totalPoints;
  final int modulesCompleted;
  final int quizzesCompleted;
  final int challengesCompleted;
  final int perfectQuizzes;
  final int maxStreak;
  final int currentStreak;
  final String? lastLoginDate;
  final List<String> achievementsUnlocked;
  final List<String> unlockedSkins;
  final int friendsCount;
  final Timestamp? createdAt;
  final Timestamp? lastActive;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.usernameLower,
    required this.fullName,
    required this.email,
    this.robotConfig,
    this.robotName = 'Mi Robot',
    this.level = 1,
    this.levelTitle = 'Principiante',
    this.totalPoints = 0,
    this.modulesCompleted = 0,
    this.quizzesCompleted = 0,
    this.challengesCompleted = 0,
    this.perfectQuizzes = 0,
    this.maxStreak = 0,
    this.currentStreak = 0,
    this.lastLoginDate,
    this.achievementsUnlocked = const [],
    this.unlockedSkins = const [],
    this.friendsCount = 0,
    this.createdAt,
    this.lastActive,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      username: map['username'] ?? '',
      usernameLower: map['usernameLower'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      robotConfig:
          map['robotConfig'] != null ? RobotConfig.fromMap(Map<String, dynamic>.from(map['robotConfig'])) : null,
      robotName: map['robotName'] ?? 'Mi Robot',
      level: map['level'] ?? 1,
      levelTitle: map['levelTitle'] ?? 'Principiante',
      totalPoints: map['totalPoints'] ?? 0,
      modulesCompleted: map['modulesCompleted'] ?? 0,
      quizzesCompleted: map['quizzesCompleted'] ?? 0,
      challengesCompleted: map['challengesCompleted'] ?? 0,
      perfectQuizzes: map['perfectQuizzes'] ?? 0,
      maxStreak: map['maxStreak'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      lastLoginDate: map['lastLoginDate'],
      achievementsUnlocked: List<String>.from(map['achievementsUnlocked'] ?? []),
      unlockedSkins: List<String>.from(map['unlockedSkins'] ?? []),
      friendsCount: map['friendsCount'] ?? 0,
      createdAt: map['createdAt'] as Timestamp?,
      lastActive: map['lastActive'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'usernameLower': usernameLower,
      'fullName': fullName,
      'email': email,
      'robotConfig': robotConfig?.toMap(),
      'robotName': robotName,
      'level': level,
      'levelTitle': levelTitle,
      'totalPoints': totalPoints,
      'modulesCompleted': modulesCompleted,
      'quizzesCompleted': quizzesCompleted,
      'challengesCompleted': challengesCompleted,
      'perfectQuizzes': perfectQuizzes,
      'maxStreak': maxStreak,
      'currentStreak': currentStreak,
      'lastLoginDate': lastLoginDate,
      'achievementsUnlocked': achievementsUnlocked,
      'unlockedSkins': unlockedSkins,
      'friendsCount': friendsCount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? username,
    String? fullName,
    RobotConfig? robotConfig,
    String? robotName,
    int? level,
    String? levelTitle,
    int? totalPoints,
    int? modulesCompleted,
    int? quizzesCompleted,
    int? challengesCompleted,
    int? perfectQuizzes,
    int? maxStreak,
    int? currentStreak,
    String? lastLoginDate,
    List<String>? achievementsUnlocked,
    List<String>? unlockedSkins,
    int? friendsCount,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      usernameLower: (username ?? this.username).toLowerCase(),
      fullName: fullName ?? this.fullName,
      email: email,
      robotConfig: robotConfig ?? this.robotConfig,
      robotName: robotName ?? this.robotName,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      totalPoints: totalPoints ?? this.totalPoints,
      modulesCompleted: modulesCompleted ?? this.modulesCompleted,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      perfectQuizzes: perfectQuizzes ?? this.perfectQuizzes,
      maxStreak: maxStreak ?? this.maxStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      friendsCount: friendsCount ?? this.friendsCount,
      createdAt: createdAt,
      lastActive: lastActive,
    );
  }
}
