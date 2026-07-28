/* ============================================================
   CULTIVATEC — Mascota en 3D

   Construida con primitivas de Three.js en vez de cargar una malla:
   así la cabeza es un grupo propio y puede girar sola hacia el cursor,
   que es lo que pedía el diseño. Además no descarga ningún modelo.

   Jerarquía:
     raiz
       └ cuerpo        (torso, engrane, brazos, piernas)   — quieto
       └ cabeza        (cráneo, ojos, sonrisa, orejas)     — sigue al ratón
            └ brote    (tallo y hojas)                     — se mece
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

const AZUL_CLARO = 0xA9CDEF;
const AZUL_MEDIO = 0x4A82C8;
const AZUL_OSCURO = 0x1E4C8A;
const AZUL_FUERTE = 0x1B3F7A;
const VERDE_BROTE = 0x5BC8B4;

const LIMITE_X = 0.62;   // giro horizontal de la cabeza ~36°
const LIMITE_Y = 0.34;   // cabeceo ~19°
const INERCIA = 0.075;

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
  const mat = (color, opts = {}) => new THREE.MeshStandardMaterial({
    color, roughness: 0.42, metalness: 0.08, ...opts
  });
  const mClaro  = mat(AZUL_CLARO);
  const mMedio  = mat(AZUL_MEDIO);
  const mOscuro = mat(AZUL_OSCURO, { roughness: 0.3 });
  const mFuerte = mat(AZUL_FUERTE, { roughness: 0.26, metalness: 0.2 });
  const mBrote  = mat(VERDE_BROTE, { roughness: 0.5 });

  const caja = (w, h, d, r = 0.06, m = mClaro) =>
    new THREE.Mesh(new RoundedBoxGeometry(w, h, d, 4, r), m);

  /* ---------- escena ---------- */
  const escena = new THREE.Scene();
  const camara = new THREE.PerspectiveCamera(30, 1, 0.1, 100);
  camara.position.set(0, 0.1, 8.2);

  const render = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  render.setPixelRatio(Math.min(devicePixelRatio, 2));
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping;
  render.toneMappingExposure = 1.1;
  host.appendChild(render.domElement);

  escena.add(new THREE.HemisphereLight(0xffffff, 0xbcd6f5, 2.4));
  const clave = new THREE.DirectionalLight(0xffffff, 2.2);
  clave.position.set(2.6, 3.4, 4.2); escena.add(clave);
  const contra = new THREE.DirectionalLight(0x2563eb, 1.9);
  contra.position.set(-3.4, 1.2, -2.6); escena.add(contra);
  const relleno = new THREE.DirectionalLight(0x22d3ee, 0.9);
  relleno.position.set(-1.8, -2, 2.4); escena.add(relleno);

  const raiz = new THREE.Group();
  escena.add(raiz);

  /* ---------- cuerpo ---------- */
  const cuerpo = new THREE.Group();
  raiz.add(cuerpo);

  const torso = caja(1.72, 1.55, 0.92, 0.3);
  torso.position.y = -0.55;
  cuerpo.add(torso);

  // Engrane del pecho
  const engrane = new THREE.Group();
  engrane.position.set(0, -0.42, 0.5);
  cuerpo.add(engrane);
  engrane.add(new THREE.Mesh(new THREE.TorusGeometry(0.26, 0.09, 10, 26), mFuerte));
  engrane.add(new THREE.Mesh(new THREE.CircleGeometry(0.11, 20), mClaro));
  for (let i = 0; i < 8; i++) {
    const diente = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.12, 0.11), mFuerte);
    const a = (i / 8) * Math.PI * 2;
    diente.position.set(Math.cos(a) * 0.34, Math.sin(a) * 0.34, 0);
    diente.rotation.z = a;
    engrane.add(diente);
  }

  // Pistas de circuito del torso
  const pista = (pts, gr = 0.035) => {
    const g = new THREE.TubeGeometry(
      new THREE.CatmullRomCurve3(pts.map(p => new THREE.Vector3(...p))), 22, gr, 6, false);
    return new THREE.Mesh(g, mFuerte);
  };
  cuerpo.add(pista([[-0.62, -0.05, 0.47], [-0.62, -0.42, 0.47], [-0.3, -0.42, 0.47]]));
  cuerpo.add(pista([[0.62, -0.9, 0.47], [0.62, -0.5, 0.47], [0.3, -0.5, 0.47]]));
  cuerpo.add(pista([[-0.55, -1.05, 0.47], [-0.2, -1.05, 0.47]]));
  // position es de sólo lectura en Object3D: hay que usar .set(), no asignarla
  [[-0.62, -0.05], [0.62, -0.9], [-0.2, -1.05]].forEach(([x, y]) => {
    const nodo = new THREE.Mesh(new THREE.SphereGeometry(0.075, 14, 12), mFuerte);
    nodo.position.set(x, y, 0.48);
    cuerpo.add(nodo);
  });

  // Brazos con pinza
  const brazo = lado => {
    const g = new THREE.Group();
    const sup = caja(0.36, 0.92, 0.36, 0.16, mClaro);
    sup.position.y = -0.42; g.add(sup);
    const inf = caja(0.32, 0.5, 0.32, 0.14, mMedio);
    inf.position.y = -1.02; g.add(inf);
    // pinza: dos dedos
    [-1, 1].forEach(d => {
      const dedo = caja(0.11, 0.26, 0.14, 0.05, mClaro);
      dedo.position.set(d * 0.11, -1.36, 0);
      dedo.rotation.z = d * 0.22;
      g.add(dedo);
    });
    g.position.set(lado * 1.02, -0.28, 0);
    g.rotation.z = lado * 0.12;
    return g;
  };
  const brazoIzq = brazo(-1), brazoDer = brazo(1);
  cuerpo.add(brazoIzq, brazoDer);

  // Piernas
  [-1, 1].forEach(d => {
    const p = caja(0.46, 0.62, 0.5, 0.18, mClaro);
    p.position.set(d * 0.42, -1.62, 0);
    cuerpo.add(p);
    const pie = caja(0.54, 0.24, 0.62, 0.1, mMedio);
    pie.position.set(d * 0.42, -1.98, 0.05);
    cuerpo.add(pie);
  });

  /* ---------- cabeza (grupo propio: sigue al cursor) ---------- */
  const cabeza = new THREE.Group();
  cabeza.position.y = 0.78;
  raiz.add(cabeza);

  const craneo = caja(1.92, 1.46, 1.06, 0.34, mClaro);
  cabeza.add(craneo);

  // Ojos
  const ojos = [];
  [-1, 1].forEach(d => {
    const o = new THREE.Mesh(new THREE.SphereGeometry(0.155, 20, 16), mFuerte);
    o.position.set(d * 0.4, 0.12, 0.52);
    cabeza.add(o); ojos.push(o);
  });

  // Sonrisa
  const sonrisa = new THREE.Mesh(
    new THREE.TorusGeometry(0.3, 0.045, 8, 22, Math.PI * 0.86), mFuerte);
  sonrisa.position.set(0, -0.16, 0.5);
  sonrisa.rotation.z = Math.PI + Math.PI * 0.07;
  cabeza.add(sonrisa);

  // Orejas / módulos laterales
  [-1, 1].forEach(d => {
    const or = caja(0.24, 0.5, 0.44, 0.09, mMedio);
    or.position.set(d * 1.06, 0, 0);
    cabeza.add(or);
  });

  // Cuello
  const cuello = caja(0.6, 0.22, 0.5, 0.07, mMedio);
  cuello.position.y = -0.82;
  cabeza.add(cuello);

  /* ---------- brote (lo que hace "Cultiva") ---------- */
  const brote = new THREE.Group();
  brote.position.y = 0.72;
  cabeza.add(brote);

  const tallo = new THREE.Mesh(
    new THREE.TubeGeometry(new THREE.CatmullRomCurve3([
      new THREE.Vector3(0, 0, 0), new THREE.Vector3(0.04, 0.26, 0),
      new THREE.Vector3(-0.02, 0.5, 0)]), 14, 0.045, 6, false), mBrote);
  brote.add(tallo);

  const hoja = (lado, alt) => {
    const forma = new THREE.Shape();
    forma.moveTo(0, 0);
    forma.bezierCurveTo(0.16, 0.1, 0.34, 0.3, 0.44, 0.56);
    forma.bezierCurveTo(0.2, 0.5, 0.04, 0.3, 0, 0);
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(forma, {
      depth: 0.05, bevelEnabled: true, bevelSize: 0.02, bevelThickness: 0.02, bevelSegments: 2
    }), mBrote);
    m.scale.x = lado;
    m.position.set(lado * 0.02, alt, -0.025);
    m.rotation.z = lado * -0.3;
    return m;
  };
  const hojaIzq = hoja(-1, 0.3), hojaDer = hoja(1, 0.42);
  brote.add(hojaIzq, hojaDer);

  /* ---------- encuadre ---------- */
  const encuadrar = () => {
    const a = host.clientWidth, b = host.clientHeight || a;
    if (!a || !b) return;
    camara.aspect = a / b;
    // Con el lienzo estrecho, alejar para que el robot entre completo
    camara.position.z = 8.2 * Math.max(1, 1.25 / camara.aspect);
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

  zona.addEventListener('pointermove', e => {
    const r = zona.getBoundingClientRect();
    meta.x = (((e.clientX - r.left) / r.width) - 0.5) * 2 * LIMITE_X;
    meta.y = (((e.clientY - r.top) / r.height) - 0.5) * 2 * LIMITE_Y;
  });
  zona.addEventListener('pointerleave', () => { meta.x = 0; meta.y = 0; });

  let visible = true;
  new IntersectionObserver(([e]) => { visible = e.isIntersecting; }).observe(host);
  document.addEventListener('visibilitychange', () => { visible = !document.hidden; });

  const reloj = new THREE.Clock();
  let proxParpadeo = 2 + Math.random() * 3;

  function bucle() {
    requestAnimationFrame(bucle);
    if (!visible) return;
    const t = reloj.getElapsedTime();

    // La cabeza sigue al cursor; el cuerpo sólo la acompaña un poco
    act.x += (meta.x - act.x) * INERCIA;
    act.y += (meta.y - act.y) * INERCIA;
    cabeza.rotation.y = act.x;
    cabeza.rotation.x = act.y;
    cabeza.rotation.z = act.x * -0.12;              // ladea al girar
    cuerpo.rotation.y = act.x * 0.22;

    // Respiración
    const resp = Math.sin(t * 0.9) * 0.03;
    raiz.position.y = resp;
    cabeza.position.y = 0.78 + resp * 0.5;

    // Parpadeo
    if (t > proxParpadeo) {
      const p = (t - proxParpadeo) / 0.13;
      const s = p < 1 ? Math.abs(Math.sin(p * Math.PI)) : 0;
      ojos.forEach(o => o.scale.y = 1 - s * 0.9);
      if (p >= 1) { proxParpadeo = t + 2.4 + Math.random() * 3.4; ojos.forEach(o => o.scale.y = 1); }
    }

    // Engrane y brote
    engrane.rotation.z = -t * 0.55;
    brote.rotation.z = Math.sin(t * 1.1) * 0.09;
    hojaIzq.rotation.z = -0.3 + Math.sin(t * 1.5) * 0.13;
    hojaDer.rotation.z = 0.3 + Math.sin(t * 1.5 + 0.9) * 0.13;

    // Brazos con vaivén mínimo
    brazoIzq.rotation.z = -0.12 + Math.sin(t * 0.8) * 0.04;
    brazoDer.rotation.z = 0.12 - Math.sin(t * 0.8) * 0.04;

    render.render(escena, camara);
  }
  bucle();
}
