import 'package:flutter/material.dart';
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/screens/learning/quiz_screen.dart';

/// A STEM category for the online tournaments (and the seed question bank that
/// also powers module quizzes until questions come from Firestore).
class StemCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<QuizQuestionData> questions;

  const StemCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

const List<StemCategory> stemCategories = [
  StemCategory(
    id: 'electronica',
    name: 'Electrónica',
    icon: Icons.bolt_rounded,
    color: AppTheme.accentCyan,
    questions: [
      QuizQuestionData(
        id: 'el1',
        question: '¿Qué componente enciende y emite luz cuando pasa corriente?',
        options: ['Resistencia', 'LED', 'Interruptor', 'Cable'],
        correct: 1,
        explanation: 'El LED (diodo emisor de luz) se ilumina al pasar corriente en el sentido correcto.',
      ),
      QuizQuestionData(
        id: 'el2',
        question: '¿Para qué sirve una resistencia en un circuito?',
        options: ['Para generar luz', 'Para limitar la corriente', 'Para almacenar datos', 'Para hacer ruido'],
        correct: 1,
        explanation: 'La resistencia limita o controla cuánta corriente pasa, protegiendo otros componentes.',
      ),
      QuizQuestionData(
        id: 'el3',
        question: '¿Qué necesita un circuito para que la corriente fluya?',
        options: ['Estar abierto', 'Estar cerrado (completo)', 'No tener pila', 'Estar mojado'],
        correct: 1,
        explanation: 'La corriente solo fluye en un circuito cerrado: un camino completo desde la pila y de vuelta.',
      ),
      QuizQuestionData(
        id: 'el4',
        question: '¿Qué guarda energía y la entrega a tu robot?',
        options: ['La batería', 'El LED', 'El sensor', 'La hélice'],
        correct: 0,
        explanation: 'La batería almacena energía eléctrica que alimenta al robot.',
      ),
      QuizQuestionData(
        id: 'el5',
        question: '¿Qué hace un interruptor?',
        options: ['Mide temperatura', 'Abre o cierra el paso de la corriente', 'Da color', 'Suma números'],
        correct: 1,
        explanation: 'El interruptor abre (corta) o cierra (permite) el paso de la corriente.',
      ),
    ],
  ),
  StemCategory(
    id: 'programacion',
    name: 'Programación',
    icon: Icons.code_rounded,
    color: AppTheme.primaryBlue,
    questions: [
      QuizQuestionData(
        id: 'pr1',
        question: '¿Qué es un "bucle" (loop) en programación?',
        options: ['Un error', 'Repetir instrucciones varias veces', 'Borrar el código', 'Apagar el robot'],
        correct: 1,
        explanation: 'Un bucle repite un bloque de instrucciones, por ejemplo "avanza 4 veces".',
      ),
      QuizQuestionData(
        id: 'pr2',
        question: 'Para que el robot decida entre dos caminos, usamos una instrucción...',
        options: ['condicional (si/entonces)', 'de color', 'de sonido', 'de batería'],
        correct: 0,
        explanation: 'Las condicionales (si… entonces…) permiten tomar decisiones según lo que ocurre.',
      ),
      QuizQuestionData(
        id: 'pr3',
        question: '¿Qué es un algoritmo?',
        options: ['Un tipo de cable', 'Una serie de pasos para resolver algo', 'Una pila', 'Un robot'],
        correct: 1,
        explanation: 'Un algoritmo es una secuencia ordenada de pasos para lograr una tarea.',
      ),
      QuizQuestionData(
        id: 'pr4',
        question: 'Si tu programa no funciona como esperabas, tiene un...',
        options: ['bug (error)', 'premio', 'sensor', 'motor'],
        correct: 0,
        explanation: 'Un "bug" es un error en el código; corregirlo se llama "debuggear".',
      ),
      QuizQuestionData(
        id: 'pr5',
        question: '¿Qué hace la instrucción "avanzar" en un robot?',
        options: ['Lo apaga', 'Lo mueve hacia adelante', 'Cambia su color', 'Lo recarga'],
        correct: 1,
        explanation: 'Es una orden de movimiento: el robot se desplaza hacia adelante.',
      ),
    ],
  ),
  StemCategory(
    id: 'mecanica',
    name: 'Mecánica',
    icon: Icons.settings_rounded,
    color: AppTheme.toneAzure,
    questions: [
      QuizQuestionData(
        id: 'me1',
        question: '¿Qué componente convierte la electricidad en movimiento?',
        options: ['El motor', 'La resistencia', 'El LED', 'El cable'],
        correct: 0,
        explanation: 'El motor transforma energía eléctrica en movimiento (rotación).',
      ),
      QuizQuestionData(
        id: 'me2',
        question: '¿Para qué sirven los engranajes?',
        options: ['Para dar luz', 'Para transmitir y cambiar el movimiento', 'Para medir', 'Para guardar datos'],
        correct: 1,
        explanation: 'Los engranajes transmiten movimiento y pueden cambiar su velocidad o fuerza.',
      ),
      QuizQuestionData(
        id: 'me3',
        question: '¿Qué parte del robot le permite rodar por el suelo?',
        options: ['Las ruedas', 'La antena', 'El sensor', 'La pantalla'],
        correct: 0,
        explanation: 'Las ruedas, movidas por motores, permiten que el robot se desplace.',
      ),
      QuizQuestionData(
        id: 'me4',
        question: 'Una rueda grande comparada con una pequeña, por cada vuelta...',
        options: ['avanza más', 'avanza menos', 'no se mueve', 'gira al revés'],
        correct: 0,
        explanation: 'Con mayor diámetro, cada vuelta cubre más distancia.',
      ),
      QuizQuestionData(
        id: 'me5',
        question: '¿Qué es la estructura o chasis de un robot?',
        options: ['Su cerebro', 'El cuerpo que sostiene las piezas', 'Su batería', 'Su programa'],
        correct: 1,
        explanation: 'El chasis es la estructura que sostiene y conecta todos los componentes.',
      ),
    ],
  ),
  StemCategory(
    id: 'logica',
    name: 'Lógica',
    icon: Icons.extension_rounded,
    color: AppTheme.accentPurple,
    questions: [
      QuizQuestionData(
        id: 'lo1',
        question: 'Sigue el patrón: 2, 4, 6, 8, ...',
        options: ['9', '10', '12', '7'],
        correct: 1,
        explanation: 'El patrón suma 2 cada vez: 8 + 2 = 10.',
      ),
      QuizQuestionData(
        id: 'lo2',
        question: 'Si "todos los robots tienen sensores" y "Robi es un robot", entonces Robi...',
        options: ['no tiene sensores', 'tiene sensores', 'es una pila', 'es un humano'],
        correct: 1,
        explanation: 'Por deducción lógica, si todos los robots tienen sensores, Robi también.',
      ),
      QuizQuestionData(
        id: 'lo3',
        question: '¿Qué figura completa la serie: 🔺🔺🔺...?',
        options: ['Un círculo', 'Otro triángulo', 'Un cuadrado', 'Nada'],
        correct: 1,
        explanation: 'El patrón se repite con triángulos, así que sigue otro triángulo.',
      ),
      QuizQuestionData(
        id: 'lo4',
        question: 'Para resolver un problema grande, conviene...',
        options: ['ignorarlo', 'dividirlo en pasos pequeños', 'apagar el robot', 'adivinar'],
        correct: 1,
        explanation: 'Dividir un problema en partes pequeñas (descomposición) lo hace más fácil.',
      ),
      QuizQuestionData(
        id: 'lo5',
        question: '¿Cuál NO encaja en el grupo: rueda, motor, batería, manzana?',
        options: ['Rueda', 'Motor', 'Batería', 'Manzana'],
        correct: 3,
        explanation: 'La manzana no es un componente de robot; las demás sí.',
      ),
    ],
  ),
  StemCategory(
    id: 'ciencia',
    name: 'Ciencia',
    icon: Icons.science_rounded,
    color: AppTheme.toneNavy,
    questions: [
      QuizQuestionData(
        id: 'ci1',
        question: '¿Qué energía usan la mayoría de los robots pequeños?',
        options: ['Energía eléctrica', 'Energía mágica', 'Energía sonora', 'Ninguna'],
        correct: 0,
        explanation: 'Funcionan con energía eléctrica, normalmente de baterías.',
      ),
      QuizQuestionData(
        id: 'ci2',
        question: '¿Qué sentido del robot es un sensor ultrasónico parecido a...?',
        options: ['el oído del murciélago', 'el gusto', 'el tacto del oso', 'el olfato'],
        correct: 0,
        explanation: 'Usa ecos de sonido para medir distancias, como el murciélago.',
      ),
      QuizQuestionData(
        id: 'ci3',
        question: '¿Qué hace un sensor en un robot?',
        options: ['Lo decora', 'Capta información del entorno', 'Le da color', 'Lo apaga'],
        correct: 1,
        explanation: 'Los sensores detectan luz, distancia, temperatura, etc., del entorno.',
      ),
      QuizQuestionData(
        id: 'ci4',
        question: 'La fuerza que nos mantiene pegados al suelo se llama...',
        options: ['gravedad', 'fricción', 'imán', 'viento'],
        correct: 0,
        explanation: 'La gravedad es la fuerza que atrae los objetos hacia la Tierra.',
      ),
      QuizQuestionData(
        id: 'ci5',
        question: '¿Qué es el método científico?',
        options: ['Adivinar respuestas', 'Observar, preguntar, experimentar y concluir', 'Copiar', 'Apagar todo'],
        correct: 1,
        explanation: 'Es la forma de investigar: observar, plantear preguntas, experimentar y sacar conclusiones.',
      ),
    ],
  ),
];

StemCategory categoryById(String id) =>
    stemCategories.firstWhere((c) => c.id == id, orElse: () => stemCategories.first);

/// Seed quiz used by the learning loop (module → "Ir al Quiz") until module
/// questions are loaded from Firestore. Returns a small mixed STEM set.
List<QuizQuestionData> seedModuleQuiz(String moduleId) {
  // Deterministic-ish mix so different modules feel a bit different.
  final pool = <QuizQuestionData>[
    stemCategories[0].questions[0],
    stemCategories[4].questions[2],
    stemCategories[2].questions[0],
    stemCategories[1].questions[0],
    stemCategories[3].questions[0],
  ];
  return pool;
}
