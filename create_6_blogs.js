const fs = require('fs');
const path = require('path');

const blogDir = path.join(__dirname, 'blog');

const templates = [
  {
    name: 'guia-abrir-club-robotica-secundaria.html',
    title: 'Guía definitiva para abrir un club de robótica en tu escuela secundaria',
    desc: 'Pasos prácticos para iniciar un club de robótica escolar con bajo presupuesto, desde conseguir el equipo hasta mantener el interés de los alumnos.',
    kw: 'club de robótica escolar, abrir club robótica, robótica secundaria, actividades extracurriculares STEM',
    cat: 't-brand',
    catName: 'Gestión Escolar',
    icon: 'ph-users-three',
    date: '28 jul 2026',
    time: '8 min',
    imgId: '1581091226825-a6a2a5aee158',
    headline: 'Guía definitiva para abrir un club de robótica en tu escuela secundaria',
    content: `
      <p>Crear un club de robótica desde cero en una secundaria puede parecer una tarea titánica. ¿De dónde sacamos el presupuesto? ¿Quién lo va a impartir? ¿Qué material compramos primero?</p>
      <p>La realidad es que los clubes más exitosos no empiezan con decenas de miles de pesos en equipo, sino con un grupo de estudiantes curiosos y un docente dispuesto a aprender con ellos. Aquí te presentamos una guía paso a paso para arrancar.</p>
      
      <h2>1. Define el objetivo (No, no tiene que ser ganar torneos)</h2>
      <p>El error más común es pensar que un club de robótica existe exclusivamente para ir a competencias de First LEGO League o WRO. Aunque las competencias son geniales, el objetivo principal debe ser crear un espacio de <strong>experimentación sin miedo al fracaso</strong>. Define si tu enfoque será recreativo, preparatorio para preparatoria, o competitivo.</p>
      
      <h2>2. El equipo mínimo viable</h2>
      <p>No necesitas comprar kits carísimos. Para empezar, la plataforma <strong>CultivaTec</strong> te permite iniciar con simuladores 3D donde los alumnos aprenden electrónica y programación sin quemar componentes reales. Cuando estén listos, puedes adquirir 3 o 4 kits básicos de Arduino que se comparten en equipos de 4 personas.</p>
      
      <h2>3. Consigue aliados estratégicos</h2>
      <p>Involucra a los padres de familia desde el día uno. A menudo, padres que son ingenieros, mecánicos o programadores están más que dispuestos a donar un par de horas al mes para dar una charla técnica o ayudar a resolver un problema con el código.</p>
      
      <h2>4. Establece roles claros</h2>
      <p>Un equipo de robótica necesita más que programadores. Necesitas constructores, diseñadores, un vocero (alguien que explique el proyecto) y un administrador de materiales. Esto permite que alumnos con distintos talentos se integren y brillen.</p>
      
      <div class="article-note">
        <i class="ph-fill ph-lightbulb"></i>
        <p><strong>El secreto del éxito:</strong> La consistencia es clave. Es mejor reunirse una hora a la semana sagradamente, que tres horas al mes cuando sobra tiempo. Establece un día fijo y respétalo.</p>
      </div>
    `
  },
  {
    name: 'python-ninos-transicion-bloques.html',
    title: 'Programación en Python para niños: Transición desde bloques',
    desc: 'Cuándo y cómo hacer la transición de la programación por bloques (Scratch) a lenguajes basados en texto como Python para niños de primaria alta y secundaria.',
    kw: 'Python para niños, programación bloques a texto, enseñar Python escuela, coding niños',
    cat: 't-ai',
    catName: 'Programación',
    icon: 'ph-code',
    date: '28 jul 2026',
    time: '6 min',
    imgId: '1526379095098-d400fd0bfce8',
    headline: 'Python para niños: Cuándo y cómo hacer la transición desde los bloques',
    content: `
      <p>La programación por bloques (como Scratch o el entorno de bloques de CultivaTec) es la puerta de entrada perfecta. Permite a los alumnos entender la lógica sin frustrarse por olvidar un punto y coma. Pero inevitablemente llega el momento en que los alumnos se sienten "encerrados" en las limitaciones visuales y están listos para escribir código real.</p>
      
      <h2>¿Cuándo es el momento adecuado?</h2>
      <p>No se trata de edad, sino de madurez lógica. Si un alumno ya entiende perfectamente qué es un bucle (loop), cómo usar sentencias condicionales complejas (if/else anidados) y utiliza variables sin confundirse, está listo para el texto. Usualmente esto ocurre entre 6to de primaria y 2do de secundaria.</p>
      
      <h2>¿Por qué Python?</h2>
      <p>Python es el lenguaje ideal para la transición porque su sintaxis lee casi como el inglés común. No hay llaves raras ni declaraciones excesivas. Un <code>print("Hola")</code> hace exactamente lo que dice.</p>
      
      <h2>Estrategias para una transición suave</h2>
      <ul>
        <li><strong>El método del espejo:</strong> Pon el código de bloques al lado del código en Python. En CultivaTec, esto se puede hacer con un solo clic, permitiendo a los alumnos ver exactamente cómo su bloque "repetir 10 veces" se traduce a un <code>for i in range(10):</code>.</li>
        <li><strong>Fomenta la mecanografía:</strong> El mayor obstáculo al pasar a texto no es la lógica, es encontrar las teclas en el teclado (como los corchetes o el guión bajo). Juegos de mecanografía (typing) ayudan enormemente.</li>
        <li><strong>No castigues los errores de sintaxis:</strong> Acostumbrarse a que una mayúscula rompa todo el programa es frustrante. Enséñales a leer los mensajes de error como "pistas" de un detective, no como calificaciones reprobatorias.</li>
      </ul>
      
      <div class="article-note">
        <i class="ph-fill ph-lightbulb"></i>
        <p><strong>El rol de la IA:</strong> La inteligencia artificial socrática es el mejor aliado aquí. En lugar de darle la respuesta al alumno cuando le falta un paréntesis, la IA le pregunta: "¿Revisaste si cerraste todas las funciones en la línea 12?".</p>
      </div>
    `
  },
  {
    name: 'beneficios-cognitivos-robotica-educativa.html',
    title: 'Beneficios cognitivos de la robótica educativa | Neurociencia',
    desc: 'Lo que dice la neurociencia sobre cómo la robótica desarrolla habilidades cognitivas avanzadas, funciones ejecutivas y plasticidad cerebral en los niños.',
    kw: 'beneficios cognitivos robótica, neurociencia educación STEM, desarrollo cerebral robótica infantil',
    cat: 't-ok',
    catName: 'Neurociencia',
    icon: 'ph-brain',
    date: '28 jul 2026',
    time: '7 min',
    imgId: '1559757149-0c5480ceca05',
    headline: 'Beneficios cognitivos de la robótica educativa: Lo que dice la neurociencia',
    content: `
      <p>Sabemos empíricamente que a los niños les encanta construir robots, pero ¿qué está pasando realmente dentro de sus cerebros cuando conectan un sensor a un microcontrolador? La neurociencia educativa ha comenzado a medir los impactos tangibles de la robótica en la arquitectura cognitiva infantil.</p>
      
      <h2>1. Funciones Ejecutivas de Alto Nivel</h2>
      <p>Cuando un estudiante planea cómo armar un mecanismo, prueba, falla y vuelve a intentar, está ejercitando fuertemente el córtex prefrontal. Esta área del cerebro gestiona las <strong>funciones ejecutivas</strong>: la planificación, la memoria de trabajo y la flexibilidad cognitiva. La robótica no perdona la impulsividad; obliga al cerebro a pensar antes de actuar.</p>
      
      <h2>2. Razonamiento Espacial Reforzado</h2>
      <p>Manipular objetos físicos (engranajes, chasis) y ver su representación en simuladores 3D fortalece el surco intraparietal. Los estudios demuestran que los niños expuestos a la construcción 3D mejoran significativamente en pruebas estandarizadas de geometría y física meses después, debido a su mejorada capacidad para rotar objetos mentalmente.</p>
      
      <h2>3. Tolerancia a la Frustración (Regulación Emocional)</h2>
      <p>La amígdala (el centro emocional del cerebro) recibe un entrenamiento intensivo en las clases de robótica. En el código, el error no es un fracaso que merezca un cero, es un dato más (un "bug" a resolver). Este cambio de paradigma enseña resiliencia neurobiológica: el cerebro aprende a no disparar respuestas de estrés paralizante ante un problema, sino a activar redes de resolución.</p>
      
      <h2>El poder de lo tangible</h2>
      <p>Aprender conceptos matemáticos abstractos (como variables o algoritmos) a través de la retroalimentación física de un motor girando consolida las conexiones sinápticas mucho más rápido que leerlo en un pizarrón.</p>
      
      <div class="article-note">
        <i class="ph-fill ph-lightbulb"></i>
        <p><strong>Conclusión:</strong> Enseñar robótica no se trata de crear futuros ingenieros mecatrónicos (aunque algunos lo serán); se trata de esculpir cerebros más resilientes, lógicos y adaptables, listos para cualquier profesión.</p>
      </div>
    `
  },
  {
    name: 'hardware-vs-simuladores-escuelas.html',
    title: 'Hardware vs Simuladores: Por qué tu escuela necesita ambos',
    desc: 'Análisis de las ventajas de los simuladores 3D y el hardware físico en la educación tecnológica. Por qué combinarlos es el modelo ideal para colegios.',
    kw: 'simuladores de robótica, hardware educativo, simuladores vs hardware, equipo robótica colegios',
    cat: 't-sim',
    catName: 'Tecnología',
    icon: 'ph-cpu',
    date: '28 jul 2026',
    time: '5 min',
    imgId: '1518770660439-4636190af475',
    headline: 'Hardware vs Simuladores: Por qué tu escuela necesita ambos',
    content: `
      <p>El debate en la academia de tecnología suele dividirse en dos bandos: los puristas que creen que si no hueles a soldadura quemada no estás aprendiendo robótica, y los modernos que aseguran que todo se puede aprender en una pantalla. La verdad pedagógica se encuentra exactamente en medio.</p>
      
      <h2>El poder democratizador del Simulador</h2>
      <p>Los simuladores son el gran nivelador. Sus ventajas son indiscutibles:</p>
      <ul>
        <li><strong>Prueba y error a coste cero:</strong> Un alumno puede conectar un LED directo a 9 voltios. En la vida real, eso significa hardware destruido y presupuesto perdido. En el simulador, solo es una animación de humo y una gran lección aprendida.</li>
        <li><strong>Escalabilidad:</strong> 30 alumnos pueden estar armando circuitos complejos simultáneamente sin que el colegio tenga que comprar 30 kits avanzados.</li>
        <li><strong>Foco en la lógica:</strong> Aisla los problemas mecánicos (cables falsos, pilas descargadas) para que el alumno se concentre puramente en si su código y su lógica electrónica son correctos.</li>
      </ul>
      
      <h2>La magia irremplazable del Hardware Físico</h2>
      <p>Sin embargo, un simulador nunca enseñará la fricción del mundo real.</p>
      <ul>
        <li><strong>Problemas del mundo físico:</strong> La luz del sol afectando un sensor infrarrojo, la batería que pierde potencia afectando la velocidad de un motor, el peso desequilibrado del robot. Aprender a compensar estas variables es donde nace la verdadera ingeniería.</li>
        <li><strong>El efecto "¡Wow!":</strong> No hay nada en una pantalla que iguale el brillo en los ojos de un niño cuando el carrito que armaron con sus propias manos cobra vida en el piso del salón.</li>
      </ul>
      
      <h2>El modelo híbrido de CultivaTec</h2>
      <p>El estándar de oro es el método de <strong>Prototipado Virtual a Físico</strong>. Los alumnos diseñan, programan y validan sus circuitos en el simulador. Una vez que la plataforma certifica que funciona, se ganan el derecho a armarlo en físico. Esto reduce drásticamente el daño a materiales y acelera el aprendizaje exponencialmente.</p>
    `
  },
  {
    name: 'evaluar-proyectos-robotica-sin-examenes.html',
    title: 'Cómo evaluar proyectos de robótica sin exámenes escritos',
    desc: 'Metodologías alternativas para evaluar el aprendizaje STEM y robótica educativa mediante rúbricas, bitácoras y presentaciones.',
    kw: 'evaluación robótica, rúbricas proyectos STEM, cómo calificar robótica, evaluación alternativa escuela',
    cat: 't-rose',
    catName: 'Pedagogía',
    icon: 'ph-chalkboard-teacher',
    date: '28 jul 2026',
    time: '6 min',
    imgId: '1434030216411-0b793f4b4273',
    headline: 'Cómo evaluar proyectos de robótica sin hacer exámenes escritos',
    content: `
      <p>Si la robótica es la materia más innovadora de la currícula escolar, ¿por qué seguimos evaluándola con exámenes de opción múltiple del siglo XX? Calificar a un estudiante sobre "cuál es el símbolo de una resistencia" en un papel no mide su capacidad para resolver problemas reales.</p>
      
      <p>Aquí te presentamos tres estrategias probadas para evaluar el desempeño en laboratorios Maker y clases de robótica.</p>
      
      <h2>1. La Bitácora del Error (El diario de ingeniería)</h2>
      <p>En lugar de calificar si el robot final funciona perfectamente, evalúa el proceso. Se le pide al alumno que lleve una bitácora simple (digital o en papel) donde documente:</p>
      <ul>
        <li>¿Qué intentamos hacer hoy?</li>
        <li>¿Qué falló dramáticamente?</li>
        <li>¿Por qué creemos que falló?</li>
        <li>¿Qué haremos diferente la próxima clase?</li>
      </ul>
      <p>Un alumno cuyo robot no logró moverse, pero documentó exhaustivamente por qué el peso afectó el torque de los motores, ha aprendido más que el equipo cuyo robot funcionó de pura suerte a la primera.</p>
      
      <h2>2. Evaluaciones de "Código Abierto" y Explicación Peer-to-Peer</h2>
      <p>Pídele a un equipo que le explique línea por línea su código a otro equipo. El maestro evalúa la claridad de la explicación y la capacidad de responder a las dudas de sus compañeros. Si puedes explicárselo a alguien más, realmente lo entiendes.</p>
      
      <h2>3. Rúbricas Multidimensionales</h2>
      <p>No califiques solo el código. Divide la nota en dimensiones como:</p>
      <ul>
        <li><strong>Técnica:</strong> ¿Usa variables y bucles eficientemente?</li>
        <li><strong>Hardware:</strong> ¿El cableado es limpio y lógico?</li>
        <li><strong>Soft Skills:</strong> ¿Cómo resolvieron el conflicto cuando dos miembros del equipo querían diseños distintos?</li>
        <li><strong>Innovación:</strong> ¿Fueron más allá de las instrucciones del manual para agregar algo único?</li>
      </ul>
      
      <div class="article-note">
        <i class="ph-fill ph-lightbulb"></i>
        <p><strong>Apóyate en la tecnología:</strong> El panel docente de CultivaTec automatiza gran parte del seguimiento técnico (cuántos intentos hizo un alumno en el simulador, qué conceptos domina), dejándote a ti, el educador, el tiempo para evaluar las habilidades blandas y el liderazgo.</p>
      </div>
    `
  },
  {
    name: 'rol-ia-socratica-aula-futuro.html',
    title: 'El rol de la IA Socrática en el aula del futuro | CultivaTec',
    desc: 'Por qué la Inteligencia Artificial Socrática es superior a las respuestas directas de ChatGPT en la educación, fomentando el pensamiento crítico en los alumnos.',
    kw: 'IA Socrática, educación inteligencia artificial, pensamiento crítico IA, futuro aulas tecnología',
    cat: 't-ai',
    catName: 'Inteligencia Artificial',
    icon: 'ph-robot',
    date: '28 jul 2026',
    time: '9 min',
    imgId: '1581089781785-603411fa81e5',
    headline: 'El rol de la Inteligencia Artificial Socrática en el aula del futuro',
    content: `
      <p>La reacción inicial de las escuelas frente a herramientas como ChatGPT fue el pánico colectivo: "Los alumnos ya no pensarán, la máquina hará su tarea". Sin embargo, el futuro de la educación no está en prohibir la Inteligencia Artificial, sino en moldearla hacia una arquitectura pedagógica. Aquí entra la <strong>IA Socrática</strong>.</p>
      
      <h2>¿Qué es la Inteligencia Artificial Socrática?</h2>
      <p>El método Socrático, inventado hace miles de años, se basa en hacer preguntas para estimular el pensamiento crítico, en lugar de dar respuestas. Una IA "normal" (como ChatGPT por defecto) es un oráculo: tú preguntas, ella responde. Una IA Socrática está programada específicamente para <strong>negarse a darte la respuesta directa</strong>, actuando en su lugar como un coach.</p>
      
      <h2>Un ejemplo práctico en clase de robótica</h2>
      <p><strong>Alumno:</strong> "Mi robot no gira a la izquierda. ¿Qué código pongo?"</p>
      
      <p><strong>IA Tradicional:</strong> "Aquí está el código corregido: <code>motorLeft.stop(); motorRight.forward();</code>"</p>
      <p><strong>Consecuencia:</strong> El alumno copia, pega, y no aprende nada.</p>
      
      <p><strong>IA Socrática (Chip de CultivaTec):</strong> "Veo que tienes problemas con el giro. Para girar a la izquierda, piensa en cómo se mueven las llantas de un tanque. ¿Qué debería estar haciendo la llanta izquierda mientras la derecha avanza?"</p>
      <p><strong>Consecuencia:</strong> El alumno pausa, visualiza la mecánica del tanque, deduce la lógica y escribe el código él mismo. Dopamina, orgullo y aprendizaje consolidado.</p>
      
      <h2>Escalando la atención personalizada</h2>
      <p>Es matemáticamente imposible que un maestro de grupo atienda las dudas de 30 alumnos construyendo código simultáneamente. Algunos alumnos se quedan atascados durante 20 minutos esperando a que el profesor se desocupe. La IA Socrática actúa como un co-maestro que desbloquea cognitivamente a los alumnos al instante, permitiendo que el docente principal intervenga solo en las barreras conceptuales más grandes.</p>
      
      <div class="article-note">
        <i class="ph-fill ph-lightbulb"></i>
        <p><strong>El futuro es guiado:</strong> Las escuelas que liderarán la próxima década no serán las que escondan los dispositivos, sino las que integren tutores virtuales socráticos que enseñen a sus alumnos a pensar, razonar y cuestionar mejor.</p>
      </div>
    `
  }
];

