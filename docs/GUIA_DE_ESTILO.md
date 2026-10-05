# Guía de estilo de código

Convenciones de Dart y Flutter para CultivaTec. El objetivo es que todo el
código parezca escrito por la misma persona.

La base es el [estilo oficial de Dart](https://dart.dev/effective-dart).
Este documento solo recoge lo que **añadimos o cambiamos**.

---

## Índice

- [Herramientas](#herramientas)
- [Nombres](#nombres)
- [Organización de un archivo](#organización-de-un-archivo)
- [Widgets](#widgets)
- [Estado](#estado)
- [Estilo y colores](#estilo-y-colores)
- [Asincronía](#asincronía)
- [Comentarios](#comentarios)
- [Pruebas](#pruebas)
- [Antipatrones](#antipatrones)

---

## Herramientas

Tres comandos, todos desde `cultivatec_flutter/`:

```bash
flutter analyze
```

```bash
dart format --line-length 120 lib test
```

```bash
dart fix --apply
```

### Reglas estrictas

El archivo `analysis_options.yaml` **promueve a error** lo que Flutter marca
como simple aviso:

| Regla | Por qué es error |
|:--|:--|
| `unused_import` | Import muerto = dependencia falsa |
| `unused_field` / `unused_element` | Suele señalar una función desconectada por accidente |
| `dead_code` | Código inalcanzable esconde bugs de lógica |
| `use_build_context_synchronously` | Usar `context` tras un `await` puede petar la app |
| `cancel_subscriptions` | Streams sin cancelar = fugas de memoria |

`flutter analyze` debe terminar en **cero avisos**. Sin excepciones.

---

## Nombres

| Elemento | Convención | Ejemplo |
|:--|:--|:--|
| Archivos y carpetas | `snake_case` | `lesson_path_screen.dart` |
| Clases, enums, extensiones | `PascalCase` | `LessonPathScreen` |
| Variables, funciones, parámetros | `camelCase` | `currentStemAreaId` |
| Constantes globales | `k` + `PascalCase` | `kDefaultSkinId` |
| Privados del archivo | `_` inicial | `_AreaCard`, `_buildHeader()` |

### El nombre debe decir la verdad

Un archivo llamado `universe_map_screen.dart` que en realidad muestra niveles
STEM confunde a quien llega nuevo. **Si renombras una clase, renombra el
archivo.**

| Sufijo | Cuándo se usa |
|:--|:--|
| `...Screen` | Ocupa la pantalla completa |
| `...Card`, `...Button`, `...Tile` | Componente reutilizable |
| `...Provider` | Extiende `ChangeNotifier` |
| `...Service` | Habla con Firebase o el sistema |
| `...Data`, `...Info`, `...Config` | Modelo de datos puro |

### Booleanos

Empiezan con `is`, `has`, `can` o `should`:

```dart
bool isLoading;
bool hasProfile;
bool canUnlockSkin;
```

---

## Organización de un archivo

Orden fijo de los imports, separados por línea en blanco:

```dart
// 1. Librería estándar de Dart
import 'dart:async';
import 'dart:math';

// 2. Paquetes de Flutter y de terceros
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 3. Del propio proyecto — SIEMPRE con ruta package:, nunca relativa
import 'package:cultivatec_flutter/core/theme/theme.dart';
import 'package:cultivatec_flutter/providers/auth_provider.dart';
```

> [!IMPORTANT]
> Los imports del proyecto usan **siempre** `package:cultivatec_flutter/…`,
> nunca rutas relativas (`../../core/theme.dart`). Lo impone la regla
> `always_use_package_imports`: los imports absolutos sobreviven a mover un
> archivo de carpeta.

### Orden dentro de una clase

```dart
class MiWidget extends StatefulWidget {
  // 1. Campos
  final String titulo;

  // 2. Constructor
  const MiWidget({super.key, required this.titulo});

  // 3. createState / build
  @override
  State<MiWidget> createState() => _MiWidgetState();
}

class _MiWidgetState extends State<MiWidget> {
  // 1. Campos de estado
  bool _cargando = false;

  // 2. Ciclo de vida
  @override
  void initState() { ... }

  @override
  void dispose() { ... }   // ← cancela aquí todo lo que abriste

  // 3. build
  @override
  Widget build(BuildContext context) { ... }

  // 4. Métodos auxiliares privados
  Widget _buildHeader() { ... }
}
```

**Un archivo, una responsabilidad.** Si supera las ~600 líneas, probablemente
haya que partirlo. Las clases privadas auxiliares (`_AreaCard`) sí pueden
convivir con la pantalla que las usa.

---

## Widgets

### `const` siempre que se pueda

```dart
// ❌ Se reconstruye en cada frame
Text('CultivaTec')

// ✅ Se construye una vez
const Text('CultivaTec')
```

Es la optimización más barata de Flutter. `dart fix --apply` la aplica sola.

### Extrae widgets, no funciones que devuelven widgets

```dart
// ⚠️ Aceptable para trozos pequeños; se reconstruye con el padre
Widget _buildCard() => Card(...);

// ✅ Mejor: puede ser const y Flutter lo optimiza por separado
class _MiCard extends StatelessWidget {
  const _MiCard({required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) => Card(...);
}
```

Regla práctica: si el trozo pasa de 30 líneas o se usa más de una vez, hazlo
una clase.

### `child` va al final

```dart
// ✅
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(color: AppTheme.primaryBlue),
  child: const Text('Hola'),
)
```

Lo impone `sort_child_properties_last`: con el `child` al final, la estructura
del árbol se lee de un vistazo.

### Llaves siempre

```dart
// ❌
if (cargando) return const CircularProgressIndicator();
for (final x in lista) hazAlgo(x);

// ✅
if (cargando) {
  return const CircularProgressIndicator();
}
for (final x in lista) {
  hazAlgo(x);
}
```

---

## Estado

### `watch` vs `read`

```dart
// En build: se redibuja cuando cambia
final profile = context.watch<AuthProvider>().profile;

// En un callback: solo lee
onPressed: () => context.read<AuthProvider>().logout(),
```

Usar `watch` en un callback provoca redibujados de más. Usar `read` en `build`
hace que la interfaz no se entere de los cambios.

### `setState` mínimo

```dart
// ❌ Trabajo pesado dentro de setState
setState(() {
  _resultados = calculoCostoso();
});

// ✅ Calcula fuera, asigna dentro
final resultados = calculoCostoso();
setState(() => _resultados = resultados);
```

### Cancela lo que abras

```dart
StreamSubscription? _sub;

@override
void dispose() {
  _sub?.cancel();
  _controller.dispose();
  super.dispose();
}
```

Un stream sin cancelar sigue vivo tras cerrar la pantalla: consume batería y
puede petar al llamar a `setState` sobre un widget desmontado.

---

## Estilo y colores

**Todo sale de `AppTheme`.** Si un color no está, añádelo ahí.

```dart
// ❌ Imposible de cambiar globalmente
color: const Color(0xFF2563EB)

// ✅
color: AppTheme.primaryBlue
```

### Espaciado

Múltiplos de 4: `4, 8, 12, 16, 20, 24, 32`.

```dart
const SizedBox(height: 16)
padding: const EdgeInsets.all(20)
```

### `SizedBox` para espacio, `Container` para decorar

```dart
// ❌
Container(height: 16)

// ✅
const SizedBox(height: 16)
```

Lo impone `sized_box_for_whitespace`: `SizedBox` es más ligero y puede ser
`const`.

---

## Asincronía

### `context` después de un `await`

```dart
// ❌ El widget puede haberse desmontado durante el await
await guardarPuntuacion();
Navigator.of(context).pop();

// ✅
await guardarPuntuacion();
if (!context.mounted) return;
Navigator.of(context).pop();
```

Lo detecta `use_build_context_synchronously`, que en este proyecto es un error.

### No te tragues los errores en silencio

```dart
// ❌ Si falla, nadie se entera nunca
try {
  await algo();
} catch (_) {}

// ✅ Al menos deja constancia y avisa al usuario
try {
  await algo();
} catch (e) {
  debugPrint('Error al guardar la puntuación: $e');
  _error = 'No pudimos guardar tu progreso. Revisa tu conexión.';
  notifyListeners();
}
```

Los mensajes de error que ve el estudiante van **en español y sin jerga
técnica**: "No pudimos guardar tu progreso", no
`FirebaseException: permission-denied`.

---

## Comentarios

Explica el **porqué**, no el **qué**.

```dart
// ❌ El código ya lo dice
// Incrementa el contador
contador++;

// ✅ Aporta lo que el código no puede
// Se compara en UTC: con hora local, un estudiante que cambia de zona
// horaria perdería la racha sin haber fallado ningún día.
final hoy = DateTime.now().toUtc();
```

- `///` para clases y funciones públicas.
- `//` para notas internas.
- Un `TODO` siempre lleva contexto: `// TODO: mover la lista de admins a
  Firestore (issue #42)`.

---

## Pruebas

Van en `test/`, con el sufijo `_test.dart`.

### Qué probar primero

| Prioridad | Qué | Ejemplo |
|:--|:--|:--|
| **Alta** | Funciones puras de lógica | `calculateLevel()` |
| **Alta** | Integridad del contenido educativo | ids únicos, respuestas válidas |
| Media | Widgets con lógica de estado | Pantalla de quiz |
| Baja | Widgets puramente decorativos | Fondos animados |

### Cómo se escribe

```dart
test('promociona exactamente en el umbral', () {
  final segundo = levelThresholds[1];
  expect(calculateLevel(segundo.xp - 1).level, 1);
  expect(calculateLevel(segundo.xp).level, segundo.level);
});
```

El nombre describe **el comportamiento esperado**, no el método. `'promociona
exactamente en el umbral'` dice mucho más que `'prueba calculateLevel'`.

Cuando una prueba pueda fallar de forma ambigua, añade `reason:` en español —
así el error explica qué hay que arreglar.

---

## Antipatrones

Lo que rechazamos en revisión:

| Antipatrón | Por qué | Qué hacer |
|:--|:--|:--|
| Firestore desde un widget | Rompe las capas | Pasa por el provider |
| Color escrito a mano | Imposible cambiarlo globalmente | Añádelo a `AppTheme` |
| `catch (_) {}` vacío | Los errores desaparecen | Registra y avisa al usuario |
| `print()` en producción | Ensucia los logs | `debugPrint()` o quítalo |
| Código comentado "por si acaso" | Git ya guarda el historial | Bórralo |
| Números mágicos sin nombre | Nadie sabe qué significan | Constante con nombre |
| Archivos de más de 600 líneas | Imposibles de revisar | Pártelos |
| `dynamic` sin necesidad | Se pierde la seguridad de tipos | Usa el tipo real |
| Import relativo (`../../`) | Se rompe al mover archivos | Usa `package:` |
| Widget de `core/` que importa un provider | Deja de ser reutilizable | Pásalo por parámetro |
