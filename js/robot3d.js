/* ============================================================
   CULTIVATEC — Mascota en 3D

   Construida con primitivas para poder separar la cabeza en su propio
   grupo: así gira sola hacia el cursor, cosa imposible con una malla
   fusionada.

   El aspecto viene de dos cosas: el contorno oscuro (casco invertido: un
   clon de cada pieza, algo mayor, con caras traseras y material sin luz)
   y las articulaciones a la vista, que son las que dan lectura de robot.

   Jerarquía:
     raiz
      ├ cuerpo   (torso, engrane, brazos, piernas)   — quieto
      └ cabeza   (casco, pantalla, orejeras)         — sigue al cursor
          └ brote (tallo y hojas)                    — se mece
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

const CLARO  = 0xA6CBF3;
const MEDIO  = 0x4A88DA;
const VIVO   = 0x2563EB;
const HONDO  = 0x1B4A96;
const CONTOR = 0x11305F;
const BROTE  = 0x3FBF9E;

const LIMITE_X = 1.15;   // giro horizontal de la cabeza ~66°
const LIMITE_Y = 0.62;   // cabeceo ~36°
const INERCIA  = 0.085;

/* Devuelve el nivel de detalle, o null si no conviene cargar nada. */
function calidad() {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return null;
  const con = navigator.connection;
  if (con && (con.saveData || ['slow-2g', '2g'].includes(con.effectiveType))) return null;
  // En móvil también se muestra, con menos resolución y menos polígonos
  return matchMedia('(min-width: 861px)').matches ? 'alta' : 'baja';
}

