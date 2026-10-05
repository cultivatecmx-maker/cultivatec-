# Configuración de Firebase

Cómo está conectada CultivaTec con Firebase, qué colecciones usa y cómo
trabajar con las reglas de seguridad sin romper nada.

---

## Índice

- [El proyecto](#el-proyecto)
- [Por qué las claves están versionadas](#por-qué-las-claves-están-versionadas)
- [Archivos de configuración](#archivos-de-configuración)
- [Autenticación](#autenticación)
- [Modelo de datos](#modelo-de-datos)
- [Reglas de seguridad](#reglas-de-seguridad)
- [Trabajar con datos durante el desarrollo](#trabajar-con-datos-durante-el-desarrollo)
- [Desplegar reglas](#desplegar-reglas)

---

## El proyecto

| Dato | Valor |
|:--|:--|
| ID del proyecto | `cultivatec-appstore` |
| Servicios usados | Authentication, Cloud Firestore |
| ID de aplicación Android | `com.cultivatec.cultivatec_app` |
| Bundle ID de iOS | `com.cultivatec.cultivatecApp` |

> [!WARNING]
> **Solo hay un proyecto Firebase, y es el de producción.** No existe un
> entorno de pruebas separado. Todo lo que hagas mientras desarrollas escribe
> en la base de datos real, junto a los datos de estudiantes reales. Trabaja
> **siempre** con tu propia cuenta de prueba.

---

## Por qué las claves están versionadas

Es la pregunta que hace todo el mundo al llegar. La respuesta corta: **las
claves de Firebase del cliente no son secretos**.

`apiKey`, `appId` y `messagingSenderId` viajan dentro de la aplicación. Están
en el `.apk` que cualquiera puede descargar de Google Play y extraer en cinco
minutos. Google las documenta explícitamente como identificadores públicos, no
como credenciales.

Lo que realmente protege los datos son:

1. **Firebase Authentication** — quién eres.
2. **`firestore.rules`** — qué puedes leer y escribir siendo quien eres.

Por eso versionarlas es seguro y práctico: un colaborador nuevo clona el
repositorio y compila sin tener que pedirle nada a nadie.

### Lo que sí sería un secreto

Estos **nunca** deben entrar al repositorio, y el `.gitignore` los bloquea:

| Archivo | Qué es |
|:--|:--|
| `*-adminsdk-*.json` | Clave del SDK de administración: acceso total, salta las reglas |
| `*service-account*.json` | Cuenta de servicio de Google Cloud |
| `*.jks`, `*.keystore` | Clave de firma de Android: quien la tenga puede publicar en tu nombre |
| `android/key.properties` | Contraseñas de la clave de firma |

Si alguna vez subes uno por error, **avisa de inmediato** siguiendo
[SECURITY.md](../SECURITY.md). Rotar la clave es sencillo; enterarse tarde, no.

---

## Archivos de configuración

| Archivo | Plataforma | Papel |
|:--|:--|:--|
| `cultivatec_flutter/lib/core/config/firebase_config.dart` | Todas | **Fuente de verdad en tiempo de ejecución.** `main.dart` inicializa Firebase desde aquí |
| `cultivatec_flutter/android/app/google-services.json` | Android | Lo consume el plugin de Gradle en la compilación |
| `cultivatec_flutter/ios/Runner/GoogleService-Info.plist` | iOS | Necesario para Google Sign-In (contiene `REVERSED_CLIENT_ID`) |
| `firestore.rules` | — | Reglas de seguridad de la base de datos |
| `firebase.json` / `.firebaserc` | — | Configuración del CLI de Firebase |

`FirebaseConfig.currentPlatform` elige la configuración según dónde se ejecute
la app. Windows y Linux no tienen configuración nativa, así que reutilizan la
de web.

> [!NOTE]
> Si cambias algo en la consola de Firebase, actualiza **los tres** archivos de
> configuración. Si solo cambias `firebase_config.dart`, la app funcionará en
> web pero fallará al compilar para Android.

---

## Autenticación

Dos métodos activos:

| Método | Detalle |
|:--|:--|
| Correo y contraseña | El estudiante puede iniciar sesión con su **correo o su nombre de usuario** |
| Google Sign-In | Android, iOS y web |

### Cómo funciona el login por nombre de usuario

Firebase Auth solo entiende de correos. Para permitir entrar con el nombre de
usuario existe la colección `usernames`:

```
1. El estudiante escribe "robotmaster"
2. Se lee usernames/robotmaster  →  { uid: "...", email: "..." }
3. Se llama a signInWithEmailAndPassword con ese correo
```

Por eso `usernames` tiene **lectura pública** en las reglas: hay que poder
consultarla *antes* de estar autenticado. Solo guarda el uid y el correo
asociados a un alias; escribirla sí requiere sesión iniciada.

---

## Modelo de datos

```
users/{uid}
  ├── username, email, fullName
  ├── robotConfig          Configuración del avatar (skin, nombre)
  ├── totalPoints          XP acumulado → determina el nivel
  ├── streak, lastActive   Racha diaria
  ├── unlockedSkins[]      Skins desbloqueadas
  ├── achievementsUnlocked[]
  └── friendsCount

usernames/{nombre}         Alias en minúscula → { uid, email }

userScores/{uid}
  └── { "<areaId>_<lessonId>": { score, total, completed } }

friendRequests/{autoId}    { fromUid, toUid, status, createdAt }

friends/{uid}/list/{amigoUid}

leagues/{leagueId}/entries/{uid}    Ligas semanales

duels/{autoId}             { players: [uidA, uidB], challengerUid, ... }
```

### Detalles importantes

- La clave de una puntuación es **`<areaId>_<lessonId>`** (por ejemplo
  `chispa_ch1`). Si cambias el `id` de una lección ya publicada, **el progreso
  de los estudiantes se pierde**: las claves antiguas dejan de coincidir.
- La amistad se guarda **dos veces** (una en cada dirección) para poder listar
  los amigos de alguien con una sola consulta.
- `friendsCount` es un contador desnormalizado. `syncFriendsCount()` lo corrige
  al iniciar sesión si se descuadra.

---

## Reglas de seguridad

Están en [`firestore.rules`](../firestore.rules) en la raíz del repositorio.

### Resumen de permisos

| Colección | Lectura | Escritura |
|:--|:--|:--|
| `users/{uid}` | Cualquier sesión iniciada | Solo el dueño (otros solo pueden tocar `friendsCount` y `lastActive`) |
| `usernames/{nombre}` | **Pública** | Solo reservar el propio alias; no se edita ni se borra |
| `userScores/{uid}` | Cualquier sesión iniciada | Solo el dueño |
| `friendRequests` | Cualquier sesión iniciada | Crea quien envía; actualizan emisor y receptor |
| `friends/{uid}/list` | Cualquier sesión iniciada | Cualquiera de los dos implicados |
| `leagues/{id}/entries/{uid}` | Cualquier sesión iniciada | Solo el dueño de la entrada |
| `duels/{id}` | Solo los dos jugadores | Crea quien reta; actualizan ambos |
| `questionBank` | Cualquier sesión iniciada | Nadie desde la app |

La función `onlySocialCounterChange()` es la excepción interesante: permite que
otra persona modifique tu perfil **únicamente** para actualizar `friendsCount`
y `lastActive` al aceptar o eliminar una amistad. Cualquier otro campo queda
bloqueado.

### Antes de tocar las reglas

> [!CAUTION]
> Una regla mal escrita puede **dejar fuera a todos los usuarios** o **exponer
> datos de menores de edad**. Los cambios en `firestore.rules` requieren
> revisión obligatoria antes de desplegarse.

Lista de comprobación:

- [ ] ¿Cada lectura exige `isSignedIn()`, salvo `usernames` que debe ser pública?
- [ ] ¿Cada escritura verifica que quien escribe es el dueño del dato?
- [ ] ¿Probé la regla en el simulador de la consola de Firebase?
- [ ] ¿Avisé al equipo de que voy a desplegar?

---

## Trabajar con datos durante el desarrollo

Reglas obligatorias, sin excepciones:

1. **Usa tu propia cuenta de prueba.** Créala desde la app la primera vez que
   la ejecutes.
2. **Nunca consultes ni exportes datos de estudiantes reales.**
3. **Nunca compartas capturas** donde se vean nombres de usuario, correos o
   cualquier dato personal.
4. **Nunca borres documentos** de la consola de Firebase salvo que sean tuyos.
5. Si necesitas datos de prueba en volumen, **pídelos al equipo** en vez de
   generarlos sobre la base real.

Estas obligaciones están recogidas en la [licencia](../LICENSE), sección 6.

---

## Desplegar reglas

Requiere el CLI de Firebase y permisos sobre el proyecto.

```bash
npm install -g firebase-tools
```

```bash
firebase login
```

Desde la **raíz del repositorio** (donde está `firebase.json`):

```bash
firebase deploy --only firestore:rules
```

> [!IMPORTANT]
> El despliegue es **inmediato** y afecta a todos los usuarios conectados. No
> hay fase de pruebas. Comprueba siempre la regla en el simulador de la consola
> de Firebase antes de desplegar, y avisa al equipo.
