# Descripción

<!-- ¿Qué hace este pull request? Dos o tres frases en lenguaje claro. -->



## Motivo

<!-- ¿Por qué era necesario? Enlaza el issue si existe: Cierra #42 -->



## Tipo de cambio

<!-- Marca con una x la casilla que corresponda: [x] -->

- [ ] 🐛 Corrección de error (`fix`)
- [ ] ✨ Función nueva (`feat`)
- [ ] 📚 Contenido educativo (`content`)
- [ ] 🎨 Cambio visual (`ui`)
- [ ] ♻️ Refactor sin cambio de comportamiento (`refactor`)
- [ ] 📝 Documentación (`docs`)
- [ ] 🔧 Configuración o dependencias (`chore`)
- [ ] ✅ Pruebas (`test`)

## Cómo probarlo

<!-- Pasos concretos para que quien revise reproduzca tu cambio. -->

1.
2.
3.

## Capturas

<!--
OBLIGATORIO si tocaste la interfaz. Antes y después si es un rediseño.
⚠️ Tapa cualquier nombre, correo o dato personal que aparezca.
-->

| Antes | Después |
|:--|:--|
|  |  |

---

## Lista de verificación

<!-- Repásala entera antes de pedir revisión. -->

### Calidad del código

- [ ] `flutter analyze` termina con **cero avisos**
- [ ] `flutter test` pasa completo
- [ ] Ejecuté `dart format --line-length 120 lib test`
- [ ] Probé el cambio en un dispositivo o emulador real
- [ ] No dejé `print()` ni `debugPrint()` de depuración
- [ ] No dejé código comentado "por si acaso"

### Arquitectura

- [ ] Ninguna pantalla accede a Firestore directamente
- [ ] Los colores y tipografías salen de `AppTheme`
- [ ] Los nombres de archivo coinciden con sus clases
- [ ] Los imports del proyecto usan `package:cultivatec_flutter/…`
- [ ] Cancelé en `dispose()` todo stream o controlador que abrí

### Seguridad y contenido

- [ ] No incluí credenciales, tokens ni claves de firma
- [ ] No incluí datos de usuarios reales (ni en capturas)
- [ ] No subí `.apk`, `.aab` ni otros binarios
- [ ] Si añadí una dependencia, su licencia es MIT/BSD/Apache y la registré en `THIRD_PARTY_NOTICES.md`
- [ ] Si toqué `firestore.rules`, lo avisé al equipo

### Documentación

- [ ] Añadí una línea en `CHANGELOG.md` si el cambio es visible para el usuario
- [ ] Actualicé la documentación afectada, si la hay

---

## Notas para quien revisa

<!--
¿Hay algo que quieras que se mire con especial atención?
¿Tomaste alguna decisión discutible que quieras contrastar?
¿Dejaste algo pendiente a propósito?
-->


