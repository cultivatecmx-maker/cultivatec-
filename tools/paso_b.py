# -*- coding: utf-8 -*-
import json, re, glob, sys, os, datetime
sys.path.insert(0, 'tools')
from sitio_lib import *

HOY = datetime.date.today().isoformat()
FUENTES = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=League+Spartan:wght@700;800&display=swap'

def esc(s): return s.replace('&', '&amp;').replace('"', '&quot;')

def ld(obj): return '<script type="application/ld+json">' + json.dumps(obj, ensure_ascii=False) + '</script>'

def migas(items):
    return {"@context": "https://schema.org", "@type": "BreadcrumbList",
            "itemListElement": [{"@type": "ListItem", "position": i + 1, "name": n, "item": DOM + u} for i, (n, u) in enumerate(items)]}

def faq_ld(pares):
    return {"@context": "https://schema.org", "@type": "FAQPage",
            "mainEntity": [{"@type": "Question", "name": q, "acceptedAnswer": {"@type": "Answer", "text": a}} for q, a in pares]}

def faq_html(pares):
    return '<div class="faq">' + ''.join(f'<details><summary>{q}</summary><p>{a}</p></details>' for q, a in pares) + '</div>'

def shell(archivo, titulo, desc, body, active='', jsonld='', noindex=False, base='', cta_movil=True, og='img/hero-taller.jpg', canon=True, abs_paths=False):
    p = '/' if abs_paths else base
    url = f'{DOM}/{archivo}'
    robots = '<meta name="robots" content="noindex, follow">\n' if noindex else ''
    can = f'<link rel="canonical" href="{url}">\n' if canon else ''
    navh = nav(p, active)
    if abs_paths: navh = navh.replace('href="//', 'href="/')
    return f'''<!DOCTYPE html>
<html lang="es-MX">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{titulo}</title>
<meta name="description" content="{esc(desc)}">
{can}{robots}<meta name="theme-color" content="#0958C2">
<meta property="og:type" content="website">
<meta property="og:site_name" content="Cultivatec">
<meta property="og:locale" content="es_MX">
<meta property="og:title" content="{esc(titulo)}">
<meta property="og:description" content="{esc(desc)}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{DOM}/{og}">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="{p}icon-192.png">
<link rel="apple-touch-icon" href="{p}icon-192.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="{FUENTES}" rel="stylesheet">
<script src="https://unpkg.com/@phosphor-icons/web"></script>
<link rel="stylesheet" href="{p}css/styles.css">
<link rel="stylesheet" href="{p}css/sitio.css">
{jsonld}
</head>
<body>
<a href="#main" class="skip-link">Saltar al contenido</a>
{navh}
<main id="main">
{body}
</main>
{footer(p)}
{flotantes(p, cta_movil)}<button class="back-to-top" aria-label="Volver arriba"><i class="ph-bold ph-caret-up"></i></button>
<script src="{p}js/main.js?v=20261012"></script>
<script src="{p}js/sitio.js" defer></script>
</body>
</html>
'''

def hero(h1, lead, miga_actual, acciones, media='', compartir=False):
    comp = '<button type="button" class="btn-compartir" data-compartir><i class="ph-bold ph-share-network"></i> Compartir</button>' if compartir else ''
    med = f'<div class="hero-media">{media}</div>' if media else ''
    return f'''<section class="page-hero azul-curvo" style="--ph1:var(--brand-50)">
  <div class="container hero-split">
    <div>
      <div class="crumbs"><a href="/">Inicio</a><i class="ph-bold ph-caret-right" aria-hidden="true"></i><span aria-current="page">{miga_actual}</span></div>
      <h1>{h1}</h1>
      <p>{lead}</p>
      <div class="hero-acciones">{acciones}{comp}</div>
    </div>
    {med}
  </div>
</section>'''

def puntos(lista, icono='ph-check-circle'):
    return '<ul class="puntos">' + ''.join(f'<li><i class="ph-fill {icono}" aria-hidden="true"></i><span>{t}</span></li>' for t in lista) + '</ul>'

