import 'package:cultivatec_flutter/core/widgets/wokov_states.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/data/services/firestore_service.dart';
import 'package:cultivatec_flutter/data/models/level_system.dart';
import 'package:cultivatec_flutter/data/models/robot_config.dart';
import 'package:cultivatec_flutter/core/widgets/robot_avatar.dart';

class FriendsScreen extends StatefulWidget {
  final bool embedded;
  const FriendsScreen({super.key, this.embedded = false});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _searchCtrl = TextEditingController();

  int _tab = 0; // 0=friends, 1=requests, 2=search
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  Map<String, dynamic>? _searchResult;
  bool _searching = false;
  String? _searchError;
  StreamSubscription? _friendsSub;
  StreamSubscription? _requestsSub;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _friendsSub = _firestore.onFriendsChange(uid).listen((list) {
        if (mounted) setState(() => _friends = list);
      });
      _requestsSub = _firestore.onPendingRequestsChange(uid).listen((list) {
        if (mounted) setState(() => _requests = list);
      });
    }
  }

  @override
  void dispose() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _searchResult = null;
      _searchError = null;
    });
    try {
      final result = await _firestore.searchUserByUsername(query);
      if (result != null) {
        setState(
            () => _searchResult = {'uid': result.uid, 'username': result.username, 'totalPoints': result.totalPoints});
      } else {
        setState(() => _searchError = 'Usuario no encontrado');
      }
    } catch (e) {
      setState(() => _searchError = 'Error al buscar');
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _sendRequest(String toUid) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final myProfile = await _firestore.getUserProfile(uid);
      final toProfile = await _firestore.getUserProfile(toUid);
      await _firestore.sendFriendRequest(
        fromUid: uid,
        fromUsername: myProfile?.username ?? '',
        toUid: toUid,
        toUsername: toProfile?.username ?? '',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Solicitud enviada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _acceptRequest(String requestId, String fromUid) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final fromProfile = await _firestore.getUserProfile(fromUid);
    final myProfile = await _firestore.getUserProfile(uid);
    await _firestore.acceptFriendRequest(
      requestId: requestId,
      fromUid: fromUid,
      toUid: uid,
      fromUsername: fromProfile?.username ?? '',
      toUsername: myProfile?.username ?? '',
    );
  }

  Future<void> _rejectRequest(String requestId) async {
    await _firestore.rejectFriendRequest(requestId);
  }

  Future<void> _removeFriend(String friendUid) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore.removeFriend(uid, friendUid);
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
            Expanded(child: _buildContent()),
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
          const Text('👥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Amigos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          ),
          if (_requests.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_requests.length}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
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
          _tabBtn(0, Icons.people, 'Amigos (${_friends.length})'),
          const SizedBox(width: 8),
          _tabBtn(1, Icons.notifications, 'Solicitudes'),
          const SizedBox(width: 8),
          _tabBtn(2, Icons.search, 'Buscar'),
        ],
      ),
    );
  }

  Widget _tabBtn(int idx, IconData icon, String label) {
    final active = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? AppTheme.primaryBlue : AppTheme.borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? AppTheme.primaryBlue : AppTheme.textMuted),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: active ? AppTheme.primaryBlue : AppTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_tab) {
      case 0:
        return _buildFriendsList();
      case 1:
        return _buildRequests();
      case 2:
        return _buildSearch();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const WokovEmptyState(
        pose: WokovPose.sad,
        title: 'No tienes amigos aún',
        message: '¡Busca a tus compañeros por su nombre de inventor y envíales una solicitud!',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, idx) {
        final friend = _friends[idx];
        final config =
            friend['robotConfig'] is Map<String, dynamic> ? RobotConfig.fromMap(friend['robotConfig']) : null;
        final lv = calculateLevel(friend['totalPoints'] ?? 0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              if (config != null)
                RobotMiniWidget(config: config, size: 40)
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Icon(Icons.smart_toy, size: 20)),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend['username'] ?? 'Anónimo',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${lv.icon} Nv.${lv.level} • ⭐ ${friend['totalPoints'] ?? 0} XP',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _confirmRemove(friend['uid']),
                child: const Icon(Icons.person_remove, color: AppTheme.textMuted, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRemove(String friendUid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        title: const Text('¿Eliminar amigo?', style: TextStyle(color: AppTheme.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeFriend(friendUid);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequests() {
    if (_requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📭', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Sin solicitudes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, idx) {
        final req = _requests[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Icon(Icons.person, size: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  req['fromUsername'] ?? 'Usuario',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: () => _acceptRequest(req['id'], req['from']),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check, color: AppTheme.accentGreen, size: 18),
                ),
              ),
              GestureDetector(
                onTap: () => _rejectRequest(req['id']),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, color: AppTheme.accentRed, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre de usuario...',
                      hintStyle: TextStyle(color: AppTheme.textHint),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _searchUser(),
                  ),
                ),
                GestureDetector(
                  onTap: _searchUser,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_searching)
            const Padding(
              padding: EdgeInsets.all(24),
              child: WokovLoading(message: 'Buscando…'),
            ),
          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(_searchError!, style: const TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            ),
          if (_searchResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Icon(Icons.smart_toy, size: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _searchResult!['username'] ?? '',
                          style:
                              const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                        ),
                        Text(
                          '⭐ ${_searchResult!['totalPoints'] ?? 0} XP',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _sendRequest(_searchResult!['uid']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Agregar',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
