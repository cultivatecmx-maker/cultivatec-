import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/screens/learning/quiz_screen.dart';

/// Type of a lesson content card (drives its icon/color in the UI).
enum CardType { concept, example, funFact, tip }

class LessonCard {
  final CardType type;
  final String title;
  final String body;
  const LessonCard(this.type, this.title, this.body);
}

enum PracticeType { none, coding, electronics }

class Lesson {
  final String id;
  final String emoji;
  final String title;
  final String subtitle; // module (Formación) name
  final List<LessonCard> cards;
  final List<QuizQuestionData> questions;
  final PracticeType practiceType;
  final String? challengeId;

  const Lesson({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cards,
    required this.questions,
    this.practiceType = PracticeType.none,
    this.challengeId,
  });
}

/// A learning level the child chooses (the 3 levels of the Wokov
/// curriculum: Chispa → Maker → Inventor).
class StemArea {
  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final Color color;
  final List<Lesson> lessons;

  const StemArea({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.lessons,
  });
}

StemArea areaById(String id) => stemAreas.firstWhere((a) => a.id == id, orElse: () => stemAreas.first);

// Shorthands.
const _c = CardType.concept;
const _e = CardType.example;
const _f = CardType.funFact;
const _t = CardType.tip;
const _coding = PracticeType.coding;
const _elec = PracticeType.electronics;
QuizQuestionData _q(String id, String q, List<String> o, int c, String e) =>
    QuizQuestionData(id: id, question: q, options: o, correct: c, explanation: e);

