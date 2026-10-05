# Avisos de terceros

CultivaTec es [software propietario](LICENSE), pero se apoya en componentes de
código abierto. Este documento registra cada uno y su licencia.

Todas las licencias listadas son **permisivas** (MIT, BSD, Apache 2.0) y por
tanto compatibles con un producto propietario: permiten el uso comercial y la
distribución sin obligar a liberar nuestro código.

> [!IMPORTANT]
> **Nunca añadas una dependencia con licencia GPL, LGPL o AGPL.** Obligarían a
> publicar el código fuente de CultivaTec. Ante cualquier duda sobre una
> licencia, pregunta antes de añadir el paquete.

Última revisión: **julio de 2026** · Versión de la app: **2.5.0**

---

## Framework

| Componente | Licencia | Titular |
|:--|:--|:--|
| [Flutter SDK](https://flutter.dev) | BSD 3-Clause | The Flutter Authors |
| [Dart SDK](https://dart.dev) | BSD 3-Clause | The Dart project authors |

---

## Dependencias de producción

| Paquete | Licencia | Titular | Para qué lo usamos |
|:--|:--|:--|:--|
| `firebase_core` | BSD 3-Clause | The Chromium Authors | Inicialización de Firebase |
| `firebase_auth` | BSD 3-Clause | The Chromium Authors | Registro e inicio de sesión |
| `cloud_firestore` | BSD 3-Clause | The Chromium project authors | Base de datos en tiempo real |
| `google_sign_in` | BSD 3-Clause | The Flutter Authors | Inicio de sesión con Google |
| `provider` | MIT | Remi Rousselet | Gestión de estado |
| `go_router` | BSD 3-Clause | The Flutter Authors | Enrutado (dependencia declarada) |
| `shared_preferences` | BSD 3-Clause | The Flutter Authors | Preferencias locales |
| `google_fonts` | Apache 2.0 | Google LLC | Tipografías de la interfaz |
| `flutter_svg` | MIT | Dan Field | Renderizado de gráficos SVG |
| `flutter_animate` | BSD 3-Clause | Grant Skinner | Animaciones de la interfaz |
| `cached_network_image` | MIT | Rene Floor | Caché de imágenes remotas |
| `audioplayers` | MIT | Blue Fire | Reproducción de efectos de sonido |
| `intl` | BSD 3-Clause | The Dart project authors | Formato de fechas y números |

---

## Dependencias de desarrollo

No se distribuyen con la aplicación.

| Paquete | Licencia | Titular | Para qué lo usamos |
|:--|:--|:--|:--|
| `flutter_test` | BSD 3-Clause | The Flutter Authors | Marco de pruebas |
| `flutter_lints` | BSD 3-Clause | The Flutter Authors | Reglas del analizador |
| `flutter_launcher_icons` | MIT | Mark O'Sullivan | Generación de iconos de app |

---

## Recursos gráficos y sonoros

Las imágenes, ilustraciones, skins de robot, logotipos y sonidos incluidos en
`cultivatec_flutter/assets/` son **obra original propiedad de CultivaTec** y no
están cubiertos por ninguna licencia de código abierto. Su uso se rige
exclusivamente por la [licencia del proyecto](LICENSE).

> [!WARNING]
> Antes de incorporar cualquier imagen, icono, tipografía o sonido de un
> tercero, verifica su licencia y déjalo registrado en este archivo. Un recurso
> con licencia incompatible puede obligar a retirar la app de las tiendas.

---

## Cómo mantener este archivo

Cuando añadas una dependencia:

1. Comprueba su licencia en su ficha de [pub.dev](https://pub.dev).
2. Confirma que es MIT, BSD o Apache 2.0.
3. Añádela a la tabla correspondiente.
4. Menciónalo en la descripción de tu pull request.

Para revisar todas las licencias en uso:

```bash
flutter pub deps --style=compact
```

La app también muestra las licencias en tiempo de ejecución mediante el widget
`LicensePage` de Flutter, que las recopila automáticamente.
