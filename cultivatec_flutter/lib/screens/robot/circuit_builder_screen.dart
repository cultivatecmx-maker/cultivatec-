import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ═══════════════════════════════════════════════════════════════
// ELECTRONICS SIMULATOR — Full port from React CircuitBuilder
// Pin-based connections, 12 challenges, educational content,
// CustomPaint illustrations, BFS simulation
// ═══════════════════════════════════════════════════════════════

// ─── Pin definition ───
class PinDef {
  final String id;
  final double rx;
  final double ry;
  final String type;
  final String label;
  const PinDef(this.id, this.rx, this.ry, this.type, this.label);
}

// ─── Component definition ───
class ECompDef {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double w;
  final double h;
  final List<PinDef> pins;
  final String shortDesc;
  final String description;
  final String funFact;
  final String learningTip;
  final String category;
  final double voltage;
  final double resistance;
  final double minVoltage;
  final double maxVoltage;
  final bool isSwitch;
  final bool isSensor;
  final bool isArduino;

  const ECompDef({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.w = 90,
    this.h = 70,
    required this.pins,
    required this.shortDesc,
    required this.description,
    required this.funFact,
    required this.learningTip,
    required this.category,
    this.voltage = 0,
    this.resistance = 0,
    this.minVoltage = 0,
    this.maxVoltage = 0,
    this.isSwitch = false,
    this.isSensor = false,
    this.isArduino = false,
  });
}

class ECatDef {
  final String label;
  final Color color;
  final String icon;
  final String desc;
  const ECatDef(this.label, this.color, this.icon, this.desc);
}

class EChallenge {
  final int id;
  final String title;
  final String difficulty;
  final int stars;
  final String description;
  final String hint;
  final String explanation;
  final List<String> requiredComponents;
  final String goal;
  final int xp;
  final bool isFreeMode;
  const EChallenge({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.stars,
    required this.description,
    required this.hint,
    required this.explanation,
    required this.requiredComponents,
    required this.goal,
    required this.xp,
    this.isFreeMode = false,
  });
}

// ─── Placed component ───
class _Placed {
  final String uid;
  final ECompDef def;
  double x, y;
  bool switchState;
  _Placed({required this.uid, required this.def, required this.x, required this.y, this.switchState = true});
}

class _Wire {
  final String uid;
  final String fromComp, fromPin, toComp, toPin;
  _Wire({required this.uid, required this.fromComp, required this.fromPin, required this.toComp, required this.toPin});

  Offset from(List<_Placed> p) => _pos(p, fromComp, fromPin);
  Offset to(List<_Placed> p) => _pos(p, toComp, toPin);

  static Offset _pos(List<_Placed> p, String cUid, String pId) {
    final c = p.firstWhere((e) => e.uid == cUid, orElse: () => p.first);
    final pin = c.def.pins.firstWhere((e) => e.id == pId, orElse: () => c.def.pins.first);
    return Offset(c.x + pin.rx * c.def.w, c.y + pin.ry * c.def.h);
  }
}

class _CState {
  final String uid, type;
  bool isActive = false;
  _CState(this.uid, this.type);
}

// ═══════════════════════════════════════════════════════════════
// DATA
// ═══════════════════════════════════════════════════════════════

const _comps = <String, ECompDef>{
  'battery': ECompDef(
      id: 'bat_9v',
      name: 'Batería 9V',
      icon: Icons.battery_charging_full_rounded,
      color: Colors.amber,
      voltage: 9.0,
      category: 'power',
      pins: [PinDef('pos', 1, 0.2, 'out', '+'), PinDef('neg', 1, 0.8, 'out', '-')],
      shortDesc: 'Fuente de 9V',
      description: 'Proporciona 9 voltios de tensión. Ideal para circuitos que necesitan más fuerza que una pila AA.',
      funFact: 'Las baterías de 9V tienen 6 celdas pequeñas de 1.5V conectadas por dentro.',
      learningTip: 'Asegúrate de no hacer cortocircuito uniendo directamente el + y -, ¡se calentará mucho!'),
  'led_red': ECompDef(
      id: 'led_red',
      name: 'LED Rojo',
      icon: Icons.lightbulb_outline_rounded,
      color: Colors.red,
      voltage: 0,
      minVoltage: 1.8,
      maxVoltage: 2.2,
      resistance: 10,
      category: 'output',
      pins: [PinDef('anode', 0, 0.5, 'in', '+'), PinDef('cathode', 1, 0.5, 'out', '-')],
      shortDesc: 'Emite luz roja',
      description:
          'Un Diodo Emisor de Luz (LED) que se ilumina al pasar la corriente. ¡Ojo! La corriente solo fluye en una dirección (del + al -).',
      funFact: 'Los LEDs gastan mucha menos energía que los focos antiguos y duran años.',
      learningTip: 'La pata larga (ánodo) va al positivo (+) y la pata corta (cátodo) va al negativo (-).'),
  'resistor': ECompDef(
      id: 'res_220',
      name: 'Resistor 220Ω',
      icon: Icons.horizontal_rule_rounded,
      color: Colors.brown,
      voltage: 0,
      resistance: 220,
      category: 'passive',
      pins: [PinDef('a', 0, 0.5, 'inout', ''), PinDef('b', 1, 0.5, 'inout', '')],
      shortDesc: 'Limita corriente',
      description:
          'Ofrece 220 ohmios de resistencia. Reduce la fuerza de la corriente para proteger componentes frágiles como los LEDs.',
      funFact: 'Las rayitas de colores en el resistor indican su valor. ¡Son como un código secreto!',
      learningTip: 'Siempre usa un resistor en serie con un LED para evitar que se queme.'),
  'switch_comp': ECompDef(
      id: 'switch_spst',
      name: 'Interruptor',
      icon: Icons.toggle_off_rounded,
      color: Colors.grey,
      isSwitch: true,
      category: 'control',
      pins: [PinDef('a', 0, 0.5, 'inout', ''), PinDef('b', 1, 0.5, 'inout', '')],
      shortDesc: 'Abre/cierra circuito',
      description: 'Permite o interrumpe el paso de la corriente. Es como un puente levadizo para los electrones.',
      funFact: 'Cada vez que enciendes la luz de tu cuarto, estás usando un interruptor similar a este.',
      learningTip: 'Conecta el interruptor en el cable positivo para controlar el encendido de tu circuito.'),
  'motor': ECompDef(
      id: 'motor_dc',
      name: 'Motor DC',
      icon: Icons.settings_rounded,
      color: Colors.orange,
      minVoltage: 3.0,
      maxVoltage: 9.0,
      resistance: 50,
      category: 'output',
      pins: [PinDef('pos', 0, 0.2, 'in', '+'), PinDef('neg', 0, 0.8, 'out', '-')],
      shortDesc: 'Motor que gira',
      description: 'Un pequeño motor de corriente continua. Transforma la energía eléctrica en movimiento giratorio.',
      funFact: 'Si inviertes los cables positivo y negativo, ¡el motor gira al revés!',
      learningTip: 'Necesita más corriente que un LED, así que una batería de 9V es ideal.'),
  'buzzer': ECompDef(
      id: 'buzzer',
      name: 'Buzzer',
      icon: Icons.volume_up_rounded,
      color: Colors.black,
      minVoltage: 3.0,
      maxVoltage: 5.0,
      resistance: 30,
      category: 'output',
      pins: [PinDef('pos', 0, 0.2, 'in', '+'), PinDef('neg', 0, 0.8, 'out', '-')],
      shortDesc: 'Hace ruido',
      description: 'Un zumbador que emite un sonido agudo cuando recibe corriente.',
      funFact: 'Dentro tiene un cristal piezoeléctrico que vibra súper rápido para hacer ruido.',
      learningTip: 'Tiene polaridad, así que respeta el pin positivo (+) y negativo (-).'),
  'sensor_light': ECompDef(
      id: 'sensor_light',
      name: 'Sensor de Luz',
      icon: Icons.visibility,
      color: Color(0xFFEC4899),
      w: 60,
      h: 65,
      pins: [
        PinDef('vcc', 0, 0.28, 'input+', 'V'),
        PinDef('gnd', 0, 0.72, 'input-', 'G'),
        PinDef('out', 1, 0.49, 'output', 'S')
      ],
      shortDesc: 'Detecta la luz',
      description: 'Es como un ojo electrónico. Mide cuánta luz hay. ¡Los robots lo usan para no chocar!',
      funFact: '🌙 Las luces automáticas de las calles usan un sensor de luz.',
      learningTip: '🤖 Los robots seguidores de línea usan estos sensores para "ver" la línea negra.',
      category: 'entrada',
      isSensor: true),
  'arduino': ECompDef(
      id: 'arduino',
      name: 'Arduino Nano',
      icon: Icons.psychology,
      color: Color(0xFF0EA5E9),
      w: 110,
      h: 78,
      pins: [
        PinDef('vin', 0, 0.32, 'input+', 'V+'),
        PinDef('gnd', 0, 0.71, 'input-', 'GND'),
        PinDef('d2', 1, 0.23, 'digital', 'D2'),
        PinDef('d3', 1, 0.51, 'digital', 'D3'),
        PinDef('d4', 1, 0.77, 'digital', 'D4')
      ],
      shortDesc: 'El cerebro del robot',
      description: 'Un mini-cerebro electrónico programable. ¡El corazón de casi todos los proyectos de robótica!',
      funFact: '🇮🇹 Arduino fue inventado en Italia en 2005 por estudiantes.',
      learningTip: '💻 Los pines D2-D4 son digitales: pueden encender (1) o apagar (0) cosas.',
      category: 'procesamiento',
      isArduino: true),
};

