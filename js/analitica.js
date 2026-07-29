/* ============================================================
   CULTIVATEC — Google Analytics 4

   ┌─────────────────────────────────────────────────────────┐
   │  PEGA AQUÍ EL IDENTIFICADOR DE MEDICIÓN Y LISTO.        │
   │  Se saca de Google Analytics:                           │
   │    Administrar → Flujos de datos → tu sitio web         │
   │  Tiene la forma G-XXXXXXXXXX.                           │
   └─────────────────────────────────────────────────────────┘

   Va en un archivo aparte, y no pegado en cada página, para que solo
   haya que cambiarlo en un sitio: las 35 páginas lo cargan de aquí.

   Mientras diga 'G-XXXXXXXXXX' no se carga nada de Google: ni la
   etiqueta, ni la cookie, ni una sola petición. Así el sitio no arrastra
   peso ni avisos de cookies por una medición que todavía no existe.
   ============================================================ */

const MEDICION = 'G-XXXXXXXXXX';

/* Formato real: G- y diez caracteres. El del hueco no pasa el filtro. */
if (/^G-[A-Z0-9]{8,12}$/.test(MEDICION) && MEDICION !== 'G-XXXXXXXXXX') {

  window.dataLayer = window.dataLayer || [];
  window.gtag = function () { dataLayer.push(arguments); };
  gtag('js', new Date());

  /* `anonymize_ip` recorta el último octeto antes de guardar. En México
     no lo exige la ley, pero no cuesta nada y reduce el dato personal
     que sale del sitio. */
  gtag('config', MEDICION, {
    anonymize_ip: true,
    send_page_view: true
  });

  const etiqueta = document.createElement('script');
  etiqueta.async = true;
  etiqueta.src = 'https://www.googletagmanager.com/gtag/js?id=' + MEDICION;
  document.head.appendChild(etiqueta);
}
