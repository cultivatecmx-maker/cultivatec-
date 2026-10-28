# -*- coding: utf-8 -*-
"""Piezas compartidas del sitio: menú, pie de página, accesos flotantes."""
import re

DOM = 'https://cultivatec.com.mx'
VENTAS = 'ventas@cultivatec.com.mx'
CONTACTO = 'contacto@cultivatec.com.mx'

SOCIALS = '''<div class="socials">
          <a href="https://www.facebook.com/profile.php?id=100089359082614" target="_blank" rel="noopener" class="social" aria-label="Facebook"><i class="ph-bold ph-facebook-logo"></i></a>
          <a href="https://www.instagram.com/cultivatecmx/" target="_blank" rel="noopener" class="social" aria-label="Instagram"><i class="ph-bold ph-instagram-logo"></i></a>
          <a href="https://www.tiktok.com/@cultivatecmx" target="_blank" rel="noopener" class="social" aria-label="TikTok"><i class="ph-bold ph-tiktok-logo"></i></a>
          <a href="https://www.youtube.com/@cultivatecmx" target="_blank" rel="noopener" class="social" aria-label="YouTube"><i class="ph-bold ph-youtube-logo"></i></a>
        </div>'''

def nav(base='', active=''):
    items = [
        ('inicio', 'Inicio', '/'),
        ('productos', 'Productos', base + 'productos.html'),
        ('escuela', 'Tu escuela', base + 'tu-escuela.html'),
        ('impacto', 'Impacto social', base + 'impacto-social.html'),
        ('nosotros', 'Nosotros', base + 'historia.html'),
        ('contacto', 'Contacto', base + 'contacto.html'),
    ]
    lis = []
    for key, label, href in items:
        cur = ' aria-current="page"' if key == active else ''
        cls = 'nav-item active' if key == active else 'nav-item'
        lis.append(f'      <li><a href="{href}" class="{cls}"{cur}>{label}</a></li>')
    cta = f'{base}tu-escuela.html#formulario'
    return f'''<nav class="navbar" role="navigation" aria-label="Navegación principal">
  <div class="container nav-inner">
    <a href="/" class="nav-logo" aria-label="Cultivatec — Inicio">
      <img src="{base}logo.png" alt="Cultivatec" width="47" height="40">
      <span class="nav-wordmark">Cultiva<b>tec</b></span>
    </a>

    <ul class="nav-menu" id="nav-menu">
{chr(10).join(lis)}
      <li class="nav-menu-cta"><a href="{cta}" class="btn btn-primary">Diseñemos tu laboratorio</a></li>
    </ul>

    <div class="nav-actions">
      <a href="{cta}" class="nav-cta">Diseñemos tu laboratorio</a>
      <button class="hamburger" aria-label="Abrir menú" aria-expanded="false" aria-controls="nav-menu">
        <span></span><span></span><span></span>
      </button>
    </div>
  </div>
</nav>'''