const _cats = <String, ECatDef>{
  'energía': ECatDef('Energía', Color(0xFFFF6B35), '🔋', 'Dan energía al circuito'),
  'salida': ECatDef('Salida', Color(0xFF5B7CFA), '💡', 'Hacen algo visible'),
  'protección': ECatDef('Protección', Color(0xFFA0522D), '🛡️', 'Protegen el circuito'),
  'control': ECatDef('Control', Color(0xFF6B7280), '🔘', 'Controlan el flujo'),
  'entrada': ECatDef('Entrada', Color(0xFFEC4899), '👁️', 'Detectan el ambiente'),
  'procesamiento': ECatDef('Procesamiento', Color(0xFF0EA5E9), '🧠', 'Toman decisiones'),
};

const _challenges = <EChallenge>[
  EChallenge(
      id: 1,
      title: 'Mi Primer Circuito',
      difficulty: 'fácil',
      stars: 1,
      description: 'Conecta una batería a un LED para encenderlo. ¡Tu primer circuito!',
      hint: 'El + de la batería va al + del LED, y el − va al −',
      explanation: 'Un circuito es un camino cerrado por donde viajan los electrones.',
      requiredComponents: ['battery', 'led_red'],
      goal: 'Enciende el LED rojo',
      xp: 50),
  EChallenge(
      id: 2,
      title: 'Protege tu LED',
      difficulty: 'fácil',
      stars: 1,
      description: 'Los LEDs necesitan una resistencia para no quemarse.',
      hint: 'La resistencia va entre la batería y el LED',
      explanation: 'Sin resistencia, demasiada corriente pasa por el LED y lo quema.',
      requiredComponents: ['battery', 'resistor', 'led_red'],
      goal: 'Enciende el LED con resistencia',
      xp: 75),
  EChallenge(
      id: 3,
      title: 'Control con Interruptor',
      difficulty: 'medio',
      stars: 2,
      description: 'Agrega un interruptor para controlar cuándo se enciende el LED.',
      hint: 'El interruptor va en serie con el circuito',
      explanation: 'Los interruptores cortan el camino de los electrones.',
      requiredComponents: ['battery', 'switch_comp', 'resistor', 'led_red'],
      goal: 'Controla el LED',
      xp: 100),
  EChallenge(
      id: 4,
      title: 'Motor en Acción',
      difficulty: 'difícil',
      stars: 3,
      description: 'Conecta un motor DC y hazlo girar.',
      hint: 'El motor necesita la batería directamente',
      explanation: 'Los motores DC convierten electricidad en movimiento usando imanes.',
      requiredComponents: ['battery', 'switch_comp', 'motor'],
      goal: 'Haz girar el motor',
      xp: 200),
  EChallenge(
      id: 5,
      title: 'Alarma Sonora',
      difficulty: 'difícil',
      stars: 3,
      description: 'Crea una alarma que suene al activar el interruptor.',
      hint: 'El buzzer se conecta igual que un LED: tiene + y −',
      explanation: 'El buzzer vibra con electricidad y crea ondas de sonido.',
      requiredComponents: ['battery', 'switch_comp', 'buzzer'],
      goal: 'Activa el buzzer',
      xp: 200),
  EChallenge(
      id: 6,
      title: 'Arduino LED',
      difficulty: 'experto',
      stars: 4,
      description: 'Conecta un Arduino y controla un LED desde D2.',
      hint: 'La batería alimenta el Arduino (V+ y GND), del pin D2 sale al LED',
      explanation: 'El Arduino recibe energía y la distribuye de forma inteligente.',
      requiredComponents: ['battery', 'arduino', 'resistor', 'led_red'],
      goal: 'Controla LED con Arduino',
      xp: 300),
  EChallenge(
      id: 7,
      title: 'Modo Libre',
      difficulty: 'libre',
      stars: 0,
      description: '¡Usa todos los componentes! Experimenta sin límites.',
      hint: '¡No hay reglas! Prueba combinaciones.',
      explanation: 'La mejor forma de aprender es experimentando.',
      requiredComponents: [],
      goal: 'Experimenta',
      xp: 0,
      isFreeMode: true),
];