def campo(id_, label, tipo='text', req=False, ancho=False, extra='', opc=False):
    r = ' required' if req else ''
    sm = ' <small>(opcional)</small>' if opc else ''
    cls = 'campo ancho' if ancho else 'campo'
    return f'<div class="{cls}"><label for="{id_}">{label}{sm}</label><input id="{id_}" name="{id_}" type="{tipo}"{r} aria-describedby="err-{id_}" autocomplete="off" {extra}><p class="campo-error" id="err-{id_}" role="alert"></p></div>'

def formulario(form_id, titulo, intro, asunto, campos_html, boton, nota=''):
    return f'''<div class="form-card" id="formulario">
  <h2>{titulo}</h2>
  <p class="form-intro">{intro}</p>
  <form id="{form_id}" method="POST" action="https://formsubmit.co/{CONTACTO}" data-formulario data-gracias="gracias.html" novalidate>
    <input type="hidden" name="_subject" value="{asunto}">
    <input type="hidden" name="_cc" value="{VENTAS}">
    <input type="hidden" name="_template" value="table">
    <input type="hidden" name="_captcha" value="false">
    <input type="hidden" name="_next" value="{DOM}/gracias.html">
    <div class="hp" aria-hidden="true"><label>No llenar este campo<input type="text" name="_honey" tabindex="-1" autocomplete="off"></label></div>
    <div class="form-grid">
{campos_html}
      <div class="campo ancho"><label class="campo-check" for="privacidad"><input id="privacidad" name="privacidad" type="checkbox" required aria-describedby="err-privacidad"><span>He leído y acepto el <a href="aviso-de-privacidad.html" target="_blank" rel="noopener">Aviso de privacidad</a>.</span></label><p class="campo-error" id="err-privacidad" role="alert"></p></div>
    </div>
    <div class="form-acciones"><button type="submit" class="btn btn-primary btn-lg"><i class="ph-bold ph-paper-plane-tilt" aria-hidden="true"></i> {boton}</button>{nota}</div>
    <p class="form-estado" role="status" aria-live="polite"></p>
  </form>
</div>'''

def mail(asunto): return f'mailto:{VENTAS}?subject={asunto.replace(" ", "%20")}'

# ------------------------------------------------------------ PRODUCTOS
KITS = [
 ('1', 'CultivaKit 1.0', 'Enciende tu primer LED', 'ph-lightbulb', '140',
  'Principiante: tu primer contacto con la electrónica',
  'Comprender un circuito eléctrico básico y encender un LED.',
  'Tu primer circuito, con un LED que enciende gracias a tu montaje.'),
 ('2', 'CultivaKit 2.0', 'Construye tu semáforo', 'ph-traffic-signal', '150',
  'Principiante: con las bases del CultivaKit 1.0',
  'Construir un semáforo y comprender las conexiones y la secuencia de sus luces.',
  'Un semáforo cuyas luces siguen una secuencia.'),
 ('3', 'CultivaKit 3.0', 'Crea tu primera alarma interactiva', 'ph-bell-ringing', '170',
  'Principiante: con las bases de los kits anteriores',
  'Crear un circuito que responda a una entrada, como un botón, y active una señal luminosa o sonora.',
  'Una alarma que responde cuando presionas un botón.'),
]

def tarjeta_kit(k):
    n, nombre, sub, icono, precio, nivel, obj, construye = k
    return f'''<article class="producto-card" id="kit-{n}">
  <div class="producto-media"><span class="producto-num">Kit {n}.0</span><i class="ph-fill {icono} producto-icono" aria-hidden="true"></i></div>
  <div class="producto-body">
    <h3>{nombre}</h3>
    <p class="producto-sub">{sub}</p>
    <ul class="producto-meta">
      <li><b>Nivel recomendado:</b> {nivel}.</li>
      <li><b>Objetivo de aprendizaje:</b> {obj}</li>
      <li><b>Qué construyes:</b> {construye}</li>
      <li><b>Incluye:</b> los componentes necesarios para armar el proyecto e instrucciones claras.</li>
    </ul>
    <!-- PENDIENTE (dueño): lista exacta de componentes y foto real de cada kit -->
    <div class="producto-precio"><strong>${precio}</strong><span>MXN</span></div>
    <a class="btn btn-primary" href="{mail('Quiero cotizar el ' + nombre)}"><i class="ph-bold ph-envelope-simple" aria-hidden="true"></i> Consultar {nombre}</a>
  </div>
</article>'''

