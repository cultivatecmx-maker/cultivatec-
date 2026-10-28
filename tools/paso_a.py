import re, glob, os, sys
sys.path.insert(0, 'tools')
from sitio_lib import *

ACTIVA = {'index.html':'inicio','plataforma.html':'escuela','cursos.html':'escuela','historia.html':'nosotros',
          'contacto.html':'contacto','blog.html':'','school.html':''}
SIN_CTA_MOVIL = {'contacto.html','school.html'}

for f, act in ACTIVA.items():
    h = open(f, encoding='utf-8').read()
    h = aplicar_base(h, '', act, cta_movil=(f not in SIN_CTA_MOVIL))
    open(f, 'w', encoding='utf-8').write(h)
for f in sorted(glob.glob('blog/*.html')):
    h = open(f, encoding='utf-8').read()
    h = aplicar_base(h, '../', '', cta_movil=True)
    open(f, 'w', encoding='utf-8').write(h)

def stub(destino, nombre):
    return f'''<!DOCTYPE html>
<html lang="es-MX">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Esta página se movió | Cultivatec</title>
<meta http-equiv="refresh" content="0; url={destino}">
<link rel="canonical" href="{DOM}/{destino}">
<script>location.replace("{destino}");</script>
</head>
<body style="font-family:system-ui,sans-serif;padding:40px">
<p>Esta página se movió. <a href="{destino}">Ir a {nombre}</a>.</p>
</body>
</html>
'''
open('cultivalab.html','w',encoding='utf-8').write(stub('plataforma.html','Plataforma y simuladores'))
open('cultivaquest.html','w',encoding='utf-8').write(stub('cursos.html','Cursos'))
open('kits.html','w',encoding='utf-8').write(stub('productos.html','Productos'))

for f in ['css/cultivalab.css','css/cultivaquest.css','js/cultivalab.js','js/cultivaquest.js','js/quest-data.js','js/componente3d.js']:
    if os.path.exists(f): os.remove(f)

m = open('js/main.js', encoding='utf-8').read()
m = m.replace('Cultivatec.com.mx', 'cultivatec.com.mx')
open('js/main.js','w',encoding='utf-8').write(m)
print('listo')