// ═══════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════

class CircuitBuilderScreen extends StatefulWidget {
  final String? challengeId;
  const CircuitBuilderScreen({super.key, this.challengeId});
  @override
  State<CircuitBuilderScreen> createState() => _CircuitBuilderScreenState();
}

class _CircuitBuilderScreenState extends State<CircuitBuilderScreen> with TickerProviderStateMixin {
  String _view = 'challenges';
  EChallenge? _currentChallenge;
  final Set<int> _completed = {};
  final List<_Placed> _placed = [];
  final List<_Wire> _wires = [];
  String? _selPin;
  bool _isSimulating = false;
  final Map<String, _CState> _cState = {};
  final Set<String> _activeWires = {};
  bool _showSuccess = false;
  String? _infoId;
  String? _selCompType;
  int _uid = 0;
  String _nuid() => 'c${_uid++}';
  late final AnimationController _flow;

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
    if (widget.challengeId != null) {
      int numericId = int.tryParse(widget.challengeId!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      final ch = _challenges.firstWhere((c) => c.id == numericId, orElse: () => _challenges[0]);
      _loadChallenge(ch);
    }
  }

  void _loadChallenge(EChallenge ch) => setState(() {
        _currentChallenge = ch;
        _view = 'builder';
        _reset();
      });

  void _reset() => setState(() {
        _placed.clear();
        _wires.clear();
        _selPin = null;
        _isSimulating = false;
        _cState.clear();
        _activeWires.clear();
        _showSuccess = false;
        _selCompType = null;
      });

  // ─── Challenge validation ───
  bool _validate(EChallenge ch) {
    final c = _cState.values.toList();
    switch (ch.id) {
      case 1:
        return c.any((e) => e.type == 'led_red' && e.isActive);
      case 2:
        return c.any((e) => e.type == 'resistor') && c.any((e) => e.type == 'led_red' && e.isActive);
      case 3:
        return c.any((e) => e.type == 'switch_comp') && c.any((e) => e.type == 'led_red');
      case 4:
        return c.any((e) => e.type == 'motor' && e.isActive);
      case 5:
        return c.any((e) => e.type == 'buzzer' && e.isActive);
      case 6:
        return c.any((e) => e.type == 'arduino' && e.isActive) && c.any((e) => e.type == 'led_red');
      case 7:
        return true;
      default:
        return false;
    }
  }

