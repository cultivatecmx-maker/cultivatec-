/* ============================================================
   CULTIVATEC — Mascota en 3D

   Construida con primitivas para poder separar la cabeza en su propio
   grupo: así gira sola hacia el cursor, cosa imposible con una malla
   fusionada.

   El aspecto de la mascota 2D viene del contorno oscuro. Aquí se consigue
   con la técnica de casco invertido: un clon de cada pieza, algo más
   grande, con las caras traseras y material sin luz. Es lo que hace que
   se lea como el personaje y no como un montón de cajas.

   Jerarquía:
     raiz
      ├ cuerpo   (torso, engrane, brazos, piernas)   — quieto
      └ cabeza   (cráneo, ojos, sonrisa, orejas)     — sigue al cursor
          └ brote (tallo y hojas)                    — se mece
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

/* Paleta: azules del logo, más saturados que la versión anterior */
const CLARO   = 0x9CC5F2;
const MEDIO   = 0x4A88DA;
const VIVO    = 0x2563EB;
const CONTOR  = 0x13366E;   // contorno y detalles
const BROTE   = 0x3FBF9E;

const LIMITE_X = 1.15;   // giro horizontal de la cabeza ~66°
const LIMITE_Y = 0.62;   // cabeceo ~36°
const INERCIA  = 0.085;

function puedeCargar() {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return false;
  if (!matchMedia('(min-width: 861px)').matches) return false;
  const con = navigator.connection;
  if (con && (con.saveData || ['slow-2g', '2g'].includes(con.effectiveType))) return false;
  return true;
}

