# Historial de cambios

Todos los cambios relevantes de CultivaTec se registran en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y el versionado sigue [SemVer](https://semver.org/lang/es/).

**Categorías:** `Añadido` · `Cambiado` · `Corregido` · `Eliminado` ·
`Obsoleto` · `Seguridad`

---

## [Sin publicar]

### Cambiado

- **Rediseño visual "Wokov Blue"** inspirado en Duolingo: paleta azul de marca
  (`#0958C2`), colores planos sin degradados, sombras sólidas bajo cada pieza,
  tipografía Nunito, botones 3D unificados (`ModernButton` ahora envuelve a
  `CartoonButton`) y barra de navegación inferior fija.
- Wokov reemplaza las ilustraciones con fondo pintado. Nuevo `WokovMascot` con
  31 poses transparentes (`assets/images/wokov/`), flotación, reacción al toque,
  globos de diálogo y secuencias cuadro a cuadro (`WokovSequences`).
- Camino de lecciones con nodos 3D, globo «¡EMPIEZA!» y Wokov señalando.
- Quiz con opciones 3D, panel de retroalimentación con Wokov, vibración y sonido.

### Corregido

- **El formulario de acceso se destruía al iniciar sesión**: `AppRouter` mostraba
  la pantalla de carga con `auth.isLoading`, que el login también activa, así que
  un intento fallido devolvía al usuario a la bienvenida sin ningún mensaje. Ahora
  usa `auth.isInitializing` (solo la carga inicial de Firebase).
- El interruptor de **Sonido** en Ajustes no hacía nada: solo cambiaba una
  variable local. Ahora se guarda y lo respeta `SoundService`.

### Añadido

- Lección estilo Duolingo: barra superior con progreso y vidas (solo en prácticas,
  nunca en torneos ni duelos; se desactivan con `_kHeartsEnabled` en `quiz_screen.dart`),
  selección → COMPROBAR → panel verde/rojo → CONTINUAR, confirmación al salir y
  pantalla de «sin vidas».
- Meta diaria de XP (20/30/50/100, configurable en Ajustes) con aro, semana de
  actividad, racha y mensajes de Wokov en Inicio (`DailyGoalService`, `DailyGoalCard`).
- Celebraciones con confeti azul, sonido y Wokov al subir de nivel, desbloquear un
  logro o cumplir la meta (`CelebrationService` + `CelebrationHost`).
- Camino de lecciones por unidades (agrupadas por módulo): banner de unidad, cofre
  de recompensa (+20 XP, una vez por unidad) y estrellas en lecciones completadas.
- Ejercicio «Une los pares» (término ↔ definición) con el glosario.
- `WokovSplash`, `WokovLoading` y `WokovEmptyState` (carga, vacío y error) aplicados
  en amigos, ranking, duelos y liga.
- «Reducir movimiento» en Ajustes (también respeta el ajuste del sistema).
- Autocompletado de contraseñas y correo de verificación al registrarse.
- Pruebas: `widgets_and_services_test.dart` y `validators_test.dart`.

### Eliminado

- Botón «Continuar con Apple» (solo mostraba un aviso; vuelve cuando esté implementado).
- Scripts de un solo uso movidos a `tools/legacy/`.

### Rediseño azul (ronda 3)

- Paleta con más tonos de azul (`navyDeep`, `navy`, `toneNavy`, `toneIndigo`, `toneAzure`,
  `toneSky`) y degradados solo en superficies grandes (`headerGradient`, `pageGradient`);
  los botones siguen siendo sólidos. Los colores decorativos (áreas STEM, categorías de
  torneos, simuladores, mosaicos) pasaron a tonos de azul; amarillo, verde y rojo quedan
  para recompensas y aciertos/errores.
- `BlueHeader`: encabezado azul reutilizable. Usado en Aprender, Torneos, Social, Perfil y
  en cada lección. Inicio con encabezado propio (avatar, nivel, barra de XP dorada, racha, Wokov).
- Barra de navegación inferior azul marino.
- Selector de áreas con progreso por área y «SIGUE AQUÍ».
- Pantalla de lección rediseñada: Wokov cambia de pose según el tipo de tarjeta, progreso por
  segmentos, tarjetas con color por tipo y botones 3D (todo dentro de un scroll).
- Onboarding en 3 pasos con Wokov (bienvenida, meta diaria, nombre del robot).
- Wokov habla: la boca se abre y cierra cuando aparece un globo de texto (capa `mouth`).
- `WokovAssembly`: GIF de Wokov armándose (`robot_ensamblaje.gif`) en la pantalla de carga y en
  las lecciones de armado. 6 poses nuevas (`hop`, `crouch`, `fall`, `trip`, `crossed`, `dash`) y
  20 retratos de expresiones (`WokovFace`).
- `WokovSparkles`: chispas doradas al celebrar.
- Simulador de **cinemática de un brazo robótico** (2 segmentos, espacio de trabajo y reto del
  objetivo) enlazado desde el hub de simuladores y la lección `in_cinematica`.

- Simulador de **Control PID** (`pid_simulator_screen.dart`): planta de segundo orden para que
  se vean de verdad el error permanente de «solo P», cómo la integral lo elimina, el overshoot con
  P alto y cómo la derivada amortigua. Pasos de tiempo fijos (igual en 60 o 120 Hz), botones de
  ejemplo (Solo P, P + I, Mucho P, PID), «Cambiar meta» y lecturas de valor/meta/error.
  Enlazado desde el hub de simuladores y la lección `in_pid`. La lógica vive en `PidSimulation`
  (clase pura, con pruebas).

- Hub de **Simuladores**, **Configuración** y **Glosario** con el encabezado azul (el glosario con
  el buscador integrado), y tarjetas 3D por simulador (los que aún no existen se ven apagados y con
  candado). Se quitó una importación sin usar en Configuración.

### Corregido (ronda 3)

- Cuadros rojos «Unable to load asset» en Wokov: ahora `LivingWokov` comprueba sus capas y,
  si falta alguna, muestra la imagen estática (y avisa en consola qué falta).
- «BOTTOM OVERFLOWED»: alturas fijas animadas reemplazadas por `AnimatedSize`; pantallas de
  bienvenida, lección, quiz, sin vidas, resultados y celebración ahora scrollean en pantallas chicas.

### Animaciones

- **`LivingWokov`**: Wokov animado por capas (`assets/images/wokov/layers/`: cuerpo,
  brazos, cabeza, brote y párpado). Respira, el brote se mece, la cabeza se inclina,
  los brazos se balancean y parpadea al azar (a veces dos veces). Gestos: saludo
  (`WokovAction.wave`) y festejo con salto (`WokovAction.cheer`); al tocarlo reacciona.
  `WokovMascot(pose: WokovPose.idle)` lo usa automáticamente (`idleAction` /
  `actionInterval` repiten un gesto). Respeta «Reducir movimiento».
- Usado en bienvenida, formulario de acceso, inicio, celebraciones y resultados (70–89 %).
- Quiz: la pregunta y las opciones se deslizan al cambiar, «+10 XP» flotante al
  acertar, corazón que tiembla con «-1» al fallar y llama de racha que parpadea.
- Resultados: el porcentaje cuenta hacia arriba (`CountUpText`).
- Inicio: las pestañas aparecen con fundido y deslizamiento.
- Transición con fundido entre carga, acceso, onboarding e inicio, y entre
  bienvenida y formulario.
- Llama de racha animada en la tarjeta de meta diaria.
- Corregido: `assets/images/wokov/layers/` declarado en `pubspec.yaml` (las carpetas
  de assets no son recursivas).

### Añadido (visual)

- Confeti azul (`BlueConfetti`) en bienvenida, respuestas correctas y resultados.
- `SoundService` real: sonidos (`assets/sounds/`) y vibración háptica.
- Registro/inicio de sesión: validación por campo, medidor y lista de requisitos
  de contraseña, confirmación de contraseña, mensajes de error amables en
  español y recuperación de contraseña por correo.

- Documentación completa para colaboradores: `README.md`, `CONTRIBUTING.md`,
  `SECURITY.md`, `THIRD_PARTY_NOTICES.md` y la carpeta `docs/` con guías de
  arquitectura, estilo, flujo de Git y configuración de Firebase.
- Licencia propietaria (`LICENSE`) con cesión de aportaciones, cláusulas de
  confidencialidad y obligaciones sobre datos de menores de edad.
- Plantillas de pull request e issues, `CODEOWNERS` y flujo de integración
  continua que ejecuta el analizador y las pruebas en cada pull request.
- Suite de pruebas real: 18 pruebas que cubren el sistema de niveles y la
  integridad del plan de estudios (ids únicos, respuestas válidas,
  explicaciones presentes).
- `.editorconfig` y `.gitattributes` para unificar formato y finales de línea
  entre Windows, macOS y Linux.

### Cambiado

- Reglas del analizador endurecidas: los imports sin usar, el código muerto y
  los campos huérfanos ahora son **errores**, no avisos. `flutter analyze`
  termina sin ningún aviso.
- Archivos renombrados para que su nombre describa lo que hacen:
  - `universe_provider.dart` → `learning_provider.dart` (`UniverseProvider` → `LearningProvider`)
  - `screens/map/universe_map_screen.dart` → `screens/learning/stem_area_select_screen.dart`
  - `screens/map/world_map_screen.dart` → `screens/learning/lesson_path_screen.dart`
- Metadatos de la aplicación corregidos en todas las plataformas: el nombre
  visible pasa de `cultivatec_flutter` a **CultivaTec** en Android, iOS y web.
- Espacio de nombres de Android corregido: `com.example.cultivatec_flutter` →
  `com.cultivatec.cultivatec_app`, alineado con el `applicationId`.
- `pubspec.lock` pasa a versionarse, para que todo el equipo compile con las
  mismas versiones exactas de dependencias.
- Un único `.gitignore` en la raíz como fuente de verdad.

### Corregido

- El modal de información de componentes del simulador de circuitos nunca se
  mostraba: el botón actualizaba el estado pero el widget no estaba en el
  árbol.
- `GoogleService-Info.plist` de iOS no incluía `CLIENT_ID` ni
  `REVERSED_CLIENT_ID`, necesarios para Google Sign-In.

### Eliminado

- `CultivaTec.apk` (58 MB) deja de versionarse. Los binarios se publican como
  *Release* de GitHub.
- Archivos duplicados en la raíz del repositorio: `google-services.json`,
  `GoogleService-Info.plist`, `iconodeapp.png` y `robotimagen.png` (todos
  idénticos a la copia que ya existe dentro del proyecto).
- Carpeta `skins/` con 26 PNG heredados de la versión anterior en React,
  sustituidos por los `.webp` de `assets/images/`.
- Código muerto del port desde React: `worlds_data.dart`,
  `playful_background.dart` y `diagnostic_exam_screen.dart`, más el sistema de
  roles y diagnóstico que ya no se usaba.
- Prueba plantilla `widget_test.dart` (el contador por defecto de Flutter, que
  además fallaba al ejecutarse).

---

## [2.5.0] — 2026-06-20

### Añadido

- Plan de estudios reestructurado en 3 niveles progresivos —
  **Chispa → Maker → Inventor** — con 61 lecciones y 156 preguntas.
- Notificación emergente de energía diaria al comprobar la racha.
- Imágenes propias para las estaciones del mapa (electrónica, programación,
  bahía) en sustitución de los iconos genéricos.

### Cambiado

- Rediseño completo de la Estación de Control con una interfaz colorida y
  redondeada, pensada para público infantil.
- Estaciones del mapa mostradas como imágenes grandes con su nombre completo.

### Corregido

- Progresión de módulos y desbloqueo de mundos.
- Las skins conocidas se guardan en almacenamiento local para no volver a
  mostrar la animación de desbloqueo en cada inicio de sesión.
- Icono de pantalla de inicio en iOS (`apple-touch-icon` de 180 × 180).

---

## Cómo escribir una entrada

Al abrir un pull request con un cambio visible para el usuario, añade una línea
bajo `[Sin publicar]` en la categoría que corresponda.

**Escribe para quien usa la app, no para quien lee el código:**

| ✅ Bien | ❌ Mal |
|:--|:--|
| `Corregido: la racha ya no se pierde al viajar de zona horaria` | `Corregido: bug en checkAndUpdateStreak` |
| `Añadido: 6 lecciones de sensores en el nivel Maker` | `Añadido: entradas en stem_content.dart` |

Al publicar una versión, `[Sin publicar]` se convierte en el número de versión
con su fecha y se abre una sección nueva vacía.

### Cómo elegir el número de versión

| Cambio | Sube | Ejemplo |
|:--|:--|:--|
| Correcciones | Parche | 2.5.0 → 2.5.1 |
| Funciones o contenido nuevo | Menor | 2.5.1 → 2.6.0 |
| Rediseño mayor o cambio incompatible | Mayor | 2.6.0 → 3.0.0 |

Recuerda subir también el **código de build** en `pubspec.yaml`
(`version: 2.5.0+1` → `2.6.0+2`) en cada publicación a las tiendas.