  // ─── BFS Simulation ───
  void _simulate() {
    _cState.clear();
    _activeWires.clear();
    for (final p in _placed) {
      _cState[p.uid] = _CState(p.uid, p.def.id);
    }

    final bats = _placed.where((c) => c.def.id == 'battery').toList();
    if (bats.isEmpty) {
      setState(() => _isSimulating = true);
      return;
    }

    final visited = <String>{};
    final queue = <String>[];
    for (final b in bats) {
      visited.add(b.uid);
      _cState[b.uid]!.isActive = true;
      queue.add(b.uid);
    }

    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      final comp = _placed.firstWhere((c) => c.uid == cur);
      if (comp.def.isSwitch && !comp.switchState) continue;
      for (final w in _wires) {
        String? nb;
        if (w.fromComp == cur && !visited.contains(w.toComp)) {
          nb = w.toComp;
        } else if (w.toComp == cur && !visited.contains(w.fromComp)) {
          nb = w.fromComp;
        }
        if (nb != null) {
          final nc = _placed.firstWhere((c) => c.uid == nb);
          if (nc.def.isSwitch && !nc.switchState) {
            visited.add(nb);
            continue;
          }
          visited.add(nb);
          _cState[nb]!.isActive = true;
          _activeWires.add(w.uid);
          queue.add(nb);
        }
      }
    }
    setState(() {
      _isSimulating = true;
      if (_currentChallenge != null && !_currentChallenge!.isFreeMode && _validate(_currentChallenge!)) {
        _completed.add(_currentChallenge!.id);
        _showSuccess = true;
      }
    });
  }

  // ─── Pin click ───
  void _onPin(String fullId, _Placed comp, PinDef pin) {
    if (_selPin == null) {
      setState(() => _selPin = fullId);
    } else if (_selPin == fullId) {
      setState(() => _selPin = null);
    } else {
      final parts = _selPin!.split('-');
      final fComp = parts[0], fPin = parts.sublist(1).join('-');
      if (fComp == comp.uid) {
        setState(() => _selPin = fullId);
        return;
      }
      final dup = _wires.any((w) =>
          (w.fromComp == fComp && w.fromPin == fPin && w.toComp == comp.uid && w.toPin == pin.id) ||
          (w.fromComp == comp.uid && w.fromPin == pin.id && w.toComp == fComp && w.toPin == fPin));
      if (!dup) _wires.add(_Wire(uid: _nuid(), fromComp: fComp, fromPin: fPin, toComp: comp.uid, toPin: pin.id));
      setState(() {
        _selPin = null;
        _isSimulating = false;
        _cState.clear();
        _activeWires.clear();
      });
    }
  }

  void _delComp(String uid) => setState(() {
        _wires.removeWhere((w) => w.fromComp == uid || w.toComp == uid);
        _placed.removeWhere((c) => c.uid == uid);
        _isSimulating = false;
        _cState.clear();
        _activeWires.clear();
      });

  void _placeAt(Offset pos, String id) {
    final def = _comps[id];
    if (def == null) return;
    setState(() {
      _placed.add(
          _Placed(uid: _nuid(), def: def, x: pos.dx - def.w / 2, y: pos.dy - def.h / 2, switchState: !def.isSwitch));
      _isSimulating = false;
      _cState.clear();
      _activeWires.clear();
    });
  }

  @override
  Widget build(BuildContext context) => _view == 'challenges' ? _challengeSelector() : _builder();

  // ═══════════════════════════════════════════════════════════════
  // CHALLENGE SELECTOR
  // ═══════════════════════════════════════════════════════════════
  Widget _challengeSelector() {
    final done = _completed.length;
    final total = _challenges.length - 1;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)])),
        child: SafeArea(
            child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))]),
            child: Row(children: [
              _backBtn(() => Navigator.pop(context)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('⚡ Simulador de Electrónica',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                Text('$done/$total desafíos completados',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ])),
            ]),
          ),
          Expanded(
              child: GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.82),
            itemCount: _challenges.length,
            itemBuilder: (ctx, i) {
              final ch = _challenges[i];
              final isDone = _completed.contains(ch.id);
              final unlocked = ch.isFreeMode || ch.id <= 2 || _completed.contains(ch.id - 1);
              final dc = _dc(ch.difficulty);
              return GestureDetector(
                onTap: unlocked ? () => _loadChallenge(ch) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: unlocked ? Colors.white : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDone ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0), width: isDone ? 2 : 1),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [dc, dc.withValues(alpha: 0.7)]),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(ch.difficulty.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5))),
                        const SizedBox(height: 8),
                        Text(ch.title,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: unlocked ? const Color(0xFF1E293B) : const Color(0xFF94A3B8)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ])),
                ),
              ).animate().fadeIn(delay: (i * 50).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
            },
          )),
        ])),
      ),
    );
  }

  Color _dc(String d) {
    switch (d) {
      case 'fácil':
        return const Color(0xFF22C55E);
      case 'medio':
        return const Color(0xFFF59E0B);
      case 'difícil':
        return const Color(0xFFEF4444);
      case 'experto':
        return const Color(0xFF5B7CFA);
      default:
        return const Color(0xFF1F6FEB);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILDER VIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _builder() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)])),
        child: SafeArea(
            child: Column(children: [
          _builderHeader(),
          Expanded(child: LayoutBuilder(builder: (ctx, box) {
            final wide = box.maxWidth > 700;
            return Row(children: [
              if (wide) SizedBox(width: 220, child: _desktopPalette()),
              Expanded(
                  child: Column(children: [
                if (!wide) _mobileBar(),
                Expanded(child: _canvas()),
              ])),
            ]);
          })),
        ])),
      ),
    );
  }

  Widget _backBtn(VoidCallback tap) => GestureDetector(
      onTap: tap,
      child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back, color: Color(0xFF475569), size: 20)));

  Widget _builderHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
          color: Colors.white, boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))]),
      child: Row(children: [
        _backBtn(() => setState(() {
              _view = 'challenges';
              _reset();
            })),
        const SizedBox(width: 8),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_currentChallenge?.title ?? 'Simulador',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
        GestureDetector(
            onTap: _simulate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF059669)]),
                  borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.play_arrow, size: 16, color: Colors.white),
                SizedBox(width: 2),
                Text('Probar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white))
              ]),
            )),
      ]),
    );
  }

  Widget _mobileBar() {
    final ids = _currentChallenge?.isFreeMode == true
        ? _comps.keys.toList()
        : (_currentChallenge?.requiredComponents.toSet().toList() ?? _comps.keys.toList());
    return SizedBox(
        height: 72,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          physics: const BouncingScrollPhysics(),
          children: ids.map((id) {
            final c = _comps[id];
            if (c == null) return const SizedBox.shrink();
            return GestureDetector(
                onTap: () => setState(() => _selCompType = _selCompType == id ? null : id),
                child: Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                        color: c.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _selCompType == id ? c.color : c.color.withValues(alpha: 0.25))),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _CIcon(id: c.id, sz: 28, c: c.color),
                      const SizedBox(height: 2),
                      Text(c.name.split(' ')[0],
                          style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: c.color))
                    ])));
          }).toList(),
        ));
  }

  Widget _desktopPalette() {
    final ids = _currentChallenge?.isFreeMode == true
        ? _comps.keys.toList()
        : (_currentChallenge?.requiredComponents.toSet().toList() ?? _comps.keys.toList());
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFE2E8F0)))),
      child: ListView(
          padding: const EdgeInsets.all(6),
          children: ids.map((id) {
            final comp = _comps[id]!;
            return GestureDetector(
                onTap: () => setState(() => _selCompType = _selCompType == id ? null : id),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                        color: _selCompType == id ? comp.color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      _CIcon(id: comp.id, sz: 28, c: comp.color),
                      const SizedBox(width: 8),
                      Text(comp.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: comp.color))
                    ])));
          }).toList()),
    );
  }

  Widget _canvas() {
    return GestureDetector(
      onTapUp: (d) {
        if (_selCompType != null) {
          _placeAt(d.localPosition, _selCompType!);
          setState(() => _selCompType = null);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
        child: Stack(children: [
          const Positioned.fill(child: CustomPaint(painter: _DotGrid())),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _flow,
              builder: (_, __) => CustomPaint(
                painter: _WirePainter(wires: _wires, placed: _placed, active: _activeWires, phase: _flow.value),
              ),
            ),
          ),
          ..._placed.map((c) {
            final st = _cState[c.uid];
            final act = st?.isActive == true;
            return Positioned(
                left: c.x,
                top: c.y,
                child: _CompW(
                    comp: c,
                    active: act,
                    selPin: _selPin,
                    onDrag: (dx, dy) => setState(() {
                          c.x += dx;
                          c.y += dy;
                        }),
                    onPin: _onPin,
                    onDel: () => _delComp(c.uid),
                    onInfo: () => setState(() => _infoId = c.def.id),
                    onSwitch: () {
                      setState(() => c.switchState = !c.switchState);
                      if (_isSimulating) _simulate();
                    }));
          }),
          if (_showSuccess && _currentChallenge != null) _successModal(),
          if (_infoId != null) _infoModal(),
        ]),
      ),
    );
  }

  Widget _successModal() {
    final ch = _currentChallenge!;
    return Positioned.fill(
        child: GestureDetector(
            onTap: () {},
            child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.emoji_events, size: 56),
                      const SizedBox(height: 8),
                      const Text('¡Completado!',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  setState(() => _showSuccess = false);
                                  _reset();
                                },
                                child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                                    child: const Text('Reintentar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF475569)))))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  setState(() => _showSuccess = false);
                                  final idx = _challenges.indexWhere((c) => c.id == ch.id) + 1;
                                  if (idx < _challenges.length) {
                                    _loadChallenge(_challenges[idx]);
                                  } else {
                                    setState(() => _view = 'challenges');
                                  }
                                },
                                child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF1F6FEB), Color(0xFF1F6FEB)]),
                                        borderRadius: BorderRadius.circular(12)),
                                    child: const Text('Siguiente ▶',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white))))),
                      ]),
                    ]),
                  ),
                ))));
  }

  // ─── Info modal ───
  Widget _infoModal() {
    final comp = _comps[_infoId];
    if (comp == null) return const SizedBox.shrink();
    final cat = _cats[comp.category];
    return Positioned.fill(
        child: GestureDetector(
            onTap: () => setState(() => _infoId = null),
            child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                        width: 380,
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 24)]),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  // Header
                                  Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                        comp.color.withValues(alpha: 0.1),
                                        comp.color.withValues(alpha: 0.2)
                                      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                                      child: Column(children: [
                                        Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(color: comp.color.withValues(alpha: 0.2), blurRadius: 12)
                                                ]),
                                            child:
                                                Center(child: _CIcon(id: comp.id, sz: 52, c: comp.color, glow: true))),
                                        const SizedBox(height: 10),
                                        Text('${comp.icon} ${comp.name}',
                                            style: TextStyle(
                                                fontSize: 20, fontWeight: FontWeight.w900, color: comp.color)),
                                        const SizedBox(height: 6),
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: cat?.color ?? Colors.grey,
                                                borderRadius: BorderRadius.circular(12)),
                                            child: Text('${cat?.icon ?? ''} ${cat?.label ?? ''}',
                                                style: const TextStyle(
                                                    fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
                                      ])),
                                  Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const Row(children: [
                                          Icon(Icons.menu_book, size: 16, color: Color(0xFF1F6FEB)),
                                          SizedBox(width: 6),
                                          Text('¿Qué hace?',
                                              style: TextStyle(
                                                  fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF374151)))
                                        ]),
                                        const SizedBox(height: 6),
                                        Text(comp.description,
                                            style:
                                                const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.5)),
                                        const SizedBox(height: 12),
                                        Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFFEFCE8),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFFDE68A), width: 1.5)),
                                            child: Text(comp.funFact,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF854D0E),
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.4))),
                                        const SizedBox(height: 10),
                                        Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5)),
                                            child: Text(comp.learningTip,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF1E40AF),
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.4))),
                                        const SizedBox(height: 12),
                                        // Tech details
                                        Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFF9FAFB),
                                                borderRadius: BorderRadius.circular(12)),
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              const Text('📊 Datos Técnicos',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFF374151))),
                                              const SizedBox(height: 8),
                                              Wrap(spacing: 6, runSpacing: 6, children: [
                                                if (comp.voltage > 0) _tb('Voltaje', '${comp.voltage}V'),
                                                if (comp.resistance > 0)
                                                  _tb('Resistencia', '${comp.resistance.toInt()}Ω'),
                                                if (comp.minVoltage > 0) _tb('V mín', '${comp.minVoltage}V'),
                                                if (comp.maxVoltage > 0) _tb('V máx', '${comp.maxVoltage}V'),
                                                _tb('Pines', '${comp.pins.length}'),
                                                _tb('Tipo', cat?.label ?? ''),
                                              ])
                                            ])),
                                        const SizedBox(height: 12),
                                        // Pin diagram
                                        Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFF9FAFB),
                                                borderRadius: BorderRadius.circular(12)),
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              const Text('📌 Pines de conexión',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFF374151))),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,
                                                  children: comp.pins.map((p) {
                                                    final pc = p.type.contains('+')
                                                        ? const Color(0xFFEF4444)
                                                        : p.type.contains('-')
                                                            ? const Color(0xFF374151)
                                                            : p.type == 'digital'
                                                                ? const Color(0xFF1F6FEB)
                                                                : p.type == 'output'
                                                                    ? const Color(0xFF22C55E)
                                                                    : const Color(0xFF94A3B8);
                                                    return Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(color: const Color(0xFFE2E8F0))),
                                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                          Container(
                                                              width: 10,
                                                              height: 10,
                                                              decoration:
                                                                  BoxDecoration(color: pc, shape: BoxShape.circle)),
                                                          const SizedBox(width: 5),
                                                          Text(p.label.isNotEmpty ? p.label : p.id,
                                                              style: const TextStyle(
                                                                  fontSize: 10, fontWeight: FontWeight.w700)),
                                                          const SizedBox(width: 4),
                                                          Text(p.type,
                                                              style: const TextStyle(
                                                                  fontSize: 8, color: Color(0xFF94A3B8)))
                                                        ]));
                                                  }).toList())
                                            ])),
                                        const SizedBox(height: 12),
                                        GestureDetector(
                                            onTap: () => setState(() => _infoId = null),
                                            child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(12)),
                                                child: const Text('Cerrar',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w800,
                                                        color: Color(0xFF475569))))),
                                      ])),
                                ])))),
                  )
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 250.ms),
                ))));
  }

  Widget _tb(String l, String v) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$l: ', style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
        Text(v, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)))
      ]));
}

