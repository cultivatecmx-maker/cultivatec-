<div align="center">

# CultivaTec

**Plataforma educativa gamificada de robótica y STEM para niños y adolescentes.**

[![Flutter](https://img.shields.io/badge/Flutter-3.27-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Licencia](https://img.shields.io/badge/Licencia-Propietaria-red)](LICENSE)

</div>

---

> [!IMPORTANT]
> **Software propietario y confidencial.** Este repositorio es privado. Su
> contenido no puede copiarse, publicarse ni compartirse fuera del equipo
> autorizado. Antes de escribir una sola línea de código, lee la
> [licencia](LICENSE) y la [guía de colaboración](CONTRIBUTING.md).

---

## Tabla de contenidos

1. [Qué es CultivaTec](#1-qué-es-cultivatec)
2. [Cómo funciona la app](#2-cómo-funciona-la-app)
3. [Arquitectura en 2 minutos](#3-arquitectura-en-2-minutos)
4. [Estructura del repositorio](#4-estructura-del-repositorio)
5. [Puesta en marcha](#5-puesta-en-marcha)
6. [Comandos del día a día](#6-comandos-del-día-a-día)
7. [Cómo subir tus cambios](#7-cómo-subir-tus-cambios)
8. [Dónde va cada cosa](#8-dónde-va-cada-cosa)
9. [Estado actual y deuda técnica](#9-estado-actual-y-deuda-técnica)
10. [Documentación ampliada](#10-documentación-ampliada)

---

## 1. Qué es CultivaTec

CultivaTec enseña **robótica, electrónica y programación** a estudiantes de
primaria y secundaria convirtiendo el plan de estudios en un juego: el
estudiante avanza por un camino de lecciones, responde cuestionarios, construye
circuitos y programa robots con bloques, gana XP, sube de nivel, desbloquea
skins para su robot y compite con sus amigos.

La aplicación es **multiplataforma** (Android, iOS, Web, Windows, macOS y
Linux) y está construida con un único código base en Flutter. Toda la interfaz
y el contenido educativo están en **español**.

### El plan de estudios

El contenido vive en [`stem_content.dart`](cultivatec_flutter/lib/data/static/stem_content.dart)
y se organiza en **3 niveles progresivos** con **61 lecciones** y
**156 preguntas** en total:

| Nivel | Enfoque | Lecciones |
|:--|:--|--:|
| ⚡ **Chispa** | Primeros pasos: qué es un robot, electricidad básica, lógica | 10 |
| 🔧 **Maker** | Sensores, motores, circuitos, programación con bloques | 22 |
| 🚀 **Inventor** | Robótica avanzada, IA, proyectos completos | 29 |

Cada lección tiene la misma anatomía:

```
Lección
├── Tarjetas de contenido   (concepto · ejemplo · dato curioso · consejo)
├── Cuestionario            (preguntas de opción múltiple con explicación)
└── Práctica (opcional)     → Simulador de circuitos  o  Programación por bloques
```

### Qué puede hacer un estudiante

| Función | Descripción |
|:--|:--|
| 🗺️ **Camino de lecciones** | Progresión lineal: una lección se desbloquea al completar la anterior |
| ❓ **Cuestionarios** | Opción múltiple con explicación inmediata del porqué de la respuesta |
| ⚡ **Simulador de circuitos** | Arrastra componentes, conecta pines y simula el flujo de corriente |
| 💻 **Programación por bloques** | Programa el comportamiento de un robot encajando bloques visuales |
| 🤖 **Editor de robot** | Personaliza su avatar con **31 skins** desbloqueables |
| 📈 **Niveles y XP** | 25 rangos, de *Cadete Espacial* a *Omnisciente Galáctico* |
| 🏆 **Logros** | Insignias por hitos de aprendizaje y constancia |
| 🔥 **Rachas** | Recompensa por entrar y practicar días consecutivos |
| 👥 **Amigos** | Búsqueda por usuario, solicitudes y lista de amistades |
| 🥇 **Ranking** | Tabla de posiciones global |
| ⚔️ **Torneos y duelos** | Ligas semanales y retos uno contra uno |
| 🏫 **Aula** | Un docente agrupa a su clase mediante un código |
| 📖 **Glosario** | Diccionario de términos técnicos del plan de estudios |

---

## 2. Cómo funciona la app

### Flujo de arranque

```
main()
  ├─ Firebase.initializeApp()      Conecta con el proyecto cultivatec-appstore
  ├─ SoundService.init()           Carga las preferencias de audio
  └─ runApp(CultivaTecApp)
        └─ AppRouter  ─── decide qué pantalla mostrar ───┐
                                                          │
   ¿Cargando sesión?     ──► Pantalla de carga            │
   ¿Sin sesión?          ──► AuthScreen        (login / registro)
   ¿Sin robot creado?    ──► OnboardingScreen  (crea tu robot)
   Todo listo            ──► HomeScreen        (app completa)
```

`AppRouter` vive en [`main.dart`](cultivatec_flutter/lib/main.dart) y reacciona
automáticamente a `AuthProvider`: no hay navegación manual entre estos tres
estados.

### Navegación principal

`HomeScreen` es un `IndexedStack` con cinco pestañas fijas en una barra
flotante. El `IndexedStack` mantiene vivo el estado de cada pestaña, así que
cambiar de pestaña no reinicia lo que el estudiante estaba haciendo.

```
┌──────────────────────────────────────────────────────────┐
│  Inicio  ·  Aprender  ·  Torneos  ·  Social  ·  Perfil   │
└──────────────────────────────────────────────────────────┘
              │
              └─ Aprender ─┬─ StemAreaSelectScreen   (elige Chispa/Maker/Inventor)
                           └─ LessonPathScreen       (camino de lecciones)
                                 └─ ModuleListScreen
                                       ├─ QuizScreen
                                       ├─ CircuitBuilderScreen
                                       └─ BlockCodingScreen
```

### Cómo se guarda el progreso

Hay **dos almacenes** y es importante no confundirlos:

| Dónde | Qué guarda | Por qué |
|:--|:--|:--|
| **Firestore** | Perfil, XP, puntuaciones, logros, skins, amigos, rachas | Debe sobrevivir al cambio de dispositivo |
| **SharedPreferences** | Nivel STEM abierto, volumen, sonido activado | Preferencia local del dispositivo |

Una lección cuenta como **completada** cuando el estudiante acierta al menos
el **70 %** del cuestionario. Ese umbral está en
`AuthProvider.isModuleCompleted()`.

Los datos se leen mediante **streams en tiempo real**: `AuthProvider` se
suscribe a los documentos de Firestore, así que cuando el perfil cambia
—aunque sea desde otro dispositivo— la interfaz se actualiza sola. **Nunca
consultes Firestore directamente desde un widget**; hazlo siempre a través del
provider.

---

## 3. Arquitectura en 2 minutos

CultivaTec usa una arquitectura por capas con **Provider** para el estado.
La regla de oro es que **las dependencias apuntan siempre hacia abajo**:

```
┌───────────────────────────────────────────────────┐
│  screens/          Pantallas y widgets            │  ← Solo dibuja
├───────────────────────────────────────────────────┤
│  providers/        Estado de la aplicación        │  ← Coordina y notifica
├───────────────────────────────────────────────────┤
│  data/services/    Acceso a Firebase              │  ← Habla con la red
│  data/models/      Modelos de dominio             │
│  data/static/      Contenido educativo            │
├───────────────────────────────────────────────────┤
│  core/             Tema, widgets base, utilidades │  ← No conoce a nadie
└───────────────────────────────────────────────────┘
```

| Regla | Sí | No |
|:--|:--|:--|
| Una pantalla lee estado | `context.watch<AuthProvider>()` | `FirebaseFirestore.instance...` |
| Un provider guarda datos | `_firestoreService.updateUserProfile(...)` | Escribir Firestore a mano |
| Un servicio devuelve datos | Modelos de `data/models/` | `Map<String, dynamic>` sueltos |
| Un widget de `core/` | Es genérico y reutilizable | Importa un provider |

Los dos providers registrados en `main.dart`:

- **`AuthProvider`** — sesión, perfil, puntuaciones, solicitudes de amistad,
  nivel y XP. Es el más usado de la app.
- **`LearningProvider`** — en qué nivel STEM está el estudiante.

📖 Detalle completo en **[docs/ARQUITECTURA.md](docs/ARQUITECTURA.md)**.

---

## 4. Estructura del repositorio

```
Cultivatec-app/
│
├── README.md                    ← Estás aquí
├── CONTRIBUTING.md              Cómo colaborar (LÉELO ANTES DE EMPEZAR)
├── LICENSE                      Licencia propietaria
├── SECURITY.md                  Cómo reportar un problema de seguridad
├── CHANGELOG.md                 Historial de versiones
├── THIRD_PARTY_NOTICES.md       Licencias de las dependencias
│
├── .editorconfig                Formato compartido entre editores
├── .gitattributes               Normalización de finales de línea
├── .gitignore                   Qué NO se sube (único archivo, en la raíz)
│
├── .github/
│   ├── CODEOWNERS               Quién debe revisar cada carpeta
│   ├── PULL_REQUEST_TEMPLATE.md Plantilla de pull request
│   ├── ISSUE_TEMPLATE/          Plantillas de bugs y propuestas
│   └── workflows/ci.yml         Análisis y pruebas automáticas
│
├── docs/
│   ├── ARQUITECTURA.md          Capas, providers, flujo de datos
│   ├── GUIA_DE_ESTILO.md        Convenciones de código Dart/Flutter
│   ├── FLUJO_DE_TRABAJO_GIT.md  Ramas, commits, pull requests
│   └── CONFIGURACION_FIREBASE.md Proyecto Firebase y reglas
│
├── firebase.json                Configuración de Firebase CLI
├── .firebaserc                  Proyecto por defecto
├── firestore.rules              Reglas de seguridad de la base de datos
│
└── cultivatec_flutter/          👈 LA APLICACIÓN
    ├── pubspec.yaml             Dependencias y versión
    ├── pubspec.lock             Versiones exactas (SÍ se versiona)
    ├── analysis_options.yaml    Reglas del analizador estático
    │
    ├── lib/
    │   ├── main.dart            Punto de entrada y enrutador raíz
    │   │
    │   ├── core/                Cimientos, sin lógica de negocio
    │   │   ├── config/          Credenciales de Firebase por plataforma
    │   │   ├── theme/           Colores, tipografías, gradientes
    │   │   ├── utils/           Servicio de sonido
    │   │   └── widgets/         Botones, tarjetas, fondos reutilizables
    │   │
    │   ├── data/
    │   │   ├── models/          Perfil, robot, niveles, torneos
    │   │   ├── services/        Auth, Firestore, torneos
    │   │   └── static/          Plan de estudios y banco de preguntas
    │   │
    │   ├── providers/           Estado global (Provider)
    │   │
    │   └── screens/             Interfaz, agrupada por área funcional
    │       ├── auth/            Login, registro, onboarding
    │       ├── home/            Panel principal y ajustes
    │       ├── learning/        Niveles, lecciones, quiz, glosario, aula
    │       ├── robot/           Circuitos, bloques, editor de skins
    │       ├── social/          Amigos, ranking, logros
    │       └── tournaments/     Ligas y duelos
    │
    ├── assets/
    │   ├── icons/               Icono de la aplicación
    │   └── images/              Logos, robots y 31 skins
    │
    ├── test/                    Pruebas automatizadas
    │
    └── android/ ios/ web/       Proyectos nativos por plataforma
        windows/ macos/ linux/   (rara vez se tocan a mano)
```

---

## 5. Puesta en marcha

### Requisitos

| Herramienta | Versión | Cómo comprobar |
|:--|:--|:--|
| **Flutter SDK** | 3.27 o superior (canal `stable`) | `flutter --version` |
| **Dart** | 3.6 o superior (viene con Flutter) | `dart --version` |
| **Git** | Cualquiera reciente | `git --version` |
| **Android Studio** | Para compilar a Android | — |
| **Xcode** | Solo en macOS, para compilar a iOS | — |

Editor recomendado: **VS Code** con las extensiones *Flutter* y *Dart*, o
**Android Studio**. El archivo `.editorconfig` ya deja el formato configurado.

### Instalación

**1. Clona el repositorio** (necesitas acceso concedido por CultivaTec):

```bash
git clone https://github.com/cultivatecmx-maker/Cultivatec-app.git
```

**2. Entra en la carpeta de la aplicación:**

```bash
cd "Cultivatec-app/cultivatec_flutter"
```

**3. Instala las dependencias:**

```bash
flutter pub get
```

**4. Verifica que tu entorno está completo:**

```bash
flutter doctor
```

**5. Ejecuta la app:**

```bash
flutter run
```

> [!NOTE]
> **No necesitas configurar Firebase.** Las credenciales del cliente ya están
> en el repositorio y apuntan al proyecto `cultivatec-appstore`. Están
> protegidas por las reglas de `firestore.rules`, no por ocultarlas.
> Detalles en [docs/CONFIGURACION_FIREBASE.md](docs/CONFIGURACION_FIREBASE.md).

> [!WARNING]
> La app te conecta a la **base de datos real**. Crea una **cuenta de prueba
> propia** y trabaja siempre con ella. Nunca uses ni modifiques datos de
> estudiantes reales.

### Si algo falla

| Síntoma | Solución |
|:--|:--|
| Errores raros al compilar | `flutter clean` y luego `flutter pub get` |
| Conflictos de dependencias | Borra `pubspec.lock`, ejecuta `flutter pub get` y **comenta el cambio en tu PR** |
| Gradle falla en Android | Comprueba que `flutter doctor --android-licenses` esté aceptado |
| No aparece ningún dispositivo | `flutter devices`; abre un emulador o conecta el teléfono con depuración USB |

---

## 6. Comandos del día a día

Todos se ejecutan desde `cultivatec_flutter/`.

### Desarrollo

```bash
flutter run
```

```bash
flutter run -d chrome
```

```bash
flutter devices
```

Con la app corriendo: pulsa `r` para **hot reload** (conserva el estado) y `R`
para **hot restart** (reinicia la app).

### Antes de cada commit — obligatorio

```bash
flutter analyze
```

```bash
flutter test
```

```bash
dart format --line-length 120 lib test
```

`flutter analyze` **debe terminar sin ningún aviso**. El proyecto usa reglas
estrictas: los imports sin usar, el código muerto y los campos huérfanos son
errores, no sugerencias. Muchos se arreglan solos con:

```bash
dart fix --apply
```

### Compilar para publicar

```bash
flutter build apk --release
```

```bash
flutter build appbundle --release
```

```bash
flutter build web --release
```

> [!IMPORTANT]
> Los binarios (`.apk`, `.aab`, `.ipa`) **no se suben al repositorio** — el
> `.gitignore` los bloquea. Para compartir una compilación, publícala como
> *Release* en GitHub.

---

## 7. Cómo subir tus cambios

Este es el flujo completo, paso a paso. Si nunca has trabajado con ramas y
pull requests, sigue esta sección literalmente.

### Reglas que no se negocian

| ❌ Nunca | ✅ Siempre |
|:--|:--|
| Trabajar directamente en `main` | Crear una rama por cada tarea |
| Hacer `git push --force` a `main` | Abrir un pull request y esperar revisión |
| Subir con `flutter analyze` fallando | Analizar y probar antes del commit |
| Subir `.apk`, `.aab` o binarios | Publicarlos como Release de GitHub |
| Mezclar 5 temas en un solo commit | Un commit = un cambio con sentido propio |

### Paso 1 — Actualiza tu copia local

Antes de empezar cualquier tarea, sincroniza con lo último:

```bash
git checkout main
```

```bash
git pull origin main
```

### Paso 2 — Crea tu rama

El nombre de la rama describe el trabajo con el prefijo del tipo de cambio:

```bash
git checkout -b feat/editor-de-skins
```

| Prefijo | Cuándo se usa | Ejemplo |
|:--|:--|:--|
| `feat/` | Función nueva | `feat/duelos-por-equipos` |
| `fix/` | Corrección de un error | `fix/racha-no-se-actualiza` |
| `content/` | Lecciones, preguntas, glosario | `content/nivel-inventor-sensores` |
| `ui/` | Cambios visuales sin lógica nueva | `ui/rediseno-ranking` |
| `refactor/` | Reorganizar código sin cambiar comportamiento | `refactor/servicio-firestore` |
| `docs/` | Documentación | `docs/guia-de-estilo` |
| `chore/` | Dependencias, configuración, tareas de mantenimiento | `chore/actualizar-firebase` |

### Paso 3 — Trabaja y revisa lo que hiciste

```bash
git status
```

```bash
git diff
```

Lee tu propio diff antes de continuar. Es la forma más rápida de detectar un
`print()` olvidado o un archivo que no querías tocar.

### Paso 4 — Comprueba que no rompiste nada

```bash
flutter analyze
```

```bash
flutter test
```

Si alguno falla, **arréglalo antes de seguir**. No abras un pull request con
la comprobación en rojo.

### Paso 5 — Haz el commit

```bash
git add .
```

```bash
git commit -m "feat: añade filtro por rareza al editor de skins"
```

**Formato del mensaje** — [Conventional Commits](https://www.conventionalcommits.org/es/):

```
<tipo>: <qué hace el cambio, en imperativo y en minúscula>
```

Los tipos son los mismos que los prefijos de rama: `feat`, `fix`, `content`,
`ui`, `refactor`, `docs`, `chore`, `test`.

| ✅ Buenos mensajes | ❌ Malos mensajes |
|:--|:--|
| `fix: corrige la racha al cambiar de zona horaria` | `arreglos` |
| `feat: añade 8 lecciones al nivel Maker` | `cambios varios` |
| `ui: aumenta el contraste del botón de continuar` | `update` |
| `refactor: extrae la lógica de nivel a level_system` | `asdf` |

Si necesitas explicar **por qué** hiciste el cambio, añade un cuerpo:

```bash
git commit -m "fix: corrige la racha al cambiar de zona horaria" -m "La comparación usaba la hora local del dispositivo, así que un estudiante que viajaba perdía la racha. Ahora se normaliza a UTC antes de comparar los días."
```

### Paso 6 — Sube tu rama

```bash
git push -u origin feat/editor-de-skins
```

La primera vez usa `-u`. Después basta con `git push`.

### Paso 7 — Abre el pull request

1. Entra en el repositorio en GitHub. Aparecerá un aviso con tu rama recién
   subida y un botón **Compare & pull request**.
2. Rellena la plantilla que se abre sola: qué cambiaste, por qué, y cómo
   probarlo.
3. Adjunta **capturas de pantalla** si tocaste la interfaz. Es lo que más
   acelera una revisión.
4. Espera a que la comprobación automática (CI) se ponga en verde.
5. Pide revisión y **atiende los comentarios** con nuevos commits en la misma
   rama; no hace falta abrir otro pull request.

### Paso 8 — Después de que se fusione

```bash
git checkout main
```

```bash
git pull origin main
```

```bash
git branch -d feat/editor-de-skins
```

### Si te sale un conflicto

Ocurre cuando alguien modificó las mismas líneas que tú. Se resuelve así:

```bash
git checkout main
```

```bash
git pull origin main
```

```bash
git checkout feat/editor-de-skins
```

```bash
git merge main
```

Git marcará los archivos en conflicto con `<<<<<<<`, `=======` y `>>>>>>>`.
Abre cada uno, decide qué versión debe quedar, borra esas marcas, y después:

```bash
git add .
```

```bash
git commit
```

```bash
git push
```

> [!TIP]
> Si te bloqueas en un conflicto, **pregunta antes de forzar nada**. Un
> `git push --force` mal dado puede borrar el trabajo de otra persona.

📖 Guía ampliada en **[docs/FLUJO_DE_TRABAJO_GIT.md](docs/FLUJO_DE_TRABAJO_GIT.md)**.

---

## 8. Dónde va cada cosa

La duda más frecuente al empezar es "¿en qué archivo escribo esto?". Esta tabla
la resuelve:

| Quiero… | Archivo o carpeta |
|:--|:--|
| Añadir o editar una lección | `lib/data/static/stem_content.dart` |
| Añadir preguntas a un cuestionario | `lib/data/static/stem_content.dart` |
| Añadir preguntas de torneo | `lib/data/static/tournament_questions.dart` |
| Cambiar un color o una tipografía | `lib/core/theme/theme.dart` |
| Crear un botón o tarjeta reutilizable | `lib/core/widgets/` |
| Cambiar cómo se ve una pantalla | `lib/screens/<área>/` |
| Cambiar qué se guarda en la base de datos | `lib/data/services/firestore_service.dart` |
| Cambiar la lógica de login o registro | `lib/data/services/auth_service.dart` |
| Cambiar cómo se calculan niveles y XP | `lib/data/models/level_system.dart` |
| Añadir una skin nueva | `assets/images/` + registrarla en la lista `RobotSkin` de `lib/screens/robot/robot_skin_editor_screen.dart` |
| Cambiar permisos de la base de datos | `firestore.rules` (raíz del repositorio) |
| Añadir una dependencia | `cultivatec_flutter/pubspec.yaml` |

### Añadir una lección — ejemplo completo

Abre `lib/data/static/stem_content.dart`, localiza el nivel al que pertenece y
añade un `Lesson` dentro de su lista:

```dart
Lesson(
  id: 'chispa_11',                    // Único dentro del nivel
  emoji: '🔋',
  title: '¿Cómo funciona una pila?',
  subtitle: 'Energía para tu robot',
  practiceType: _elec,                 // _coding, _elec, o se omite
  challengeId: 'e3',                   // Obligatorio si hay práctica
  cards: [
    LessonCard(_c, 'La pila',          '...'),   // _c = concepto
    LessonCard(_e, 'En tu casa',       '...'),   // _e = ejemplo
    LessonCard(_f, '¿Sabías que…?',    '...'),   // _f = dato curioso
    LessonCard(_t, 'Consejo',          '...'),   // _t = consejo
  ],
  questions: [
    _q('cq11a', '¿Qué guarda una pila?',
       ['Agua', 'Energía', 'Aire', 'Luz'], 1,    // 1 = índice de la correcta
       'La pila almacena energía química y la convierte en eléctrica.'),
    // …al menos 3 preguntas por lección
  ],
),
```

Después ejecuta `flutter test`: las pruebas de `stem_content_test.dart`
verifican automáticamente que no repitas ids, que cada pregunta apunte a una
opción que existe y que toda práctica declare su `challengeId`.

---

## 9. Estado actual y deuda técnica

Transparencia con quien llega nuevo. Esto es lo que **todavía no está
terminado**:

| Tema | Situación | Prioridad |
|:--|:--|:--|
| **Sonido** | `SoundService` expone la API completa pero los métodos de reproducción están vacíos. Las preferencias sí funcionan. | Media |
| **Firma de release en Android** | `build.gradle` firma la release con la clave de depuración. Hay que generar una clave propia antes de publicar en Google Play. | **Alta** |
| **Administradores** | La lista está fija en el código (`firestore_service.dart`). Debería moverse a Firestore. | Media |
| **Cobertura de pruebas** | Solo hay pruebas de lógica pura (niveles y contenido). Faltan pruebas de widgets. | Media |
| **Torneos y duelos** | La interfaz existe; la lógica de servidor está incompleta. | Media |
| **Aula (`classroom`)** | Registro básico de clase. Falta el panel del docente. | Baja |

Si vas a trabajar en alguno de estos puntos, **abre primero un issue** para no
duplicar esfuerzo con otra persona del equipo.

---

## 10. Documentación ampliada

| Documento | Qué encontrarás |
|:--|:--|
| [CONTRIBUTING.md](CONTRIBUTING.md) | Guía completa de colaboración y revisión de código |
| [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | Capas, providers, flujo de datos, decisiones de diseño |
| [docs/GUIA_DE_ESTILO.md](docs/GUIA_DE_ESTILO.md) | Convenciones de nombres, formato y patrones de Flutter |
| [docs/FLUJO_DE_TRABAJO_GIT.md](docs/FLUJO_DE_TRABAJO_GIT.md) | Ramas, commits, pull requests y resolución de conflictos |
| [docs/CONFIGURACION_FIREBASE.md](docs/CONFIGURACION_FIREBASE.md) | Proyecto Firebase, colecciones y reglas de seguridad |
| [SECURITY.md](SECURITY.md) | Cómo reportar una vulnerabilidad |
| [CHANGELOG.md](CHANGELOG.md) | Historial de versiones |
| [LICENSE](LICENSE) | Licencia propietaria y cesión de aportaciones |

---

<div align="center">

**CultivaTec** · Software propietario · © 2026 · Todos los derechos reservados

</div>
