import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';

// ═══════════════════════════════════════════════
// ROBOT SKINS DATA
// ═══════════════════════════════════════════════

class RobotSkin {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String rarity;
  final String rarityLabel;
  final Color rarityColor;
  final int challengesRequired;
  final String imagePath;

  const RobotSkin({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.rarityLabel,
    required this.rarityColor,
    this.challengesRequired = 0,
    required this.imagePath,
  });
}

const _cCommon = Color(0xFF58CC02);
const _cRare = Color(0xFF1F6FEB);
const _cEpic = Color(0xFFFF4B4B);
const _cLegendary = Color(0xFFFFC800);
const _cLegend = Color(0xFFFF6B00);
const _cAdmin = Color(0xFF9333EA);

const List<RobotSkin> robotSkins = [
  RobotSkin(
      id: 'skin_1',
      name: 'Neo-Bot',
      description: 'El inicio de tu aventura tecnológica',
      icon: Icons.explore,
      rarity: 'common',
      rarityLabel: 'Inicial',
      rarityColor: _cCommon,
      challengesRequired: 0,
      imagePath: 'assets/images/skin_1.webp'),
  RobotSkin(
      id: 'skin_6',
      name: 'Astro-Bot',
      description: 'Listo para explorar la inmensidad del espacio digital',
      icon: Icons.rocket_launch,
      rarity: 'common',
      rarityLabel: 'Común',
      rarityColor: _cCommon,
      challengesRequired: 1,
      imagePath: 'assets/images/skin_6.webp'),
  RobotSkin(
      id: 'skin_7',
      name: 'Explorador',
      description: 'Adaptado a los entornos de hardware más difíciles',
      icon: Icons.explore_off,
      rarity: 'common',
      rarityLabel: 'Común',
      rarityColor: _cCommon,
      challengesRequired: 2,
      imagePath: 'assets/images/skin_7.webp'),
  RobotSkin(
      id: 'skin_8',
      name: 'Héroe Relámpago',
      description: 'Rápido como la corriente eléctrica',
      icon: Icons.bolt,
      rarity: 'rare',
      rarityLabel: 'Raro',
      rarityColor: _cRare,
      challengesRequired: 4,
      imagePath: 'assets/images/skin_8.webp'),
  RobotSkin(
      id: 'skin_21',
      name: 'Prototipo Inicial',
      description: 'Uno de los primeros modelos de prueba',
      icon: Icons.science,
      rarity: 'rare',
      rarityLabel: 'Raro',
      rarityColor: _cRare,
      challengesRequired: 6,
      imagePath: 'assets/images/skin_21.webp'),
  RobotSkin(
      id: 'skin_3',
      name: 'Caballero Azul',
      description: 'Protegido con armadura de alta resistencia',
      icon: Icons.shield,
      rarity: 'rare',
      rarityLabel: 'Raro',
      rarityColor: _cRare,
      challengesRequired: 8,
      imagePath: 'assets/images/skin_3.webp'),
  RobotSkin(
      id: 'skin_15',
      name: 'Robot Burbuja',
      description: 'Resistente al agua y refrigeración líquida',
      icon: Icons.water_drop,
      rarity: 'rare',
      rarityLabel: 'Raro',
      rarityColor: _cRare,
      challengesRequired: 10,
      imagePath: 'assets/images/skin_15.webp'),
  RobotSkin(
      id: 'skin_10',
      name: 'Gólem de Vida',
      description: 'La naturaleza ha reclamado a este gigante de piedra',
      icon: Icons.nature_people,
      rarity: 'epic',
      rarityLabel: 'Épico',
      rarityColor: _cEpic,
      challengesRequired: 12,
      imagePath: 'assets/images/skin_10.webp'),
  RobotSkin(
      id: 'skin_5',
      name: 'Ciber-Génesis',
      description: 'Procesador cuántico visible en su pecho',
      icon: Icons.memory,
      rarity: 'epic',
      rarityLabel: 'Épico',
      rarityColor: _cEpic,
      challengesRequired: 14,
      imagePath: 'assets/images/skin_5.webp'),
  RobotSkin(
      id: 'skin_4',
      name: 'Óxido Volcánico',
      description: 'Su núcleo genera un calor insoportable',
      icon: Icons.local_fire_department,
      rarity: 'epic',
      rarityLabel: 'Épico',
      rarityColor: _cEpic,
      challengesRequired: 16,
      imagePath: 'assets/images/skin_4.webp'),
  RobotSkin(
      id: 'skin_9',
      name: 'Ciber-Núcleo',
      description: 'Hologramas de energía pura brotan de sus hombros',
      icon: Icons.hail,
      rarity: 'epic',
      rarityLabel: 'Épico',
      rarityColor: _cEpic,
      challengesRequired: 18,
      imagePath: 'assets/images/skin_9.webp'),
  RobotSkin(
      id: 'skin_11',
      name: 'Guardián Fúngico',
      description: 'Los hongos han creado una red neuronal con él',
      icon: Icons.forest,
      rarity: 'epic',
      rarityLabel: 'Épico',
      rarityColor: _cEpic,
      challengesRequired: 20,
      imagePath: 'assets/images/skin_11.webp'),
  RobotSkin(
      id: 'skin_14',
      name: 'Shinobi Digital',
      description: 'Indetectable para cualquier antivirus',
      icon: Icons.dark_mode,
      rarity: 'epic',
      rarityLabel: 'Épico',
      rarityColor: _cEpic,
      challengesRequired: 22,
      imagePath: 'assets/images/skin_14.webp'),
  RobotSkin(
      id: 'skin_16',
      name: 'Arcade-Bot',
      description: 'Guarda todos los récords de los años 80',
      icon: Icons.videogame_asset,
      rarity: 'epic',
      rarityLabel: 'Épico',
      rarityColor: _cEpic,
      challengesRequired: 24,
      imagePath: 'assets/images/skin_16.webp'),
  RobotSkin(
      id: 'skin_12',
      name: 'Espíritu del Bosque',
      description: 'Tallado en madera mágica que nunca se pudre',
      icon: Icons.park,
      rarity: 'legendary',
      rarityLabel: 'Legendario',
      rarityColor: _cLegendary,
      challengesRequired: 26,
      imagePath: 'assets/images/skin_12.webp'),
  RobotSkin(
      id: 'skin_2',
      name: 'Gólem Rúnico',
      description: 'Las runas de su cuerpo le dan energía infinita',
      icon: Icons.diamond,
      rarity: 'legendary',
      rarityLabel: 'Legendario',
      rarityColor: _cLegendary,
      challengesRequired: 28,
      imagePath: 'assets/images/skin_2.webp'),
  RobotSkin(
      id: 'skin_13',
      name: 'Ifrit Mecánico',
      description: 'Forjado en el centro de un volcán digital',
      icon: Icons.whatshot,
      rarity: 'legendary',
      rarityLabel: 'Legendario',
      rarityColor: _cLegendary,
      challengesRequired: 30,
      imagePath: 'assets/images/skin_13.webp'),
  RobotSkin(
      id: 'skin_17',
      name: 'Corsario Oxidado',
      description: 'Busca los tesoros de criptografía perdidos',
      icon: Icons.sailing,
      rarity: 'legendary',
      rarityLabel: 'Legendario',
      rarityColor: _cLegendary,
      challengesRequired: 32,
      imagePath: 'assets/images/skin_17.webp'),
  RobotSkin(
      id: 'skin_18',
      name: 'Invasor Galáctico',
      description: 'Llegó de una galaxia muy lejana',
      icon: Icons.rocket,
      rarity: 'legendary',
      rarityLabel: 'Legendario',
      rarityColor: _cLegendary,
      challengesRequired: 34,
      imagePath: 'assets/images/skin_18.webp'),
  RobotSkin(
      id: 'skin_19',
      name: 'Espíritu Acuático',
      description: 'Controla los mares de datos',
      icon: Icons.water,
      rarity: 'legend',
      rarityLabel: 'Leyenda',
      rarityColor: _cLegend,
      challengesRequired: 36,
      imagePath: 'assets/images/skin_19.webp'),
  RobotSkin(
      id: 'skin_24',
      name: 'Fénix Ancestral',
      description: 'Renace de las cenizas del conocimiento total',
      icon: Icons.local_fire_department,
      rarity: 'legend',
      rarityLabel: 'Leyenda',
      rarityColor: _cLegend,
      challengesRequired: 38,
      imagePath: 'assets/images/skin_24.webp'),
  RobotSkin(
      id: 'skin_25',
      name: 'Titán Cósmico',
      description: 'Forjado en las estrellas, domina todos los mundos',
      icon: Icons.stars,
      rarity: 'legend',
      rarityLabel: 'Leyenda',
      rarityColor: _cLegend,
      challengesRequired: 40,
      imagePath: 'assets/images/skin_25.webp'),
  RobotSkin(
      id: 'skin_26',
      name: 'Oráculo',
      description: 'Vidente digital que ha completado cada desafío',
      icon: Icons.remove_red_eye,
      rarity: 'legend',
      rarityLabel: 'Leyenda',
      rarityColor: _cLegend,
      challengesRequired: 42,
      imagePath: 'assets/images/skin_26.webp'),
  RobotSkin(
      id: 'skin_27',
      name: 'Dragón Milenario',
      description: 'Bestia mecánica legendaria para los más persistentes',
      icon: Icons.pets,
      rarity: 'legend',
      rarityLabel: 'Leyenda',
      rarityColor: _cLegend,
      challengesRequired: 44,
      imagePath: 'assets/images/skin_27.webp'),
  RobotSkin(
      id: 'skin_28',
      name: 'Espectro Supremo',
      description: 'Entidad etérea que trasciende la realidad',
      icon: Icons.blur_on,
      rarity: 'legend',
      rarityLabel: 'Leyenda',
      rarityColor: _cLegend,
      challengesRequired: 46,
      imagePath: 'assets/images/skin_28.webp'),
  RobotSkin(
      id: 'skin_29',
      name: 'Nexus Primordial',
      description: 'El origen de todo. Última skin legendaria',
      icon: Icons.diamond,
      rarity: 'legend',
      rarityLabel: 'Leyenda',
      rarityColor: _cLegend,
      challengesRequired: 50,
      imagePath: 'assets/images/skin_29.webp'),
  RobotSkin(
      id: 'skin_20',
      name: 'Cazador de Bugs',
      description: 'Solo los elegidos por el admin obtienen esta skin',
      icon: Icons.bug_report,
      rarity: 'admin',
      rarityLabel: 'Exclusivo',
      rarityColor: _cAdmin,
      challengesRequired: 999,
      imagePath: 'assets/images/skin_20.webp'),
  RobotSkin(
      id: 'skin_22',
      name: 'Prototipo X',
      description: 'Creación secreta del laboratorio, solo para los elegidos',
      icon: Icons.science_outlined,
      rarity: 'admin',
      rarityLabel: 'Exclusivo',
      rarityColor: _cAdmin,
      challengesRequired: 999,
      imagePath: 'assets/images/skin_22.webp'),
  RobotSkin(
      id: 'skin_23',
      name: 'Arcángel',
      description: 'Skin divina otorgada solo por el administrador supremo',
      icon: Icons.wb_sunny,
      rarity: 'admin',
      rarityLabel: 'Admin',
      rarityColor: _cAdmin,
      challengesRequired: 999,
      imagePath: 'assets/images/skin_23.webp'),
  RobotSkin(
      id: 'skin_30',
      name: 'Deidad Digital',
      description: 'La creación más sagrada del admin',
      icon: Icons.security,
      rarity: 'admin',
      rarityLabel: 'Admin',
      rarityColor: _cAdmin,
      challengesRequired: 999,
      imagePath: 'assets/images/skin_30.webp'),
];

