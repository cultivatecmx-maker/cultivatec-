# -*- coding: utf-8 -*-
import re, glob, sys, os, json, datetime
sys.path.insert(0, 'tools')
from sitio_lib import *
exec(open('tools/paso_b.py', encoding='utf-8').read().split('# ------------------------------------------------------------ PRODUCTOS')[0].split("FUENTES =")[0])  # solo imports/HOY
HOY = datetime.date.today().isoformat()
def ld(o): return '<script type="application/ld+json">' + json.dumps(o, ensure_ascii=False) + '</script>'

def quitar_div(html, inicio_marca):
    i = html.index(inicio_marca); depth = 0
    for m in re.finditer(r'<div\b|</div>', html[i:]):
        depth += 1 if m.group(0) == '<div' else -1
        if depth == 0:
            return html[:i] + html[i + m.end():]
    raise ValueError('div sin cerrar')

# ---------------- INDEX
h = open('index.html', encoding='utf-8').read()
T = 'Cultivatec | CultivaKits y laboratorios de robótica para escuelas'
D = 'CultivaKits accesibles, laboratorios de robótica para escuelas y capacitación docente. Educación STEM con impacto social, desde Mexicali y Monterrey.'
h = re.sub(r'<title>.*?</title>', f'<title>{T}</title>', h, count=1, flags=re.S)
h = re.sub(r'<meta name="description" content="[^"]*">', f'<meta name="description" content="{D}">', h, count=1)
h = re.sub(r'<meta name="keywords"[^>]*>\s*', '', h)
for prop in ('og:title', 'twitter:title'):
    h = re.sub(rf'<meta (property|name)="{prop}" content="[^"]*">', rf'<meta \1="{prop}" content="{T}">', h)
for prop in ('og:description', 'twitter:description'):
    h = re.sub(rf'<meta (property|name)="{prop}" content="[^"]*">', rf'<meta \1="{prop}" content="{D}">', h)
h = re.sub(r'<script type="application/ld\+json">.*?</script>\s*', '', h, flags=re.S)
sociales = re.findall(r'href="(https://www\.(?:facebook|instagram|tiktok|youtube)\.com/[^"]+)"', SOCIALS)
org = {"@context": "https://schema.org", "@type": "Organization", "name": "Cultivatec", "url": DOM + "/",
       "logo": DOM + "/img/logo-cultivatec-nombre.png", "email": VENTAS, "foundingDate": "2023-01",
       "founder": {"@type": "Person", "name": "Abraham Doñate"},
       "description": "Robótica educativa accesible: CultivaKits, laboratorios de robótica y capacitación docente para escuelas.",
       "areaServed": [{"@type": "City", "name": n} for n in ("Mexicali", "Monterrey", "Ciudad de México")],
       "contactPoint": [{"@type": "ContactPoint", "contactType": "sales", "email": VENTAS, "availableLanguage": "es"}],
       "sameAs": sociales}
web = {"@context": "https://schema.org", "@type": "WebSite", "name": "Cultivatec", "url": DOM + "/", "inLanguage": "es-MX"}
h = h.replace('</head>', ld(org) + '\n' + ld(web) + '\n</head>', 1)

# hero: subtitulo, formulario -> dos caminos, linea de contacto, sin fila de placas
h = re.sub(r'(</h1>\s*)<p[^>]*>.*?</p>', r'\1<p class="hero-sub h-an h-an-3">CultivaKits accesibles para empezar, laboratorios de robótica para tu escuela y capacitación para tus docentes. Y talleres gratuitos donde no hay presupuesto.</p>', h, count=1, flags=re.S)
h = re.sub(r'<form class="hero-form.*?</form>', '<div class="hero-acciones h-an h-an-4"><a href="tu-escuela.html#formulario" class="btn btn-primary btn-lg">Diseñemos tu laboratorio</a><a href="productos.html" class="btn btn-soft btn-lg">Ver CultivaKits</a></div>', h, count=1, flags=re.S)
h = re.sub(r'<p class="hero-alt[^"]*">.*?</p>', f'<p class="hero-alt h-an h-an-5">¿Prefieres escribirnos? <a href="mailto:{VENTAS}">{VENTAS}</a></p>', h, count=1, flags=re.S)
h = quitar_div(h, '<div class="hero-placas')
h = h.replace('<div class="hero-prueba', '<div class="hero-prueba', 1)