// ═══════════════════════════════════════════════════════════════
// PLACED COMPONENT WIDGET
// ═══════════════════════════════════════════════════════════════
class _CompW extends StatefulWidget {
  final _Placed comp;
  final bool active;
  final String? selPin;
  final void Function(double, double) onDrag;
  final void Function(String, _Placed, PinDef) onPin;
  final VoidCallback onDel, onInfo, onSwitch;
  const _CompW(
      {required this.comp,
      required this.active,
      required this.selPin,
      required this.onDrag,
      required this.onPin,
      required this.onDel,
      required this.onInfo,
      required this.onSwitch});
  @override
  State<_CompW> createState() => _CompWS();
}

class _CompWS extends State<_CompW> {
  bool _actions = false, _dragging = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.comp;
    final d = c.def;
    final isLed = d.id.startsWith('led_');
    final glow = widget.active && isLed;
    return SizedBox(
        width: d.w,
        height: d.h,
        child: Stack(clipBehavior: Clip.none, children: [
          if (_actions)
            Positioned(
                top: -32,
                left: 0,
                right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                      onTap: widget.onInfo,
                      child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Color(0xFF1F6FEB),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4)]),
                          child: const Icon(Icons.info, size: 15, color: Colors.white))),
                  const SizedBox(width: 6),
                  GestureDetector(
                      onTap: widget.onDel,
                      child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4)]),
                          child: const Icon(Icons.delete, size: 15, color: Colors.white))),
                ])),
          Positioned.fill(
              child: GestureDetector(
                  onPanUpdate: (e) {
                    setState(() => _dragging = true);
                    widget.onDrag(e.delta.dx, e.delta.dy);
                  },
                  onPanEnd: (_) => setState(() => _dragging = false),
                  onTap: () {
                    if (d.isSwitch) {
                      widget.onSwitch();
                    } else {
                      setState(() => _actions = !_actions);
                    }
                  },
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                          color: glow
                              ? d.color.withValues(alpha: 0.2)
                              : widget.active
                                  ? d.color.withValues(alpha: 0.08)
                                  : Color.alphaBlend(d.color.withValues(alpha: 0.04), Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: widget.active ? d.color : d.color.withValues(alpha: 0.2),
                              width: widget.active ? 2.5 : 1),
                          boxShadow: [
                            if (glow) BoxShadow(color: d.color.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2),
                            if (_dragging)
                              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, spreadRadius: 2),
                            if (!glow && !_dragging)
                              const BoxShadow(color: AppTheme.borderColor, blurRadius: 0, offset: Offset(0, 5))
                          ]),
                      child: Center(
                          child: _CIcon(
                              id: d.id,
                              sz: min(d.w, d.h) * 0.65,
                              c: d.color,
                              glow: widget.active,
                              on: c.switchState))))),
          ...d.pins.map((p) {
            final pid = '${c.uid}-${p.id}';
            final sel = widget.selPin == pid;
            final pc = p.type.contains('+')
                ? const Color(0xFFEF4444)
                : p.type.contains('-')
                    ? const Color(0xFF374151)
                    : p.type == 'digital'
                        ? const Color(0xFF1F6FEB)
                        : p.type == 'output'
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF94A3B8);
            return Positioned(
                left: p.rx * d.w - 14,
                top: p.ry * d.h - 14,
                child: GestureDetector(
                    onTap: () => widget.onPin(pid, c, p),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: sel ? const Color(0xFFFDE047) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: sel ? const Color(0xFFF59E0B) : pc, width: sel ? 3 : 2),
                            boxShadow: sel
                                ? [BoxShadow(color: const Color(0xFFFDE047).withValues(alpha: 0.5), blurRadius: 8)]
                                : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 3)]),
                        child: Center(
                            child: Text(p.label,
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: sel ? const Color(0xFF92400E) : pc))))));
          }),
          Positioned(
              bottom: -16,
              left: 0,
              right: 0,
              child: Center(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration:
                          BoxDecoration(color: d.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(d.name,
                          style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: d.color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)))),
        ]));
  }
}

