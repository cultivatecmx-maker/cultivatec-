# -*- coding: utf-8 -*-
import re, glob, os, sys, datetime, json
sys.path.insert(0, 'tools')
from sitio_lib import *
HOY = datetime.date.today().isoformat()

# ---- sitemap (conserva fechas de los posts del blog)
old = open('sitemap.xml', encoding='utf-8').read()
fechas = dict(re.findall(r'<loc>https://cultivatec\.com\.mx/(blog/[^<]+)</loc>\s*<lastmod>([^<]+)</lastmod>', old))
pag = [('', '1.0'), ('productos.html', '0.9'), ('tu-escuela.html', '0.9'), ('impacto-social.html', '0.8'), ('historia.html', '0.7'),
       ('cursos.html', '0.7'), ('plataforma.html', '0.6'), ('blog.html', '0.6'), ('contacto.html', '0.6'),
       ('aviso-de-privacidad.html', '0.2'), ('terminos-y-condiciones.html', '0.2')]
u = [f'  <url>\n    <loc>{DOM}/{p}</loc>\n    <lastmod>{HOY}</lastmod>\n    <priority>{pr}</priority>\n  </url>' for p, pr in pag]
for f in sorted(glob.glob('blog/*.html')):
    u.append(f'  <url>\n    <loc>{DOM}/{f}</loc>\n    <lastmod>{fechas.get(f, "2026-07-28")}</lastmod>\n    <priority>0.5</priority>\n  </url>')
open('sitemap.xml', 'w', encoding='utf-8').write('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + '\n'.join(u) + '\n</urlset>\n')

open('robots.txt', 'w', encoding='utf-8').write(f'User-agent: *\nAllow: /\n\nSitemap: {DOM}/sitemap.xml\n')

open('llms.txt', 'w', encoding='utf-8').write(f'''# Cultivatec

> Robótica educativa accesible desde Mexicali y Monterrey: CultivaKits para principiantes, laboratorios de robótica y capacitación docente para escuelas, e impacto social para niños con menos oportunidades.

## Páginas principales
- [Inicio]({DOM}/): resumen de la oferta de Cultivatec.
- [Productos]({DOM}/productos.html): CultivaKit 1.0 (enciende tu primer LED), 2.0 (construye tu semáforo) y 3.0 (crea tu primera alarma interactiva).
- [Tu escuela]({DOM}/tu-escuela.html): diseño y equipamiento de laboratorios de robótica, capacitación docente y programas educativos STEM.
- [Impacto social]({DOM}/impacto-social.html): misión, alcance y formas de colaborar, incluida la financiación de programas por empresas.
- [Nosotros]({DOM}/historia.html): historia e identidad de Cultivatec, fundada en enero de 2023 por Abraham Doñate.
- [Contacto]({DOM}/contacto.html): ventas ({VENTAS}) y contacto general ({CONTACTO}).

## Más información
- [Cursos]({DOM}/cursos.html)
- [Plataforma y simuladores]({DOM}/plataforma.html)
- [Blog]({DOM}/blog.html)
- [Aviso de privacidad]({DOM}/aviso-de-privacidad.html)
''')

os.makedirs('.vscode', exist_ok=True)
open('.vscode/tasks.json', 'w', encoding='utf-8').write(json.dumps({"version": "2.0.0", "tasks": [
  {"label": "Servidor local (Python)", "type": "shell", "command": "python -m http.server 5500", "isBackground": True, "problemMatcher": []},
  {"label": "Servidor local (npx serve)", "type": "shell", "command": "npx serve -l 3000", "isBackground": True, "problemMatcher": []}]}, indent=2) + '\n')

# ---- tipografias: solo las que se usan
VIEJA = re.compile(r'https://fonts\.googleapis\.com/css2\?[^"]+')
NUEVA = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=League+Spartan:wght@700;800&display=swap'
for f in glob.glob('*.html') + glob.glob('blog/*.html'):
    t = open(f, encoding='utf-8').read(); n = VIEJA.sub(NUEVA, t)
    if n != t: open(f, 'w', encoding='utf-8').write(n)

# ---- logo ligero (se muestra a 47px)
from PIL import Image
im = Image.open('logo.png').convert('RGBA'); im.thumbnail((160, 160)); im.save('logo.png', optimize=True)
print('logo.png', os.path.getsize('logo.png') // 1024, 'KB')

# ---- archivos huerfanos de Lab / Quest
def referenciados():
    txt = ''
    for f in glob.glob('**/*', recursive=True):
        if f.endswith(('.html', '.css', '.js', '.xml', '.txt', '.json')) and not f.startswith(('tools/', 'node_modules/')):
            txt += open(f, encoding='utf-8', errors='ignore').read()
    return txt
t = referenciados()
for a in ['img/robot_ensamblaje.gif', 'img/robot_ensamblaje.webp', 'img/robot-mascota.png', 'img/mitadvaleobservando.png', 'img/valeon-mejillas.webp', 'img/valeonpulgararriba.png']:
    if os.path.exists(a) and os.path.basename(a) not in t:
        os.remove(a); print('eliminado (sin uso):', a)

# ---- verificador de enlaces internos
rotos = []
ids_cache = {}
def ids(path):
    if path not in ids_cache:
        ids_cache[path] = set(re.findall(r'\bid="([^"]+)"', open(path, encoding='utf-8', errors='ignore').read()))
    return ids_cache[path]
for f in sorted(glob.glob('*.html') + glob.glob('blog/*.html')):
    h = open(f, encoding='utf-8').read(); d = os.path.dirname(f)
    for attr, v in re.findall(r'\b(href|src)="([^"]*)"', h):
        if not v or re.match(r'(https?:|mailto:|tel:|data:|javascript:|//)', v): continue
        ruta, _, frag = v.partition('#'); ruta = ruta.split('?')[0]
        if ruta == '': destino = f
        elif ruta.startswith('/'): destino = ruta.lstrip('/') or 'index.html'
        else: destino = os.path.normpath(os.path.join(d, ruta))
        if os.path.isdir(destino): destino = os.path.join(destino, 'index.html')
        if not os.path.exists(destino): rotos.append((f, v)); continue
        if frag and destino.endswith('.html') and frag not in ids(destino): rotos.append((f, v + '  (ancla inexistente)'))
print('ENLACES ROTOS:', len(rotos))
for r in rotos[:40]: print('  ', r)
