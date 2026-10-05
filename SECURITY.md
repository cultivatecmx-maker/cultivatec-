# Política de seguridad

CultivaTec es una aplicación educativa usada por **menores de edad**. Un fallo
de seguridad aquí no expone datos de empresa: expone datos de niños. Tratamos
cualquier reporte con la máxima prioridad.

---

## Cómo reportar una vulnerabilidad

> [!CAUTION]
> **No abras un issue público.** Un issue es visible para todo el equipo con
> acceso al repositorio y deja constancia permanente del fallo antes de que
> esté corregido.

Repórtalo por un canal privado directo a la dirección del proyecto:

1. Usa **GitHub Security Advisories** (pestaña *Security* → *Report a
   vulnerability*), o
2. Contacta **en privado** con la persona responsable del repositorio.

### Qué incluir

- Qué encontraste, en una frase.
- Cómo reproducirlo, paso a paso.
- Qué datos o funciones quedan expuestos.
- Tu valoración de la gravedad.
- Capturas o registros, **con los datos personales tapados**.

### Qué esperar

| Plazo | Qué ocurre |
|:--|:--|
| 48 horas | Confirmamos que recibimos tu reporte |
| 5 días hábiles | Te damos una valoración inicial y un plan |
| Según gravedad | Publicamos la corrección |

---

## Qué consideramos vulnerabilidad

### Gravedad crítica — reporta de inmediato

- Acceso a datos de estudiantes sin ser su dueño.
- Reglas de Firestore que permiten leer o escribir datos ajenos.
- Escalada de privilegios (obtener permisos de administración).
- Exposición de correos, nombres reales o cualquier dato personal de menores.
- Credenciales de servidor o claves de firma filtradas en el repositorio.

### Gravedad alta

- Suplantación de identidad de otra cuenta.
- Manipulación del progreso, XP o ranking de otro estudiante.
- Inyección de contenido en campos que ven otros usuarios.

### Gravedad media

- Manipulación del propio progreso o XP (hacer trampas).
- Fuga de información en mensajes de error.
- Dependencia con una vulnerabilidad conocida publicada.

### No es una vulnerabilidad

- Que las claves de cliente de Firebase estén en el repositorio. Es
  intencionado y seguro: son identificadores públicos, no credenciales.
  La explicación completa está en
  [docs/CONFIGURACION_FIREBASE.md](docs/CONFIGURACION_FIREBASE.md).
- Errores de interfaz sin impacto en datos. Ábrelos como issue normal.

---

## Si filtraste un secreto por accidente

Ocurre. Lo importante es la velocidad de reacción.

**No intentes arreglarlo tú solo borrando el archivo en un commit nuevo**: el
secreto sigue en el historial de Git y sigue siendo válido.

1. **Avisa de inmediato** por el canal privado.
2. Indica **qué** se filtró y **en qué commit**.
3. La dirección del proyecto **rota la credencial** — ese es el paso que
   realmente cierra el agujero.
4. Después, si procede, se limpia el historial.

Nadie recibe una reprimenda por avisar rápido. El problema serio es el silencio.

---

## Buenas prácticas del equipo

| Práctica | Por qué |
|:--|:--|
| Cuenta de prueba propia, siempre | Nunca toques datos de estudiantes reales |
| Tapa los datos personales en capturas | Una captura en un PR queda para siempre |
| No exportes colecciones de Firestore | Aunque sea "solo para mirar" |
| Revisa `firestore.rules` con especial cuidado | Una regla mal puesta expone toda la base |
| Nunca subas `.jks`, `.keystore` ni `*-adminsdk-*.json` | Dan control total sobre la app o la base |
| Activa la verificación en dos pasos en tu cuenta de GitHub | Protege el acceso al repositorio privado |
| No pegues código del proyecto en servicios externos | Incumple la confidencialidad de la licencia |

---

## Protección de datos de menores

La app procesa datos de menores de edad. Las obligaciones legales del equipo
están recogidas en la **sección 6 de la [licencia](LICENSE)**:

- Usar exclusivamente cuentas y datos de prueba durante el desarrollo.
- No extraer, copiar ni compartir datos de usuarios reales.
- Notificar de inmediato cualquier incidente o exposición.

Estas obligaciones siguen vigentes después de terminar tu colaboración con
CultivaTec.
