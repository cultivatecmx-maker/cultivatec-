import 'package:cloud_firestore/cloud_firestore.dart';

/// Returns a stable key for the current week, e.g. `2026-W25`, used to group
/// weekly-league leaderboards (they reset each week).
String currentWeekKey([DateTime? now]) {
  final d = now ?? DateTime.now();
  final firstDay = DateTime(d.year, 1, 1);
  final daysSinceStart = d.difference(firstDay).inDays;
  final week = ((daysSinceStart + firstDay.weekday - 1) / 7).floor() + 1;
  return '${d.year}-W${week.toString().padLeft(2, '0')}';
}

/// A single player's entry in a weekly league leaderboard.
class LeagueEntry {
  final String uid;
  final String username;
  final int score; // percentage 0–100
  final int correct;
  final int total;
  final int bestTimeMs;

  const LeagueEntry({
    required this.uid,
    required this.username,
    required this.score,
    required this.correct,
    required this.total,
    required this.bestTimeMs,
  });

  factory LeagueEntry.fromMap(String uid, Map<String, dynamic> map) {
    return LeagueEntry(
      uid: uid,
      username: map['username'] ?? 'Explorador',
      score: map['score'] ?? 0,
      correct: map['correct'] ?? 0,
      total: map['total'] ?? 0,
      bestTimeMs: map['bestTimeMs'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'username': username,
        'score': score,
        'correct': correct,
        'total': total,
        'bestTimeMs': bestTimeMs,
        'playedAt': FieldValue.serverTimestamp(),
      };
}

/// An async 1-vs-1 duel between friends. Both answer the same category; the
/// challenger plays first, the opponent plays when they accept.
class Duel {
  final String id;
  final String challengerUid;
  final String challengerName;
  final String opponentUid;
  final String opponentName;
  final String categoryId;
  final int? challengerScore;
  final int? opponentScore;
  final String status; // 'pending' (opponent must play) | 'completed'

  const Duel({
    required this.id,
    required this.challengerUid,
    required this.challengerName,
    required this.opponentUid,
    required this.opponentName,
    required this.categoryId,
    this.challengerScore,
    this.opponentScore,
    required this.status,
  });

  factory Duel.fromMap(String id, Map<String, dynamic> m) => Duel(
        id: id,
        challengerUid: m['challengerUid'] ?? '',
        challengerName: m['challengerName'] ?? 'Retador',
        opponentUid: m['opponentUid'] ?? '',
        opponentName: m['opponentName'] ?? 'Rival',
        categoryId: m['categoryId'] ?? 'electronica',
        challengerScore: m['challengerScore'],
        opponentScore: m['opponentScore'],
        status: m['status'] ?? 'pending',
      );

  /// Winner uid, or null if tie / not finished.
  String? get winnerUid {
    if (status != 'completed' || challengerScore == null || opponentScore == null) return null;
    if (challengerScore! > opponentScore!) return challengerUid;
    if (opponentScore! > challengerScore!) return opponentUid;
    return null; // tie
  }
}
