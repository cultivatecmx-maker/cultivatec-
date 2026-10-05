# Arquitectura de CultivaTec

Documento técnico para quien va a modificar el código. Explica cómo están
organizadas las capas, cómo fluyen los datos y por qué se tomaron ciertas
decisiones.

---

## Índice

- [Visión general](#visión-general)
- [Las capas](#las-capas)
- [Estado global: los providers](#estado-global-los-providers)
- [Flujo de datos completo](#flujo-de-datos-completo)
- [Persistencia](#persistencia)
- [Navegación](#navegación)
- [Sistema de progresión](#sistema-de-progresión)
- [Sistema de diseño](#sistema-de-diseño)
- [Decisiones de diseño](#decisiones-de-diseño)

---

## Visión general

CultivaTec es una aplicación **Flutter** con un único código base para seis
plataformas, respaldada por **Firebase** (Authentication + Cloud Firestore).

| Aspecto | Elección | Motivo |
|:--|:--|:--|
| Framework | Flutter 3.27 | Un solo código para móvil, web y escritorio |
| Estado | `provider` + `ChangeNotifier` | Suficiente para el tamaño de la app, sin la curva de aprendizaje de BLoC o Riverpod |
| Autenticación | Firebase Auth | Correo/contraseña y Google Sign-In listos |
| Base de datos | Cloud Firestore | Streams en tiempo real y trabajo sin conexión |
| Contenido educativo | Constantes de Dart | Sin latencia, funciona sin red, se versiona con el código |
| Preferencias locales | `shared_preferences` | Ajustes que no deben viajar entre dispositivos |

---

## Las capas

```
┌──────────────────────────────────────────────────────────────┐
│  lib/screens/          PRESENTACIÓN                          │
│  Widgets, pantallas, animaciones.                            │
│  Solo dibuja y captura gestos. No decide reglas de negocio.  │
└──────────────────────────────┬───────────────────────────────┘
                               │ lee estado / dispara acciones
┌──────────────────────────────▼───────────────────────────────┐
│  lib/providers/        ESTADO                                │
│  AuthProvider, LearningProvider.                             │
│  Mantienen el estado vivo y avisan a la interfaz.            │
└──────────────────────────────┬───────────────────────────────┘
                               │ llama
┌──────────────────────────────▼───────────────────────────────┐
│  lib/data/services/    ACCESO A DATOS                        │
│  AuthService, FirestoreService, TournamentService.           │
│  Únicos autorizados a hablar con Firebase.                   │
├──────────────────────────────────────────────────────────────┤
│  lib/data/models/      DOMINIO                               │
│  UserProfile, RobotConfig, LevelInfo, modelos de torneo.     │
├──────────────────────────────────────────────────────────────┤
│  lib/data/static/      CONTENIDO                             │
│  Plan de estudios y banco de preguntas.                      │
└──────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────┐
│  lib/core/             CIMIENTOS                             │
│  Tema, widgets reutilizables, sonido, config de Firebase.    │
│  No importa nada de las capas superiores.                    │
└──────────────────────────────────────────────────────────────┘
```

### La regla de las dependencias

**Las flechas apuntan siempre hacia abajo.** Una capa puede usar lo que hay
por debajo; nunca lo que hay por encima.

| Desde | Puede importar | Nunca importa |
|:--|:--|:--|
| `screens/` | providers, models, static, core | services (directamente) |
| `providers/` | services, models, static | screens |
| `services/` | models, core/config | providers, screens |
| `models/` | otros models, core | services, providers, screens |
| `core/` | nada del proyecto | todo lo demás |

> [!WARNING]
> Si una pantalla importa `firestore_service.dart`, la arquitectura está rota.
> El acceso a datos pasa **siempre** por un provider.

---

## Estado global: los providers

Ambos se registran en `main.dart` con `MultiProvider`, por encima del árbol de
widgets.

### `AuthProvider`

El más importante de la app. Vive mientras dure la sesión y mantiene tres
suscripciones abiertas a Firestore.

```
FirebaseAuth.authStateChanges()
        │
        ├─► onUserProfileChange(uid)     ──► _profile         (UserProfile)
        ├─► onUserScoresChange(uid)      ──► _userScores      (Map)
        └─► onPendingRequestsChange(uid) ──► _pendingRequests (List)
```

Al iniciar sesión también dispara `checkAndUpdateStreak()` (racha diaria) y
`syncFriendsCount()` (recuento de amistades).

| Propiedad | Devuelve |
|:--|:--|
| `user` | Usuario de Firebase Auth, o `null` |
| `profile` | Perfil completo del estudiante |
| `userScores` | Puntuación por lección, indexada por `<areaId>_<lessonId>` |
| `pendingRequests` | Solicitudes de amistad recibidas |
| `levelInfo` | Nivel y XP calculados a partir de `totalPoints` |
| `isAdmin` | Si el correo está en la lista de administradores |
| `isModuleCompleted(id)` | `true` si acertó ≥ 70 % del cuestionario |

**Importante:** `dispose()` cancela las tres suscripciones. Si añades una
nueva, cancélala también ahí o provocarás una fuga de memoria.

### `LearningProvider`

Mucho más simple: guarda en qué nivel STEM está el estudiante
(`chispa`, `maker` o `inventor`) y lo persiste en `SharedPreferences`.

| Propiedad o método | Qué hace |
|:--|:--|
| `currentStemAreaId` | Nivel abierto, o `null` si está en el selector |
| `showAreaSelector` | `true` cuando hay que mostrar el selector de niveles |
| `enterStemArea(id)` | Abre el camino de lecciones de ese nivel |
| `exitToAreaSelector()` | Vuelve al selector |

### Cómo leer un provider desde un widget

```dart
// Se redibuja cuando el provider notifica un cambio
final profile = context.watch<AuthProvider>().profile;

// Solo lee una vez; úsalo dentro de callbacks (onTap, etc.)
context.read<AuthProvider>().saveScore(moduleId, data);

// Para escuchar dos providers a la vez
Consumer2<AuthProvider, LearningProvider>(
  builder: (context, auth, learning, _) => ...,
)
```

> [!TIP]
> `watch` dentro de `build`, `read` dentro de callbacks. Usar `watch` en un
> callback provoca redibujados innecesarios; usar `read` en `build` hace que
> la interfaz no se actualice.

---

## Flujo de datos completo

Ejemplo real: **el estudiante termina un cuestionario**.

```
1. QuizScreen                    El estudiante responde la última pregunta
        │
        ▼
2. context.read<AuthProvider>().saveScore(moduleId, {score, total, completed})
        │
        ▼
3. AuthProvider                  Delega; no toca Firestore directamente
        │
        ▼
4. FirestoreService.saveModuleScore(uid, moduleId, data)
        │
        ▼
5. Cloud Firestore               Escribe en userScores/{uid}
        │
        ▼
6. onUserScoresChange(uid)       El stream emite el documento actualizado
        │
        ▼
7. AuthProvider._userScores      Se actualiza y llama a notifyListeners()
        │
        ▼
8. LessonPathScreen              Se redibuja: la siguiente lección aparece
                                 desbloqueada
```

Fíjate en que **nadie navega ni refresca a mano**. La interfaz reacciona
porque escucha el stream. Este es el patrón de toda la app.

---

## Persistencia

### Firestore — lo que debe sobrevivir al cambio de dispositivo

| Colección | Documento | Contiene |
|:--|:--|:--|
| `users` | `{uid}` | Perfil, XP, racha, skins, logros, recuento de amigos |
| `usernames` | `{nombre}` | Reserva del nombre de usuario → uid |
| `userScores` | `{uid}` | Puntuación por lección |
| `friendRequests` | `{autoId}` | Solicitudes de amistad pendientes |
| `friends/{uid}/list` | `{amigoUid}` | Lista de amistades |
| `leagues/{id}/entries` | `{uid}` | Participación en ligas semanales |
| `duels` | `{autoId}` | Duelos uno contra uno |

La colección `usernames` permite dos cosas: comprobar si un nombre está libre
**antes** de registrarse, e iniciar sesión escribiendo el usuario en vez del
correo. Por eso su lectura es pública en `firestore.rules`.

### SharedPreferences — preferencias del dispositivo

| Clave | Valor |
|:--|:--|
| `cultivatec_currentStemAreaId` | Último nivel STEM abierto |
| Preferencias de `SoundService` | Sonido activado y volumen |

### Contenido estático — compilado en la app

El plan de estudios (`stem_content.dart`) y el banco de preguntas de torneo
(`tournament_questions.dart`) son constantes de Dart. Ventajas: cero latencia,
funcionan sin conexión y se revisan en los pull requests como cualquier código.
Coste: cambiar una lección requiere publicar una versión nueva de la app.

---

## Navegación

CultivaTec **no usa rutas con nombre ni `go_router`** pese a tenerlo como
dependencia. La navegación se resuelve con estado y `Navigator.push`.

### Nivel raíz — `AppRouter` en `main.dart`

```dart
if (auth.isLoading)      return PantallaDeCarga();
if (!auth.isLoggedIn)    return AuthScreen();
if (!auth.onboardingDone) return OnboardingScreen();
return HomeScreen();
```

Es un `Consumer<AuthProvider>`: cuando el estado de sesión cambia, la pantalla
correcta aparece sola. `onboardingDone` es simplemente
`profile.robotConfig != null` — el estudiante ya creó su robot.

### Nivel principal — `HomeScreen`

Un `IndexedStack` con cinco pestañas. El `IndexedStack` **mantiene vivos** los
widgets de todas las pestañas, así que cambiar de pestaña no pierde el estado
de lo que estabas haciendo (a cambio de más memoria, aceptable con cinco
pestañas).

### Dentro de una pestaña

`Navigator.push` con `MaterialPageRoute` normal.

---

## Sistema de progresión

### XP y niveles

`lib/data/models/level_system.dart` define **25 rangos** con umbrales de XP
crecientes, de *Cadete Espacial* (0 XP) a *Omnisciente Galáctico* (70 000 XP).

```dart
final info = calculateLevel(profile.totalPoints);
info.level      // 7
info.title      // 'Programador Espacial'
info.progress   // 0.42  → para la barra de progreso
info.isMaxLevel // false
```

`calculateLevel` es una **función pura**: mismos puntos, mismo resultado. Por
eso está cubierta por pruebas en `test/level_system_test.dart`.

### Desbloqueo de lecciones

Progresión **lineal** dentro de cada nivel STEM. Una lección se desbloquea
cuando la anterior está completada:

```dart
final clave = '${area.id}_${leccionAnterior.id}';
final desbloqueada = esLaPrimera || userScores[clave]?['completed'] == true;
```

El umbral para "completada" es **70 % de aciertos**, definido en
`AuthProvider.isModuleCompleted()`.

### Skins

31 skins con cuatro rarezas (`common`, `rare`, `epic`, `legendary`). Se
desbloquean por número de desafíos completados (`challengesRequired`); algunas
son exclusivas de administración. El catálogo está en
`lib/screens/robot/robot_skin_editor_screen.dart`.

---

## Sistema de diseño

Todo el estilo sale de `lib/core/theme/theme.dart`. **No escribas colores
sueltos en las pantallas**: si falta uno, añádelo a `AppTheme`.

### Widgets reutilizables de `core/widgets/`

| Widget | Para qué sirve |
|:--|:--|
| `AnimatedBackground` | Fondo animado por defecto de la app |
| `ThemedBackground` | Fondo teñido con el color de un nivel STEM |
| `GlassCard` | Tarjeta con efecto cristal esmerilado |
| `ModernButton` | Botón principal |
| `CartoonButton` | Botón con estilo infantil, para pantallas de acceso |
| `RobotAvatar` | Muestra el robot del estudiante con su skin |

Antes de crear un widget nuevo, revisa si ya existe algo aquí.

---

## Decisiones de diseño

### Por qué Provider y no BLoC o Riverpod

La app tiene dos porciones de estado global y un equipo pequeño. Provider es
parte del ecosistema oficial de Flutter, se aprende en una tarde y no impone
código repetitivo. BLoC o Riverpod añadirían complejidad sin resolver ningún
problema que tengamos hoy.

### Por qué el contenido está en Dart y no en Firestore

Un estudiante en un aula con mala conexión debe poder aprender igual. El
contenido compilado carga instantáneamente y funciona sin red. Además se
revisa en los pull requests como el resto del código, lo que ha evitado varios
errores antes de llegar a producción. El precio —publicar una versión para
cambiar una lección— es asumible con el ritmo actual de cambios.

### Por qué la configuración de Firebase está versionada

Las claves de `firebase_config.dart` son **claves de cliente**, diseñadas para
viajar dentro de la app. Cualquiera puede extraerlas de un `.apk` publicado.
Lo que protege los datos son las reglas de `firestore.rules`, no ocultar la
clave. Versionarlas permite que un colaborador nuevo clone y compile sin
pedirle nada a nadie. Más detalle en
[CONFIGURACION_FIREBASE.md](CONFIGURACION_FIREBASE.md).

### Por qué `IndexedStack` y no `PageView`

Un estudiante que va a Ranking a ver su posición y vuelve a Aprender espera
encontrar la lección donde la dejó. `IndexedStack` conserva ese estado;
`PageView` reconstruiría la pestaña cada vez.

### Deuda técnica conocida

Consulta la sección
[Estado actual y deuda técnica](../README.md#9-estado-actual-y-deuda-técnica)
del README. Está mantenida al día y es lo primero que debes leer antes de
proponer un cambio grande.