def footer(base=''):
    return f'''<footer class="footer">
  <div class="container">
    <div class="footer-grid">
      <div class="footer-brand">
        <a href="/" class="footer-brand-logo">
          <img src="{base}img/logo-cultivatec-nombre.png" alt="Cultivatec" width="150" height="140" loading="lazy">
        </a>
        <p>Robótica educativa accesible: CultivaKits, laboratorios y capacitación docente para escuelas, con sede en Mexicali y Monterrey.</p>
        {SOCIALS}
      </div>
      <div>
        <h4>Productos</h4>
        <ul class="footer-links">
          <li><a href="{base}productos.html#kit-1">CultivaKit 1.0</a></li>
          <li><a href="{base}productos.html#kit-2">CultivaKit 2.0</a></li>
          <li><a href="{base}productos.html#kit-3">CultivaKit 3.0</a></li>
          <li><a href="mailto:{VENTAS}">Pedir cotización</a></li>
        </ul>
      </div>
      <div>
        <h4>Tu escuela</h4>
        <ul class="footer-links">
          <li><a href="{base}tu-escuela.html#laboratorios">Laboratorios de robótica</a></li>
          <li><a href="{base}tu-escuela.html#capacitacion">Capacitación docente</a></li>
          <li><a href="{base}tu-escuela.html#programas">Programas STEM</a></li>
          <li><a href="{base}plataforma.html">Plataforma y simuladores</a></li>
          <li><a href="{base}cursos.html">Cursos</a></li>
        </ul>
      </div>
      <div>
        <h4>Cultivatec</h4>
        <ul class="footer-links">
          <li><a href="{base}historia.html">Nosotros</a></li>
          <li><a href="{base}impacto-social.html">Impacto social</a></li>
          <li><a href="{base}blog.html">Blog</a></li>
          <li><a href="{base}school.html">School (próximamente)</a></li>
          <li><a href="{base}contacto.html">Contacto</a></li>
        </ul>
      </div>
      <div>
        <h4>Contacto</h4>
        <ul class="footer-links">
          <li><a class="mail" href="mailto:{VENTAS}">{VENTAS}</a></li>
          <li><a class="mail" href="mailto:{CONTACTO}">{CONTACTO}</a></li>
          <li><span>Mexicali, B.C. · Monterrey, N.L.</span></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <span>&copy; <span class="js-year">2026</span> Cultivatec. Todos los derechos reservados.</span>
      <span class="footer-legal"><a href="{base}aviso-de-privacidad.html">Aviso de privacidad</a> · <a href="{base}terminos-y-condiciones.html">Términos y condiciones</a></span>
    </div>
  </div>
</footer>'''

def flotantes(base='', cta_movil=True):
    cta = f'{base}tu-escuela.html#formulario'
    out = f'''<div class="floating-actions" aria-label="Accesos rápidos">
  <a href="{cta}" class="floating-btn floating-contacto"><i class="ph-bold ph-flask"></i> <span>Diseñemos tu laboratorio</span></a>
  <a href="mailto:{VENTAS}" class="floating-btn floating-recursos"><i class="ph-bold ph-envelope-simple"></i> <span>Escribir a ventas</span></a>
</div>
'''
    if cta_movil:
        out += f'''<div class="cta-movil" id="cta-movil"><a href="{cta}" class="btn btn-primary">Diseñemos tu laboratorio</a></div>
'''
    return out

def aplicar_base(html, base, active, cta_movil=True):
    """Reemplaza menú, pie, flotantes; limpia cabecera. Devuelve html."""
    n = len(re.findall(r'<nav class="navbar"', html)); assert n == 1, 'nav'
    html = re.sub(r'<nav class="navbar".*?</nav>', lambda m: nav(base, active), html, count=1, flags=re.S)
    html = re.sub(r'<footer class="footer">.*?</footer>', lambda m: footer(base), html, count=1, flags=re.S)
    html = re.sub(r'<div class="floating-actions">.*?</div>\s*', '', html, count=1, flags=re.S)
    html = re.sub(r'<div class="cta-movil".*?</div>\s*', '', html, count=1, flags=re.S)
    html = html.replace('<button class="back-to-top"', flotantes(base, cta_movil) + '<button class="back-to-top"', 1)
    # cabecera: sin Animate.css (no se usa), favicon unico, hoja de estilos nueva
    html = re.sub(r'<link rel="stylesheet" href="https://cdnjs\.cloudflare\.com/ajax/libs/animate\.css[^>]*>\s*', '', html)
    html = re.sub(r'<link rel="(?:icon|apple-touch-icon)"[^>]*>\s*', '', html)
    html = html.replace('</title>', '</title>', 1)
    fav = f'<link rel="icon" href="{base}icon-192.png">\n<link rel="apple-touch-icon" href="{base}icon-192.png">\n'
    html = re.sub(r'(<link rel="stylesheet" href="' + re.escape(base) + r'css/styles\.css[^"]*">)',
                  lambda m: fav + m.group(1) + f'\n<link rel="stylesheet" href="{base}css/sitio.css">', html, count=1)
    if 'js/sitio.js' not in html:
        html = html.replace('</body>', f'<script src="{base}js/sitio.js" defer></script>\n</body>', 1)
    return html
