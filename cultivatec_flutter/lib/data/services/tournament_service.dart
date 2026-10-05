import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cultivatec_flutter/data/models/tournament_models.dart';
import 'package:cultivatec_flutter/data/static/tournament_questions.dart';
import 'package:cultivatec_flutter/screens/learning/quiz_screen.dart';

/// Backend for online tournaments — weekly leagues live in Firestore under
/// `leagues/{weekKey}_{category}/entries/{uid}`.
class TournamentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String leagueId(String categoryId, [String? week]) => '${week ?? currentWeekKey()}_$categoryId';

  CollectionReference<Map<String, dynamic>> _entries(String categoryId) =>
      _db.collection('leagues').doc(leagueId(categoryId)).collection('entries');

  /// Submits a league result, keeping only the player's best score of the week.
  Future<void> submitLeagueScore({
    required String categoryId,
    required String uid,
    required String username,
    required int score,
    required int correct,
    required int total,
    required int timeMs,
  }) async {
    final ref = _entries(categoryId).doc(uid);
    final existing = await ref.get();
    if (existing.exists) {
      final prevScore = (existing.data()?['score'] ?? 0) as int;
      final prevTime = (existing.data()?['bestTimeMs'] ?? 1 << 30) as int;
      // Keep the better result (higher score, then faster time).
      if (prevScore > score || (prevScore == score && prevTime <= timeMs)) return;
    }
    await ref.set(LeagueEntry(
      uid: uid,
      username: username,
      score: score,
      correct: correct,
      total: total,
      bestTimeMs: timeMs,
    ).toMap());
  }

  /// Live leaderboard for a category this week (sorted by score, then time).
  Stream<List<LeagueEntry>> topEntries(String categoryId, {int limit = 50}) {
    return _entries(categoryId).orderBy('score', descending: true).limit(limit).snapshots().map((snap) {
      final list = snap.docs.map((d) => LeagueEntry.fromMap(d.id, d.data())).toList();
      // Tie-break by time client-side to avoid needing a composite index.
      list.sort((a, b) {
        if (b.score != a.score) return b.score - a.score;
        return a.bestTimeMs - b.bestTimeMs;
      });
      return list;
    });
  }

  // ---- Friend duels (Phase 2) ----------------------------------------------

  /// Creates a duel after the challenger has played (their score is known).
  Future<void> createDuel({
    required String challengerUid,
    required String challengerName,
    required String opponentUid,
    required String opponentName,
    required String categoryId,
    required int challengerScore,
  }) async {
    await _db.collection('duels').add({
      'challengerUid': challengerUid,
      'challengerName': challengerName,
      'opponentUid': opponentUid,
      'opponentName': opponentName,
      'categoryId': categoryId,
      'challengerScore': challengerScore,
      'opponentScore': null,
      'status': 'pending',
      'players': [challengerUid, opponentUid],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// The opponent submits their score, completing the duel.
  Future<void> submitDuelResult({required String duelId, required int opponentScore}) async {
    await _db.collection('duels').doc(duelId).update({
      'opponentScore': opponentScore,
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// All duels the user takes part in (as challenger or opponent).
  Stream<List<Duel>> myDuels(String uid) {
    return _db.collection('duels').where('players', arrayContains: uid).snapshots().map((snap) {
      final list = snap.docs.map((d) => Duel.fromMap(d.id, d.data())).toList();
      // Newest-ish first: pending (your turn) naturally surfaced in the UI.
      return list;
    });
  }

  /// Loads a category's questions from Firestore (`questionBank/{cat}/items`),
  /// falling back to the bundled seed bank when none exist yet.
  Future<List<QuizQuestionData>> loadCategoryQuestions(String categoryId) async {
    try {
      final snap = await _db.collection('questionBank').doc(categoryId).collection('items').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) {
          final m = d.data();
          return QuizQuestionData(
            id: d.id,
            question: m['question'] ?? '',
            options: List<String>.from(m['options'] ?? const []),
            correct: m['correct'] ?? 0,
            explanation: m['explanation'] ?? '',
          );
        }).toList();
      }
    } catch (_) {
      // Offline or rules not deployed yet — use local seed.
    }
    return categoryById(categoryId).questions;
  }
}