FAQ_PROD = [
 ('¿Necesito experiencia previa para usar un CultivaKit?', 'No. Los CultivaKits están pensados para principiantes: el primero parte de un circuito básico y cada kit suma una habilidad nueva sin volver complicado el montaje.'),
 ('¿En qué se diferencian los tres CultivaKits?', 'Siguen una progresión: con el 1.0 enciendes un LED, con el 2.0 construyes un semáforo y con el 3.0 creas una alarma que responde a un botón.'),
 ('¿Cómo puedo comprar un CultivaKit?', f'Por ahora atendemos por consulta: escríbenos a {VENTAS} y confirmamos contigo la disponibilidad, la entrega y la forma de pago.'),
 ('¿Puedo pedir kits para un grupo o para mi escuela?', 'Sí. Cuéntanos tu proyecto en la página Tu escuela y preparamos una propuesta adaptada a tu institución.'),
]

def pagina_productos():
    hero_h = hero('CultivaKits: robótica accesible, un proyecto a la vez',
        'Los CultivaKits nacieron de nuestra experiencia dando talleres y probando actividades con niños. Cada kit tiene un proyecto concreto, instrucciones claras y componentes que un principiante puede aprender a usar.',
        'Productos',
        '<a href="#catalogo" class="btn btn-primary btn-lg">Ver los kits</a>',
        '<img src="img/valeon-robot.webp" alt="Valeon, la mascota de Cultivatec, armando un carrito robot" width="300" height="379">', compartir=True)
    resumen = '<div class="container"><div class="resumen"><h2>Lo esencial</h2>' + puntos([
        'Pensados para principiantes, con instrucciones claras.',
        'Un objetivo de aprendizaje concreto en cada kit.',
        'Una progresión: comprender, construir, experimentar y obtener un resultado tangible.',
        'Precios accesibles, para que más niños puedan empezar.']) + '</div></div>'
    cuerpo = hero_h + f'''
<section class="section-sm bg-white">{resumen}</section>

<section class="section bg-sky" id="catalogo" aria-labelledby="cat-t">
  <div class="container">
    <div class="sec-head center reveal">
      <h2 class="sec-title" id="cat-t">Elige tu CultivaKit</h2>
      <p class="sec-sub">Diseñamos los kits para hacer la robótica más accesible: proyectos de principiante, componentes que un niño puede aprender a usar y precios pensados para que más familias y escuelas puedan empezar.</p>
    </div>
    <div class="productos-grid reveal">
{''.join(tarjeta_kit(k) for k in KITS)}
    </div>
    <p class="producto-nota" style="text-align:center;margin-top:18px">Precios en pesos mexicanos. Confirma disponibilidad con nuestro equipo en <a href="mailto:{VENTAS}">{VENTAS}</a>.</p>
  </div>
</section>

<section class="section bg-white" aria-labelledby="prog-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="prog-t">Cada kit suma una habilidad</h2></div>
    <div class="progresion reveal">
      <div><h3>1.0 · Encender</h3><p>Entiendes cómo circula la corriente y enciendes tu primer LED.</p></div>
      <div><h3>2.0 · Secuenciar</h3><p>Aplicas lo aprendido para controlar la secuencia de las luces de un semáforo.</p></div>
      <div><h3>3.0 · Interactuar</h3><p>Haces que el circuito responda a una acción, como presionar un botón.</p></div>
    </div>
  </div>
</section>

<section class="section bg-sky" aria-labelledby="faq-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="faq-t">Preguntas frecuentes</h2></div>
    {faq_html(FAQ_PROD)}
  </div>
</section>

<section class="section-sm bg-white">
  <div class="container">
    <div class="bloque-cta reveal">
      <h2>Cotiza tus CultivaKits</h2>
      <p>Escríbenos y te ayudamos a elegir el kit adecuado. Si lo necesitas para un grupo o un laboratorio, cuéntanos tu proyecto.</p>
      <div class="acciones"><a href="mailto:{VENTAS}" class="btn btn-white btn-lg"><i class="ph-bold ph-envelope-simple" aria-hidden="true"></i> Escribir a ventas</a><a href="tu-escuela.html#formulario" class="btn btn-glass btn-lg">Diseñemos tu laboratorio</a></div>
    </div>
  </div>
</section>'''
    j = ld(migas([('Inicio', '/'), ('Productos', '/productos.html')])) + ld(faq_ld(FAQ_PROD))
    return shell('productos.html', 'CultivaKits: kits de robótica para principiantes | Cultivatec',
        'Kits de robótica para principiantes: enciende un LED, construye un semáforo y crea una alarma interactiva. Proyectos accesibles con instrucciones claras.',
        cuerpo, 'productos', j)