# cuerpo nuevo: todo lo que hay entre el hero y el pie
cuerpo = f'''</header>

<section class="section bg-white" aria-labelledby="vias-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="vias-t">¿Cómo podemos ayudarte?</h2>
    <p class="sec-sub">Robótica accesible para empezar en casa o en el aula, y acompañamiento para las escuelas que quieren implementarla bien.</p></div>
    <div class="vias reveal">
      <a class="via-card" href="productos.html"><div class="via-icono"><i class="ph-fill ph-package" aria-hidden="true"></i></div><h3>CultivaKits</h3><p>Kits de robótica para principiantes: un proyecto claro, instrucciones sencillas y un resultado que puedes tocar.</p><span class="via-link">Ver productos <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></span></a>
      <a class="via-card" href="tu-escuela.html"><div class="via-icono"><i class="ph-fill ph-chalkboard-teacher" aria-hidden="true"></i></div><h3>Tu escuela</h3><p>Diseñamos el laboratorio de robótica de tu institución, capacitamos a tus docentes e implementamos programas STEM.</p><span class="via-link">Diseñemos tu laboratorio <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></span></a>
      <a class="via-card" href="impacto-social.html#colaborar"><div class="via-icono"><i class="ph-fill ph-handshake" aria-hidden="true"></i></div><h3>Empresas e impacto social</h3><p>Si tu empresa quiere financiar programas de robótica para niños con menos oportunidades, conversemos.</p><span class="via-link">Conocer cómo colaborar <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></span></a>
    </div>
  </div>
</section>

<section class="section bg-sky" aria-labelledby="kits-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="kits-t">Tres kits, tres habilidades</h2>
    <p class="sec-sub">Cada CultivaKit introduce una habilidad nueva sin volver complicado el montaje.</p></div>
    <div class="vias reveal">
      <a class="via-card" href="productos.html#kit-1"><div class="via-icono"><i class="ph-fill ph-lightbulb" aria-hidden="true"></i></div><h3>CultivaKit 1.0</h3><p>Enciende tu primer LED y comprende un circuito eléctrico básico.</p><span class="via-link">$140 MXN <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></span></a>
      <a class="via-card" href="productos.html#kit-2"><div class="via-icono"><i class="ph-fill ph-traffic-signal" aria-hidden="true"></i></div><h3>CultivaKit 2.0</h3><p>Construye tu semáforo y entiende la secuencia de sus luces.</p><span class="via-link">$150 MXN <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></span></a>
      <a class="via-card" href="productos.html#kit-3"><div class="via-icono"><i class="ph-fill ph-bell-ringing" aria-hidden="true"></i></div><h3>CultivaKit 3.0</h3><p>Crea tu primera alarma interactiva que responde a un botón.</p><span class="via-link">$170 MXN <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></span></a>
    </div>
  </div>
</section>

<section class="section bg-white" aria-labelledby="esc-t">
  <div class="container">
    <div class="banner-escuela reveal">
      <img src="img/valeon-saludando.webp" alt="" width="130" height="191" loading="lazy">
      <div><h2 id="esc-t">Laboratorio de robótica, capacitación docente y programas STEM</h2><p>Una solución personalizada para tu escuela, según tu presupuesto, tu espacio y tus objetivos académicos.</p></div>
      <a href="tu-escuela.html" class="btn btn-white btn-lg">Conoce Tu escuela</a>
    </div>
  </div>
</section>

<section class="section bg-sky" aria-labelledby="met-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="met-t">La metodología Cultivatec</h2>
    <p class="sec-sub">Es distinta a la tradicional: el niño aprende con proyectos y retos, avanzando paso a paso hasta obtener un resultado que puede tocar.</p></div>
    <ol class="pasos cuatro reveal">
      <li><h3>Comprender</h3><p>Entiende la idea detrás del proyecto.</p></li>
      <li><h3>Construir</h3><p>Arma el circuito con sus propias manos.</p></li>
      <li><h3>Experimentar</h3><p>Prueba, se equivoca y ajusta.</p></li>
      <li><h3>Resultado tangible</h3><p>Termina con algo que funciona.</p></li>
    </ol>
  </div>
</section>

<section class="section bg-white" aria-labelledby="imp-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="imp-t">Robótica para quienes menos oportunidades tienen</h2>
    <p class="sec-sub">Empezamos en enero de 2023 y desde entonces más de 1,000 alumnos han recibido robótica con nosotros. Nuestros servicios a escuelas y las alianzas con empresas ayudan a ampliar ese acceso.</p></div>
    <div class="impacto-card reveal">
      <img src="img/testimonio-nino.jpg" alt="Alumno de Cultivatec mostrando el circuito que armó en un taller de robótica" loading="lazy" decoding="async">
      <div class="impacto-overlay"><p class="impacto-frase">"No me gustó,<br>me encantó"</p><span class="impacto-autor">— Alumno, después del taller de robótica de Cultivatec</span></div>
    </div>
    <p style="text-align:center;margin-top:22px"><a href="impacto-social.html" class="btn btn-soft btn-lg">Conoce nuestro impacto</a></p>
  </div>
</section>

<section class="section-sm bg-sky">
  <div class="container">
    <div class="bloque-cta reveal">
      <h2>¿Hablamos de tu escuela o de un CultivaKit?</h2>
      <p>Cuéntanos qué necesitas. Si todavía no lo tienes claro, también te orientamos.</p>
      <div class="acciones"><a href="tu-escuela.html#formulario" class="btn btn-white btn-lg">Diseñemos tu laboratorio</a><a href="mailto:{VENTAS}" class="btn btn-glass btn-lg"><i class="ph-bold ph-envelope-simple" aria-hidden="true"></i> Escribir a ventas</a></div>
    </div>
  </div>
</section>

'''
i = h.index('</header>'); j = h.index('<footer class="footer">')
h = h[:i] + cuerpo + h[j:]
open('index.html', 'w', encoding='utf-8').write(h)