// ═══════════════════════════════════════════════════════════════
// COMPONENT ICON (CustomPaint illustrations)
// ═══════════════════════════════════════════════════════════════
class _CIcon extends StatelessWidget {
  final String id;
  final double sz;
  final Color c;
  final bool glow;
  final bool on;
  const _CIcon({required this.id, required this.sz, required this.c, this.glow = false, this.on = true});
  @override
  Widget build(BuildContext ctx) => CustomPaint(size: Size(sz, sz), painter: _CPaint(id: id, c: c, glow: glow, on: on));
}

class _CPaint extends CustomPainter {
  final String id;
  final Color c;
  final bool glow, on;
  _CPaint({required this.id, required this.c, this.glow = false, this.on = true});

  @override
  void paint(Canvas cv, Size size) {
    final s = size.width;
    switch (id) {
      case 'battery':
        _bat(cv, s);
        break;
      case 'led_red':
        _led(cv, s, const Color(0xFFFF4B4B));
        break;
      case 'led_green':
        _led(cv, s, const Color(0xFF58CC02));
        break;
      case 'led_blue':
        _led(cv, s, const Color(0xFF1CB0F6));
        break;
      case 'resistor':
        _res(cv, s);
        break;
      case 'switch_comp':
        _sw(cv, s);
        break;
      case 'motor':
        _mot(cv, s);
        break;
      case 'buzzer':
        _buz(cv, s);
        break;
      case 'sensor_light':
        _sen(cv, s);
        break;
      case 'arduino':
        _ard(cv, s);
        break;
      default:
        _def(cv, s);
    }
  }