# ------------------------------------------------------------ TU ESCUELA
FAQ_ESC = [
 ('¿Necesito tener definido mi presupuesto?', 'No. El presupuesto estimado es opcional en el formulario. Podemos conversar sobre tus objetivos y tu espacio y proponer alternativas.'),
 ('¿Puedo enviar la solicitud si todavía no sé qué necesito?', 'Sí. Basta con tu nombre, tu institución y tu correo. El resto lo vemos en la conversación.'),
 ('¿Los equipos son de Cultivatec?', 'Los CultivaKits son productos de Cultivatec. Para el resto del equipamiento hacemos selección, integración y gestión de equipamiento de proveedores, según el proyecto de cada escuela.'),
 ('¿Qué pasa después de enviar el formulario?', 'Nuestro equipo revisa tu solicitud y se pone en contacto contigo al correo que nos compartas para conversar sobre tu proyecto.'),
]

def pagina_escuela():
    hero_h = hero('Diseñemos el laboratorio de robótica de tu escuela',
        'Te acompañamos a implementar un laboratorio de robótica de acuerdo con las necesidades, el presupuesto, el espacio y los objetivos académicos de tu institución.',
        'Tu escuela',
        '<a href="#formulario" class="btn btn-primary btn-lg">Diseñemos tu laboratorio</a>',
        '<img src="img/valeon-saludando.webp" alt="Valeon, la mascota de Cultivatec, saludando" width="300" height="441">')
    resumen = '<div class="container"><div class="resumen"><h2>Qué podemos hacer por tu escuela</h2>' + puntos([
        'Diseñar y equipar tu laboratorio de robótica.',
        'Capacitar a tus docentes para impartir robótica, electrónica y programación.',
        'Implementar talleres, cursos o programas STEM para tus alumnos.']) + '</div></div>'
    serv = f'''<div class="container">
<div class="servicio reveal" id="laboratorios">
  <div><span class="servicio-letra">Servicio A</span><h2>Diseño y equipamiento de laboratorios de robótica</h2>
  <p>Te acompañamos en la selección y adquisición de los recursos que necesita tu institución para implementar su laboratorio. Cada propuesta se construye a la medida de tu escuela: no ofrecemos un paquete idéntico para todos.</p>
  <p>Trabajamos con selección, integración y gestión de equipamiento de proveedores.</p></div>
  {puntos(['Kits de robótica educativa.', 'Componentes electrónicos y materiales didácticos.', 'Equipos y herramientas necesarios para las actividades.', 'Software y recursos digitales para el aprendizaje STEM.', 'Propuesta de equipamiento adaptada al presupuesto y al nivel educativo.', 'Orientación para organizar el espacio y estructurar las actividades.'])}
</div>
<div class="servicio reveal" id="capacitacion">
  <div><span class="servicio-letra">Servicio B</span><h2>Capacitación docente</h2>
  <p>Ayudamos a los docentes a desarrollar las habilidades necesarias para impartir actividades de robótica, electrónica, programación y STEM.</p></div>
  {puntos(['Talleres prácticos para profesores.', 'Introducción a electrónica y programación.', 'Uso pedagógico de kits y simuladores.', 'Diseño de actividades y proyectos.', 'Orientación para integrar las herramientas en el programa educativo.'])}
</div>
<div class="servicio reveal" id="programas">
  <div><span class="servicio-letra">Servicio C</span><h2>Programas educativos STEM</h2>
  <p>Implementamos talleres, cursos o programas educativos para alumnos, adaptados a su edad, su nivel de conocimientos y los objetivos de la institución.</p>
  <p><a href="cursos.html" class="via-link" style="font-weight:700;color:#0958C2">Conoce nuestros cursos <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></a></p></div>
  {puntos(['Talleres y cursos para alumnos.', 'Contenido adaptado a la edad y al nivel.', 'Alineado con los objetivos de tu institución.'])}
</div>
</div>'''
    cuerpo = hero_h + f'''
<section class="section-sm bg-white">{resumen}</section>
<section class="section bg-white" aria-label="Servicios">{serv}</section>

<section class="section bg-sky" aria-labelledby="como-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="como-t">Cómo empezar</h2></div>
    <ol class="pasos reveal">
      <li><h3>Cuéntanos tu escuela</h3><p>Llena el formulario. Puedes enviarlo aunque todavía no tengas todos los detalles.</p></li>
      <li><h3>Conversamos</h3><p>Nuestro equipo te contacta para entender tus necesidades, tu espacio y tu presupuesto.</p></li>
      <li><h3>Recibes una propuesta</h3><p>Una propuesta adaptada a tu institución, no un paquete genérico.</p></li>
    </ol>
  </div>
</section>

<section class="section-sm bg-white">
  <div class="container">
    <div class="banner-escuela reveal">
      <img src="img/valeon-saludando.webp" alt="" width="130" height="191" loading="lazy">
      <div><h2>Tu escuela también puede tener su laboratorio de robótica</h2><p>Cuéntanos qué necesitas y diseñemos juntos el siguiente paso.</p></div>
      <a href="#formulario" class="btn btn-white btn-lg">Diseñemos tu laboratorio</a>
    </div>
  </div>
</section>

<section class="section bg-white">
  <div class="container">
{formulario('form-escuela', 'Diseñemos tu laboratorio', 'Solo necesitamos lo básico para iniciar la conversación. Los campos marcados como opcionales puedes dejarlos en blanco.', 'Solicitud: Diseñemos tu laboratorio',
 campo('nombre', 'Nombre y apellidos', 'text', True) + campo('institucion', 'Institución educativa', 'text', True) +
 campo('email', 'Correo electrónico', 'email', True) + campo('cargo', 'Cargo o función', 'text', False, opc=True) +
 '<div class="campo"><label for="servicio">Servicio de interés <small>(opcional)</small></label><select id="servicio" name="servicio"><option value="">Selecciona una opción</option><option>Diseño y equipamiento de laboratorio de robótica</option><option>Capacitación docente</option><option>Programas educativos STEM</option><option>Todavía no lo sé, necesito orientación</option></select></div>' +
 campo('alumnos', 'Número aproximado de alumnos o participantes', 'number', False, opc=True, extra='min="1" inputmode="numeric"') +
 campo('presupuesto', 'Presupuesto estimado', 'text', False, opc=True, extra='placeholder="Por ejemplo, $50,000 MXN"') +
 '<div class="campo ancho"><label for="mensaje">Descripción de tus necesidades <small>(opcional)</small></label><textarea id="mensaje" name="mensaje" rows="4"></textarea></div>',
 'Enviar solicitud')}
  </div>
</section>

<section class="section bg-sky" aria-labelledby="faq-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="faq-t">Preguntas frecuentes</h2></div>
    {faq_html(FAQ_ESC)}
  </div>
</section>
<section class="section-sm bg-white">
  <div class="container"><p style="text-align:center;color:var(--slate-500)">Explora también: <a href="productos.html" style="color:#0958C2;font-weight:600">CultivaKits</a> · <a href="plataforma.html" style="color:#0958C2;font-weight:600">Plataforma y simuladores</a> · <a href="cursos.html" style="color:#0958C2;font-weight:600">Cursos</a> · <a href="impacto-social.html" style="color:#0958C2;font-weight:600">Impacto social</a></p></div>
</section>'''
    j = ld(migas([('Inicio', '/'), ('Tu escuela', '/tu-escuela.html')])) + ld(faq_ld(FAQ_ESC))
    return shell('tu-escuela.html', 'Laboratorios de robótica para escuelas | Cultivatec',
        'Diseñamos laboratorios de robótica educativa a la medida de tu escuela: equipamiento, capacitación docente y programas STEM adaptados a tu presupuesto.',
        cuerpo, 'escuela', j, cta_movil=True)