final List<StemArea> stemAreas = [
  // ==========================================================================
  // NIVEL 1 — CHISPA
  // ==========================================================================
  StemArea(
    id: 'chispa',
    name: 'Chispa',
    tagline: 'Tus primeros pasos en robótica',
    icon: Icons.bolt_rounded,
    color: AppTheme.toneIndigo,
    lessons: [
      // --- El mundo de los robots ---
      Lesson(
        id: 'ch_robots',
        emoji: '🤖',
        title: 'Identifica robots',
        subtitle: 'El mundo de los robots',
        practiceType: _coding,
        challengeId: 'c1',
        cards: [
          const LessonCard(_c, '¿Qué es un robot?',
              'Un robot es una máquina que puede sentir, pensar y actuar. No todo lo que se mueve es un robot: necesita sensores, un "cerebro" y partes que se muevan.'),
          const LessonCard(_e, '¿Robot o no?',
              'Una lavadora con sensores y programa es casi un robot; una silla no lo es. Una aspiradora que esquiva muebles, ¡sí!'),
        ],
        questions: [
          _q('chr1', 'Un robot puede sentir, pensar y…', ['comer', 'actuar', 'dormir', 'cantar'], 1,
              'Siente, decide y actúa.'),
          _q('chr2', 'Verdadero o Falso: una silla es un robot.', ['Verdadero', 'Falso'], 1,
              'No siente ni decide ni se mueve solo.'),
          _q(
              'chr3',
              '¿Cuál SÍ es un robot?',
              ['una aspiradora que esquiva muebles', 'una piedra', 'un cuaderno', 'un vaso'],
              0,
              'Siente y decide para moverse.'),
        ],
      ),
      Lesson(
        id: 'ch_partes',
        emoji: '🦾',
        title: 'Partes de un robot',
        subtitle: 'El mundo de los robots',
        cards: [
          const LessonCard(_c, 'Las 4 partes',
              'Un robot tiene: sensores (sentidos), actuadores (movimiento), control (cerebro) y alimentación (energía/batería).'),
          const LessonCard(_e, 'Como tu cuerpo',
              'Los sensores son tus ojos y oídos, los actuadores tus músculos, el control tu cerebro y la batería tu comida.'),
        ],
        questions: [
          _q('chp1', '¿Qué parte capta el entorno?', ['el sensor', 'el actuador', 'la batería', 'el tornillo'], 0,
              'Los sensores captan información.'),
          _q('chp2', '¿Qué parte da el movimiento?', ['el actuador (motor)', 'el sensor', 'la batería', 'la antena'], 0,
              'Los actuadores mueven al robot.'),
          _q('chp3', '¿Qué parte le da energía?', ['la alimentación (batería)', 'el sensor', 'el control', 'la rueda'],
              0, 'La batería alimenta todo.'),
        ],
      ),
      Lesson(
        id: 'ch_arma',
        emoji: '🔧',
        title: 'Arma un robot',
        subtitle: 'El mundo de los robots',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'Mecánica, electrónica e instrucciones',
              'Para armar un robot conectas su mecánica (cuerpo y motores), su electrónica (cables y energía) y le das instrucciones (programa).'),
          const LessonCard(
              _t, 'Orden', 'Primero el cuerpo, luego las conexiones, y al final el programa que lo controla.'),
        ],
        questions: [
          _q('cha1', 'Para que el robot se mueva primero conectas su…',
              ['mecánica y electrónica', 'color', 'nombre', 'sonido'], 0, 'El cuerpo y las conexiones.'),
          _q(
              'cha2',
              '¿Qué le dice al robot qué hacer?',
              ['las instrucciones (programa)', 'la pintura', 'el tamaño', 'la batería vacía'],
              0,
              'El programa lo controla.'),
          _q('cha3', 'Verdadero o Falso: el programa va al final.', ['Verdadero', 'Falso'], 0,
              'Primero armas, luego programas.'),
        ],
      ),
      // --- Circuitos Mágicos ---
      Lesson(
        id: 'ch_electri',
        emoji: '⚡',
        title: 'Qué es la electricidad',
        subtitle: 'Circuitos Mágicos',
        cards: [
          const LessonCard(_c, 'Energía que se mueve',
              'La electricidad es energía que viaja por los cables. Está en todo: desde un rayo en la naturaleza hasta los focos de tu casa.'),
          const LessonCard(_f, 'Átomos',
              'La electricidad nace del movimiento de partículas diminutas (electrones) dentro de los átomos.'),
        ],
        questions: [
          _q('che1', 'La electricidad es energía que viaja por…',
              ['los cables', 'el aire seco', 'la madera', 'el vidrio'], 0, 'Por los conductores como los cables.'),
          _q(
              'che2',
              'Un rayo es un ejemplo de electricidad en…',
              ['la naturaleza', 'un cuaderno', 'una piedra seca', 'nada'],
              0,
              'La naturaleza también tiene electricidad.'),
          _q('che3', 'La electricidad viene del movimiento de…', ['electrones', 'piedras', 'gotas', 'hojas'], 0,
              'Electrones dentro de los átomos.'),
        ],
      ),
      Lesson(
        id: 'ch_pilas',
        emoji: '🔋',
        title: 'Pilas y baterías',
        subtitle: 'Circuitos Mágicos',
        practiceType: _elec,
        challengeId: 'e1',
        cards: [
          const LessonCard(_c, '¿Qué guarda la energía?',
              'La pila o batería guarda energía y la entrega al circuito. Tiene dos polos: positivo (+) y negativo (−).'),
          const LessonCard(
              _e, 'Un carro a pilas', 'La batería de un carrito le da energía a su motor para que las ruedas giren.'),
        ],
        questions: [
          _q('chpi1', '¿Qué guarda la energía del circuito?', ['la pila/batería', 'el cable', 'el LED', 'el aire'], 0,
              'La pila almacena energía.'),
          _q('chpi2', 'Los polos de una pila son…', ['+ y −', 'A y B', 'rojo y rojo', 'sí y no'], 0,
              'Positivo y negativo.'),
          _q('chpi3', 'La batería de un carrito alimenta su…', ['motor', 'pintura', 'nombre', 'antena'], 0,
              'El motor mueve las ruedas.'),
        ],
      ),
      Lesson(
        id: 'ch_circuito',
        emoji: '💡',
        title: 'Arma un circuito',
        subtitle: 'Circuitos Mágicos',
        practiceType: _elec,
        challengeId: 'e1',
        cards: [
          const LessonCard(_c, 'Circuito cerrado',
              'Un circuito es un camino cerrado para la corriente: de la pila, por los cables, al LED, y de regreso. Si está completo, ¡enciende!'),
          const LessonCard(
              _e, 'Serie y paralelo', 'En serie los componentes van uno tras otro; en paralelo, en caminos separados.'),
        ],
        questions: [
          _q('chc1', 'El LED enciende cuando el circuito está…', ['cerrado', 'abierto', 'roto', 'frío'], 0,
              'Un camino completo deja pasar la corriente.'),
          _q('chc2', 'En un circuito en serie los componentes van…',
              ['uno tras otro', 'separados', 'apagados', 'al revés'], 0, 'Uno después de otro.'),
          _q('chc3', 'Verdadero o Falso: si el circuito está abierto, el LED no enciende.', ['Verdadero', 'Falso'], 0,
              'Un corte impide el paso de corriente.'),
        ],
      ),
      // --- Código Visual ---
      Lesson(
        id: 'ch_programar',
        emoji: '📝',
        title: 'Qué es programar',
        subtitle: 'Código Visual',
        practiceType: _coding,
        challengeId: 'c1',
        cards: [
          const LessonCard(_c, 'Dar instrucciones en orden',
              'Programar es darle a la máquina una lista de instrucciones en orden. Ella hace exactamente lo que le dices, paso a paso.'),
          const LessonCard(_e, 'Mueve el carrito',
              'Para llevar un carrito a la meta ordenas instrucciones: avanza, avanza, gira, avanza.'),
        ],
        questions: [
          _q('chpr1', 'Programar es dar instrucciones…', ['en orden', 'al azar', 'sin sentido', 'invisibles'], 0,
              'En una secuencia ordenada.'),
          _q('chpr2', 'La máquina hace…', ['exactamente lo que le dices', 'lo que quiere', 'nada', 'lo contrario'], 0,
              'Sigue tus instrucciones al pie de la letra.'),
          _q('chpr3', 'Verdadero o Falso: el orden de las instrucciones importa.', ['Verdadero', 'Falso'], 0,
              'Cambiar el orden cambia el resultado.'),
        ],
      ),
      Lesson(
        id: 'ch_herramientas',
        emoji: '🧰',
        title: 'Bucles y condicionales',
        subtitle: 'Código Visual',
        practiceType: _coding,
        challengeId: 'c3',
        cards: [
          const LessonCard(_c, 'Repetir y decidir',
              'El bucle repite instrucciones ("repite 3 veces: avanza"). La condicional decide ("SI hay pared, gira").'),
          const LessonCard(_e, 'Juntos', 'Puedes integrar ambos: repite avanzar, y SI hay obstáculo, gira.'),
        ],
        questions: [
          _q('chh1', 'Un bucle sirve para…', ['repetir', 'borrar', 'apagar', 'pintar'], 0, 'Repite instrucciones.'),
          _q('chh2', 'Una condicional sirve para…', ['decidir', 'repetir', 'sumar', 'dormir'], 0,
              'Elige según una condición.'),
          _q('chh3', '"Repite 3 veces: avanza" hará avanzar…', ['3 veces', '1 vez', '0 veces', 'siempre'], 0,
              'El bucle repite 3 veces.'),
        ],
      ),
      Lesson(
        id: 'ch_programarobot',
        emoji: '🚀',
        title: 'Programa un robot',
        subtitle: 'Código Visual',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'Lleva el robot a la meta',
              'Combina instrucciones, bucles y condicionales para que un robot, una nave o un brazo cumplan su objetivo.'),
          const LessonCard(_t, 'Práctica', '¡En el simulador, arrastra bloques para llevar al robot hasta la bandera!'),
        ],
        questions: [
          _q('chpo1', 'Para llevar el robot a la meta usas…',
              ['instrucciones en orden', 'solo colores', 'nada', 'magia'], 0, 'Programas su recorrido.'),
          _q('chpo2', 'Si te faltan pasos, el robot…', ['no llega a la meta', 'llega igual', 'desaparece', 'crece'], 0,
              'Necesita las instrucciones correctas.'),
          _q('chpo3', 'Verdadero o Falso: puedes usar bucles para no repetir tantos bloques.', ['Verdadero', 'Falso'],
              0, 'El bucle ahorra bloques.'),
        ],
      ),
      // --- Arma tu brazo robótico ---
      Lesson(
        id: 'ch_brazo',
        emoji: '🦿',
        title: 'Arma tu brazo robótico',
        subtitle: 'Arma tu brazo robótico',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Diseña, arma y codifica',
              'Para tu brazo: diseña su objetivo y movimientos, elige componentes, ármalo (mecánica + electrónica) y dale sus instrucciones.'),
          const LessonCard(
              _e, 'Pruébalo', 'Prueba el brazo moviendo cajas y ajusta sus instrucciones hasta que funcione.'),
        ],
        questions: [
          _q('chb1', 'Antes de armar el brazo, primero…',
              ['diseñas su objetivo y movimientos', 'lo pintas', 'lo guardas', 'lo tiras'], 0, 'Planear primero.'),
          _q('chb2', 'El brazo se mueve gracias a sus…', ['motores (actuadores)', 'colores', 'stickers', 'nada'], 0,
              'Los actuadores lo mueven.'),
          _q('chb3', 'Si el brazo no hace lo correcto, revisas sus…',
              ['instrucciones', 'calcomanías', 'nombre', 'tamaño'], 0, 'El programa controla sus movimientos.'),
        ],
      ),
    ],
  ),

  // ==========================================================================
  // NIVEL 2 — MAKER
  // ==========================================================================
  StemArea(
    id: 'maker',
    name: 'Maker',
    tagline: 'Construye con Arduino, sensores y código',
    icon: Icons.build_rounded,
    color: AppTheme.toneAzure,
    lessons: [
      // --- Electrónica Básica ---
      Lesson(
        id: 'mk_ohm',
        emoji: '🔬',
        title: 'Ley de Ohm',
        subtitle: 'Electrónica Básica',
        practiceType: _elec,
        challengeId: 'e1',
        cards: [
          const LessonCard(_c, 'Voltaje, corriente y resistencia',
              'La Ley de Ohm dice: V = I × R. El voltaje (V) empuja la corriente (I), y la resistencia (R) la frena.'),
          const LessonCard(_e, 'Más resistencia, menos corriente',
              'Si subes la resistencia, pasa menos corriente; si subes el voltaje, pasa más.'),
        ],
        questions: [
          _q('mko1', 'La Ley de Ohm es…', ['V = I × R', 'V = I + R', 'V = I − R', 'V = R ÷ I'], 0,
              'Voltaje = corriente × resistencia.'),
          _q('mko2', 'Si la resistencia sube, la corriente…', ['baja', 'sube', 'no cambia', 'se apaga'], 0,
              'Más resistencia frena la corriente.'),
          _q('mko3', 'El voltaje es el que…', ['empuja la corriente', 'la frena', 'la pinta', 'la borra'], 0,
              'El voltaje impulsa la corriente.'),
        ],
      ),
      Lesson(
        id: 'mk_comp',
        emoji: '🧩',
        title: 'Componentes',
        subtitle: 'Electrónica Básica',
        practiceType: _elec,
        challengeId: 'e2',
        cards: [
          const LessonCard(_c, 'LED, resistencia, fuente, interruptor',
              'El LED da luz, la resistencia limita la corriente, la fuente da energía y el interruptor abre o cierra el paso.'),
          const LessonCard(_t, 'Protege el LED', 'Siempre usa una resistencia con el LED para que no se queme.'),
        ],
        questions: [
          _q('mkc1', '¿Qué componente limita la corriente?', ['la resistencia', 'el LED', 'la fuente', 'el cable'], 0,
              'Controla cuánta corriente pasa.'),
          _q('mkc2', '¿Qué abre o cierra el paso de corriente?',
              ['el interruptor', 'el LED', 'la resistencia', 'la fuente'], 0, 'El interruptor.'),
          _q('mkc3', 'Verdadero o Falso: el LED necesita una resistencia para no quemarse.', ['Verdadero', 'Falso'], 0,
              'La resistencia lo protege.'),
        ],
      ),
      Lesson(
        id: 'mk_circ',
        emoji: '🔌',
        title: 'Circuitos (serie y paralelo)',
        subtitle: 'Electrónica Básica',
        practiceType: _elec,
        challengeId: 'e1',
        cards: [
          const LessonCard(_c, 'Serie vs. paralelo',
              'En serie los componentes comparten el mismo camino; en paralelo tienen caminos separados, así que cada uno recibe el voltaje completo.'),
          const LessonCard(
              _e, 'Luces de casa', 'Las luces de tu casa van en paralelo: si apagas una, las demás siguen encendidas.'),
        ],
        questions: [
          _q('mkci1', 'En serie los componentes comparten…',
              ['el mismo camino', 'caminos separados', 'nada', 'colores'], 0, 'Un solo camino para la corriente.'),
          _q('mkci2', 'Las luces de casa suelen ir en…', ['paralelo', 'serie', 'círculo', 'diagonal'], 0,
              'Por eso una no apaga a las demás.'),
          _q(
              'mkci3',
              'En paralelo, cada componente recibe…',
              ['el voltaje completo', 'medio voltaje', 'cero', 'el doble siempre'],
              0,
              'Cada rama recibe el voltaje de la fuente.'),
        ],
      ),
      Lesson(
        id: 'mk_protoboard',
        emoji: '🧱',
        title: 'Protoboard',
        subtitle: 'Electrónica Básica',
        practiceType: _elec,
        challengeId: 'e2',
        cards: [
          const LessonCard(_c, '¿Qué es una protoboard?',
              'Es una tablilla con orificios conectados por dentro que te deja armar circuitos SIN soldar. ¡Ideal para probar!'),
          const LessonCard(_t, 'Filas conectadas',
              'Las filas internas están unidas: si insertas dos patas en la misma fila, quedan conectadas.'),
        ],
        questions: [
          _q('mkp1', 'La protoboard sirve para…', ['armar circuitos sin soldar', 'cocinar', 'medir peso', 'pintar'], 0,
              'Prototipar circuitos fácilmente.'),
          _q('mkp2', 'Dos patas en la misma fila quedan…', ['conectadas', 'separadas', 'quemadas', 'apagadas'], 0,
              'Las filas están unidas por dentro.'),
          _q('mkp3', 'Verdadero o Falso: en protoboard necesitas soldar.', ['Verdadero', 'Falso'], 1,
              'No: insertas las patas, sin soldar.'),
        ],
      ),
      // --- Hola Arduino ---
      Lesson(
        id: 'mk_arduino',
        emoji: '🟦',
        title: 'Comprende Arduino',
        subtitle: 'Hola Arduino',
        practiceType: _coding,
        challengeId: 'c1',
        cards: [
          const LessonCard(_c, '¿Qué es Arduino?',
              'Arduino es una pequeña placa con un "cerebro" (microcontrolador) que puedes programar para controlar luces, motores y sensores.'),
          const LessonCard(_e, 'Sus partes',
              'Tiene pines digitales y analógicos para conectar componentes, y un puerto USB para programarla.'),
        ],
        questions: [
          _q('mka1', 'Arduino es una placa que puedes…', ['programar', 'comer', 'pintar', 'doblar'], 0,
              'Se programa para controlar cosas.'),
          _q('mka2', 'El "cerebro" de Arduino es el…', ['microcontrolador', 'cable', 'LED', 'botón'], 0,
              'Procesa y controla.'),
          _q('mka3', 'Conectas componentes en sus…', ['pines', 'esquinas', 'stickers', 'patas de madera'], 0,
              'Pines digitales y analógicos.'),
        ],
      ),
      Lesson(
        id: 'mk_arducom',
        emoji: '🔢',
        title: 'Pines y monitor serial',
        subtitle: 'Hola Arduino',
        practiceType: _coding,
        challengeId: 'c1',
        cards: [
          const LessonCard(_c, 'Digitales y analógicos',
              'Los pines digitales manejan encendido/apagado (1 y 0); los analógicos leen valores que cambian poco a poco (como la luz).'),
          const LessonCard(_e, 'Monitor serial',
              'El monitor serial te deja ver mensajes del Arduino en la computadora, útil para saber qué está pasando.'),
        ],
        questions: [
          _q('mkac1', 'Un pin digital maneja…', ['encendido/apagado', 'colores', 'sonidos', 'olores'], 0, '1 y 0.'),
          _q('mkac2', 'Para leer un valor que cambia poco a poco usas un pin…',
              ['analógico', 'digital', 'roto', 'de madera'], 0, 'El analógico lee valores continuos.'),
          _q(
              'mkac3',
              'El monitor serial sirve para…',
              ['ver mensajes del Arduino', 'pintar', 'cargar la pila', 'medir peso'],
              0,
              'Muestra información en la PC.'),
        ],
      ),
      Lesson(
        id: 'mk_arduprog',
        emoji: '⌨️',
        title: 'Programa en Arduino',
        subtitle: 'Hola Arduino',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'Enciende un LED y mueve un motor',
              'Con código le dices al Arduino qué pin encender o apagar para controlar un LED, un motor o leer un sensor.'),
          const LessonCard(
              _t, 'setup y loop', 'En Arduino, "setup" se ejecuta una vez al inicio y "loop" se repite para siempre.'),
        ],
        questions: [
          _q('mkap1', '"loop" en Arduino se…', ['repite para siempre', 'ejecuta una vez', 'borra', 'apaga'], 0,
              'Se repite continuamente.'),
          _q('mkap2', '"setup" se ejecuta…', ['una vez al inicio', 'cada segundo', 'nunca', 'al final'], 0,
              'Solo una vez al encender.'),
          _q('mkap3', 'Para encender un LED, le dices al pin que se ponga en…',
              ['encendido (HIGH)', 'apagado siempre', 'analógico', 'rojo'], 0, 'HIGH enciende el pin.'),
        ],
      ),
      // --- Sensores y actuadores ---
      Lesson(
        id: 'mk_sensores',
        emoji: '📡',
        title: 'Sensores',
        subtitle: 'Sensores y actuadores',
        cards: [
          const LessonCard(_c, 'Sentir el entorno',
              'Hay sensores de temperatura y humedad, infrarrojos (detectan obstáculos o líneas) y acelerómetros (detectan movimiento e inclinación).'),
          const LessonCard(_e, 'Ejemplos',
              'Un sensor infrarrojo permite que un robot siga una línea; el acelerómetro sabe si el robot se inclina.'),
        ],
        questions: [
          _q('mks1', 'Un sensor de temperatura mide…', ['qué tan caliente está', 'el color', 'el peso', 'el sonido'], 0,
              'Mide temperatura.'),
          _q('mks2', 'Para seguir una línea, el robot usa un sensor…',
              ['infrarrojo', 'de sabor', 'de música', 'de olor'], 0, 'El infrarrojo detecta la línea.'),
          _q('mks3', 'El acelerómetro detecta…', ['movimiento e inclinación', 'color', 'voltaje', 'la hora'], 0,
              'Movimiento e inclinación.'),
        ],
      ),
      Lesson(
        id: 'mk_actuadores',
        emoji: '⚙️',
        title: 'Actuadores',
        subtitle: 'Sensores y actuadores',
        practiceType: _elec,
        challengeId: 'e3',
        cards: [
          const LessonCard(_c, 'Servos y motores',
              'Un servo 180° gira a un ángulo exacto; un servo 360° gira continuamente; una bomba de agua mueve líquido. Todos convierten electricidad en movimiento.'),
          const LessonCard(_e, 'Brazo robótico',
              'Los servos 180° son perfectos para mover las articulaciones de un brazo a posiciones exactas.'),
        ],
        questions: [
          _q('mkac1b', 'Un servo 180° gira…', ['a un ángulo exacto', 'sin parar', 'al azar', 'nunca'], 0,
              'Va a posiciones precisas.'),
          _q('mkac2b', 'Un actuador convierte electricidad en…', ['movimiento', 'luz', 'sonido', 'agua'], 0,
              'Produce movimiento.'),
          _q('mkac3b', 'Para las articulaciones de un brazo conviene un servo…',
              ['180°', '360° siempre', 'de agua', 'apagado'], 0, 'El 180° da ángulos exactos.'),
        ],
      ),
      Lesson(
        id: 'mk_integra',
        emoji: '🔗',
        title: 'Integra sensores y actuadores',
        subtitle: 'Sensores y actuadores',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Sentir y reaccionar',
              'La magia está en unir sensor + actuador: si el sensor de distancia ve algo cerca, el motor se detiene o gira.'),
          const LessonCard(
              _e, 'Ejemplos', 'Distancia → enciende un LED; luz → activa una bomba; temperatura → mueve un servo.'),
        ],
        questions: [
          _q(
              'mki1',
              'Integrar sensor y actuador significa…',
              ['sentir y reaccionar', 'solo leer', 'solo mover', 'apagar'],
              0,
              'El sensor manda y el actuador responde.'),
          _q('mki2', 'Si el sensor de distancia ve una pared cerca, el motor podría…',
              ['detenerse o girar', 'acelerar siempre', 'pintar', 'nada'], 0, 'Reacciona para no chocar.'),
          _q('mki3', 'Verdadero o Falso: el actuador reacciona a lo que dice el sensor.', ['Verdadero', 'Falso'], 0,
              'El sensor informa y el actuador actúa.'),
        ],
      ),
      // --- Lógica y Control ---
      Lesson(
        id: 'mk_variables',
        emoji: '📦',
        title: 'Variables',
        subtitle: 'Lógica y Control',
        practiceType: _coding,
        challengeId: 'c3',
        cards: [
          const LessonCard(_c, 'Cajitas con datos',
              'Una variable guarda un dato con nombre. Hay enteras (3), decimales (3.5) y de texto ("hola").'),
          const LessonCard(_e, 'Contar', 'puntos = 0; cada acierto: puntos = puntos + 1.'),
        ],
        questions: [
          _q('mkv1', 'Una variable guarda…', ['un dato con nombre', 'nada', 'un color fijo', 'electricidad'], 0,
              'Una cajita con nombre.'),
          _q('mkv2', '3.5 es una variable…', ['decimal', 'entera', 'de texto', 'vacía'], 0, 'Tiene decimales.'),
          _q('mkv3', 'Si puntos = 4 y sumas 2, vale…', ['6', '4', '2', '42'], 0, '4 + 2 = 6.'),
        ],
      ),
      Lesson(
        id: 'mk_condicionales',
        emoji: '🔀',
        title: 'Condicionales (if/else)',
        subtitle: 'Lógica y Control',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Si… si no…',
              'Con "if" decides: SI la condición es verdadera haces algo; con "else", haces otra cosa si es falsa.'),
          const LessonCard(_e, 'Decisión', 'SI hay obstáculo → gira; ELSE → avanza.'),
        ],
        questions: [
          _q('mkco1', '"if" sirve para…', ['decidir', 'repetir', 'sumar', 'borrar'], 0, 'Tomar decisiones.'),
          _q('mkco2', '"else" se ejecuta cuando la condición es…', ['falsa', 'verdadera', 'rota', 'verde'], 0,
              'El else cubre el caso contrario.'),
          _q('mkco3', 'SI hay pared gira, ELSE avanza. Sin pared el robot…', ['avanza', 'gira', 'se apaga', 'salta'], 0,
              'Ejecuta el else.'),
        ],
      ),
      Lesson(
        id: 'mk_bucles',
        emoji: '🔁',
        title: 'Bucles (for/while)',
        subtitle: 'Lógica y Control',
        practiceType: _coding,
        challengeId: 'c3',
        cards: [
          const LessonCard(_c, 'Repetir con for y while',
              '"for" repite un número exacto de veces; "while" repite MIENTRAS una condición sea verdadera.'),
          const LessonCard(_e, 'Ejemplos', 'for: parpadea 5 veces. while: avanza mientras no haya pared.'),
        ],
        questions: [
          _q('mkb1', '"for" repite…', ['un número exacto de veces', 'para siempre', 'una vez', 'nunca'], 0,
              'Cantidad fija de repeticiones.'),
          _q('mkb2', '"while" repite mientras la condición sea…', ['verdadera', 'falsa', 'roja', 'vacía'], 0,
              'Mientras se cumpla.'),
          _q('mkb3', 'Verdadero o Falso: un bucle evita escribir lo mismo muchas veces.', ['Verdadero', 'Falso'], 0,
              'Ahorra repetir código.'),
        ],
      ),
      Lesson(
        id: 'mk_funciones',
        emoji: '🧮',
        title: 'Funciones',
        subtitle: 'Lógica y Control',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'Bloques reutilizables',
              'Una función es un bloque de instrucciones con nombre que puedes usar muchas veces. Ej.: "avanzarYgirar()".'),
          const LessonCard(_t, 'Combina', 'Puedes combinar funciones para hacer rutinas más grandes.'),
        ],
        questions: [
          _q('mkf1', 'Una función es…', ['un bloque con nombre reutilizable', 'un error', 'una pila', 'un color'], 0,
              'Se puede llamar muchas veces.'),
          _q('mkf2', 'Verdadero o Falso: las funciones evitan repetir código.', ['Verdadero', 'Falso'], 0,
              'Reúsas el bloque.'),
          _q(
              'mkf3',
              'Combinar funciones sirve para…',
              ['hacer rutinas más grandes', 'gastar batería', 'confundir', 'nada'],
              0,
              'Construyes programas complejos.'),
        ],
      ),
      Lesson(
        id: 'mk_boolean',
        emoji: '✅',
        title: 'Lógica booleana (AND/OR/NOT)',
        subtitle: 'Lógica y Control',
        cards: [
          const LessonCard(_c, 'Verdadero y falso',
              'La lógica booleana combina condiciones: AND (las dos), OR (al menos una), NOT (lo contrario).'),
          const LessonCard(_e, 'Ejemplo', 'SI hace frío AND llueve → quédate en casa. NOT verdadero = falso.'),
        ],
        questions: [
          _q('mkbo1', 'AND es verdadero cuando…',
              ['las dos condiciones se cumplen', 'una se cumple', 'ninguna', 'siempre'], 0, 'Necesita ambas.'),
          _q('mkbo2', 'OR es verdadero cuando…', ['al menos una se cumple', 'ninguna', 'las dos solamente', 'nunca'], 0,
              'Basta con una.'),
          _q('mkbo3', 'NOT verdadero es…', ['falso', 'verdadero', 'rojo', 'vacío'], 0, 'Invierte el valor.'),
        ],
      ),
      // --- Programador ---
      Lesson(
        id: 'mk_debug',
        emoji: '🐞',
        title: 'Depuración',
        subtitle: 'Programador',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Encontrar y corregir errores',
              'Depurar (debug) es buscar bugs y arreglarlos. También se limpia el código para hacerlo más sencillo y claro.'),
          const LessonCard(
              _t, 'Paso a paso', 'Lee tu código línea por línea, como la computadora, para hallar el error.'),
        ],
        questions: [
          _q('mkd1', 'Depurar es…', ['buscar y corregir errores', 'borrar todo', 'apagar', 'pintar'], 0,
              'Arreglar bugs.'),
          _q('mkd2', 'Limpiar el código lo hace más…', ['sencillo y claro', 'difícil', 'lento siempre', 'invisible'], 0,
              'Más fácil de entender.'),
          _q('mkd3', 'Verdadero o Falso: todos cometen bugs.', ['Verdadero', 'Falso'], 0, 'Es normal y se corrige.'),
        ],
      ),
      Lesson(
        id: 'mk_ctrl',
        emoji: '🎚️',
        title: 'Control avanzado y millis()',
        subtitle: 'Programador',
        practiceType: _coding,
        challengeId: 'c3',
        cards: [
          const LessonCard(_c, 'switch y millis()',
              'Con "switch" eliges entre muchos casos; con "millis()" mides el tiempo sin detener el programa (en vez de "delay").'),
          const LessonCard(_e, 'Combinar', 'Puedes combinar condicionales y bucles para controlar todo con precisión.'),
        ],
        questions: [
          _q('mkct1', '"switch" sirve para…', ['elegir entre muchos casos', 'sumar', 'pintar', 'apagar'], 0,
              'Selecciona un caso entre varios.'),
          _q('mkct2', '"millis()" mide…', ['el tiempo', 'el color', 'el peso', 'la luz'], 0,
              'Cuenta el tiempo transcurrido.'),
          _q('mkct3', 'Verdadero o Falso: millis() no detiene el programa como delay.', ['Verdadero', 'Falso'], 0,
              'Deja seguir ejecutando.'),
        ],
      ),
      Lesson(
        id: 'mk_libs',
        emoji: '📚',
        title: 'Librerías',
        subtitle: 'Programador',
        cards: [
          const LessonCard(_c, 'Código que ya existe',
              'Una librería es código hecho por otros que puedes usar: LCD (pantallas), Servo, DHT (temperatura), Tone (sonidos).'),
          const LessonCard(_e, 'Ahorra trabajo',
              'Con la librería Servo controlas un motor con pocas líneas, sin programar todo desde cero.'),
        ],
        questions: [
          _q('mkl1', 'Una librería es…', ['código ya hecho que reutilizas', 'una pila', 'un robot', 'un cable'], 0,
              'Te ahorra trabajo.'),
          _q('mkl2', 'La librería LCD sirve para…', ['pantallas', 'motores de agua', 'pintar', 'cargar pilas'], 0,
              'Controla pantallas LCD.'),
          _q('mkl3', 'Verdadero o Falso: las librerías ahorran trabajo.', ['Verdadero', 'Falso'], 0,
              'Reúsas código probado.'),
        ],
      ),
      Lesson(
        id: 'mk_progav',
        emoji: '💻',
        title: 'Programación avanzada (C++/Python)',
        subtitle: 'Programador',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'Lenguajes de texto',
              'Además de bloques, existen lenguajes escritos como C++ (Arduino) y Python. Sirven para proyectos más grandes, como una calculadora.'),
          const LessonCard(_t, 'Mismas ideas', 'Variables, condicionales y bucles existen en todos los lenguajes.'),
        ],
        questions: [
          _q('mkpa1', 'Arduino se programa principalmente en…', ['C++', 'español', 'dibujos', 'morse'], 0, 'Usa C++.'),
          _q(
              'mkpa2',
              'Python sirve para…',
              ['proyectos como una calculadora', 'cocinar', 'cargar pilas', 'pintar paredes'],
              0,
              'Es un lenguaje versátil.'),
          _q('mkpa3', 'Verdadero o Falso: variables y bucles existen en C++ y Python.', ['Verdadero', 'Falso'], 0,
              'Son conceptos universales.'),
        ],
      ),
      // --- Mecánico ---
      Lesson(
        id: 'mk_herr',
        emoji: '🛠️',
        title: 'Uso de herramientas',
        subtitle: 'Mecánico',
        cards: [
          const LessonCard(_c, 'Herramientas del maker',
              'Aprende a apretar/aflojar llantas, medir con un vernier (con precisión) y soldar con cautín para unir componentes.'),
          const LessonCard(_t, 'Seguridad', 'El cautín está MUY caliente: tómalo del mango y pide ayuda de un adulto.'),
        ],
        questions: [
          _q('mkh1', 'El vernier sirve para…', ['medir con precisión', 'soldar', 'pintar', 'cargar pilas'], 0,
              'Mide medidas exactas.'),
          _q('mkh2', 'El cautín sirve para…', ['soldar (unir con estaño)', 'medir', 'cortar papel', 'pintar'], 0,
              'Une componentes soldando.'),
          _q('mkh3', 'Verdadero o Falso: el cautín está muy caliente y hay que tener cuidado.', ['Verdadero', 'Falso'],
              0, 'Tómalo del mango y con ayuda.'),
        ],
      ),
      Lesson(
        id: 'mk_transmision',
        emoji: '⚙️',
        title: 'Transmisión de movimiento',
        subtitle: 'Mecánico',
        cards: [
          const LessonCard(_c, 'Engranajes y bandas',
              'Los engranajes y las bandas transmiten el movimiento del motor a las ruedas, y pueden cambiar la velocidad o la fuerza.'),
          const LessonCard(
              _e, 'Más fuerza', 'Un engranaje grande moviendo uno pequeño da más velocidad; al revés, más fuerza.'),
        ],
        questions: [
          _q(
              'mkt1',
              'Los engranajes y bandas sirven para…',
              ['transmitir movimiento', 'medir', 'pintar', 'guardar datos'],
              0,
              'Llevan el giro del motor a las ruedas.'),
          _q('mkt2', 'Los engranajes pueden cambiar…', ['velocidad o fuerza', 'el color', 'el sonido', 'nada'], 0,
              'Modifican velocidad/fuerza.'),
          _q('mkt3', 'Verdadero o Falso: una banda puede conectar dos poleas.', ['Verdadero', 'Falso'], 0,
              'Transmite el giro entre poleas.'),
        ],
      ),
      Lesson(
        id: 'mk_ensamblaje',
        emoji: '🔩',
        title: 'Ensamblaje y mantenimiento',
        subtitle: 'Mecánico',
        cards: [
          const LessonCard(_c, 'Armar y cuidar',
              'Ensamblar es unir las piezas en orden y a la medida. Mantener es revisar el robot y encontrar por qué algo no funciona.'),
          const LessonCard(_t, 'Diagnóstico', 'Si un brazo no se mueve: revisa batería, cables y motor, uno por uno.'),
        ],
        questions: [
          _q('mke1', 'Ensamblar es…', ['unir las piezas en orden', 'pintar', 'borrar', 'medir tiempo'], 0,
              'Armar el robot.'),
          _q('mke2', 'Si un brazo no se mueve, revisas…',
              ['batería, cables y motor', 'el color', 'su nombre', 'el clima'], 0, 'Diagnóstico paso a paso.'),
          _q('mke3', 'Mantener un robot significa…', ['revisarlo y arreglarlo', 'tirarlo', 'ignorarlo', 'pintarlo'], 0,
              'Cuidarlo para que siga funcionando.'),
        ],
      ),
    ],
  ),

  // ==========================================================================
  // NIVEL 3 — INVENTOR
  // ==========================================================================
  StemArea(
    id: 'inventor',
    name: 'Inventor',
    tagline: 'Electrónica avanzada, IA y robótica',
    icon: Icons.science_rounded,
    color: AppTheme.primaryBlue,
    lessons: [
      // --- Electrónica Avanzada ---
      Lesson(
        id: 'in_diodos',
        emoji: '🔺',
        title: 'Semiconductores y diodos',
        subtitle: 'Electrónica Avanzada',
        practiceType: _elec,
        challengeId: 'e1',
        cards: [
          const LessonCard(_c, 'El diodo',
              'Un diodo deja pasar la corriente en UN solo sentido. El diodo rectificador convierte corriente alterna en directa; el LED es un diodo que da luz.'),
        ],
        questions: [
          _q('ind1', 'Un diodo deja pasar la corriente en…',
              ['un solo sentido', 'los dos sentidos', 'ninguno', 'círculo'], 0, 'Solo en una dirección.'),
          _q('ind2', 'Un LED es un tipo de…', ['diodo', 'motor', 'pila', 'resistencia'], 0, 'Diodo Emisor de Luz.'),
          _q('ind3', 'Un rectificador convierte corriente alterna en…', ['directa', 'sonido', 'luz', 'calor'], 0,
              'De alterna a directa.'),
        ],
      ),
      Lesson(
        id: 'in_transistor',
        emoji: '🎛️',
        title: 'Transistores',
        subtitle: 'Electrónica Avanzada',
        practiceType: _elec,
        challengeId: 'e2',
        cards: [
          const LessonCard(_c, 'Interruptor y amplificador',
              'Un transistor puede funcionar como un interruptor controlado por electricidad o amplificar una señal pequeña para hacerla más grande.'),
        ],
        questions: [
          _q('int1', 'Un transistor puede actuar como…', ['interruptor o amplificador', 'pila', 'rueda', 'pantalla'], 0,
              'Dos usos clave.'),
          _q('int2', 'Amplificar significa…', ['hacer una señal más grande', 'borrarla', 'apagarla', 'pintarla'], 0,
              'Aumenta la señal.'),
        ],
      ),
      Lesson(
        id: 'in_ampop',
        emoji: '📈',
        title: 'Amplificadores operacionales',
        subtitle: 'Electrónica Avanzada',
        practiceType: _elec,
        challengeId: 'e2',
        cards: [
          const LessonCard(_c, 'El "amp op"',
              'Un amplificador operacional aumenta señales (inversor o no inversor) y puede comparar dos voltajes para decidir cuál es mayor.'),
        ],
        questions: [
          _q(
              'ina1',
              'Un amplificador operacional sirve para…',
              ['amplificar y comparar señales', 'pintar', 'medir peso', 'cargar pilas'],
              0,
              'Amplifica/compara voltajes.'),
          _q('ina2', 'Un comparador decide…', ['cuál voltaje es mayor', 'el color', 'la hora', 'el sabor'], 0,
              'Compara dos entradas.'),
        ],
      ),
      Lesson(
        id: 'in_ci555',
        emoji: '⏱️',
        title: 'Circuitos integrados (555)',
        subtitle: 'Electrónica Avanzada',
        practiceType: _elec,
        challengeId: 'e3',
        cards: [
          const LessonCard(_c, 'El temporizador 555',
              'Un circuito integrado reúne muchos componentes en un solo chip. El 555 genera pulsos de tiempo (modo astable) o un pulso único (monoestable).'),
        ],
        questions: [
          _q('inc1', 'Un circuito integrado reúne muchos componentes en…',
              ['un solo chip', 'una pila', 'un cable', 'una rueda'], 0, 'Todo en un chip.'),
          _q('inc2', 'El 555 sirve para generar…', ['pulsos de tiempo', 'colores', 'sonidos al azar', 'agua'], 0,
              'Temporización.'),
        ],
      ),
      Lesson(
        id: 'in_fuentes',
        emoji: '🔌',
        title: 'Fuentes de alimentación',
        subtitle: 'Electrónica Avanzada',
        practiceType: _elec,
        challengeId: 'e1',
        cards: [
          const LessonCard(_c, 'Voltaje estable',
              'Una fuente entrega voltaje estable. Un regulador (como el LM7805) mantiene 5V fijos aunque la entrada cambie; una fuente variable permite elegir el voltaje.'),
        ],
        questions: [
          _q('inf1', 'Un regulador de voltaje sirve para…',
              ['mantener un voltaje fijo', 'pintar', 'medir peso', 'cargar archivos'], 0, 'Voltaje estable.'),
          _q('inf2', 'El LM7805 entrega…', ['5V fijos', '12V variables', 'sonido', 'luz'], 0, 'Regula a 5V.'),
        ],
      ),
      Lesson(
        id: 'in_pcb',
        emoji: '🟩',
        title: 'Diseño de PCB',
        subtitle: 'Electrónica Avanzada',
        practiceType: _elec,
        challengeId: 'e2',
        cards: [
          const LessonCard(_c, '¿Qué es una PCB?',
              'Una PCB (placa de circuito impreso) reemplaza los cables sueltos por pistas de cobre. Con software de diseño dibujas el circuito y enrutas las pistas.'),
        ],
        questions: [
          _q('inp1', 'Una PCB reemplaza los cables por…', ['pistas de cobre', 'hilos de lana', 'pegamento', 'agua'], 0,
              'Pistas grabadas en la placa.'),
          _q('inp2', '"Enrutar" significa…', ['trazar el camino de las pistas', 'pintar', 'medir tiempo', 'borrar'], 0,
              'Conectar los componentes con pistas.'),
        ],
      ),
      // --- Pensamiento Computacional ---
      Lesson(
        id: 'in_descomp',
        emoji: '🧩',
        title: 'Descomposición de problemas',
        subtitle: 'Pensamiento Computacional',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Divide y vencerás',
              'Descomponer es dividir un problema grande en subproblemas pequeños, más fáciles de resolver uno por uno.'),
        ],
        questions: [
          _q('inde1', 'Descomponer es…', ['dividir un problema en partes pequeñas', 'rendirse', 'adivinar', 'pintar'],
              0, 'Partes manejables.'),
          _q('inde2', 'Verdadero o Falso: partes pequeñas son más fáciles de resolver.', ['Verdadero', 'Falso'], 0,
              'Por eso se descompone.'),
        ],
      ),
      Lesson(
        id: 'in_patrones',
        emoji: '🔍',
        title: 'Patrones y abstracción',
        subtitle: 'Pensamiento Computacional',
        practiceType: _coding,
        challengeId: 'c3',
        cards: [
          const LessonCard(_c, 'Ver lo que se repite',
              'Reconocer patrones es ver lo que se repite; abstraer es quedarte con lo importante e ignorar los detalles que no importan.'),
        ],
        questions: [
          _q('inpa1', 'Reconocer un patrón es…', ['ver lo que se repite', 'borrar', 'apagar', 'medir peso'], 0,
              'Identificar repeticiones.'),
          _q('inpa2', 'Abstraer es…', ['quedarte con lo importante', 'guardar todo', 'pintar', 'gritar'], 0,
              'Ignorar lo irrelevante.'),
        ],
      ),
      Lesson(
        id: 'in_algoritmos',
        emoji: '📊',
        title: 'Algoritmos paso a paso',
        subtitle: 'Pensamiento Computacional',
        practiceType: _coding,
        challengeId: 'c1',
        cards: [
          const LessonCard(_c, 'Búsqueda y ordenamiento',
              'Un algoritmo es una serie de pasos para resolver algo. Hay algoritmos para buscar un dato y para ordenar una lista.'),
        ],
        questions: [
          _q('inal1', 'Un algoritmo es…', ['pasos en orden para resolver algo', 'un robot', 'una pila', 'un color'], 0,
              'Secuencia de pasos.'),
          _q('inal2', 'Un algoritmo de ordenamiento sirve para…',
              ['ordenar una lista', 'borrarla', 'pintarla', 'apagarla'], 0, 'Pone los datos en orden.'),
        ],
      ),
      Lesson(
        id: 'in_flujo',
        emoji: '🗺️',
        title: 'Diagramas de flujo',
        subtitle: 'Pensamiento Computacional',
        cards: [
          const LessonCard(_c, 'Dibuja la lógica',
              'Un diagrama de flujo dibuja los pasos de un programa con figuras y flechas: óvalos (inicio/fin), rectángulos (acciones) y rombos (decisiones).'),
        ],
        questions: [
          _q('influ1', 'En un diagrama de flujo, un rombo representa…',
              ['una decisión', 'el inicio', 'una acción simple', 'nada'], 0, 'Las decisiones van en rombo.'),
          _q('influ2', 'Un diagrama de flujo sirve para…',
              ['dibujar la lógica de un programa', 'pintar', 'cargar pilas', 'medir peso'], 0, 'Visualiza los pasos.'),
        ],
      ),
      Lesson(
        id: 'in_retos',
        emoji: '🧠',
        title: 'Resolución de problemas complejos',
        subtitle: 'Pensamiento Computacional',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Retos multi-etapa',
              'Los problemas complejos tienen varias variables y etapas. Se resuelven combinando descomposición, patrones y algoritmos.'),
        ],
        questions: [
          _q('inr1', 'Un problema multi-etapa se resuelve…',
              ['por partes y en orden', 'todo de golpe', 'adivinando', 'ignorándolo'], 0, 'Paso a paso.'),
          _q('inr2', 'Verdadero o Falso: combinar técnicas ayuda con problemas difíciles.', ['Verdadero', 'Falso'], 0,
              'Descomposición + patrones + algoritmos.'),
        ],
      ),
      // --- Diseño y Fabricación ---
      Lesson(
        id: 'in_diseno3d',
        emoji: '🧊',
        title: 'Diseño 3D y CAD',
        subtitle: 'Diseño y Fabricación',
        cards: [
          const LessonCard(_c, 'Modelar en 3D',
              'El diseño 3D (CAD) te deja crear piezas en la computadora: engranajes, carcasas y más, antes de fabricarlas.'),
        ],
        questions: [
          _q('ind3d1', 'CAD sirve para…', ['diseñar piezas en 3D', 'pintar paredes', 'cargar pilas', 'cocinar'], 0,
              'Modelado por computadora.'),
          _q('ind3d2', 'Verdadero o Falso: con CAD diseñas antes de fabricar.', ['Verdadero', 'Falso'], 0,
              'Pruebas en la PC primero.'),
        ],
      ),
      Lesson(
        id: 'in_impresion3d',
        emoji: '🖨️',
        title: 'Impresión 3D',
        subtitle: 'Diseño y Fabricación',
        cards: [
          const LessonCard(_c, '¿Cómo funciona?',
              'Una impresora 3D construye una pieza capa por capa derritiendo plástico. Primero preparas el archivo del modelo 3D.'),
        ],
        questions: [
          _q('inim1', 'Una impresora 3D construye la pieza…',
              ['capa por capa', 'de un solo golpe', 'pintándola', 'cortándola'], 0, 'Va apilando capas.'),
          _q('inim2', 'Antes de imprimir necesitas…', ['preparar el archivo 3D', 'una pila', 'pintura', 'agua'], 0,
              'El modelo listo para imprimir.'),
        ],
      ),
      Lesson(
        id: 'in_corte',
        emoji: '✂️',
        title: 'Corte láser, CNC y prototipado',
        subtitle: 'Diseño y Fabricación',
        cards: [
          const LessonCard(_c, 'Fabricar y mejorar',
              'El corte láser y la CNC cortan materiales con precisión. Prototipar es hacer una versión de prueba, probarla y mejorarla (iterar).'),
        ],
        questions: [
          _q('inco1', 'El corte láser sirve para…',
              ['cortar materiales con precisión', 'pintar', 'cargar pilas', 'medir tiempo'], 0, 'Corte preciso.'),
          _q('inco2', 'Iterar un prototipo es…', ['probarlo y mejorarlo', 'tirarlo', 'ignorarlo', 'esconderlo'], 0,
              'Mejorar versión tras versión.'),
        ],
      ),
      // --- Controlador ---
      Lesson(
        id: 'in_micro',
        emoji: '🧠',
        title: 'Microcontroladores avanzados',
        subtitle: 'Controlador',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'El cerebro por dentro',
              'Un microcontrolador tiene procesador, memoria y pines. Configurando sus "registros" controlas con detalle cómo se comporta.'),
        ],
        questions: [
          _q('inmi1', 'Un microcontrolador tiene…', ['procesador, memoria y pines', 'ruedas', 'pintura', 'agua'], 0,
              'Un mini-computador.'),
          _q('inmi2', 'Los registros sirven para…', ['configurar el comportamiento', 'pintar', 'medir peso', 'nada'], 0,
              'Ajustes internos finos.'),
        ],
      ),
      Lesson(
        id: 'in_i2c',
        emoji: '🔗',
        title: 'Comunicación I2C y SPI',
        subtitle: 'Controlador',
        cards: [
          const LessonCard(_c, 'Placas que hablan',
              'I2C y SPI son formas de que dos placas o un sensor y un microcontrolador se comuniquen e intercambien datos.'),
        ],
        questions: [
          _q('ini2c1', 'I2C y SPI sirven para…', ['comunicar dispositivos', 'pintar', 'cargar pilas', 'cortar'], 0,
              'Intercambiar datos.'),
          _q('ini2c2', 'Verdadero o Falso: con SPI un microcontrolador puede leer un sensor.', ['Verdadero', 'Falso'],
              0, 'Es un protocolo de comunicación.'),
        ],
      ),
      Lesson(
        id: 'in_pid',
        emoji: '🎯',
        title: 'Control PID y máquinas de estado',
        subtitle: 'Controlador',
        practiceType: _coding,
        challengeId: 'c3',
        cards: [
          const LessonCard(_c, 'Control preciso',
              'El control PID ajusta automáticamente para llegar a un objetivo (como mantener una velocidad). Una máquina de estados organiza el robot en modos (buscar, agarrar, soltar).'),
        ],
        questions: [
          _q('inpid1', 'El control PID sirve para…',
              ['llegar a un objetivo con precisión', 'pintar', 'medir peso', 'nada'], 0, 'Ajuste automático.'),
          _q('inpid2', 'Una máquina de estados organiza el robot en…',
              ['modos o estados', 'colores', 'pilas', 'sonidos'], 0, 'Estados como buscar/agarrar.'),
        ],
      ),
      Lesson(
        id: 'in_retro',
        emoji: '🔄',
        title: 'Sistemas de retroalimentación',
        subtitle: 'Controlador',
        cards: [
          const LessonCard(_c, 'Lazo abierto vs cerrado',
              'En lazo abierto el robot actúa sin revisar el resultado; en lazo cerrado usa un sensor para corregirse y mejorar.'),
        ],
        questions: [
          _q('inre1', 'En lazo cerrado el robot…',
              ['se corrige usando un sensor', 'no revisa nada', 'se apaga', 'pinta'], 0, 'Usa retroalimentación.'),
          _q('inre2', 'En lazo abierto el robot…', ['no revisa el resultado', 'se corrige', 'mide siempre', 'duerme'],
              0, 'Actúa sin verificar.'),
        ],
      ),
      // --- Inteligencia Artificial ---
      Lesson(
        id: 'in_ia',
        emoji: '🧠',
        title: '¿Qué es la IA?',
        subtitle: 'Inteligencia Artificial',
        cards: [
          const LessonCard(_c, 'Máquinas que aprenden',
              'La Inteligencia Artificial permite que una máquina aprenda de ejemplos y tome decisiones, en vez de seguir solo reglas fijas.'),
        ],
        questions: [
          _q('inia1', 'La IA permite que la máquina…', ['aprenda y decida', 'solo se apague', 'pinte', 'nada'], 0,
              'Aprende de datos.'),
          _q('inia2', 'Verdadero o Falso: la IA aprende de ejemplos.', ['Verdadero', 'Falso'], 0,
              'Aprende de datos/ejemplos.'),
        ],
      ),
      Lesson(
        id: 'in_vision',
        emoji: '👁️',
        title: 'Visión por computadora',
        subtitle: 'Inteligencia Artificial',
        cards: [
          const LessonCard(_c, 'Robots que ven',
              'La visión por computadora permite a un robot detectar bordes, reconocer objetos y seguir un color usando una cámara.'),
        ],
        questions: [
          _q('inv1', 'La visión por computadora usa…', ['una cámara para "ver"', 'una pila', 'una rueda', 'pintura'], 0,
              'Procesa imágenes.'),
          _q('inv2', 'Un robot puede seguir…', ['un color', 'un olor', 'un sabor', 'un sueño'], 0,
              'Sigue colores con la cámara.'),
        ],
      ),
      Lesson(
        id: 'in_ml',
        emoji: '🤖',
        title: 'Voz, ML y redes neuronales',
        subtitle: 'Inteligencia Artificial',
        cards: [
          const LessonCard(_c, 'Aprender y obedecer',
              'Con reconocimiento de voz el robot obedece comandos hablados. El Machine Learning entrena modelos con datos, y una red neuronal imita cómo funcionan las neuronas.'),
        ],
        questions: [
          _q('inml1', 'El reconocimiento de voz permite…',
              ['obedecer comandos hablados', 'pintar', 'medir peso', 'cargar pilas'], 0, 'Responde a la voz.'),
          _q('inml2', 'El Machine Learning entrena modelos con…', ['datos/ejemplos', 'pintura', 'agua', 'nada'], 0,
              'Aprende de datos.'),
          _q('inml3', 'Una red neuronal imita…', ['las neuronas del cerebro', 'una pila', 'una rueda', 'un cable'], 0,
              'Inspirada en el cerebro.'),
        ],
      ),
      Lesson(
        id: 'in_iarobot',
        emoji: '🦾',
        title: 'IA aplicada a la robótica',
        subtitle: 'Inteligencia Artificial',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Robots inteligentes',
              'Juntando IA y robótica creas robots que aprenden a esquivar obstáculos y toman decisiones por sí mismos.'),
        ],
        questions: [
          _q('iniar1', 'Un robot con IA puede…', ['aprender a esquivar obstáculos', 'solo apagarse', 'pintar', 'nada'],
              0, 'Aprende y decide.'),
          _q('iniar2', 'Verdadero o Falso: la IA hace al robot más autónomo.', ['Verdadero', 'Falso'], 0,
              'Toma decisiones propias.'),
        ],
      ),
      // --- Integrador ---
      Lesson(
        id: 'in_integra',
        emoji: '🧩',
        title: 'Integración hardware-software',
        subtitle: 'Integrador',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'Que todo trabaje junto',
              'Integrar es conectar los sensores y actuadores con el código para que el robot completo funcione como uno solo.'),
        ],
        questions: [
          _q('inint1', 'Integrar hardware y software es…',
              ['conectar componentes con el código', 'pintar', 'medir peso', 'nada'], 0, 'Que todo trabaje junto.'),
          _q('inint2', 'Verdadero o Falso: el código conecta los sensores con las acciones.', ['Verdadero', 'Falso'], 0,
              'El software une todo.'),
        ],
      ),
      Lesson(
        id: 'in_modulos',
        emoji: '🛰️',
        title: 'Comunicación y multi-sensor',
        subtitle: 'Integrador',
        cards: [
          const LessonCard(_c, 'Módulos que cooperan',
              'Varios módulos pueden comunicarse y sincronizarse; al fusionar datos de varios sensores el robot entiende mejor su entorno.'),
        ],
        questions: [
          _q('inmo1', 'Fusionar datos de varios sensores ayuda a…',
              ['entender mejor el entorno', 'pintar', 'apagar', 'nada'], 0, 'Más información, mejores decisiones.'),
          _q('inmo2', 'Sincronizar módulos significa que…',
              ['trabajan coordinados', 'se ignoran', 'se apagan', 'se pintan'], 0, 'Cooperan en el tiempo.'),
        ],
      ),
      Lesson(
        id: 'in_pruebas',
        emoji: '✅',
        title: 'Arquitectura y pruebas',
        subtitle: 'Integrador',
        cards: [
          const LessonCard(_c, 'Diseñar y probar el sistema',
              'La arquitectura es el plano de cómo se conectan las partes (diagrama de bloques). Las pruebas de integración verifican que todo el sistema funcione y detectan fallos.'),
        ],
        questions: [
          _q('inpru1', 'Un diagrama de bloques muestra…',
              ['cómo se conectan las partes', 'el color', 'la hora', 'el peso'], 0, 'El plano del sistema.'),
          _q('inpru2', 'Las pruebas de integración sirven para…',
              ['verificar y hallar fallos', 'pintar', 'cargar pilas', 'nada'], 0, 'Comprobar todo junto.'),
        ],
      ),
      // --- Robótica ---
      Lesson(
        id: 'in_cinematica',
        emoji: '📐',
        title: 'Cinemática de robots',
        subtitle: 'Robótica',
        cards: [
          const LessonCard(_c, 'Calcular el movimiento',
              'La cinemática calcula dónde estará la mano de un brazo robótico según los ángulos de sus articulaciones.'),
          const LessonCard(_t, 'Seno, coseno, y listo',
              'Para un brazo de 2 segmentos, la posición de la mano se calcula sumando dos vectores: uno por cada segmento, usando seno y coseno del ángulo acumulado hasta ese punto. Pruébalo tú mismo en el simulador — mueve los ángulos y mira cómo las coordenadas X/Y cambian al instante.'),
          const LessonCard(_f, 'Hay un límite que ningún ángulo supera',
              'Por más que combines los ángulos, la mano de un brazo de 2 segmentos nunca puede ir más lejos que la suma de las longitudes de ambos segmentos. A esa zona alcanzable se le llama "espacio de trabajo" del robot — en el simulador es el círculo punteado.'),
        ],
        questions: [
          _q('incin1', 'La cinemática calcula…', ['la posición del brazo', 'el color', 'el sonido', 'la pila'], 0,
              'Posición según los ángulos.'),
          _q('incin2', 'Verdadero o Falso: con los ángulos sabes dónde está la mano del brazo.', ['Verdadero', 'Falso'],
              0, 'Eso hace la cinemática directa.'),
          _q('incin3', 'La zona máxima que la mano de un brazo puede alcanzar, sin importar los ángulos, se llama…',
              ['espacio de trabajo', 'zona prohibida', 'cinemática inversa', 'error de cálculo'], 0,
              'Está limitada por la suma de las longitudes de los segmentos.'),
        ],
      ),
      Lesson(
        id: 'in_tipos',
        emoji: '🚗',
        title: 'Robots móviles vs brazos',
        subtitle: 'Robótica',
        cards: [
          const LessonCard(_c, 'Elige el robot correcto',
              'Los robots móviles se desplazan (ruedas, patas); los brazos robóticos se quedan fijos y manipulan objetos. Cada tarea pide un tipo.'),
        ],
        questions: [
          _q('inti1', 'Un robot móvil sirve para…', ['desplazarse', 'quedarse fijo siempre', 'pintar', 'nada'], 0,
              'Se mueve por el espacio.'),
          _q('inti2', 'Un brazo robótico sirve para…', ['manipular objetos', 'rodar lejos', 'volar', 'dormir'], 0,
              'Agarra y mueve objetos.'),
        ],
      ),
      Lesson(
        id: 'in_navegacion',
        emoji: '🧭',
        title: 'Navegación y comportamientos',
        subtitle: 'Robótica',
        practiceType: _coding,
        challengeId: 'c2',
        cards: [
          const LessonCard(_c, 'Seguir y evitar',
              'Con sensores el robot puede seguir una línea, evitar obstáculos y ejecutar rutinas autónomas tomando sus propias decisiones.'),
        ],
        questions: [
          _q('innav1', 'Para evitar obstáculos el robot usa…', ['sensores', 'pintura', 'una pila vacía', 'nada'], 0,
              'Detecta y esquiva.'),
          _q('innav2', 'Una rutina autónoma es cuando el robot…',
              ['decide y actúa solo', 'espera órdenes siempre', 'se apaga', 'se pinta'], 0, 'Actúa por sí mismo.'),
        ],
      ),
      Lesson(
        id: 'in_colab',
        emoji: '🤝',
        title: 'Robots colaborativos y competencias',
        subtitle: 'Robótica',
        practiceType: _coding,
        challengeId: 'c4',
        cards: [
          const LessonCard(_c, 'Trabajar en equipo',
              'Los robots colaborativos trabajan juntos o con personas para lograr una meta. En las competencias resuelves retos cronometrados.'),
        ],
        questions: [
          _q('incol1', 'Un robot colaborativo…',
              ['trabaja con otros o con personas', 'siempre solo', 'se apaga', 'pinta'], 0, 'Coopera para una meta.'),
          _q('incol2', 'En una competencia de robótica resuelves…',
              ['retos (a veces cronometrados)', 'pinturas', 'recetas', 'nada'], 0, 'Desafíos con reglas.'),
        ],
      ),
    ],
  ),
];