  void _bat(Canvas cv, double s) {
    final f = s / 64;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(8 * f, 16 * f, 40 * f, 32 * f), Radius.circular(4 * f)),
        Paint()..color = const Color(0xFFFF6B35));
    cv.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(8 * f, 16 * f, 40 * f, 32 * f), Radius.circular(4 * f)),
        Paint()
          ..color = const Color(0xFFCC4A1A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * f);
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(48 * f, 24 * f, 8 * f, 16 * f), Radius.circular(2 * f)),
        Paint()..color = const Color(0xFFCC4A1A));
    final w = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * f
      ..strokeCap = StrokeCap.round;
    cv.drawLine(Offset(14 * f, 28 * f), Offset(20 * f, 28 * f), w);
    cv.drawLine(Offset(17 * f, 25 * f), Offset(17 * f, 31 * f), w);
    cv.drawLine(Offset(32 * f, 28 * f), Offset(38 * f, 28 * f), w);
    _t(cv, '9V', Colors.white, Offset(18 * f, 32 * f), 9 * f);
  }

  void _led(Canvas cv, double s, Color col) {
    final f = s / 64;
    final dr = Rect.fromLTWH(16 * f, 6 * f, 32 * f, 36 * f);
    if (glow) {
      cv.drawOval(
          dr.inflate(4 * f),
          Paint()
            ..color = col.withValues(alpha: 0.3)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * f));
    }
    final g = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1,
        colors: [Colors.white.withValues(alpha: 0.7), col.withValues(alpha: 0.9), col]);
    cv.drawOval(dr, Paint()..shader = g.createShader(dr));
    cv.drawOval(
        dr,
        Paint()
          ..color = col
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * f);
    cv.drawRect(Rect.fromLTWH(22 * f, 40 * f, 20 * f, 5 * f), Paint()..color = const Color(0xFF888888));
    final lg = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..strokeWidth = 2.5 * f
      ..strokeCap = StrokeCap.round;
    cv.drawLine(Offset(27 * f, 45 * f), Offset(27 * f, 57 * f), lg);
    cv.drawLine(Offset(37 * f, 45 * f), Offset(37 * f, 57 * f), lg);
    _t(cv, '+', const Color(0xFF666666), Offset(24 * f, 52 * f), 6 * f);
    _t(cv, '−', const Color(0xFF666666), Offset(35 * f, 52 * f), 6 * f);
    if (glow) {
      final r = Paint()
        ..color = col.withValues(alpha: 0.5)
        ..strokeWidth = 1.5 * f
        ..strokeCap = StrokeCap.round;
      cv.drawLine(Offset(32 * f, 2 * f), Offset(32 * f, 6 * f), r);
      cv.drawLine(Offset(16 * f, 10 * f), Offset(13 * f, 7 * f), r);
      cv.drawLine(Offset(48 * f, 10 * f), Offset(51 * f, 7 * f), r);
      cv.drawLine(Offset(10 * f, 24 * f), Offset(6 * f, 24 * f), r);
      cv.drawLine(Offset(54 * f, 24 * f), Offset(58 * f, 24 * f), r);
    }
  }

  void _res(Canvas cv, double s) {
    final f = s / 64;
    final w = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..strokeWidth = 2.5 * f
      ..strokeCap = StrokeCap.round;
    cv.drawLine(Offset(0, 32 * f), Offset(12 * f, 32 * f), w);
    cv.drawLine(Offset(52 * f, 32 * f), Offset(64 * f, 32 * f), w);
    cv.drawRect(Rect.fromLTWH(12 * f, 22 * f, 40 * f, 20 * f), Paint()..color = const Color(0xFFE8D5B7));
    cv.drawRect(
        Rect.fromLTWH(12 * f, 22 * f, 40 * f, 20 * f),
        Paint()
          ..color = const Color(0xFFA0522D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * f);
    cv.drawRect(Rect.fromLTWH(17 * f, 22 * f, 4 * f, 20 * f), Paint()..color = const Color(0xFFFF0000));
    cv.drawRect(Rect.fromLTWH(23 * f, 22 * f, 4 * f, 20 * f), Paint()..color = const Color(0xFFFF0000));
    cv.drawRect(Rect.fromLTWH(29 * f, 22 * f, 4 * f, 20 * f), Paint()..color = const Color(0xFF8B4513));
    cv.drawRect(Rect.fromLTWH(40 * f, 22 * f, 4 * f, 20 * f), Paint()..color = const Color(0xFFFFD700));
    _t(cv, '220Ω', const Color(0xFFA0522D), Offset(20 * f, 44 * f), 5 * f);
  }

  void _sw(Canvas cv, double s) {
    final f = s / 64;
    final base = RRect.fromRectAndRadius(Rect.fromLTWH(6 * f, 20 * f, 52 * f, 16 * f), Radius.circular(8 * f));
    cv.drawRRect(base, Paint()..color = (on ? const Color(0xFFDEF7EC) : const Color(0xFFFDE8E8)));
    cv.drawRRect(
        base,
        Paint()
          ..color = (on ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * f);
    cv.drawCircle(Offset(16 * f, 28 * f), 5 * f, Paint()..color = const Color(0xFF888888));
    cv.drawCircle(Offset(48 * f, 28 * f), 5 * f, Paint()..color = const Color(0xFF888888));
    cv.drawLine(
        Offset(16 * f, 28 * f),
        Offset(on ? 48 * f : 32 * f, on ? 28 * f : 14 * f),
        Paint()
          ..color = (on ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
          ..strokeWidth = 3 * f
          ..strokeCap = StrokeCap.round);
    final wp = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..strokeWidth = 2.5 * f
      ..strokeCap = StrokeCap.round;
    cv.drawLine(Offset(0, 28 * f), Offset(11 * f, 28 * f), wp);
    cv.drawLine(Offset(53 * f, 28 * f), Offset(64 * f, 28 * f), wp);
    _t(cv, on ? 'ON' : 'OFF', on ? const Color(0xFF22C55E) : const Color(0xFFEF4444), Offset(24 * f, 42 * f), 7 * f);
  }

  void _mot(Canvas cv, double s) {
    final f = s / 64;
    final ctr = Offset(32 * f, 32 * f);
    const g = LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFA78BFA), Color(0xFF0958C2)]);
    cv.drawCircle(ctr, 22 * f, Paint()..shader = g.createShader(Rect.fromCircle(center: ctr, radius: 22 * f)));
    cv.drawCircle(
        ctr,
        22 * f,
        Paint()
          ..color = const Color(0xFF5B21B6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * f);
    cv.drawCircle(ctr, 6 * f, Paint()..color = const Color(0xFFDDDDDD));
    cv.drawCircle(
        ctr,
        6 * f,
        Paint()
          ..color = const Color(0xFF999999)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * f);
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(30 * f, 2 * f, 4 * f, 12 * f), Radius.circular(2 * f)),
        Paint()..color = const Color(0xFF999999));
    final m = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.5 * f
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      cv.drawLine(Offset(32 * f + cos(a) * 14 * f, 32 * f + sin(a) * 14 * f),
          Offset(32 * f + cos(a) * 20 * f, 32 * f + sin(a) * 20 * f), m);
    }
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(12 * f, 52 * f, 8 * f, 4 * f), Radius.circular(1 * f)),
        Paint()..color = const Color(0xFFEF4444));
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(44 * f, 52 * f, 8 * f, 4 * f), Radius.circular(1 * f)),
        Paint()..color = const Color(0xFF333333));
    _t(cv, '+', const Color(0xFFEF4444), Offset(13 * f, 57 * f), 6 * f);
    _t(cv, '−', const Color(0xFF333333), Offset(46 * f, 57 * f), 6 * f);
  }

  void _buz(Canvas cv, double s) {
    final f = s / 64;
    final ctr = Offset(32 * f, 30 * f);
    cv.drawCircle(ctr, 20 * f, Paint()..color = const Color(0xFFFEF3C7));
    cv.drawCircle(
        ctr,
        20 * f,
        Paint()
          ..color = const Color(0xFFF59E0B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * f);
    cv.drawCircle(ctr, 12 * f, Paint()..color = const Color(0xFFFDE68A));
    cv.drawCircle(
        ctr,
        12 * f,
        Paint()
          ..color = const Color(0xFFD97706)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 * f);
    cv.drawCircle(ctr, 5 * f, Paint()..color = const Color(0xFFF59E0B));
    for (final o in [Offset(0, -4 * f), Offset(-4 * f, 0), Offset(4 * f, 0), Offset(0, 4 * f)]) {
      cv.drawCircle(ctr + o, 1.5 * f, Paint()..color = const Color(0xFFD97706));
    }
    final lg = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..strokeWidth = 2 * f
      ..strokeCap = StrokeCap.round;
    cv.drawLine(Offset(24 * f, 50 * f), Offset(24 * f, 60 * f), lg);
    cv.drawLine(Offset(40 * f, 50 * f), Offset(40 * f, 60 * f), lg);
    _t(cv, '+', const Color(0xFF666666), Offset(21 * f, 55 * f), 6 * f);
    _t(cv, '−', const Color(0xFF666666), Offset(38 * f, 55 * f), 6 * f);
    if (glow) {
      final wv = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * f;
      cv.drawPath(
          Path()
            ..moveTo(55 * f, 22 * f)
            ..quadraticBezierTo(60 * f, 30 * f, 55 * f, 38 * f),
          wv);
      cv.drawPath(
          Path()
            ..moveTo(59 * f, 18 * f)
            ..quadraticBezierTo(66 * f, 30 * f, 59 * f, 42 * f),
          wv..color = const Color(0xFFF59E0B).withValues(alpha: 0.25));
    }
  }

  void _sen(Canvas cv, double s) {
    final f = s / 64;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(12 * f, 10 * f, 40 * f, 34 * f), Radius.circular(6 * f)),
        Paint()..color = const Color(0xFFFDF2F8));
    cv.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(12 * f, 10 * f, 40 * f, 34 * f), Radius.circular(6 * f)),
        Paint()
          ..color = const Color(0xFFEC4899)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * f);
    cv.drawCircle(Offset(32 * f, 24 * f), 10 * f, Paint()..color = Colors.white);
    cv.drawCircle(
        Offset(32 * f, 24 * f),
        10 * f,
        Paint()
          ..color = const Color(0xFFEC4899)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * f);
    cv.drawCircle(Offset(32 * f, 24 * f), 5 * f, Paint()..color = const Color(0xFFEC4899));
    cv.drawCircle(Offset(34 * f, 22 * f), 2 * f, Paint()..color = Colors.white.withValues(alpha: 0.6));
    final wv = Paint()
      ..color = const Color(0xFFEC4899).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * f;
    cv.drawPath(
        Path()
          ..moveTo(10 * f, 20 * f)
          ..quadraticBezierTo(4 * f, 27 * f, 10 * f, 34 * f),
        wv);
    cv.drawPath(
        Path()
          ..moveTo(54 * f, 20 * f)
          ..quadraticBezierTo(60 * f, 27 * f, 54 * f, 34 * f),
        wv);
    final p = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..strokeWidth = 1.5 * f
      ..strokeCap = StrokeCap.round;
    cv.drawLine(Offset(20 * f, 44 * f), Offset(20 * f, 58 * f), p);
    cv.drawLine(Offset(32 * f, 44 * f), Offset(32 * f, 58 * f), p);
    cv.drawLine(Offset(44 * f, 44 * f), Offset(44 * f, 58 * f), p);
    _t(cv, 'V', const Color(0xFFEC4899), Offset(17 * f, 54 * f), 5 * f);
    _t(cv, 'G', const Color(0xFF888888), Offset(29 * f, 54 * f), 5 * f);
    _t(cv, 'S', const Color(0xFF1F6FEB), Offset(41 * f, 54 * f), 5 * f);
  }

  void _ard(Canvas cv, double s) {
    final f = s / 64;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2 * f, 4 * f, 60 * f, 48 * f), Radius.circular(4 * f)),
        Paint()..color = const Color(0xFF0EA5E9));
    cv.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(2 * f, 4 * f, 60 * f, 48 * f), Radius.circular(4 * f)),
        Paint()
          ..color = const Color(0xFF0284C7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * f);
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 16 * f, 8 * f, 18 * f), Radius.circular(2 * f)),
        Paint()..color = const Color(0xFFCCCCCC));
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(22 * f, 14 * f, 20 * f, 22 * f), Radius.circular(2 * f)),
        Paint()..color = const Color(0xFF222222));
    cv.drawCircle(Offset(28 * f, 25 * f), 1.5 * f, Paint()..color = const Color(0xFF555555));
    for (int i = 0; i < 5; i++) {
      final y = 10 * f + i * 7 * f;
      cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(8 * f, y, 4 * f, 3 * f), Radius.circular(0.5 * f)),
          Paint()..color = const Color(0xFFFFD700));
      cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(52 * f, y, 4 * f, 3 * f), Radius.circular(0.5 * f)),
          Paint()..color = const Color(0xFFFFD700));
    }
    cv.drawCircle(Offset(48 * f, 40 * f), 2 * f, Paint()..color = const Color(0xFF58CC02));
    if (glow) {
      cv.drawCircle(Offset(48 * f, 40 * f), 4 * f, Paint()..color = const Color(0xFF58CC02).withValues(alpha: 0.3));
    }
    _t(cv, 'V+', Colors.white, Offset(9 * f, 8 * f), 4 * f);
    _t(cv, 'GND', Colors.white, Offset(9 * f, 40 * f), 3.5 * f);
    _t(cv, 'D2', Colors.white, Offset(46 * f, 8 * f), 3.5 * f);
    _t(cv, 'D3', Colors.white, Offset(46 * f, 21 * f), 3.5 * f);
    _t(cv, 'D4', Colors.white, Offset(46 * f, 34 * f), 3.5 * f);
    _t(cv, 'ARDUINO', Colors.white, Offset(16 * f, 48 * f), 4 * f);
  }

  void _def(Canvas cv, double s) {
    final f = s / 64;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(8 * f, 8 * f, 48 * f, 48 * f), Radius.circular(8 * f)),
        Paint()..color = c.withValues(alpha: 0.2));
    _t(cv, '?', c, Offset(28 * f, 24 * f), 16 * f);
  }

  void _t(Canvas cv, String tx, Color col, Offset p, double fs) {
    final tp = TextPainter(
        text: TextSpan(text: tx, style: TextStyle(fontSize: fs, fontWeight: FontWeight.w800, color: col)),
        textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(cv, p);
  }

  @override
  bool shouldRepaint(covariant _CPaint o) => o.id != id || o.glow != glow || o.on != on || o.c != c;
}