# ------------------------------------------------------------ IMPACTO SOCIAL
def alt_de(archivo):
    for f in glob.glob('*.html') + glob.glob('blog/*.html'):
        h = open(f, encoding='utf-8').read()
        m = re.search(r'<img[^>]*src="(?:\.\./)?img/aula/' + re.escape(archivo) + r'"[^>]*alt="([^"]+)"', h) or \
            re.search(r'<img[^>]*alt="([^"]+)"[^>]*src="(?:\.\./)?img/aula/' + re.escape(archivo) + r'"', h)
        if m: return m.group(1)
    return None

def galeria():
    figs = []
    for f in sorted(os.listdir('img/aula')):
        if not f.lower().endswith(('.jpg', '.jpeg', '.webp')): continue
        a = alt_de(f)
        if a and len(figs) < 3:
            figs.append(f'<figure><img src="img/aula/{f}" alt="{esc(a)}" loading="lazy" decoding="async"></figure>')
    return '<div class="galeria reveal">' + ''.join(figs) + '</div>' if figs else ''

def pagina_impacto():
    hero_h = hero('Robótica y STEM para niños con menos oportunidades',
        'Cultivatec nació para acercar la robótica y la educación STEM a niños de comunidades con menos oportunidades. Los servicios que damos a escuelas y las alianzas con empresas nos permiten ampliar ese acceso.',
        'Impacto social',
        '<a href="#colaborar" class="btn btn-primary btn-lg">Cómo colaborar</a>', '', compartir=True)
    resumen = '<div class="container"><div class="resumen"><h2>Lo esencial</h2>' + puntos([
        'Empezamos en enero de 2023, en una pequeña primaria de Mexicali.',
        'Más de 1,000 alumnos han recibido robótica con nosotros.',
        'Hemos trabajado en Mexicali, Ciudad de México y Monterrey, y pronto llegaremos a Perú.']) + '</div></div>'
    cuerpo = hero_h + f'''
<section class="section-sm bg-white">{resumen}</section>

<section class="section bg-white" aria-labelledby="mis-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="mis-t">Nuestra misión</h2>
    <p class="sec-sub">Darle a cada niño, sin importar el barrio donde nació, un espacio para crear tecnología con sus propias manos y la certeza de que puede construir un futuro distinto. Conoce nuestra historia en <a href="historia.html#identidad" style="color:#0958C2;font-weight:600">Nosotros</a>.</p></div>
    <ul class="cifras reveal">
      <li><strong>+1,000</strong><span>alumnos</span></li>
      <li><strong>3</strong><span>ciudades</span></li>
      <li><strong>2023</strong><span>año en que empezamos</span></li>
    </ul>
  </div>
</section>

<section class="section bg-sky" aria-labelledby="fot-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="fot-t">Así se ven nuestros talleres</h2></div>
    {galeria()}
  </div>
</section>

<section class="section bg-white" aria-labelledby="his-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="his-t">Lo que dicen nuestros alumnos</h2></div>
    <div class="impacto-card reveal">
      <img src="img/testimonio-nino.jpg" alt="Alumno de Cultivatec mostrando el circuito que armó en un taller de robótica" loading="lazy" decoding="async">
      <div class="impacto-overlay"><p class="impacto-frase">"No me gustó,<br>me encantó"</p><span class="impacto-autor">— Alumno, después del taller de robótica de Cultivatec</span></div>
    </div>
  </div>
</section>

<section class="section bg-sky" id="colaborar" aria-labelledby="col-t">
  <div class="container">
    <div class="sec-head center reveal"><h2 class="sec-title" id="col-t">Formas de colaborar</h2>
    <p class="sec-sub">Los servicios comerciales para instituciones y las alianzas con empresas ayudan a ampliar las oportunidades de acceso a la educación tecnológica.</p></div>
    <div class="vias reveal" style="grid-template-columns:repeat(2,1fr)">
      <div class="via-card"><div class="via-icono"><i class="ph-fill ph-handshake" aria-hidden="true"></i></div><h3>Empresas que financian programas</h3><p>Si tu empresa quiere apoyar iniciativas STEM, solicita una propuesta de colaboración y conversemos sobre cómo financiar programas educativos.</p></div>
      <a class="via-card" href="tu-escuela.html"><div class="via-icono"><i class="ph-fill ph-chalkboard-teacher" aria-hidden="true"></i></div><h3>Escuelas que contratan nuestros servicios</h3><p>Cada colaboración comercial con una institución ayuda a sostener nuestra misión social.</p><span class="via-link">Ver Tu escuela <i class="ph-bold ph-arrow-right" aria-hidden="true"></i></span></a>
    </div>
  </div>
</section>

<section class="section bg-white">
  <div class="container">
{formulario('form-alianza', 'Solicita una propuesta de colaboración', 'Cuéntanos qué tipo de apoyo te interesa y te contactaremos para conversar.', 'Solicitud: colaboración empresarial',
 campo('nombre', 'Nombre y apellidos', 'text', True) + campo('empresa', 'Empresa u organización', 'text', True) + campo('email', 'Correo electrónico', 'email', True) +
 campo('cargo', 'Cargo o función', 'text', False, opc=True) +
 '<div class="campo ancho"><label for="mensaje">¿Cómo te gustaría colaborar? <small>(opcional)</small></label><textarea id="mensaje" name="mensaje" rows="4"></textarea></div>',
 'Solicitar propuesta')}
  </div>
</section>'''
    j = ld(migas([('Inicio', '/'), ('Impacto social', '/impacto-social.html')]))
    return shell('impacto-social.html', 'Impacto social: STEM para niños con menos oportunidades | Cultivatec',
        'Cultivatec nació para acercar la robótica y la educación STEM a niños con menos oportunidades. Conoce nuestro impacto y cómo colaborar.',
        cuerpo, 'impacto', j, og='img/testimonio-nino.jpg')

