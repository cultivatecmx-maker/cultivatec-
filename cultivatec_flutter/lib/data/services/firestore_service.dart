import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cultivatec_flutter/data/models/user_profile.dart';
import 'package:cultivatec_flutter/data/models/level_system.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================================================================
  // USER PROFILES
  // ================================================================

  /// Create user profile + reserve username.
  Future<void> createUserProfile({
    required String uid,
    required String username,
    required String fullName,
    required String email,
    Map<String, dynamic>? robotConfig,
    String robotName = '',
  }) async {
    final batch = _db.batch();

    // Reserve username. Email is stored here too so username-based login can
    // resolve the email without a pre-auth read of the (protected) users doc.
    final usernameRef = _db.collection('usernames').doc(username.toLowerCase());
    batch.set(usernameRef, {'uid': uid, 'email': email, 'createdAt': FieldValue.serverTimestamp()});

    // Create main profile
    final userRef = _db.collection('users').doc(uid);
    batch.set(userRef, {
      'username': username,
      'usernameLower': username.toLowerCase(),
      'fullName': fullName.isEmpty ? username : fullName,
      'email': email,
      'robotConfig': robotConfig,
      'robotName': robotName.isEmpty ? 'Mi Robot' : robotName,
      'level': 1,
      'levelTitle': 'Principiante',
      'totalPoints': 0,
      'modulesCompleted': 0,
      'quizzesCompleted': 0,
      'challengesCompleted': 0,
      'perfectQuizzes': 0,
      'maxStreak': 0,
      'currentStreak': 0,
      'lastLoginDate': null,
      'achievementsUnlocked': [],
      'friendsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });

    // Create scores doc
    final scoresRef = _db.collection('userScores').doc(uid);
    batch.set(scoresRef, {});

    await batch.commit();
  }

  /// Check if username is available.
  Future<bool> checkUsernameAvailable(String username) async {
    final snap = await _db.collection('usernames').doc(username.toLowerCase()).get();
    return !snap.exists;
  }

  /// Get email by username (for username-based login). Reads the email from the
  /// public `usernames` doc so it works before authentication.
  Future<String?> getEmailByUsername(String username) async {
    final usernameSnap = await _db.collection('usernames').doc(username.toLowerCase()).get();
    if (!usernameSnap.exists) return null;
    final data = usernameSnap.data()!;
    final email = data['email'] as String?;
    if (email != null) return email;
    // Legacy fallback (docs created before email was stored here).
    final uid = data['uid'] as String?;
    if (uid == null) return null;
    final userSnap = await _db.collection('users').doc(uid).get();
    return userSnap.exists ? userSnap.data()!['email'] as String? : null;
  }

  /// Unlock an achievement for a user (idempotent via arrayUnion).
  Future<void> unlockAchievement(String uid, String achievementId) async {
    await _db.collection('users').doc(uid).update({
      'achievementsUnlocked': FieldValue.arrayUnion([achievementId]),
    });
  }

  /// Get user profile.
  Future<UserProfile?> getUserProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(uid, snap.data()!);
  }

  /// Listen to user profile changes in real time.
  Stream<UserProfile?> onUserProfileChange(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set({
      ...data,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check and update daily streak.
  Future<({int streak, bool isNewDay})> checkAndUpdateStreak(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return (streak: 0, isNewDay: false);

    final data = snap.data()!;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (data['lastLoginDate'] == todayStr) {
      return (streak: (data['currentStreak'] ?? 0) as int, isNewDay: false);
    }

    int newStreak = 1;
    if (data['lastLoginDate'] != null) {
      final lastDate = DateTime.tryParse('${data['lastLoginDate']}T00:00:00');
      if (lastDate != null) {
        final today = DateTime.parse('${todayStr}T00:00:00');
        final diffDays = today.difference(lastDate).inDays;
        if (diffDays == 1) {
          newStreak = ((data['currentStreak'] ?? 0) as int) + 1;
        }
      }
    }

    final newMax = newStreak > ((data['maxStreak'] ?? 0) as int) ? newStreak : (data['maxStreak'] ?? 0) as int;

    await _db.collection('users').doc(uid).update({
      'currentStreak': newStreak,
      'lastLoginDate': todayStr,
      'maxStreak': newMax,
      'lastActive': FieldValue.serverTimestamp(),
    });

    return (streak: newStreak, isNewDay: true);
  }

  // ================================================================
  // SCORES & PROGRESS
  // ================================================================

  /// Save module score. Uses set+merge so it works even if the userScores
  /// document doesn't exist yet (otherwise progress is lost and the next
  /// level never unlocks).
  Future<void> saveModuleScore(String uid, String moduleId, Map<String, dynamic> scoreData) async {
    await _db.collection('userScores').doc(uid).set({
      moduleId: scoreData,
    }, SetOptions(merge: true));
  }

  /// Listen to user scores.
  Stream<Map<String, dynamic>> onUserScoresChange(String uid) {
    return _db.collection('userScores').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return {};
      return snap.data() ?? {};
    });
  }

  /// Sync user stats with transaction (atomic).
  Future<void> syncUserStats(String uid, Map<String, dynamic> statsUpdate) async {
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(userRef);
      final currentData = snap.exists ? snap.data()! : {};

      final updateData = <String, dynamic>{
        'lastActive': FieldValue.serverTimestamp(),
      };

      if (statsUpdate['addPoints'] != null) {
        final currentPoints = (currentData['totalPoints'] ?? 0) as int;
        final newTotal = currentPoints + (statsUpdate['addPoints'] as int);
        updateData['totalPoints'] = newTotal;

        final lv = calculateLevel(newTotal);
        updateData['level'] = lv.level;
        updateData['levelTitle'] = lv.title;
      }

      if (statsUpdate['addModulesCompleted'] != null) {
        updateData['modulesCompleted'] =
            ((currentData['modulesCompleted'] ?? 0) as int) + (statsUpdate['addModulesCompleted'] as int);
      }
      if (statsUpdate['addQuizzesCompleted'] != null) {
        updateData['quizzesCompleted'] =
            ((currentData['quizzesCompleted'] ?? 0) as int) + (statsUpdate['addQuizzesCompleted'] as int);
      }
      if (statsUpdate['addChallengesCompleted'] != null) {
        updateData['challengesCompleted'] =
            ((currentData['challengesCompleted'] ?? 0) as int) + (statsUpdate['addChallengesCompleted'] as int);
      }
      if (statsUpdate['addPerfectQuizzes'] != null) {
        updateData['perfectQuizzes'] =
            ((currentData['perfectQuizzes'] ?? 0) as int) + (statsUpdate['addPerfectQuizzes'] as int);
      }

      if (statsUpdate['achievementId'] != null) {
        updateData['achievementsUnlocked'] = FieldValue.arrayUnion([statsUpdate['achievementId']]);
      }

      transaction.update(userRef, updateData);
    });
  }

  // ================================================================
  // RANKING
  // ================================================================

  /// Get global ranking (top N).
  Future<List<Map<String, dynamic>>> getGlobalRanking({int limit = 50}) async {
    final snap = await _db.collection('users').orderBy('totalPoints', descending: true).limit(limit).get();
    return snap.docs.asMap().entries.map((e) {
      final data = e.value.data();
      return <String, dynamic>{'uid': e.value.id, 'rank': e.key + 1, ...data};
    }).toList();
  }

  /// Listen to ranking in real time.
  Stream<List<Map<String, dynamic>>> onRankingChange({int limit = 50}) {
    return _db.collection('users').orderBy('totalPoints', descending: true).limit(limit).snapshots().map((snap) {
      return snap.docs.asMap().entries.map((e) {
        final data = e.value.data();
        return <String, dynamic>{'uid': e.value.id, 'rank': e.key + 1, ...data};
      }).toList();
    });
  }

  // ================================================================
  // FRIENDS SYSTEM
  // ================================================================

  /// Search user by username.
  Future<UserProfile?> searchUserByUsername(String username) async {
    final snap = await _db.collection('users').where('usernameLower', isEqualTo: username.toLowerCase()).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return UserProfile.fromMap(doc.id, doc.data());
  }

  /// Send friend request.
  Future<void> sendFriendRequest({
    required String fromUid,
    required String fromUsername,
    required String toUid,
    required String toUsername,
  }) async {
    // Check if request already exists
    final existing = await _db
        .collection('friendRequests')
        .where('fromUid', isEqualTo: fromUid)
        .where('toUid', isEqualTo: toUid)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Ya enviaste una solicitud a este usuario.');
    }

    // Check if already friends
    final friendSnap = await _db.collection('friends').doc(fromUid).collection('list').doc(toUid).get();
    if (friendSnap.exists) {
      throw Exception('Ya son amigos.');
    }

    await _db.collection('friendRequests').add({
      'fromUid': fromUid,
      'fromUsername': fromUsername,
      'toUid': toUid,
      'toUsername': toUsername,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get pending friend requests.
  Stream<List<Map<String, dynamic>>> onPendingRequestsChange(String uid) {
    return _db
        .collection('friendRequests')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Accept friend request.
  Future<void> acceptFriendRequest({
    required String requestId,
    required String fromUid,
    required String toUid,
    required String fromUsername,
    required String toUsername,
  }) async {
    final batch = _db.batch();

    batch.update(
      _db.collection('friendRequests').doc(requestId),
      {'status': 'accepted'},
    );

    batch.set(
      _db.collection('friends').doc(fromUid).collection('list').doc(toUid),
      {'username': toUsername, 'since': FieldValue.serverTimestamp()},
    );

    batch.set(
      _db.collection('friends').doc(toUid).collection('list').doc(fromUid),
      {'username': fromUsername, 'since': FieldValue.serverTimestamp()},
    );

    batch.update(
      _db.collection('users').doc(toUid),
      {'friendsCount': FieldValue.increment(1)},
    );

    await batch.commit();

    try {
      await _db.collection('users').doc(fromUid).update({
        'friendsCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  /// Reject friend request.
  Future<void> rejectFriendRequest(String requestId) async {
    await _db.collection('friendRequests').doc(requestId).update({'status': 'rejected'});
  }

  /// Get friends list with profiles.
  Future<List<UserProfile>> getFriendsList(String uid) async {
    final friendsSnap = await _db.collection('friends').doc(uid).collection('list').get();
    if (friendsSnap.docs.isEmpty) return [];

    final friends = <UserProfile>[];
    for (final doc in friendsSnap.docs) {
      final profile = await getUserProfile(doc.id);
      if (profile != null) {
        friends.add(profile);
      }
    }
    friends.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return friends;
  }

  /// Listen to friends list.
  Stream<List<Map<String, dynamic>>> onFriendsChange(String uid) {
    return _db.collection('friends').doc(uid).collection('list').snapshots().asyncMap((snap) async {
      final friends = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final profile = await getUserProfile(doc.id);
        if (profile != null) {
          friends.add({
            'uid': doc.id,
            'username': profile.username,
            'level': profile.level,
            'totalPoints': profile.totalPoints,
            'robotConfig': profile.robotConfig?.toMap(),
          });
        }
      }
      friends.sort((a, b) => ((b['totalPoints'] ?? 0) as int).compareTo((a['totalPoints'] ?? 0) as int));
      return friends;
    });
  }

  /// Remove friend.
  Future<void> removeFriend(String uid, String friendUid) async {
    final batch = _db.batch();
    batch.delete(_db.collection('friends').doc(uid).collection('list').doc(friendUid));
    batch.delete(_db.collection('friends').doc(friendUid).collection('list').doc(uid));
    batch.update(
      _db.collection('users').doc(uid),
      {'friendsCount': FieldValue.increment(-1)},
    );
    await batch.commit();

    try {
      await _db.collection('users').doc(friendUid).update({
        'friendsCount': FieldValue.increment(-1),
      });
    } catch (_) {}
  }

  /// Sync friends count.
  Future<void> syncFriendsCount(String uid) async {
    final friendsSnap = await _db.collection('friends').doc(uid).collection('list').get();
    final realCount = friendsSnap.docs.length;
    final userSnap = await _db.collection('users').doc(uid).get();
    if (userSnap.exists && (userSnap.data()!['friendsCount'] ?? 0) != realCount) {
      await _db.collection('users').doc(uid).update({'friendsCount': realCount});
    }
  }

  /// Check if email is admin.
  bool isAdminEmail(String? email) {
    if (email == null) return false;
    const adminEmails = ['admin@cultivatec.com']; // Configure as needed
    return adminEmails.contains(email.toLowerCase());
  }
}