export async function montarRobot3D(host) {
  const nivel = host && calidad();
  if (!nivel) return;
  const alta = nivel === 'alta';

  const [THREE, { RoundedBoxGeometry }] = await Promise.all([
    import(CDN),
    import(`${CDN}/examples/jsm/geometries/RoundedBoxGeometry.js`)
  ]);

  /* ---------- materiales ---------- */
  const pintura = c => new THREE.MeshStandardMaterial({ color: c, roughness: 0.36, metalness: 0.1 });
  const mClaro = pintura(CLARO);
  const mMedio = pintura(MEDIO);
  const mVivo  = pintura(VIVO);
  const mHondo = pintura(HONDO);
  const mMetal = new THREE.MeshStandardMaterial({ color: CONTOR, roughness: 0.24, metalness: 0.55 });
  const mPantalla = new THREE.MeshStandardMaterial({ color: 0x0C2245, roughness: 0.16, metalness: 0.3 });
  const mBrote = pintura(BROTE);
  const mBorde = new THREE.MeshBasicMaterial({ color: CONTOR, side: THREE.BackSide });
  const emisivo = (c, i) => new THREE.MeshStandardMaterial({
    color: c, emissive: c, emissiveIntensity: i, roughness: 0.2, metalness: 0
  });
  const mOjo  = emisivo(0x6FE3FF, 2.2);
  const mLedA = emisivo(0x34D399, 2.0);
  const mLedB = emisivo(0xFBBF24, 2.0);
  const mLedC = emisivo(0x60A5FA, 2.0);

  const seg = alta ? 1 : 0.6;   // detalle de las mallas curvas

  const conBorde = (m, grosor = 0.05) => {
    const b = new THREE.Mesh(m.geometry, mBorde);
    m.geometry.computeBoundingSphere();
    b.scale.setScalar(1 + grosor / Math.max(m.geometry.boundingSphere.radius, 0.2));
    m.add(b);
    return m;
  };
  const caja = (w, h, d, r = 0.08, mat = mClaro, borde = true) => {
    const m = new THREE.Mesh(new RoundedBoxGeometry(w, h, d, alta ? 5 : 3, r), mat);
    return borde ? conBorde(m) : m;
  };
  const bola = (r, mat = mMetal) =>
    new THREE.Mesh(new THREE.SphereGeometry(r, Math.round(20 * seg), Math.round(16 * seg)), mat);
  const cil = (r, h, mat = mMetal) =>
    new THREE.Mesh(new THREE.CylinderGeometry(r, r, h, Math.round(16 * seg)), mat);
  /* Línea de panel: caja muy fina pegada a la superficie */
  const linea = (w, h, x, y, z, mat = mMetal) => {
    const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, 0.02), mat);
    m.position.set(x, y, z);
    return m;
  };

  /* ---------- escena ---------- */
  const escena = new THREE.Scene();
  const camara = new THREE.PerspectiveCamera(30, 1, 0.1, 100);
  camara.position.set(0, 0, 8.6);

  const render = new THREE.WebGLRenderer({ antialias: alta, alpha: true });
  render.setPixelRatio(Math.min(devicePixelRatio, alta ? 2 : 1.5));
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping;
  render.toneMappingExposure = 1.05;
  host.appendChild(render.domElement);

  escena.add(new THREE.HemisphereLight(0xffffff, 0x7FA9E0, 2.0));
  const clave = new THREE.DirectionalLight(0xffffff, 2.1);
  clave.position.set(2.6, 3.6, 4.4); escena.add(clave);
  const contra = new THREE.DirectionalLight(0x2563eb, 2.5);
  contra.position.set(-3.6, 1.0, -2.4); escena.add(contra);
  const relleno = new THREE.DirectionalLight(0x7DD3FC, 1.2);
  relleno.position.set(-1.6, -2.2, 2.6); escena.add(relleno);

  const raiz = new THREE.Group();
  escena.add(raiz);

  /* ================= CUERPO ================= */
  const cuerpo = new THREE.Group();
  raiz.add(cuerpo);

  // Torso en dos bloques: pecho ancho y abdomen estrecho
  const pecho = caja(1.72, 0.86, 1.0, 0.2, mClaro);
  pecho.position.y = -0.32;
  cuerpo.add(pecho);

  const abdomen = caja(1.3, 0.6, 0.86, 0.16, mMedio);
  abdomen.position.y = -1.02;
  cuerpo.add(abdomen);

  // Cintura mecánica entre ambos
  const cintura = cil(0.42, 0.2, mMetal);
  cintura.position.y = -0.74;
  cuerpo.add(cintura);

  // Placa de pecho hundida, con marco RECTO (el rombo anterior parecía grieta)
  const placa = caja(1.12, 0.62, 0.08, 0.08, mHondo);
  placa.position.set(0, -0.3, 0.5);
  cuerpo.add(placa);
  [0.33, -0.33].forEach(y => cuerpo.add(linea(1.16, 0.04, 0, -0.3 + y, 0.55)));
  [-0.58, 0.58].forEach(x => {
    const l = new THREE.Mesh(new THREE.BoxGeometry(0.04, 0.66, 0.02), mMetal);
    l.position.set(x, -0.3, 0.55);
    cuerpo.add(l);
  });

  // Engrane hundido en la placa
  const engrane = new THREE.Group();
  engrane.position.set(0, -0.3, 0.56);
  cuerpo.add(engrane);
  engrane.add(new THREE.Mesh(new THREE.TorusGeometry(0.17, 0.06, 10, Math.round(24 * seg)), mMetal));
  const eje = cil(0.06, 0.09, mVivo); eje.rotation.x = Math.PI / 2; engrane.add(eje);
  for (let i = 0; i < 8; i++) {
    const d = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.085, 0.08), mMetal);
    const a = (i / 8) * Math.PI * 2;
    d.position.set(Math.cos(a) * 0.225, Math.sin(a) * 0.225, 0);
    d.rotation.z = a;
    engrane.add(d);
  }

  // Rejilla de ventilación del abdomen
  for (let i = -1; i <= 1; i++) cuerpo.add(linea(0.62, 0.05, 0, -1.02 + i * 0.14, 0.44));

  // LEDs de estado
  const leds = [];
  [[-0.44, mLedA], [-0.28, mLedB], [-0.12, mLedC]].forEach(([x, m]) => {
    const l = bola(0.05, m);
    l.position.set(x, -0.02, 0.51);
    cuerpo.add(l); leds.push(l);
  });

  // Mochila con toberas
  const mochila = caja(0.94, 0.7, 0.24, 0.09, mMedio);
  mochila.position.set(0, -0.36, -0.6);
  cuerpo.add(mochila);
  [-1, 1].forEach(d => {
    const t = cil(0.07, 0.44, mMetal);
    t.position.set(d * 0.26, -0.36, -0.74);
    cuerpo.add(t);
  });

  /* --- Brazos con articulaciones a la vista --- */
  const brazo = lado => {
    const g = new THREE.Group();
    g.add(bola(0.2, mMetal));                       // hombro expuesto
    const pauldron = caja(0.42, 0.34, 0.56, 0.11, mVivo);
    pauldron.position.set(lado * 0.06, 0.12, 0);
    g.add(pauldron);

    const sup = caja(0.3, 0.56, 0.32, 0.1, mClaro);
    sup.position.y = -0.46;
    g.add(sup);

    const codo = bola(0.15, mMetal);                // codo visible
    codo.position.y = -0.8;
    g.add(codo);
    const pasador = cil(0.055, 0.36, mVivo);
    pasador.rotation.z = Math.PI / 2;
    pasador.position.y = -0.8;
    g.add(pasador);

    const inf = caja(0.26, 0.46, 0.28, 0.09, mMedio);
    inf.position.y = -1.1;
    g.add(inf);

    const muneca = cil(0.11, 0.1, mMetal);
    muneca.position.y = -1.36;
    g.add(muneca);

    [-1, 1].forEach(d => {
      const dedo = caja(0.1, 0.26, 0.14, 0.045, mClaro);
      dedo.position.set(d * 0.12, -1.54, 0);
      dedo.rotation.z = d * 0.26;
      g.add(dedo);
      const punta = caja(0.08, 0.12, 0.12, 0.04, mVivo);
      punta.position.set(d * 0.17, -1.7, 0);
      punta.rotation.z = d * 0.4;
      g.add(punta);
    });

    g.position.set(lado * 1.02, -0.12, 0);
    g.rotation.z = lado * 0.1;
    return g;
  };
  const brazoIzq = brazo(-1), brazoDer = brazo(1);
  cuerpo.add(brazoIzq, brazoDer);

  /* --- Piernas segmentadas --- */
  [-1, 1].forEach(d => {
    const cadera = bola(0.19, mMetal);
    cadera.position.set(d * 0.38, -1.4, 0);
    cuerpo.add(cadera);

    const muslo = caja(0.34, 0.44, 0.38, 0.11, mClaro);
    muslo.position.set(d * 0.38, -1.68, 0);
    cuerpo.add(muslo);

    const rodilla = cil(0.13, 0.3, mMetal);
    rodilla.rotation.z = Math.PI / 2;
    rodilla.position.set(d * 0.38, -1.94, 0);
    cuerpo.add(rodilla);

    const pantorrilla = caja(0.3, 0.34, 0.34, 0.1, mMedio);
    pantorrilla.position.set(d * 0.38, -2.18, 0);
    cuerpo.add(pantorrilla);

    const pie = caja(0.46, 0.18, 0.56, 0.07, mVivo);
    pie.position.set(d * 0.38, -2.42, 0.08);
    cuerpo.add(pie);
    const puntera = caja(0.4, 0.12, 0.16, 0.05, mClaro);
    puntera.position.set(d * 0.38, -2.44, 0.36);
    cuerpo.add(puntera);
    const talon = caja(0.24, 0.14, 0.14, 0.05, mMetal);
    talon.position.set(d * 0.38, -2.42, -0.2);
    cuerpo.add(talon);
  });

  /* ================= CABEZA ================= */
  const cabeza = new THREE.Group();
  cabeza.position.y = 0.72;
  raiz.add(cabeza);

  const casco = caja(1.82, 1.36, 1.04, 0.24, mClaro);
  cabeza.add(casco);

  const cresta = caja(0.9, 0.14, 0.9, 0.05, mVivo);
  cresta.position.y = 0.66;
  cabeza.add(cresta);

  // Pantalla facial hundida, con marco recto
  const marcoPantalla = caja(1.4, 0.88, 0.1, 0.16, mHondo);
  marcoPantalla.position.set(0, 0.02, 0.5);
  cabeza.add(marcoPantalla);
  const pantalla = new THREE.Mesh(
    new RoundedBoxGeometry(1.2, 0.7, 0.06, 3, 0.12), mPantalla);
  pantalla.position.set(0, 0.02, 0.56);
  cabeza.add(pantalla);

  // Ojos y sonrisa, dentro de la pantalla
  const ojos = [];
  [-1, 1].forEach(d => {
    const o = new THREE.Mesh(
      new THREE.CapsuleGeometry(0.075, 0.1, 4, Math.round(14 * seg)), mOjo);
    o.position.set(d * 0.28, 0.12, 0.6);
    cabeza.add(o); ojos.push(o);
  });
  const sonrisa = new THREE.Mesh(
    new THREE.TorusGeometry(0.2, 0.032, 8, Math.round(20 * seg), Math.PI * 0.85), mOjo);
  sonrisa.position.set(0, -0.14, 0.6);
  sonrisa.rotation.z = Math.PI + Math.PI * 0.075;
  cabeza.add(sonrisa);

  // Orejeras con disco y perno
  [-1, 1].forEach(d => {
    const orejera = caja(0.22, 0.46, 0.46, 0.08, mVivo);
    orejera.position.set(d * 1.02, -0.06, 0);
    cabeza.add(orejera);
    const disco = cil(0.14, 0.09, mMetal);
    disco.rotation.z = Math.PI / 2;
    disco.position.set(d * 1.16, -0.06, 0);
    cabeza.add(disco);
    const perno = cil(0.05, 0.08, mVivo);
    perno.rotation.z = Math.PI / 2;
    perno.position.set(d * 1.22, -0.06, 0);
    cabeza.add(perno);
  });

  // Líneas de panel del casco
  cabeza.add(linea(1.5, 0.035, 0, 0.54, 0.5));
  [-1, 1].forEach(d => {
    const l = new THREE.Mesh(new THREE.BoxGeometry(0.03, 0.8, 0.5), mMetal);
    l.position.set(d * 0.86, 0, 0);
    cabeza.add(l);
  });

  // Cuello articulado
  const cuello = cil(0.26, 0.24, mMetal);
  cuello.position.y = -0.78;
  cabeza.add(cuello);
  const anillo = new THREE.Mesh(
    new THREE.TorusGeometry(0.3, 0.04, 8, Math.round(20 * seg)), mVivo);
  anillo.position.y = -0.78;
  anillo.rotation.x = Math.PI / 2;
  cabeza.add(anillo);

  /* ================= BROTE ================= */
  const brote = new THREE.Group();
  brote.position.y = 0.72;
  cabeza.add(brote);

  const maceta = new THREE.Mesh(
    new THREE.CylinderGeometry(0.13, 0.17, 0.14, Math.round(16 * seg)), mVivo);
  conBorde(maceta, 0.035);
  maceta.position.y = 0.02;
  brote.add(maceta);

  const tallo = new THREE.Mesh(new THREE.TubeGeometry(
    new THREE.CatmullRomCurve3([
      new THREE.Vector3(0, 0.06, 0), new THREE.Vector3(0.05, 0.34, 0.02),
      new THREE.Vector3(-0.02, 0.6, 0)]), 16, 0.045, 7, false), mBrote);
  conBorde(tallo, 0.03);
  brote.add(tallo);

  const hoja = (lado, alt) => {
    const f = new THREE.Shape();
    f.moveTo(0, 0);
    f.bezierCurveTo(0.18, 0.12, 0.38, 0.34, 0.5, 0.62);
    f.bezierCurveTo(0.22, 0.55, 0.05, 0.32, 0, 0);
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(f, {
      depth: 0.05, bevelEnabled: true, bevelSize: 0.02, bevelThickness: 0.02, bevelSegments: 2
    }), mBrote);
    conBorde(m, 0.03);
    m.scale.x = lado;
    m.position.set(lado * 0.03, alt, -0.028);
    m.rotation.z = lado * -0.34;
    return m;
  };
  const hojaIzq = hoja(-1, 0.32), hojaDer = hoja(1, 0.48);
  brote.add(hojaIzq, hojaDer);

  const punta = bola(0.05, emisivo(0x7FFFD8, 2.4));
  punta.position.set(-0.02, 0.62, 0);
  brote.add(punta);

  /* ================= ENCUADRE ================= */
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

  /* ================= MOVIMIENTO ================= */
  const escenaEl = host.closest('.escena') || document.body;
  const meta = { x: 0, y: 0 };
  const act = { x: 0, y: 0 };

  addEventListener('pointermove', e => {
    meta.x = ((e.clientX / innerWidth) - 0.5) * 2 * LIMITE_X;
    meta.y = ((e.clientY / innerHeight) - 0.5) * 2 * LIMITE_Y;
  }, { passive: true });

  const caja3D = host.closest('.robot-caja');
  let avance = 0, rxPrev = -1;

  /* Se mide dentro del bucle de render, no en el evento `scroll`: va
     sincronizado con el cuadro y no depende de que el navegador entregue
     eventos, que puede omitir bajo carga. */
  const medirAvance = () => {
    const r = escenaEl.getBoundingClientRect();
    avance = Math.min(1, Math.max(0, -r.top / Math.max(r.height - innerHeight, 1)));
    if (!caja3D || !alta) return;
    const suave = avance < .5 ? 2 * avance * avance : 1 - Math.pow(-2 * avance + 2, 2) / 2;
    const rx = 4 + suave * 11;
    if (Math.abs(rx - rxPrev) > 0.05) {
      caja3D.style.setProperty('--rx', rx.toFixed(2) + '%');
      caja3D.style.setProperty('--rs', (1 - suave * 0.14).toFixed(3));
      rxPrev = rx;
    }
  };
  medirAvance();

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
    medirAvance();

    act.x += (meta.x - act.x) * INERCIA;
    act.y += (meta.y - act.y) * INERCIA;

    cabeza.rotation.y = act.x;
    cabeza.rotation.x = act.y;
    cabeza.rotation.z = act.x * -0.14;
    cuerpo.rotation.y = act.x * 0.2;

    avanceSuave += (avance - avanceSuave) * 0.09;
    const resp = Math.sin(t * 0.9) * 0.035;
    raiz.position.y = resp;
    raiz.rotation.x = avanceSuave * 0.1;
    raiz.rotation.y = avanceSuave * -0.28;
    cabeza.position.y = 0.72 + resp * 0.5;

    if (t > proxParpadeo) {
      const p = (t - proxParpadeo) / 0.13;
      const s = p < 1 ? Math.abs(Math.sin(p * Math.PI)) : 0;
      ojos.forEach(o => o.scale.y = 1 - s * 0.92);
      if (p >= 1) { proxParpadeo = t + 2.4 + Math.random() * 3.4; ojos.forEach(o => o.scale.y = 1); }
    }

    leds.forEach((l, i) => {
      l.material.emissiveIntensity = 1.1 + Math.abs(Math.sin(t * 1.6 + i * 0.8)) * 1.6;
    });
    punta.material.emissiveIntensity = 1.6 + Math.abs(Math.sin(t * 1.2)) * 1.4;

    engrane.rotation.z = -t * 0.5;
    brote.rotation.z = Math.sin(t * 1.1) * 0.1;
    hojaIzq.rotation.z = -0.34 + Math.sin(t * 1.5) * 0.14;
    hojaDer.rotation.z = 0.34 + Math.sin(t * 1.5 + 0.9) * 0.14;
    brazoIzq.rotation.z = -0.1 + Math.sin(t * 0.8) * 0.04;
    brazoDer.rotation.z = 0.1 - Math.sin(t * 0.8) * 0.04;

    render.render(escena, camara);
  }
  bucle();
}