export async function montarRobot3D(host) {
  if (!host || !puedeCargar()) return;

  const [THREE, { RoundedBoxGeometry }] = await Promise.all([
    import(CDN),
    import(`${CDN}/examples/jsm/geometries/RoundedBoxGeometry.js`)
  ]);

  /* ---------- materiales ---------- */
  const cuerpoMat = c => new THREE.MeshStandardMaterial({
    color: c, roughness: 0.38, metalness: 0.06
  });
  const mClaro  = cuerpoMat(CLARO);
  const mMedio  = cuerpoMat(MEDIO);
  const mVivo   = cuerpoMat(VIVO);
  const mDetalle = new THREE.MeshStandardMaterial({ color: CONTOR, roughness: 0.28, metalness: 0.25 });
  const mBrote  = cuerpoMat(BROTE);
  const mBorde  = new THREE.MeshBasicMaterial({ color: CONTOR, side: THREE.BackSide });
  // Piezas que iluminan: ojos, LEDs y punta de antena
  const emisivo = (c, i = 1.6) => new THREE.MeshStandardMaterial({
    color: c, emissive: c, emissiveIntensity: i, roughness: 0.25, metalness: 0
  });
  const mOjo    = emisivo(0x5FD9F5, 1.1);
  const mLedA   = emisivo(0x34D399, 2.0);
  const mLedB   = emisivo(0xFBBF24, 2.0);
  const mLedC   = emisivo(0x60A5FA, 2.0);
  const mBlanco = new THREE.MeshStandardMaterial({ color: 0xF2F8FF, roughness: 0.34 });

  /* Casco invertido: el contorno de la mascota */
  const conBorde = (malla, grosor = 0.055) => {
    const b = new THREE.Mesh(malla.geometry, mBorde);
    const s = malla.geometry.boundingSphere?.radius
      || (malla.geometry.computeBoundingSphere(), malla.geometry.boundingSphere.radius);
    const f = 1 + grosor / Math.max(s, 0.2);
    b.scale.setScalar(f);
    malla.add(b);
    return malla;
  };

  const caja = (w, h, d, r = 0.1, m = mClaro, borde = true) => {
    const malla = new THREE.Mesh(new RoundedBoxGeometry(w, h, d, 5, r), m);
    return borde ? conBorde(malla) : malla;
  };
  const esfera = (r, m = mClaro, borde = true) => {
    const malla = new THREE.Mesh(new THREE.SphereGeometry(r, 22, 18), m);
    return borde ? conBorde(malla, 0.045) : malla;
  };
  const capsula = (r, l, m = mClaro, borde = true) => {
    const malla = new THREE.Mesh(new THREE.CapsuleGeometry(r, l, 6, 16), m);
    return borde ? conBorde(malla, 0.05) : malla;
  };

  /* ---------- escena ---------- */
  const escena = new THREE.Scene();
  const camara = new THREE.PerspectiveCamera(30, 1, 0.1, 100);
  camara.position.set(0, 0, 8.6);

  const render = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  render.setPixelRatio(Math.min(devicePixelRatio, 2));
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping;
  render.toneMappingExposure = 1.0;
  host.appendChild(render.domElement);

  escena.add(new THREE.HemisphereLight(0xffffff, 0x8fb6e8, 2.0));
  const clave = new THREE.DirectionalLight(0xffffff, 2.0);
  clave.position.set(2.4, 3.6, 4.4); escena.add(clave);
  const contra = new THREE.DirectionalLight(0x2563eb, 2.4);
  contra.position.set(-3.6, 1.0, -2.4); escena.add(contra);
  const relleno = new THREE.DirectionalLight(0x60a5fa, 1.1);
  relleno.position.set(-1.6, -2.2, 2.6); escena.add(relleno);

  const raiz = new THREE.Group();
  escena.add(raiz);

  /* ---------- cuerpo ---------- */
  const cuerpo = new THREE.Group();
  raiz.add(cuerpo);

  const torso = caja(1.66, 1.5, 0.95, 0.3, mClaro);
  torso.position.y = -0.62;
  cuerpo.add(torso);

  // Panel frontal más claro, como en la mascota
  const panel = caja(1.18, 1.02, 0.06, 0.16, mMedio, false);
  panel.position.set(0, -0.6, 0.5);
  cuerpo.add(panel);

  // Marco del panel, para que no parezca una calcomanía
  const marco = new THREE.Mesh(
    new THREE.TorusGeometry(0.66, 0.022, 8, 4, Math.PI * 2), mDetalle);
  marco.position.set(0, -0.6, 0.52);
  marco.rotation.z = Math.PI / 4;
  marco.scale.set(1.28, 1.1, 1);
  cuerpo.add(marco);

  // Hombreras
  [-1, 1].forEach(d => {
    const hombrera = caja(0.44, 0.3, 0.72, 0.13, mVivo);
    hombrera.position.set(d * 0.78, 0.03, 0);
    hombrera.rotation.z = d * -0.16;
    cuerpo.add(hombrera);
  });

  // Costuras del torso
  const costura = (x, y, z, w, h) => {
    const c = new THREE.Mesh(new THREE.BoxGeometry(w, h, 0.02), mDetalle);
    c.position.set(x, y, z);
    cuerpo.add(c);
  };
  costura(0, -0.02, 0.49, 1.3, 0.026);      // línea del pecho
  costura(0, -1.2, 0.49, 1.1, 0.026);       // línea baja
  costura(0, -0.62, -0.49, 1.2, 0.026);     // espalda

  // Remaches en las esquinas del torso
  [[-0.68, -0.08], [0.68, -0.08], [-0.68, -1.16], [0.68, -1.16]].forEach(([x, y]) => {
    const rem = new THREE.Mesh(new THREE.CylinderGeometry(0.045, 0.045, 0.05, 10), mDetalle);
    rem.position.set(x, y, 0.48);
    rem.rotation.x = Math.PI / 2;
    cuerpo.add(rem);
  });

  // Mochila trasera
  const mochila = caja(1.0, 0.82, 0.26, 0.12, mMedio);
  mochila.position.set(0, -0.6, -0.58);
  cuerpo.add(mochila);
  [-1, 1].forEach(d => {
    const rejilla = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.5, 0.04), mDetalle);
    rejilla.position.set(d * 0.2, -0.6, -0.72);
    cuerpo.add(rejilla);
  });

  // Engrane del pecho, proporcionado
  const engrane = new THREE.Group();
  engrane.position.set(0, -0.58, 0.56);
  cuerpo.add(engrane);
  const aro = new THREE.Mesh(new THREE.TorusGeometry(0.2, 0.075, 12, 28), mDetalle);
  engrane.add(aro);
  const eje = new THREE.Mesh(new THREE.CylinderGeometry(0.075, 0.075, 0.09, 18), mBlanco);
  eje.rotateX(Math.PI / 2);
  engrane.add(eje);
  const tornillo = new THREE.Mesh(new THREE.CylinderGeometry(0.03, 0.03, 0.12, 8), mDetalle);
  tornillo.rotateX(Math.PI / 2);
  engrane.add(tornillo);
  for (let i = 0; i < 8; i++) {
    const d = new THREE.Mesh(new THREE.BoxGeometry(0.095, 0.1, 0.09), mDetalle);
    const a = (i / 8) * Math.PI * 2;
    d.position.set(Math.cos(a) * 0.265, Math.sin(a) * 0.265, 0);
    d.rotation.z = a;
    engrane.add(d);
  }

  // Pistas de circuito con sus nodos
  const pista = pts => new THREE.Mesh(new THREE.TubeGeometry(
    new THREE.CatmullRomCurve3(pts.map(p => new THREE.Vector3(...p))), 26, 0.028, 7, false), mDetalle);
  const nodo = (x, y) => {
    const n = new THREE.Mesh(new THREE.SphereGeometry(0.062, 14, 12), mDetalle);
    n.position.set(x, y, 0.535);
    cuerpo.add(n);
  };
  // Tres LEDs de estado, que laten en el bucle
  const leds = [];
  [[-0.24, mLedA], [0, mLedB], [0.24, mLedC]].forEach(([x, m]) => {
    const l = new THREE.Mesh(new THREE.SphereGeometry(0.058, 14, 12), m);
    l.position.set(x, -1.08, 0.52);
    cuerpo.add(l); leds.push(l);
  });

  cuerpo.add(pista([[-0.5, -0.15, 0.53], [-0.5, -0.58, 0.53], [-0.22, -0.58, 0.53]]));
  cuerpo.add(pista([[0.5, -1.05, 0.53], [0.5, -0.62, 0.53], [0.22, -0.62, 0.53]]));
  cuerpo.add(pista([[-0.46, -1.06, 0.53], [-0.16, -1.06, 0.53]]));
  nodo(-0.5, -0.15); nodo(0.5, -1.05); nodo(-0.16, -1.06);

  // Brazos: hombro esférico + cápsula + pinza
  const brazo = lado => {
    const g = new THREE.Group();
    const hombro = esfera(0.29, mMedio);
    g.add(hombro);
    const sup = capsula(0.2, 0.62, mClaro);
    sup.position.y = -0.56;
    g.add(sup);
    const codo = esfera(0.19, mMedio);
    codo.position.y = -0.98;
    g.add(codo);
    const inf = capsula(0.17, 0.34, mClaro);
    inf.position.y = -1.24;
    g.add(inf);
    // pinza de dos dedos
    [-1, 1].forEach(d => {
      const dedo = capsula(0.075, 0.16, mMedio);
      dedo.position.set(d * 0.13, -1.6, 0);
      dedo.rotation.z = d * 0.34;
      g.add(dedo);
    });
    g.position.set(lado * 0.98, -0.3, 0.04);
    g.rotation.z = lado * 0.14;
    return g;
  };
  const brazoIzq = brazo(-1), brazoDer = brazo(1);
  cuerpo.add(brazoIzq, brazoDer);

  // Piernas con cadera y pie
  [-1, 1].forEach(d => {
    const cadera = esfera(0.2, mMedio);
    cadera.position.set(d * 0.4, -1.42, 0);
    cuerpo.add(cadera);
    const pierna = capsula(0.21, 0.28, mClaro);
    pierna.position.set(d * 0.4, -1.72, 0);
    cuerpo.add(pierna);
    const pie = caja(0.52, 0.24, 0.62, 0.11, mMedio);
    pie.position.set(d * 0.4, -2.06, 0.09);
    cuerpo.add(pie);
    // Puntera y taco, para que el pie no sea un ladrillo
    const puntera = caja(0.44, 0.14, 0.16, 0.06, mVivo);
    puntera.position.set(d * 0.4, -2.1, 0.37);
    cuerpo.add(puntera);
    const taco = new THREE.Mesh(new THREE.CylinderGeometry(0.11, 0.11, 0.06, 12), mDetalle);
    taco.position.set(d * 0.4, -2.18, -0.1);
    cuerpo.add(taco);
  });

  /* ---------- cabeza ---------- */
  const cabeza = new THREE.Group();
  cabeza.position.y = 0.86;
  raiz.add(cabeza);

  const craneo = caja(1.96, 1.5, 1.1, 0.36, mClaro);
  cabeza.add(craneo);

  // Visera para asentar los ojos
  const visera = caja(1.5, 0.86, 0.06, 0.3, mMedio, false);
  visera.position.set(0, 0.06, 0.55);
  cabeza.add(visera);

  // Marco de la visera
  const marcoVisera = new THREE.Mesh(new THREE.TorusGeometry(0.8, 0.03, 8, 4), mDetalle);
  marcoVisera.position.set(0, 0.06, 0.57);
  marcoVisera.rotation.z = Math.PI / 4;
  marcoVisera.scale.set(1.02, 0.6, 1);
  cabeza.add(marcoVisera);

  // Placa superior de la cabeza
  const placa = caja(1.5, 0.1, 0.86, 0.05, mVivo);
  placa.position.set(0, 0.72, 0);
  cabeza.add(placa);

  // Costura lateral de la cabeza
  [-1, 1].forEach(d => {
    const c = new THREE.Mesh(new THREE.BoxGeometry(0.02, 0.9, 0.6), mDetalle);
    c.position.set(d * 0.94, 0, 0);
    cabeza.add(c);
  });

  const ojos = [];
  [-1, 1].forEach(d => {
    // Cuenca oscura + iris que ilumina + brillo
    const cuenca = new THREE.Mesh(new THREE.SphereGeometry(0.185, 20, 16), mDetalle);
    cuenca.position.set(d * 0.4, 0.14, 0.56);
    cabeza.add(cuenca);

    const o = new THREE.Mesh(new THREE.SphereGeometry(0.135, 22, 18), mOjo);
    o.position.set(d * 0.4, 0.14, 0.64);
    cabeza.add(o); ojos.push(o);

    const b = new THREE.Mesh(new THREE.SphereGeometry(0.045, 12, 10),
      new THREE.MeshBasicMaterial({ color: 0xffffff }));
    b.position.set(d * 0.4 + 0.055, 0.2, 0.74);
    cabeza.add(b);
  });

  const sonrisa = new THREE.Mesh(
    new THREE.TorusGeometry(0.3, 0.05, 10, 24, Math.PI * 0.9), mDetalle);
  sonrisa.position.set(0, -0.18, 0.56);
  sonrisa.rotation.z = Math.PI + Math.PI * 0.05;
  cabeza.add(sonrisa);

  // Módulos laterales
  [-1, 1].forEach(d => {
    const or = caja(0.26, 0.54, 0.48, 0.11, mVivo);
    or.position.set(d * 1.1, 0, 0);
    cabeza.add(or);
    // Disco y perno del módulo
    const disco = new THREE.Mesh(new THREE.CylinderGeometry(0.15, 0.15, 0.07, 18), mBlanco);
    disco.position.set(d * 1.24, 0, 0);
    disco.rotation.z = Math.PI / 2;
    cabeza.add(disco);
    const perno = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.05, 0.1, 10), mDetalle);
    perno.position.set(d * 1.29, 0, 0);
    perno.rotation.z = Math.PI / 2;
    cabeza.add(perno);
  });

  const cuello = caja(0.56, 0.24, 0.48, 0.09, mMedio);
  cuello.position.y = -0.86;
  cabeza.add(cuello);
  const anillo = new THREE.Mesh(new THREE.TorusGeometry(0.3, 0.038, 8, 22), mDetalle);
  anillo.position.y = -0.86;
  anillo.rotation.x = Math.PI / 2;
  cabeza.add(anillo);

  /* ---------- brote ---------- */
  const brote = new THREE.Group();
  brote.position.y = 0.74;
  cabeza.add(brote);

  // Maceta de la que sale el brote
  const maceta = new THREE.Mesh(new THREE.CylinderGeometry(0.15, 0.19, 0.16, 16), mVivo);
  conBorde(maceta, 0.04);
  maceta.position.y = -0.04;
  brote.add(maceta);

  const tallo = new THREE.Mesh(new THREE.TubeGeometry(
    new THREE.CatmullRomCurve3([
      new THREE.Vector3(0, 0, 0), new THREE.Vector3(0.05, 0.3, 0.02),
      new THREE.Vector3(-0.02, 0.58, 0)]), 18, 0.05, 8, false), mBrote);
  conBorde(tallo, 0.035);
  brote.add(tallo);

  const hoja = (lado, alt) => {
    const f = new THREE.Shape();
    f.moveTo(0, 0);
    f.bezierCurveTo(0.18, 0.12, 0.38, 0.34, 0.5, 0.62);
    f.bezierCurveTo(0.22, 0.55, 0.05, 0.32, 0, 0);
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(f, {
      depth: 0.055, bevelEnabled: true, bevelSize: 0.022, bevelThickness: 0.022, bevelSegments: 2
    }), mBrote);
    conBorde(m, 0.035);
    m.scale.x = lado;
    m.position.set(lado * 0.03, alt, -0.03);
    m.rotation.z = lado * -0.34;
    return m;
  };
  const hojaIzq = hoja(-1, 0.3), hojaDer = hoja(1, 0.46);
  brote.add(hojaIzq, hojaDer);

  // Punta luminosa del brote
  const puntaBrote = new THREE.Mesh(new THREE.SphereGeometry(0.055, 14, 12), emisivo(0x7FFFD8, 2.4));
  puntaBrote.position.set(-0.02, 0.6, 0);
  brote.add(puntaBrote);

  /* ---------- encuadre ---------- */
  const encuadrar = () => {
    const a = host.clientWidth, b = host.clientHeight || a;
    if (!a || !b) return;
    camara.aspect = a / b;
    camara.position.z = 8.6 * Math.max(1, 1.15 / camara.aspect);
    camara.updateProjectionMatrix();
    render.setSize(a, b);
  };
  encuadrar();
  new ResizeObserver(encuadrar).observe(host);
  host.classList.add('listo');

  /* ---------- movimiento ---------- */
  const zona = host.closest('.hero') || document.body;
  const meta = { x: 0, y: 0 };
  const act = { x: 0, y: 0 };

  // El cursor se sigue en toda la ventana, no sólo sobre el hero:
  // así la cabeza reacciona aunque el ratón esté sobre el texto.
  addEventListener('pointermove', e => {
    meta.x = ((e.clientX / innerWidth) - 0.5) * 2 * LIMITE_X;
    meta.y = ((e.clientY / innerHeight) - 0.5) * 2 * LIMITE_Y;
  }, { passive: true });

  /* Desplazamiento: el robot baja un poco y se acerca */
  let avance = 0;
  const alScroll = () => {
    const r = zona.getBoundingClientRect();
    avance = Math.min(1, Math.max(0, -r.top / Math.max(r.height, 1)));
  };
  addEventListener('scroll', alScroll, { passive: true });
  alScroll();

  let visible = true;
  new IntersectionObserver(([e]) => { visible = e.isIntersecting; }).observe(host);
  document.addEventListener('visibilitychange', () => { visible = !document.hidden; });

  const reloj = new THREE.Clock();
  let proxParpadeo = 2 + Math.random() * 3;
  let avanceSuave = 0;

  function bucle() {
    requestAnimationFrame(bucle);
    if (!visible) return;
    const t = reloj.getElapsedTime();

    act.x += (meta.x - act.x) * INERCIA;
    act.y += (meta.y - act.y) * INERCIA;

    cabeza.rotation.y = act.x;
    cabeza.rotation.x = act.y;
    cabeza.rotation.z = act.x * -0.14;
    cuerpo.rotation.y = act.x * 0.2;

    // Motion scroll: baja y se acerca
    avanceSuave += (avance - avanceSuave) * 0.09;
    const resp = Math.sin(t * 0.9) * 0.035;
    raiz.position.y = resp - avanceSuave * 1.35;
    raiz.scale.setScalar(1 + avanceSuave * 0.26);
    raiz.rotation.x = avanceSuave * 0.12;

    cabeza.position.y = 0.86 + resp * 0.5;

    if (t > proxParpadeo) {
      const p = (t - proxParpadeo) / 0.13;
      const s = p < 1 ? Math.abs(Math.sin(p * Math.PI)) : 0;
      ojos.forEach(o => o.scale.y = 1 - s * 0.92);
      if (p >= 1) { proxParpadeo = t + 2.4 + Math.random() * 3.4; ojos.forEach(o => o.scale.y = 1); }
    }

    // LEDs con latidos desfasados
    leds.forEach((l, i) => {
      l.material.emissiveIntensity = 1.1 + Math.abs(Math.sin(t * 1.6 + i * 0.8)) * 1.6;
    });
    puntaBrote.material.emissiveIntensity = 1.6 + Math.abs(Math.sin(t * 1.2)) * 1.4;
    ojos.forEach(o => o.material.emissiveIntensity = 0.9 + Math.abs(Math.sin(t * 0.7)) * 0.4);

    engrane.rotation.z = -t * 0.5;
    brote.rotation.z = Math.sin(t * 1.1) * 0.1;
    hojaIzq.rotation.z = -0.34 + Math.sin(t * 1.5) * 0.14;
    hojaDer.rotation.z = 0.34 + Math.sin(t * 1.5 + 0.9) * 0.14;
    brazoIzq.rotation.z = -0.14 + Math.sin(t * 0.8) * 0.045;
    brazoDer.rotation.z = 0.14 - Math.sin(t * 0.8) * 0.045;

    render.render(escena, camara);
  }
  bucle();
}
