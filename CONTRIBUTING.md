# Guía de colaboración

Bienvenido al equipo de **CultivaTec**. Esta guía explica cómo trabajamos para
que tu primera aportación salga bien a la primera.

> [!IMPORTANT]
> Antes de escribir código, lee la **[licencia](LICENSE)**. Todo lo que
> aportes pasa a ser propiedad de CultivaTec y el repositorio es
> **confidencial**: no publiques código, capturas ni contenido fuera del
> equipo.

---

## Tabla de contenidos

- [Antes de empezar](#antes-de-empezar)
- [Tu primera aportación](#tu-primera-aportación)
- [Cómo elegir en qué trabajar](#cómo-elegir-en-qué-trabajar)
- [Reglas de código](#reglas-de-código)
- [Lista de verificación antes del pull request](#lista-de-verificación-antes-del-pull-request)
- [Cómo revisamos el código](#cómo-revisamos-el-código)
- [Trabajar con contenido educativo](#trabajar-con-contenido-educativo)
- [Trabajar con la base de datos](#trabajar-con-la-base-de-datos)
- [Añadir dependencias](#añadir-dependencias)
- [Qué nunca debe pasar](#qué-nunca-debe-pasar)
- [Dónde preguntar](#dónde-preguntar)

---

## Antes de empezar

Necesitas tres cosas:

1. **Acceso al repositorio privado**, concedido por CultivaTec.
2. **Flutter 3.27 o superior** en el canal `stable` (`flutter --version`).
3. Haber leído el [README](README.md) completo, en especial las secciones
   *Arquitectura* y *Dónde va cada cosa*.

Configura tu identidad de Git con tus datos reales — así sabemos quién hizo
cada cambio:

```bash
git config user.name "Tu Nombre"
```

```bash
git config user.email "tu.correo@ejemplo.com"
```

---

## Tu primera aportación

Un recorrido completo, de principio a fin:

```bash
git clone https://github.com/cultivatecmx-maker/Cultivatec-app.git
```

```bash
cd "Cultivatec-app/cultivatec_flutter" && flutter pub get
```

```bash
flutter run
```

Cuando la app arranque en tu dispositivo o emulador, **crea una cuenta de
prueba propia**. Esa será tu cuenta de trabajo a partir de ahora.

Después:

```bash
git checkout -b fix/mi-primer-cambio
```

Haz tu cambio, y antes de subir nada:

```bash
flutter analyze && flutter test
```

```bash
git add . && git commit -m "fix: descripción breve del cambio"
```

```bash
git push -u origin fix/mi-primer-cambio
```

Y abre el pull request en GitHub. El paso a paso detallado está en la
[sección 7 del README](README.md#7-cómo-subir-tus-cambios) y en
[docs/FLUJO_DE_TRABAJO_GIT.md](docs/FLUJO_DE_TRABAJO_GIT.md).

---

## Cómo elegir en qué trabajar

1. Revisa los **issues abiertos** en GitHub. Los marcados como
   `good first issue` son buenos para empezar.
2. **Comenta el issue** antes de empezar, para que nadie duplique tu trabajo.
3. Si quieres proponer algo que no existe, abre un issue con la plantilla de
   propuesta **antes** de escribir código. Evita que dediques días a algo que
   no encaja en el plan del producto.

### Tamaño de un pull request

| Tamaño | Líneas cambiadas | Recomendación |
|:--|:--|:--|
| ✅ Ideal | menos de 400 | Se revisa en minutos |
| ⚠️ Aceptable | 400 – 800 | Explica bien la estructura en la descripción |
| ❌ Evítalo | más de 800 | Divídelo en varios pull requests |

Un pull request grande tarda días en revisarse y acumula conflictos. Si tu
tarea es grande, pártela: primero el refactor, después la función nueva.

---

## Reglas de código

### Las tres que más importan

**1. Una pantalla nunca habla con Firebase.**

```dart
// ❌ Mal — la pantalla conoce la base de datos
final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

// ✅ Bien — la pantalla pide al provider
final profile = context.watch<AuthProvider>().profile;
```

**2. Un widget de `core/` no conoce a nadie.**

Lo que vive en `lib/core/widgets/` debe poder copiarse a otro proyecto sin
arrastrar nada. Si necesita un provider, no pertenece a `core/`: recibe los
datos por parámetro.

**3. Los colores y las tipografías salen de `AppTheme`.**

```dart
// ❌ Mal — color suelto imposible de cambiar globalmente
color: const Color(0xFF2563EB)

// ✅ Bien
color: AppTheme.primaryBlue
```

Si necesitas un color que no está en `AppTheme`, **añádelo ahí** en vez de
escribirlo suelto en la pantalla.

### Nombres

| Elemento | Convención | Ejemplo |
|:--|:--|:--|
| Archivos y carpetas | `snake_case` | `lesson_path_screen.dart` |
| Clases y enums | `PascalCase` | `LessonPathScreen` |
| Variables y funciones | `camelCase` | `currentStemAreaId` |
| Constantes globales | `kCamelCase` | `kDefaultSkinId` |
| Privados del archivo | `_` al inicio | `_AreaCard` |

El nombre del archivo debe coincidir con su clase principal: la clase
`LessonPathScreen` vive en `lesson_path_screen.dart`. **Si renombras una
clase, renombra el archivo.**

### Formato

```bash
dart format --line-length 120 lib test
```

El límite es de 120 caracteres, no los 80 por defecto de Dart. Está fijado en
`.editorconfig`.

### Comentarios

Comenta el **porqué**, no el **qué**. El código ya dice lo que hace.

```dart
// ❌ Redundante
// Suma uno al contador
counter++;

// ✅ Aporta contexto que el código no puede expresar
// La racha se compara en UTC: si usáramos la hora local, un estudiante que
// viaja de zona horaria perdería la racha sin haber fallado ningún día.
final today = DateTime.now().toUtc();
```

Usa `///` para documentar clases y funciones públicas, y `//` para notas
internas. Escribe los comentarios en el mismo idioma que los que ya hay en
ese archivo.

### Idioma

| Qué | Idioma |
|:--|:--|
| Texto visible para el estudiante | **Español** |
| Contenido educativo | **Español** |
| Nombres de variables, clases y archivos | **Inglés** |
| Mensajes de commit y pull requests | **Español** |
| Documentación del repositorio | **Español** |

---

## Lista de verificación antes del pull request

Repásala entera. Es exactamente lo que mira quien revisa:

- [ ] `flutter analyze` termina con **cero avisos**
- [ ] `flutter test` pasa completo
- [ ] Ejecuté `dart format --line-length 120 lib test`
- [ ] Probé el cambio en un dispositivo o emulador real
- [ ] No dejé ningún `print()` ni `debugPrint()` de depuración
- [ ] No dejé código comentado "por si acaso"
- [ ] No subí `.apk`, `.aab`, capturas sueltas ni archivos temporales
- [ ] No incluí credenciales, claves ni datos de usuarios reales
- [ ] Los nombres de archivo coinciden con sus clases
- [ ] Si toqué la interfaz, adjunté capturas en el pull request
- [ ] Si añadí contenido educativo, `flutter test` lo valida sin errores
- [ ] El mensaje de commit sigue el formato `tipo: descripción`
- [ ] Mi rama está actualizada con `main`

---

## Cómo revisamos el código

### Qué mira quien revisa

1. **¿Funciona?** ¿Resuelve lo que dice resolver?
2. **¿Está en la capa correcta?** ¿La pantalla hace trabajo de servicio?
3. **¿Se entiende?** ¿Se leerá bien dentro de seis meses?
4. **¿Rompe algo?** ¿Afecta al progreso ya guardado de los estudiantes?
5. **¿Es seguro?** ¿Toca reglas de Firestore o datos personales?

### Cómo responder a los comentarios

- Un comentario es sobre el **código**, no sobre ti.
- Si estás de acuerdo, aplica el cambio y responde con un ✅.
- Si no estás de acuerdo, **explica por qué**. Discutir la solución es parte
  del trabajo.
- Si no entiendes un comentario, **pregunta**. Nadie espera que lo sepas todo.
- Sube los arreglos como commits nuevos en la misma rama: no cierres el pull
  request para abrir otro.

### Aprobación

Un pull request necesita **al menos una aprobación** y la comprobación
automática en verde antes de fusionarse. Quien revisa no fusiona por ti salvo
que lo acordéis.

---

## Trabajar con contenido educativo

El contenido es el corazón del producto. Se le exige el mismo cuidado que al
código.

### Antes de escribir una lección

- **Público objetivo:** niños y adolescentes. Frases cortas, sin jerga
  innecesaria. Si usas un término técnico, explícalo en la misma tarjeta.
- **Cada lección se sostiene sola.** No des por hecho que recuerdan la
  anterior.
- **Progresión:** una lección solo puede apoyarse en conceptos ya vistos en
  lecciones previas del mismo nivel.

### Requisitos de cada lección

| Elemento | Mínimo | Nota |
|:--|:--|:--|
| Tarjetas de contenido | 3 | Mezcla concepto, ejemplo y dato curioso |
| Preguntas | 3 | Idealmente 5 |
| Opciones por pregunta | 4 | Las incorrectas deben ser creíbles |
| Explicación | Siempre | Enseña *por qué*, no solo cuál era la correcta |

### Revisión ortográfica

El contenido lo lee un niño. Revisa **tildes, mayúsculas y puntuación** antes
de subirlo. Un error ortográfico en una lección desprestigia el producto.

### Validación automática

```bash
flutter test
```

Las pruebas de `test/stem_content_test.dart` comprueban que no haya ids
repetidos, que cada pregunta apunte a una opción existente, que ninguna quede
sin explicación y que toda práctica declare su `challengeId`. **Si esta prueba
falla, tu contenido tiene un error real.**

---

## Trabajar con la base de datos

> [!CAUTION]
> La app se conecta a la base de datos de **producción**. Ahí hay datos de
> menores de edad reales.

Reglas obligatorias:

- Trabaja **siempre** con tu cuenta de prueba.
- **Nunca** consultes, exportes ni modifiques datos de estudiantes reales.
- **Nunca** compartas capturas donde se vean nombres o correos de usuarios.
- Si cambias `firestore.rules`, **avisa antes de desplegar**: una regla mal
  puesta puede dejar fuera a toda la base de usuarios o exponer datos.

Detalles de colecciones y permisos en
[docs/CONFIGURACION_FIREBASE.md](docs/CONFIGURACION_FIREBASE.md).

---

## Añadir dependencias

Cada paquete nuevo es una responsabilidad a largo plazo. Antes de añadir uno:

1. **¿Es realmente necesario?** ¿Se puede resolver con lo que ya hay?
2. **¿Está mantenido?** Mira la fecha de la última publicación en pub.dev.
3. **¿Su licencia es compatible con un producto propietario?**
   MIT, BSD y Apache-2.0 sí. **GPL y AGPL no** — nos obligarían a liberar el
   código.
4. **¿Soporta todas nuestras plataformas?** Android, iOS y Web como mínimo.

Si cumple los cuatro puntos:

```bash
flutter pub add nombre_del_paquete
```

Después **explica en tu pull request por qué lo añadiste** y registra la
dependencia y su licencia en [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

## Qué nunca debe pasar

| ❌ Prohibido | Por qué |
|:--|:--|
| Hacer commit directo en `main` | Todo cambio necesita revisión |
| `git push --force` a `main` | Puede borrar el trabajo de todo el equipo |
| Subir claves, tokens o `.jks` | Compromete la cuenta de publicación |
| Subir `.apk`, `.aab` o vídeos | Inflan el repositorio para siempre |
| Publicar código fuera del equipo | Incumple la licencia y la confidencialidad |
| Tocar datos de usuarios reales | Riesgo legal con datos de menores |
| Fusionar tu propio pull request sin revisión | Se pierde el control de calidad |
| Dejar `flutter analyze` en rojo | Rompe la compilación de los demás |

---

## Dónde preguntar

- **Duda sobre el código:** coméntala en el issue o en el pull request
  correspondiente.
- **Duda sobre el producto o el contenido:** abre un issue con la plantilla de
  propuesta.
- **Problema de seguridad:** **no abras un issue público.** Sigue
  [SECURITY.md](SECURITY.md).

Preguntar pronto ahorra días de trabajo mal enfocado. Nadie espera que sepas
todo desde el primer día.

---

<div align="center">

Gracias por construir CultivaTec. 🤖

</div>