const templateHtml = fs.readFileSync(path.join(blogDir, 'curso-completo-robotica-12-sesiones.html'), 'utf8');

templates.forEach(t => {
  let newHtml = templateHtml;
  
  // Replace Head metadata
  newHtml = newHtml.replace(/<title>.*?<\/title>/, '<title>' + t.title + '</title>');
  newHtml = newHtml.replace(/<meta name="description" content=".*?">/, '<meta name="description" content="' + t.desc + '">');
  newHtml = newHtml.replace(/<meta name="keywords" content=".*?">/, '<meta name="keywords" content="' + t.kw + '">');
  newHtml = newHtml.replace(/<link rel="canonical" href=".*?">/, '<link rel="canonical" href="https://cultivatec.com.mx/blog/' + t.name + '">');
  newHtml = newHtml.replace(/<meta property="og:title" content=".*?">/, '<meta property="og:title" content="' + t.title + '">');
  newHtml = newHtml.replace(/<meta property="og:description" content=".*?">/, '<meta property="og:description" content="' + t.desc + '">');
  newHtml = newHtml.replace(/<meta property="og:url" content=".*?">/, '<meta property="og:url" content="https://cultivatec.com.mx/blog/' + t.name + '">');
  newHtml = newHtml.replace(/<meta property="og:image" content=".*?">/, '<meta property="og:image" content="https://images.unsplash.com/photo-' + t.imgId + '?q=80&w=1200&auto=format&fit=crop">');
  
  // Replace schema
  newHtml = newHtml.replace(/"headline":".*?"/, '"headline":"' + t.headline + '"');
  newHtml = newHtml.replace(/"description":".*?"/, '"description":"' + t.desc + '"');
  newHtml = newHtml.replace(/"@id":".*?"/, '"@id":"https://cultivatec.com.mx/blog/' + t.name + '"');
  
  // Replace Breadcrumb
  newHtml = newHtml.replace(/"position": 3,[\s\S]*?"name": ".*?"/, '"position": 3,\n     "name": "' + t.headline + '"');
  newHtml = newHtml.replace(/"item": ".*?"\s*}\s*]\s*}/, '"item": "https://cultivatec.com.mx/blog/' + t.name + '"\n    }\n   ]\n  }');
  
  // Replace Hero
  newHtml = newHtml.replace(/<section class="page-hero .*?"/, '<section class="page-hero ' + t.cat + '"');
  newHtml = newHtml.replace(/<span>.*?<\/span><\/div>/, '<span>' + t.catName + '</span></div>');
  newHtml = newHtml.replace(/<span class="eyebrow .*?">.*?<\/span>/, '<span class="eyebrow ' + t.cat + '"><i class="ph-fill ' + t.icon + '"></i> ' + t.catName + '</span>');
  newHtml = newHtml.replace(/<h1>.*?<\/h1>/, '<h1>' + t.headline + '</h1>');
  newHtml = newHtml.replace(/<i class="ph-fill ph-calendar-blank"><\/i> .*? &nbsp;·&nbsp;/, '<i class="ph-fill ph-calendar-blank"></i> ' + t.date + ' &nbsp;·&nbsp;');
  newHtml = newHtml.replace(/<i class="ph-fill ph-clock"><\/i> .*? de lectura/, '<i class="ph-fill ph-clock"></i> ' + t.time + ' de lectura');
  
  // Replace Article Content
  const articleStart = '<div class="article">';
  const articleEnd = '    </div>\n  </div>\n</article>';
  const articleMatch = newHtml.match(/<div class="article">([\s\S]*?)<\/div>\s*<\/div>\s*<\/article>/);
  
  if (articleMatch) {
    const fullArticleContent = '\n      <figure style="margin:0 0 32px 0;">\n        <img src="https://images.unsplash.com/photo-' + t.imgId + '?q=80&w=1200&auto=format&fit=crop" alt="' + t.headline + '" style="width:100%; border-radius:var(--r-md); box-shadow:var(--sh-sm); object-fit:cover; max-height:400px;">\n      </figure>\n      ' + t.content + '\n    ';
    newHtml = newHtml.replace(articleMatch[1], fullArticleContent);
  }

  fs.writeFileSync(path.join(blogDir, t.name), newHtml, 'utf8');
  console.log('Created ' + t.name);
});