# ------------------------------------------------------------ ESPECIALES
def pagina_gracias():
    b = '''<section class="centrado-pagina"><div>
<img src="img/valeon-saludando.webp" alt="" width="150" height="220">
<h1>¡Gracias! Recibimos tu mensaje</h1>
<p>Nuestro equipo lo revisará y te responderá al correo que nos compartiste.</p>
<div class="acciones"><a href="/" class="btn btn-primary btn-lg">Volver al inicio</a><a href="productos.html" class="btn btn-soft btn-lg">Ver los CultivaKits</a></div>
</div></section>'''
    return shell('gracias.html', 'Gracias por contactarnos | Cultivatec', 'Recibimos tu mensaje. Nuestro equipo te responderá pronto.', b, '', '', noindex=True, cta_movil=False)

def pagina_404():
    b = '''<section class="centrado-pagina"><div>
<img src="/img/valeon-saludando.webp" alt="" width="150" height="220">
<h1>No encontramos esta página</h1>
<p>Es posible que el enlace haya cambiado. Estos accesos te llevan a lo más importante.</p>
<div class="acciones"><a href="/" class="btn btn-primary btn-lg">Ir al inicio</a><a href="/productos.html" class="btn btn-soft btn-lg">Productos</a><a href="/tu-escuela.html" class="btn btn-soft btn-lg">Tu escuela</a><a href="/contacto.html" class="btn btn-soft btn-lg">Contacto</a></div>
</div></section>'''
    h = shell('404.html', 'Página no encontrada | Cultivatec', 'La página que buscas no existe o cambió de dirección.', b, '', '', noindex=True, cta_movil=False, canon=False, abs_paths=True)
    # rutas absolutas para que funcione desde cualquier URL
    h = re.sub(r'(href|src)="(?!https?:|/|#|mailto:)([^"]+)"', lambda m: f'{m.group(1)}="/{m.group(2)}"', h)
    return h