// ═══════════════════════════════════════════════════════════════
// PAINTERS
// ═══════════════════════════════════════════════════════════════
class _DotGrid extends CustomPainter {
  const _DotGrid();
  @override
  void paint(Canvas cv, Size s) {
    // Blueprint-style grid: faint blue lines + dots, like an engineering board.
    final line = Paint()
      ..color = const Color(0xFF1F6FEB).withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (double x = 0; x <= s.width; x += 24) {
      cv.drawLine(Offset(x, 0), Offset(x, s.height), line);
    }
    for (double y = 0; y <= s.height; y += 24) {
      cv.drawLine(Offset(0, y), Offset(s.width, y), line);
    }
    final d = Paint()..color = const Color(0xFFCBD5E1);
    for (double x = 12; x < s.width; x += 24) {
      for (double y = 12; y < s.height; y += 24) {
        cv.drawCircle(Offset(x, y), 1.1, d);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class _WirePainter extends CustomPainter {
  final List<_Wire> wires;
  final List<_Placed> placed;
  final Set<String> active;
  final double phase;
  _WirePainter({required this.wires, required this.placed, required this.active, this.phase = 0});

  @override
  void paint(Canvas cv, Size s) {
    for (final w in wires) {
      final f = w.from(placed), t = w.to(placed);
      final dx = (t.dx - f.dx).abs();
      final cp = max(dx * 0.4, 40.0);
      final path = Path()
        ..moveTo(f.dx, f.dy)
        ..cubicTo(f.dx + cp, f.dy, t.dx - cp, t.dy, t.dx, t.dy);
      final isA = active.contains(w.uid);

      // Drop shadow under every wire.
      cv.drawPath(
          path,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.10)
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);

      if (isA) {
        // Soft glow + bright conductor.
        cv.drawPath(
            path,
            Paint()
              ..color = const Color(0xFF22C55E).withValues(alpha: 0.35)
              ..strokeWidth = 12
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        cv.drawPath(
            path,
            Paint()
              ..color = const Color(0xFF16A34A)
              ..strokeWidth = 5
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke);
        cv.drawPath(
            path,
            Paint()
              ..color = const Color(0xFF86EFAC)
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke);

        // Moving "current" particles flowing along the wire.
        for (final m in path.computeMetrics()) {
          final len = m.length;
          for (int i = 0; i < 3; i++) {
            final dd = ((phase + i / 3) % 1.0) * len;
            final tan = m.getTangentForOffset(dd);
            if (tan != null) {
              cv.drawCircle(
                  tan.position,
                  3.4,
                  Paint()
                    ..color = Colors.white.withValues(alpha: 0.9)
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
              cv.drawCircle(tan.position, 2.0, Paint()..color = const Color(0xFFFEF9C3));
            }
          }
        }
      } else {
        cv.drawPath(
            path,
            Paint()
              ..color = const Color(0xFF9CA3AF)
              ..strokeWidth = 4.5
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WirePainter o) => true;
}
