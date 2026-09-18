// ============================================================
// CULTIVAQUEST — contenido de las lecciones
// Cada "unidad" es un grupo de niveles. Cada nivel (lección) tiene:
//   - cards: tarjetas de contenido (concepto / ejemplo / dato / consejo)
//   - questions: el cuestionario al final
//   - practice: opcional, un botón que manda a practicar en CultivaLab
// ============================================================

const QUEST_UNITS = [
  {
    id: 'mundo-robots',
    nombre: 'El mundo de los robots',
    lecciones: [
      {
        id: 'ch_robots',
        emoji: '🤖',
        titulo: 'Identifica robots',
        practice: { tipo: 'bloques', etiqueta: 'Practica en Bloques' },
        cards: [
          { tipo: 'concepto', titulo: '¿Qué es un robot?',
            texto: 'Un robot es una máquina que puede sentir, pensar y actuar. No todo lo que se mueve es un robot: necesita sensores, un "cerebro" y partes que se muevan.' },
          { tipo: 'ejemplo', titulo: '¿Robot o no?',
            texto: 'Una lavadora con sensores y programa es casi un robot; una silla no lo es. Una aspiradora que esquiva muebles, ¡sí!' },
        ],
        preguntas: [
          { pregunta: 'Un robot puede sentir, pensar y…', opciones: ['comer', 'actuar', 'dormir', 'cantar'], correcta: 1, explicacion: 'Siente, decide y actúa.' },
          { pregunta: 'Verdadero o Falso: una silla es un robot.', opciones: ['Verdadero', 'Falso'], correcta: 1, explicacion: 'No siente ni decide ni se mueve sola.' },
          { pregunta: '¿Cuál SÍ es un robot?', opciones: ['una aspiradora que esquiva muebles', 'una piedra', 'un cuaderno', 'un vaso'], correcta: 0, explicacion: 'Siente y decide para moverse.' },
        ],
      },
      {
        id: 'ch_partes',
        emoji: '🦾',
        titulo: 'Partes de un robot',
        cards: [
          { tipo: 'concepto', titulo: 'Las 4 partes',
            texto: 'Un robot tiene: sensores (sentidos), actuadores (movimiento), control (cerebro) y alimentación (energía/batería).' },
          { tipo: 'ejemplo', titulo: 'Como tu cuerpo',
            texto: 'Los sensores son tus ojos y oídos, los actuadores tus músculos, el control tu cerebro y la batería tu comida.' },
        ],
        preguntas: [
          { pregunta: '¿Qué parte capta el entorno?', opciones: ['el sensor', 'el actuador', 'la batería', 'el tornillo'], correcta: 0, explicacion: 'Los sensores captan información.' },
          { pregunta: '¿Qué parte da el movimiento?', opciones: ['el actuador (motor)', 'el sensor', 'la batería', 'la antena'], correcta: 0, explicacion: 'Los actuadores mueven al robot.' },
          { pregunta: '¿Qué parte le da energía?', opciones: ['la alimentación (batería)', 'el sensor', 'el control', 'la rueda'], correcta: 0, explicacion: 'La batería alimenta todo.' },
        ],
      },
      {
        id: 'ch_sensores',
        emoji: '👀',
        titulo: 'Sensores',
        cards: [
          { tipo: 'concepto', titulo: 'Los "sentidos" del robot',
            texto: 'Un sensor capta información del entorno: luz, distancia, sonido, temperatura o si algo lo toca. Sin sensores, el robot estaría "ciego".' },
          { tipo: 'ejemplo', titulo: 'Ejemplos de sensores',
            texto: 'Un sensor de luz sabe si está oscuro. Un sensor de distancia sabe si hay algo enfrente. Un sensor de tacto sabe si lo tocaron.' },
          { tipo: 'dato', titulo: '¡Como tus ojos!',
            texto: 'Tus ojos, oídos, nariz y piel también son sensores — le mandan información a tu cerebro todo el tiempo.' },
        ],
        preguntas: [
          { pregunta: '¿Para qué sirve un sensor?', opciones: ['Para mover al robot', 'Para captar información del entorno', 'Para darle energía', 'Para pintarlo'], correcta: 1, explicacion: 'Los sensores captan lo que pasa alrededor del robot.' },
          { pregunta: 'Si un robot necesita saber qué tan oscuro está, ¿qué sensor usa?', opciones: ['de distancia', 'de luz', 'de sonido', 'de tacto'], correcta: 1, explicacion: 'El sensor de luz mide cuánta luz hay.' },
          { pregunta: 'Verdadero o Falso: sin sensores, el robot no sabe qué pasa a su alrededor.', opciones: ['Verdadero', 'Falso'], correcta: 0, explicacion: 'Los sensores son los "sentidos" del robot.' },
        ],
      },
      {
        id: 'ch_actuadores',
        emoji: '⚙️',
        titulo: 'Actuadores',
        cards: [
          { tipo: 'concepto', titulo: 'Lo que hace que el robot se mueva',
            texto: 'Un actuador es la parte que produce movimiento: motores que giran ruedas, brazos que se doblan, o incluso una luz que se enciende.' },
          { tipo: 'ejemplo', titulo: 'Ejemplos de actuadores',
            texto: 'Un motor hace girar una rueda. Un servomotor mueve un brazo a un ángulo exacto. Un LED es un actuador de luz.' },
        ],
        preguntas: [
          { pregunta: '¿Qué parte produce movimiento en un robot?', opciones: ['el sensor', 'el actuador', 'la batería', 'el cable'], correcta: 1, explicacion: 'Los actuadores son los que mueven al robot.' },
          { pregunta: '¿Cuál de estos es un actuador?', opciones: ['un motor', 'un foco de luz de la calle', 'una piedra', 'un cuaderno'], correcta: 0, explicacion: 'El motor convierte electricidad en movimiento.' },
          { pregunta: 'Un actuador es como…', opciones: ['los ojos de un robot', 'los músculos de un robot', 'la comida de un robot', 'la piel de un robot'], correcta: 1, explicacion: 'Así como tus músculos te mueven, los actuadores mueven al robot.' },
        ],
      },
      {
        id: 'ch_control',
        emoji: '🧠',
        titulo: 'Control',
        cards: [
          { tipo: 'concepto', titulo: 'El "cerebro" del robot',
            texto: 'El control es la parte que decide qué hacer con la información de los sensores. Es el "cerebro": recibe datos y manda órdenes a los actuadores.' },
          { tipo: 'ejemplo', titulo: 'Un ejemplo sencillo',
            texto: 'Si el sensor de distancia detecta un obstáculo (información), el control decide "girar" y le ordena al motor (actuador) que gire.' },
        ],
        preguntas: [
          { pregunta: '¿Qué parte decide qué hacer con la información?', opciones: ['el sensor', 'el control', 'la batería', 'la rueda'], correcta: 1, explicacion: 'El control es el cerebro que decide.' },
          { pregunta: 'El control recibe información de…', opciones: ['los actuadores', 'los sensores', 'la batería', 'el usuario únicamente'], correcta: 1, explicacion: 'Recibe datos de los sensores para decidir.' },
          { pregunta: 'Verdadero o Falso: el control le da órdenes a los actuadores.', opciones: ['Verdadero', 'Falso'], correcta: 0, explicacion: 'El control decide y ordena a los actuadores qué hacer.' },
        ],
      },
      {
        id: 'ch_alimentacion',
        emoji: '🔋',
        titulo: 'Alimentación',
        cards: [
          { tipo: 'concepto', titulo: 'La energía del robot',
            texto: 'La alimentación es lo que le da energía a todo el robot: sin ella, ni los sensores, ni el control, ni los actuadores funcionan.' },
          { tipo: 'ejemplo', titulo: 'Ejemplos',
            texto: 'Pilas, baterías recargables, o incluso paneles solares pueden alimentar a un robot.' },
          { tipo: 'consejo', titulo: 'Cuídala',
            texto: 'Un robot sin batería es como tú sin haber comido: no tiene energía para hacer nada.' },
        ],
        preguntas: [
          { pregunta: '¿Qué le pasa a un robot sin alimentación?', opciones: ['funciona más rápido', 'no funciona nada', 'se vuelve más inteligente', 'nada, no la necesita'], correcta: 1, explicacion: 'Sin energía, ninguna parte del robot funciona.' },
          { pregunta: '¿Cuál de estos es una fuente de alimentación?', opciones: ['una batería', 'un sensor de luz', 'una rueda', 'un cable de datos'], correcta: 0, explicacion: 'La batería almacena y da energía.' },
          { pregunta: 'La alimentación es como…', opciones: ['los músculos', 'el cerebro', 'la comida', 'los ojos'], correcta: 2, explicacion: 'Así como tú necesitas comida para tener energía, el robot necesita su batería.' },
        ],
      },
      {
        id: 'ch_conecta_mec',
        emoji: '🔩',
        titulo: 'Conecta la mecánica',
        cards: [
          { tipo: 'concepto', titulo: 'Primero, el cuerpo',
            texto: 'Antes de que un robot funcione, hay que armar su cuerpo: ruedas, tornillos, soportes y piezas que sostienen todo junto.' },
          { tipo: 'ejemplo', titulo: 'Un ejemplo',
            texto: 'Si le pones la rueda floja a un robot, aunque el motor gire bien, ¡la rueda no va a avanzar derecho!' },
        ],
        preguntas: [
          { pregunta: '¿Qué se arma primero en un robot?', opciones: ['el código', 'el cuerpo (mecánica)', 'la batería únicamente', 'nada, se arma todo junto sin orden'], correcta: 1, explicacion: 'Primero se arma el cuerpo para que sostenga todas las partes.' },
          { pregunta: 'Si una rueda está floja, ¿qué puede pasar?', opciones: ['nada, no importa', 'el robot no se mueve bien', 'el robot se vuelve más rápido', 'el sensor deja de funcionar'], correcta: 1, explicacion: 'Una parte mecánica floja afecta el movimiento del robot.' },
          { pregunta: 'Verdadero o Falso: la mecánica es el cuerpo del robot.', opciones: ['Verdadero', 'Falso'], correcta: 0, explicacion: 'La mecánica son las piezas físicas que sostienen todo.' },
        ],
      },
      {
        id: 'ch_conecta_elec',
        emoji: '⚡',
        titulo: 'Conecta la electrónica',
        practice: { tipo: 'circuitos', etiqueta: 'Practica en Circuitos' },
        cards: [
          { tipo: 'concepto', titulo: 'Ahora, la energía',
            texto: 'Después del cuerpo, hay que conectar la parte eléctrica: la batería, los cables y los componentes que hacen que algo encienda o se mueva.' },
          { tipo: 'ejemplo', titulo: 'Tu primer circuito',
            texto: 'Conectar una batería a un LED es el circuito más sencillo que existe: el + va al + y el − va al −.' },
        ],
        preguntas: [
          { pregunta: '¿Qué conectamos después de armar el cuerpo del robot?', opciones: ['la electrónica', 'nada más', 'solo el nombre del robot', 'los dibujos'], correcta: 0, explicacion: 'Después de la mecánica, se conecta la electrónica.' },
          { pregunta: 'En un circuito sencillo, el + de la batería va…', opciones: ['al − del LED', 'al + del LED', 'a ningún lado', 'a otra batería siempre'], correcta: 1, explicacion: 'Positivo con positivo, negativo con negativo.' },
          { pregunta: 'Verdadero o Falso: sin conectar la electrónica, el robot no enciende.', opciones: ['Verdadero', 'Falso'], correcta: 0, explicacion: 'La electrónica es la que le da vida al robot.' },
        ],
      },
      {
        id: 'ch_instrucciones',
        emoji: '📝',
        titulo: 'Dale instrucciones',
        practice: { tipo: 'bloques', etiqueta: 'Practica en Bloques' },
        cards: [
          { tipo: 'concepto', titulo: 'El robot no adivina',
            texto: 'Un robot solo hace lo que le decimos, paso a paso. A esa lista de pasos se le llama "instrucciones" o "código".' },
          { tipo: 'ejemplo', titulo: 'Ejemplo de instrucciones',
            texto: '"Avanza", "gira a la derecha", "avanza otra vez" — cada palabra es una instrucción que el robot sigue en orden.' },
          { tipo: 'consejo', titulo: 'El orden importa',
            texto: 'Si cambias el orden de las instrucciones, ¡el robot puede terminar en un lugar totalmente distinto!' },
        ],
        preguntas: [
          { pregunta: '¿Cómo sabe un robot qué hacer?', opciones: ['lo adivina', 'siguiendo instrucciones que le damos', 'lo decide él solo sin ayuda', 'nunca sabe qué hacer'], correcta: 1, explicacion: 'El robot sigue las instrucciones que programamos.' },
          { pregunta: 'A la lista de pasos que sigue un robot se le llama…', opciones: ['batería', 'instrucciones (código)', 'sensor', 'actuador'], correcta: 1, explicacion: 'Esa lista de pasos es el código o instrucciones.' },
          { pregunta: 'Verdadero o Falso: el orden de las instrucciones no importa.', opciones: ['Verdadero', 'Falso'], correcta: 1, explicacion: 'El orden sí importa — cambiar el orden puede cambiar el resultado.' },
        ],
      },
      {
        id: 'ch_arma',
        emoji: '🔧',
        titulo: 'Arma un robot',
        practice: { tipo: 'bloques', etiqueta: 'Practica en Bloques' },
        cards: [
          { tipo: 'concepto', titulo: 'Mecánica, electrónica e instrucciones',
            texto: 'Para armar un robot conectas su mecánica (cuerpo y motores), su electrónica (cables y energía) y le das instrucciones (programa).' },
          { tipo: 'consejo', titulo: 'Orden',
            texto: 'Primero el cuerpo, luego las conexiones, y al final el programa que lo controla.' },
        ],
        preguntas: [
          { pregunta: 'Para que el robot se mueva primero conectas su…', opciones: ['mecánica y electrónica', 'color', 'nombre', 'sonido'], correcta: 0, explicacion: 'El cuerpo y las conexiones.' },
          { pregunta: '¿Qué le dice al robot qué hacer?', opciones: ['las instrucciones (programa)', 'la pintura', 'el tamaño', 'la batería vacía'], correcta: 0, explicacion: 'El programa lo controla.' },
          { pregunta: 'Verdadero o Falso: el programa va al final.', opciones: ['Verdadero', 'Falso'], correcta: 0, explicacion: 'Primero armas, luego programas.' },
        ],
      },
    ],
  },
  // Aquí seguirán las próximas unidades: "Circuitos Mágicos", "Código Visual", "Arma tu brazo robótico"...
];