def legal(archivo, titulo, desc, cuerpo):
    b = f'<article class="legal"><h1>{titulo}</h1><p class="actualizado">Última actualización: {HOY}</p>{cuerpo}</article>'
    return shell(archivo, f'{titulo} | Cultivatec', desc, b, '', '', cta_movil=False)

AVISO = f'''
<h2>1. Quién es responsable de tus datos</h2>
<p>Cultivatec, con domicilio en Mexicali, Baja California, México, es responsable del tratamiento de los datos personales que nos compartes a través de este sitio web. Puedes escribirnos a <a href="mailto:{CONTACTO}">{CONTACTO}</a>.</p>
<h2>2. Qué datos recabamos</h2>
<p>Mediante los formularios del sitio podemos recabar: nombre, institución o empresa, correo electrónico, cargo o función, servicio de interés, número aproximado de alumnos o participantes, presupuesto estimado (opcional) y el mensaje que decidas escribir.</p>
<h2>3. Para qué usamos tus datos</h2>
<p>Usamos tus datos para responder tu solicitud, preparar propuestas o cotizaciones y dar seguimiento a la conversación que iniciaste con nosotros.</p>
<h2>4. Con quién se comparten</h2>
<p>Los formularios se envían mediante el servicio FormSubmit, que entrega el mensaje por correo electrónico al equipo de Cultivatec. Más allá de ese proveedor, no compartimos tus datos con terceros salvo que la ley lo exija.</p>
<h2>5. Datos de menores de edad</h2>
<p>Este sitio está dirigido a docentes, directivos, familias y empresas. No solicitamos datos personales de menores de edad en sus formularios.</p>
<h2>6. Cookies, analítica y servicios de terceros</h2>
<p>Actualmente este sitio no utiliza herramientas de analítica ni de publicidad. Para mostrarse, tu navegador puede solicitar tipografías a Google Fonts y, en la página de inicio, la animación 3D a un servicio de distribución de archivos (esm.sh). Si en el futuro activamos analítica, actualizaremos este aviso y solicitaremos tu consentimiento cuando corresponda.</p>
<h2>7. Herramientas de inteligencia artificial</h2>
<p>Este sitio web no incluye el Tutor IA. La plataforma educativa y su Tutor IA funcionan en un entorno aparte, y el tratamiento de datos en ese entorno se informa dentro de la propia plataforma.</p>
<h2>8. Tus derechos</h2>
<p>Puedes solicitar el acceso, la rectificación o la cancelación de tus datos, o manifestar tu oposición a su tratamiento, escribiendo a <a href="mailto:{CONTACTO}">{CONTACTO}</a>.</p>
<h2>9. Cambios a este aviso</h2>
<p>Si este aviso cambia, publicaremos la versión actualizada en esta página con su fecha.</p>'''