# ---------------- HISTORIA (Nosotros): solo lo que me dijiste
s = open('historia.html', encoding='utf-8').read()
s = re.sub(r'<title>.*?</title>', '<title>Nosotros: historia e identidad de Cultivatec</title>', s, count=1, flags=re.S)
s = re.sub(r'<meta name="description" content="[^"]*">', '<meta name="description" content="Conoce la historia de Cultivatec, fundada en 2023 en Mexicali por Abraham Doñate, y la identidad que guía nuestro trabajo con la robótica educativa.">', s, count=1)
s = s.replace('<span>Nuestra historia</span>', '<span aria-current="page">Nosotros</span>')
s = s.replace('Hemos visto el mismo talento en un salón prestado que en la mejor escuela privada. La única diferencia era la oportunidad.', 'Creemos que el talento no depende del código postal: lo que cambia es la oportunidad.')
s = s.replace('<h4>Cada niño que avanza, jala a otro</h4>', '<h4>Aprender haciendo</h4>')
s = s.replace('Los alumnos más grandes ayudan a los más chicos. El conocimiento que reciben\n             gratis, lo regresan enseñando.', 'Nuestra metodología es distinta a la tradicional: el niño aprende con proyectos y retos, no solo memorizando.')
s = s.replace('Literal: así empezó todo.', 'Todo comienza con un LED.')
open('historia.html', 'w', encoding='utf-8').write(s)

# ---------------- enlaces a paginas retiradas
for f in ['plataforma.html', 'contacto.html', 'cursos.html']:
    t = open(f, encoding='utf-8').read()
    t = re.sub(r'<a href="kits\.html" class="next-card t-kit">.*?</a>',
      '<a href="productos.html" class="next-card t-kit">\n          <i class="ph-fill ph-package"></i>\n          <div class="txt"><small>Productos</small><strong>CultivaKits</strong></div>\n          <i class="ph-bold ph-arrow-right"></i>\n        </a>', t, flags=re.S)
    open(f, 'w', encoding='utf-8').write(t)
b = 'blog/robot-seguidor-de-linea-paso-a-paso.html'
t = open(b, encoding='utf-8').read()
t = t.replace('y después armarlo con el\n<a href="../kits.html">Kit Constructor</a>, que trae exactamente estos componentes.', 'y después armarlo. Conoce nuestros <a href="../productos.html">CultivaKits</a> para empezar con proyectos de robótica.')
open(b, 'w', encoding='utf-8').write(t)
print('index + historia + enlaces listos')