String _unlockLabel(RobotSkin skin) {
  if (skin.challengesRequired == 0) return 'Siempre disponible';
  if (skin.challengesRequired >= 999) return 'Regalo exclusivo del admin';
  return 'Completa ${skin.challengesRequired} retos';
}

// ═══════════════════════════════════════════════
// ROBOT SKIN EDITOR SCREEN
// ═══════════════════════════════════════════════

class RobotSkinEditorScreen extends StatefulWidget {
  const RobotSkinEditorScreen({super.key});

  @override
  State<RobotSkinEditorScreen> createState() => _RobotSkinEditorScreenState();
}

class _RobotSkinEditorScreenState extends State<RobotSkinEditorScreen> {
  String _selectedSkinId = 'skin_1';
  String _filterRarity = 'all';
  bool _initialized = false;

  static const _rarityFilters = [
    {'key': 'all', 'label': 'Todos', 'icon': Icons.palette},
    {'key': 'common', 'label': 'Común', 'icon': Icons.circle},
    {'key': 'rare', 'label': 'Raro', 'icon': Icons.star_border},
    {'key': 'epic', 'label': 'Épico', 'icon': Icons.star},
    {'key': 'legendary', 'label': 'Legendario', 'icon': Icons.military_tech},
    {'key': 'legend', 'label': 'Leyenda', 'icon': Icons.diamond},
    {'key': 'admin', 'label': 'Exclusivo', 'icon': Icons.admin_panel_settings},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = context.read<AuthProvider>();
      final config = auth.profile?.robotConfig;
      if (config?.skinImage != null && config!.skinImage!.isNotEmpty) {
        final match = robotSkins.where((s) => s.id == config.skinImage).firstOrNull;
        if (match != null) _selectedSkinId = match.id;
      }
      _initialized = true;
    }
  }

  // Skins that the user has already played the unlock animation for
  Set<String> _getUnlockedIds() {
    final auth = context.read<AuthProvider>();
    final profile = auth.profile;
    if (auth.isAdmin) return robotSkins.map((s) => s.id).toSet();

    final unlocked = <String>{};
    // Always unlock common base skins
    for (final skin in robotSkins) {
      if (skin.challengesRequired == 0) unlocked.add(skin.id);
    }
    // Add saved unlocked skins
    if (profile != null) {
      unlocked.addAll(profile.unlockedSkins);
    }
    return unlocked;
  }

  // Skins that the user CAN unlock (meets requirements)
  Set<String> _getAvailableIds() {
    final auth = context.read<AuthProvider>();
    final profile = auth.profile;
    if (auth.isAdmin) return robotSkins.map((s) => s.id).toSet();

    final challenges = profile?.challengesCompleted ?? 0;
    final available = <String>{};
    for (final skin in robotSkins) {
      if (skin.challengesRequired <= challenges) available.add(skin.id);
    }
    return available;
  }

  RobotSkin get _selectedSkin => robotSkins.firstWhere((s) => s.id == _selectedSkinId, orElse: () => robotSkins[0]);

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    await auth.updateProfile({
      'robotConfig': {
        ...?auth.profile?.robotConfig?.toMap(),
        'skinImage': _selectedSkinId,
      },
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final unlockedIds = _getUnlockedIds();
    final availableIds = _getAvailableIds();
    final filteredSkins =
        _filterRarity == 'all' ? robotSkins : robotSkins.where((s) => s.rarity == _filterRarity).toList();

    final isSelectedAvailable = availableIds.contains(_selectedSkinId);
    final isSelectedUnlocked = unlockedIds.contains(_selectedSkinId);

    return Scaffold(
      body: Container(
        color: AppTheme.bgPrimary,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(unlockedIds.length),
              _buildPreview(availableIds, unlockedIds),
              const SizedBox(height: 8),
              _buildRarityTabs(),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredSkins.length,
                  itemBuilder: (context, idx) {
                    final skin = filteredSkins[idx];
                    final isAvailable = availableIds.contains(skin.id);
                    final isUnlockedLocally = unlockedIds.contains(skin.id);
                    final isSelected = _selectedSkinId == skin.id;
                    return _skinCard(skin, isAvailable, isUnlockedLocally, isSelected)
                        .animate()
                        .fadeIn(delay: (30 + idx * 40).ms, duration: 300.ms)
                        .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1), curve: Curves.easeOutCubic);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSelectedAvailable
                        ? (isSelectedUnlocked ? _save : () => _showUnlockAnimation(context, _selectedSkin))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelectedUnlocked
                          ? AppTheme.primaryBlue
                          : (isSelectedAvailable ? AppTheme.accentGreen : AppTheme.bgSecondary),
                      disabledBackgroundColor: AppTheme.bgSecondary,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppTheme.textHint,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelectedAvailable && !isSelectedUnlocked) ...[
                          const Icon(Icons.auto_awesome, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          isSelectedAvailable
                              ? (isSelectedUnlocked ? 'Equipar Skin' : '¡Desbloquear Skin!')
                              : 'Bloqueado',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int unlockedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
            ),
          ),
          const Icon(Icons.build_circle, size: 24, color: AppTheme.textPrimary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Garage del Robot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$unlockedCount/${robotSkins.length}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.accentGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(Set<String> availableIds, Set<String> unlockedIds) {
    final skin = _selectedSkin;
    final isAvailable = availableIds.contains(skin.id);
    final isUnlocked = unlockedIds.contains(skin.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: skin.rarityColor.withValues(alpha: 0.3), width: 2),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: skin.rarityColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: skin.rarityColor.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isAvailable
                  ? Image.asset(
                      skin.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(child: Icon(skin.icon, size: 48, color: skin.rarityColor)),
                    )
                  : ColorFiltered(
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                      child: Opacity(
                        opacity: 0.5,
                        child: Image.asset(
                          skin.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(child: Icon(skin.icon, size: 42, color: Colors.grey)),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(skin.name,
                          style:
                              const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: skin.rarityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(skin.rarityLabel,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: skin.rarityColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(skin.description,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3)),
                const SizedBox(height: 6),
                if (!isAvailable)
                  Row(children: [
                    const Icon(Icons.lock, size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(_unlockLabel(skin),
                            style:
                                const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textMuted))),
                  ])
                else if (!isUnlocked)
                  Row(children: [
                    Icon(Icons.stars, size: 12, color: skin.rarityColor),
                    const SizedBox(width: 4),
                    Text('¡Listo para desbloquear!',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: skin.rarityColor)),
                  ])
                else
                  const Row(children: [
                    Icon(Icons.check_circle, size: 12, color: AppTheme.accentGreen),
                    SizedBox(width: 4),
                    Text('Desbloqueado',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentGreen)),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _rarityFilters.length,
        itemBuilder: (context, idx) {
          final filter = _rarityFilters[idx];
          final isActive = _filterRarity == filter['key'];
          return GestureDetector(
            onTap: () => setState(() => _filterRarity = filter['key'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? AppTheme.primaryBlue : AppTheme.borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter['icon']! as IconData,
                      size: 16, color: isActive ? AppTheme.primaryBlue : AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(filter['label']! as String,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isActive ? AppTheme.primaryBlue : AppTheme.textMuted)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _skinCard(RobotSkin skin, bool isAvailable, bool isUnlockedLocally, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSkinId = skin.id),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? skin.rarityColor.withValues(alpha: 0.08) : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? skin.rarityColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Color.lerp(skin.rarityColor, Colors.black, 0.28)!, blurRadius: 0, offset: const Offset(0, 5))]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: skin.rarityColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      skin.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(skin.icon, size: 32, color: isAvailable ? skin.rarityColor : Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(skin.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isAvailable ? AppTheme.textPrimary : AppTheme.textHint)),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: skin.rarityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(skin.rarityLabel,
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: skin.rarityColor)),
                ),
                const Spacer(),
              ],
            ),
            if (!isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(child: Icon(Icons.lock, color: AppTheme.textMuted, size: 20)),
                ),
              ),
            if (isAvailable && !isUnlockedLocally)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: skin.rarityColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5)),
                  child: const Icon(Icons.priority_high, color: Colors.white, size: 10),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.1, 1.1),
                        duration: 800.ms,
                        curve: Curves.easeInOut)
                    .then()
                    .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.8, 0.8), duration: 800.ms),
              ),
            if (isSelected && isUnlockedLocally)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: skin.rarityColor, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUnlockAnimation(BuildContext context, RobotSkin skin) async {
    final auth = context.read<AuthProvider>();

    // Play sound if possible, show dialog
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Spinning light rays
              Center(
                child: Animate(
                  onPlay: (c) => c.repeat(),
                  effects: const [RotateEffect(duration: Duration(seconds: 10))],
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          skin.rarityColor.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.8],
                      ),
                    ),
                  ),
                ),
              ),
              // Skin details
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '¡NUEVA SKIN DESBLOQUEADA!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: skin.rarityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: skin.rarityColor),
                      ),
                      child: Text(
                        skin.rarityLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: skin.rarityColor,
                          letterSpacing: 2,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut),
                    const SizedBox(height: 40),
                    // Image
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: skin.rarityColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: skin.rarityColor.withValues(alpha: 0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(skin.imagePath, fit: BoxFit.contain),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                            duration: 800.ms)
                        .then()
                        .shimmer(duration: 1.seconds, color: Colors.white),
                    const SizedBox(height: 30),
                    Text(
                      skin.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5, end: 0),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        skin.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ).animate().fadeIn(delay: 1200.ms),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: skin.rarityColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('¡GENIAL!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ).animate().fadeIn(delay: 1800.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    // Save unlock to DB
    await auth.unlockSkin(skin.id);
    setState(() {}); // refresh UI to show it's unlocked and equipable
  }
}