TERMINOS = f'''
<h2>1. Uso del sitio</h2>
<p>Este sitio presenta los productos y servicios de Cultivatec. Al usarlo aceptas estas condiciones.</p>
<h2>2. Precios y disponibilidad</h2>
<p>Los precios publicados son informativos, están expresados en pesos mexicanos y pueden cambiar. La disponibilidad, la entrega y la forma de pago se confirman con nuestro equipo antes de concretar un pedido. Este sitio no procesa pagos en línea.</p>
<h2>3. Solicitudes y formularios</h2>
<p>Enviar un formulario no genera una obligación de compra ni de contratación. Es el inicio de una conversación para preparar una cotización o propuesta. El uso de tus datos se describe en el <a href="aviso-de-privacidad.html">Aviso de privacidad</a>.</p>
<h2>4. Propiedad intelectual</h2>
<p>El nombre Cultivatec, su logotipo, sus personajes y los contenidos de este sitio pertenecen a Cultivatec. No pueden reproducirse sin autorización.</p>
<h2>5. Enlaces externos</h2>
<p>Este sitio puede enlazar a páginas de terceros. No controlamos su contenido ni sus políticas.</p>
<h2>6. Contacto</h2>
<p>Para dudas sobre estas condiciones escribe a <a href="mailto:{VENTAS}">{VENTAS}</a>.</p>'''

paginas = {
 'productos.html': pagina_productos(), 'tu-escuela.html': pagina_escuela(), 'impacto-social.html': pagina_impacto(),
 'gracias.html': pagina_gracias(), '404.html': pagina_404(),
 'aviso-de-privacidad.html': legal('aviso-de-privacidad.html', 'Aviso de privacidad', 'Cómo trata Cultivatec los datos personales que recibe a través de su sitio web.', AVISO),
 'terminos-y-condiciones.html': legal('terminos-y-condiciones.html', 'Términos y condiciones', 'Condiciones de uso del sitio web de Cultivatec, precios, solicitudes y formularios.', TERMINOS),
}
for f, h in paginas.items():
    open(f, 'w', encoding='utf-8').write(h)
print('paginas creadas:', ', '.join(paginas))
