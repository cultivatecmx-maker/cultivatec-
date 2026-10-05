# Flujo de trabajo con Git

Guía práctica de Git para el equipo de CultivaTec. Si nunca has trabajado con
ramas y pull requests, empieza por aquí.

---

## Índice

- [El modelo en una imagen](#el-modelo-en-una-imagen)
- [Las cinco reglas](#las-cinco-reglas)
- [Nombres de rama](#nombres-de-rama)
- [Mensajes de commit](#mensajes-de-commit)
- [Ciclo completo de una tarea](#ciclo-completo-de-una-tarea)
- [Resolver conflictos](#resolver-conflictos)
- [Situaciones frecuentes](#situaciones-frecuentes)
- [Comandos de rescate](#comandos-de-rescate)
- [Chuleta](#chuleta)

---

## El modelo en una imagen

Usamos **GitHub Flow**: una rama larga (`main`) y ramas cortas por tarea.

```
main    ●───●───────────●───────────●───────────►  siempre estable
         \             / \         /
          ●───●───●───●   ●───●───●
        feat/skins        fix/racha
```

- **`main` siempre debe compilar.** Es la rama desde la que se publica.
- Cada tarea vive en su propia rama, corta y con un solo propósito.
- Nada entra en `main` sin pull request revisado.

---

## Las cinco reglas

| # | Regla | Por qué |
|:--|:--|:--|
| 1 | **Nunca trabajes directamente en `main`** | Un error tuyo bloquea a todo el equipo |
| 2 | **Una rama = una tarea** | Ramas mezcladas son imposibles de revisar y de revertir |
| 3 | **Actualiza antes de empezar** | `git pull origin main` te ahorra conflictos |
| 4 | **Analiza y prueba antes del commit** | `flutter analyze && flutter test` |
| 5 | **Nunca `--force` sobre `main`** | Puede borrar el trabajo de otras personas |

---

## Nombres de rama

Formato: `tipo/descripcion-corta-con-guiones`

```bash
git checkout -b feat/duelos-por-equipos
```

| Prefijo | Para qué | Ejemplo |
|:--|:--|:--|
| `feat/` | Función nueva | `feat/modo-sin-conexion` |
| `fix/` | Corrección de un error | `fix/racha-zona-horaria` |
| `content/` | Lecciones, preguntas, glosario | `content/maker-sensores` |
| `ui/` | Cambios visuales | `ui/rediseno-perfil` |
| `refactor/` | Reorganizar sin cambiar comportamiento | `refactor/auth-provider` |
| `docs/` | Documentación | `docs/arquitectura` |
| `chore/` | Dependencias, configuración | `chore/subir-firebase` |
| `test/` | Pruebas | `test/cobertura-niveles` |

Reglas: **todo en minúscula**, **sin tildes ni ñ**, **guiones en vez de
espacios** y **breve pero claro**.

| ✅ | ❌ |
|:--|:--|
| `fix/quiz-no-guarda-puntuacion` | `arreglo` |
| `feat/panel-del-docente` | `mi-rama` |
| `content/inventor-ia-basica` | `Cambios_Diego_2` |

---

## Mensajes de commit

Seguimos [Conventional Commits](https://www.conventionalcommits.org/es/).

```
tipo: descripción en imperativo y minúscula

Cuerpo opcional explicando el POR QUÉ del cambio, no el qué.
El código ya dice qué hace.
```

### Ejemplos completos

```bash
git commit -m "feat: añade selector de dificultad al simulador de circuitos"
```

```bash
git commit -m "fix: evita que la racha se pierda al cambiar de zona horaria" -m "La comparación usaba la hora local del dispositivo. Un estudiante que viajaba de zona horaria perdía la racha sin haber fallado ningún día. Ahora se normaliza a UTC antes de comparar."
```

```bash
git commit -m "content: añade 6 lecciones de sensores al nivel Maker"
```

### Qué hace bueno a un mensaje

| ✅ Bien | ❌ Mal | Problema |
|:--|:--|:--|
| `fix: corrige el cálculo de XP en duelos` | `arreglado el bug` | ¿Qué bug? |
| `ui: aumenta el contraste del botón continuar` | `cambios de diseño` | ¿Cuáles? |
| `refactor: extrae la lógica de racha a un servicio` | `limpieza` | Sin información |
| `chore: actualiza firebase_core a 3.9.0` | `update` | ¿Qué se actualizó? |

**Truco:** el mensaje debe completar la frase *"Al aplicar este commit, se…"*.
"Al aplicar este commit, se **añade el selector de dificultad**". Encaja.
"Al aplicar este commit, se **cambios varios**". No encaja.

### Un commit = un cambio

Si tu mensaje necesita un "y" (`fix: arregla la racha y cambia el color del
botón`), son dos commits.

---

## Ciclo completo de una tarea

### 1. Sincroniza

```bash
git checkout main
```

```bash
git pull origin main
```

### 2. Crea la rama

```bash
git checkout -b fix/racha-zona-horaria
```

### 3. Trabaja y revisa

```bash
git status
```

```bash
git diff
```

Lee tu propio diff. Detecta `print()` olvidados y archivos que no querías tocar.

### 4. Comprueba

```bash
cd cultivatec_flutter && flutter analyze && flutter test
```

### 5. Prepara y confirma

Para añadir todo:

```bash
git add .
```

O selecciona archivos concretos (mejor si tocaste cosas no relacionadas):

```bash
git add cultivatec_flutter/lib/data/services/firestore_service.dart
```

```bash
git commit -m "fix: evita que la racha se pierda al cambiar de zona horaria"
```

### 6. Sube

```bash
git push -u origin fix/racha-zona-horaria
```

### 7. Abre el pull request

En GitHub aparecerá el botón **Compare & pull request**. Rellena la plantilla,
adjunta capturas si tocaste la interfaz, y espera a que la comprobación
automática se ponga verde.

### 8. Atiende la revisión

Los arreglos van como **commits nuevos en la misma rama**:

```bash
git add . && git commit -m "fix: aplica los comentarios de la revisión"
```

```bash
git push
```

### 9. Limpia

Cuando se fusione:

```bash
git checkout main && git pull origin main
```

```bash
git branch -d fix/racha-zona-horaria
```

---

## Resolver conflictos

Un conflicto aparece cuando tú y otra persona modificasteis las mismas líneas.
**Es normal y no has roto nada.**

### Cómo se resuelve

```bash
git checkout main && git pull origin main
```

```bash
git checkout tu-rama
```

```bash
git merge main
```

Git te dirá qué archivos están en conflicto. Ábrelos y verás:

```
<<<<<<< HEAD
final umbral = 70;      ← lo que hay en TU rama
=======
final umbral = 75;      ← lo que hay en main
>>>>>>> main
```

Decide qué debe quedar (a veces es una mezcla de ambas), **borra las tres
líneas de marcas** (`<<<<<<<`, `=======`, `>>>>>>>`) y guarda.

Después:

```bash
cd cultivatec_flutter && flutter analyze && flutter test
```

```bash
git add . && git commit
```

```bash
git push
```

### Si te bloqueas

```bash
git merge --abort
```

Esto cancela la fusión y te devuelve al estado anterior. **Después pregunta al
equipo.** Nunca resuelvas un conflicto a la fuerza con `--force`.

---

## Situaciones frecuentes

### Me equivoqué en el mensaje del último commit

Solo si **todavía no has hecho push**:

```bash
git commit --amend -m "fix: mensaje correcto"
```

### Empecé a trabajar en `main` sin darme cuenta

Tus cambios aún no están confirmados, así que puedes llevártelos a una rama:

```bash
git checkout -b fix/mi-rama
```

Los cambios te siguen. Ya puedes confirmar con normalidad.

### Necesito guardar lo que llevo para hacer otra cosa urgente

```bash
git stash
```

```bash
git stash pop
```

`stash` guarda tus cambios sin confirmar y deja el árbol limpio; `pop` los
devuelve.

### Quiero descartar mis cambios en un archivo

```bash
git restore cultivatec_flutter/lib/main.dart
```

> [!CAUTION]
> Esto **borra** tu trabajo en ese archivo sin posibilidad de recuperarlo.

### Mi rama está muy vieja

```bash
git checkout main && git pull origin main
```

```bash
git checkout tu-rama && git merge main
```

### Confirmé un archivo que no debía

Si aún no has hecho push:

```bash
git reset HEAD~1
```

Esto deshace el commit pero **conserva tus cambios** en el árbol de trabajo.
Vuelve a preparar solo lo que corresponde y confirma de nuevo.

---

## Comandos de rescate

| Necesito | Comando |
|:--|:--|
| Ver qué cambié | `git status` y `git diff` |
| Ver el historial | `git log --oneline --graph -20` |
| Ver quién tocó una línea | `git blame archivo.dart` |
| Ver un commit concreto | `git show <hash>` |
| Cancelar una fusión a medias | `git merge --abort` |
| Deshacer el último commit conservando cambios | `git reset HEAD~1` |
| Recuperar algo que creo que perdí | `git reflog` |

> [!TIP]
> `git reflog` guarda todo lo que hiciste en el repositorio local durante
> semanas. Casi nada se pierde de verdad en Git. Antes de entrar en pánico,
> mira ahí o pregunta al equipo.

---

## Chuleta

```bash
git checkout main && git pull origin main    # sincronizar
git checkout -b feat/mi-tarea                # crear rama
git status                                   # ver estado
git diff                                     # ver cambios
git add .                                    # preparar todo
git commit -m "feat: descripción"            # confirmar
git push -u origin feat/mi-tarea             # subir (primera vez)
git push                                     # subir (después)
git branch -d feat/mi-tarea                  # borrar rama local
```

Y antes de cada commit, siempre:

```bash
cd cultivatec_flutter && flutter analyze && flutter test
```
