/* ============================================================
   CULTIVATEC — Mascota en 3D

   Traducción a volumen del dibujo de la mascota: cabeza de esquinas
   redondeadas con la muesca y el brote arriba, cara de dos puntos y una
   sonrisa, torso con el circuito y el engrane, brazos de tubo con la mano
   en gancho y piernas cortas. Nada de pantalla ni de placas de blindaje:
   el original es plano y limpio.

   Se construye con primitivas para poder separar la cabeza en su propio
   grupo — así gira sola hacia el cursor, cosa imposible con una malla
   fusionada — y el contorno es un clon de cada pieza, algo mayor, con las
   caras traseras y material sin luz.

   Jerarquía:
     raiz
      ├ cuerpo   (torso, circuito, brazos, piernas)   — quieto
      └ cabeza   (casco, cara, orejas)                — sigue al cursor
          └ brote (tallo y hojas)                     — se mece
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

const CLARO  = 0xB7D8F5;   // cabeza y torso
const CUERPO = 0x93C0EA;   // extremidades, un punto más hondo
const TINTA  = 0x123A63;   // contorno, cara y circuito
const HOJA   = 0x74C043;

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

  /* ---------- materiales ----------
     Poco brillo y nada de metal: el dibujo es plano, y un plástico
     lustroso lo alejaría del original. */
  const pintura = c => new THREE.MeshStandardMaterial({ color: c, roughness: 0.62, metalness: 0 });
  const mClaro  = pintura(CLARO);
  const mCuerpo = pintura(CUERPO);
  const mTinta  = pintura(TINTA);
  const mHoja   = pintura(HOJA);
  const mBorde  = new THREE.MeshBasicMaterial({ color: TINTA, side: THREE.BackSide });

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
  const bola = (r, mat = mClaro) =>
    new THREE.Mesh(new THREE.SphereGeometry(r, Math.round(22 * seg), Math.round(16 * seg)), mat);
  const cil = (r, h, mat = mClaro) =>
    new THREE.Mesh(new THREE.CylinderGeometry(r, r, h, Math.round(18 * seg)), mat);

  /* Tubo con su contorno. Aquí no sirve el clon a escala: en una pieza
     alargada el escalado uniforme la estira a lo largo en vez de
     engordarla, así que el borde es un segundo tubo más gordo. */
  const tubo = (puntos, r, mat, grosor = 0.045) => {
    const curva = new THREE.CatmullRomCurve3(puntos.map(p => new THREE.Vector3(...p)));
    const tramos = Math.round(26 * seg), lados = Math.round(10 * seg);
    const g = new THREE.Group();
    g.add(new THREE.Mesh(new THREE.TubeGeometry(curva, tramos, r, lados, false), mat));
    g.add(new THREE.Mesh(new THREE.TubeGeometry(curva, tramos, r + grosor, lados, false), mBorde));
    return g;
  };

  /* Pista del circuito: barrita fina pegada a la cara del torso */
  const pista = (x1, y1, x2, y2, z) => {
    const m = new THREE.Mesh(
      new THREE.BoxGeometry(Math.abs(x2 - x1) + 0.05, Math.abs(y2 - y1) + 0.05, 0.03), mTinta);
    m.position.set((x1 + x2) / 2, (y1 + y2) / 2, z);
    return m;
  };
  const punto = (x, y, z, r = 0.055) => {
    const m = cil(r, 0.03, mTinta);
    m.rotation.x = Math.PI / 2;
    m.position.set(x, y, z);
    return m;
  };

  /* ---------- escena ---------- */
  const escena = new THREE.Scene();
  const camara = new THREE.PerspectiveCamera(30, 1, 0.1, 100);

  const render = new THREE.WebGLRenderer({ antialias: alta, alpha: true });
  render.setPixelRatio(Math.min(devicePixelRatio, alta ? 2 : 1.5));
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping;
  render.toneMappingExposure = 1.02;
  host.appendChild(render.domElement);

  escena.add(new THREE.HemisphereLight(0xffffff, 0x8FB4E4, 2.4));
  const clave = new THREE.DirectionalLight(0xffffff, 1.7);
  clave.position.set(2.4, 3.4, 4.6); escena.add(clave);
  const contra = new THREE.DirectionalLight(0x2563eb, 1.6);
  contra.position.set(-3.6, 1.0, -2.4); escena.add(contra);
  const relleno = new THREE.DirectionalLight(0xBFE0FF, 1.1);
  relleno.position.set(-1.8, -2.0, 2.6); escena.add(relleno);

  const raiz = new THREE.Group();
  escena.add(raiz);

  /* ================= CUERPO ================= */
  const cuerpo = new THREE.Group();
  raiz.add(cuerpo);

  const torso = caja(1.36, 1.26, 1.0, 0.26, mClaro);
  cuerpo.add(torso);

  const cuello = cil(0.22, 0.24, mCuerpo);
  conBorde(cuello, 0.045);
  cuello.position.y = 0.66;
  cuerpo.add(cuello);

  /* --- Circuito del pecho --- */
  const FZ = 0.5;                       // cara delantera del torso
  const engrane = new THREE.Group();
  engrane.position.set(0, 0.04, FZ + 0.03);
  cuerpo.add(engrane);
  engrane.add(new THREE.Mesh(
    new THREE.TorusGeometry(0.14, 0.05, 9, Math.round(24 * seg)), mTinta));
  for (let i = 0; i < 8; i++) {
    const d = new THREE.Mesh(new THREE.BoxGeometry(0.075, 0.07, 0.07), mTinta);
    const a = (i / 8) * Math.PI * 2;
    d.position.set(Math.cos(a) * 0.185, Math.sin(a) * 0.185, 0);
    d.rotation.z = a;
    engrane.add(d);
  }

  const ZC = FZ + 0.01;
  [ // tramo horizontal, tramo vertical y remate de cada pista
    [[-0.5, 0.04, -0.2, 0.04], [-0.5, 0.04, -0.5, 0.32], [-0.5, 0.36]],
    [[0.2, 0.04, 0.5, 0.04], [0.5, 0.04, 0.5, -0.26], [0.5, -0.3]],
    [[-0.34, -0.3, -0.04, -0.3], [-0.04, -0.3, -0.04, -0.12], [-0.38, -0.3]],
    [[0.06, 0.42, 0.34, 0.42], [0.06, 0.2, 0.06, 0.42], [0.38, 0.42]]
  ].forEach(([h, v, p]) => {
    cuerpo.add(pista(h[0], h[1], h[2], h[3], ZC));
    cuerpo.add(pista(v[0], v[1], v[2], v[3], ZC));
    cuerpo.add(punto(p[0], p[1], ZC + 0.01));
  });
  cuerpo.add(punto(-0.28, 0.46, ZC + 0.01, 0.045));
  cuerpo.add(pista(-0.28, 0.2, -0.28, 0.46, ZC));

  /* --- Brazos: tubo que sale, baja y termina en gancho abierto --- */
  const brazo = lado => {
    const g = new THREE.Group();
    g.add(tubo([[0, 0, 0], [lado * 0.3, -0.34, 0], [lado * 0.34, -0.86, 0]], 0.085, mCuerpo));
    const hombro = bola(0.14, mCuerpo);
    conBorde(hombro, 0.045);
    g.add(hombro);

    // Mano en gancho: aro incompleto, con la abertura hacia afuera y abajo
    const mano = new THREE.Group();
    mano.position.set(lado * 0.34, -0.98, 0);
    const aro = (grueso, mat) => new THREE.Mesh(
      new THREE.TorusGeometry(0.15, grueso, 8, Math.round(24 * seg), Math.PI * 1.45), mat);
    mano.add(aro(0.075, mCuerpo));
    mano.add(aro(0.12, mBorde));   // mismo radio de aro, tubo más gordo
    mano.rotation.z = lado * -0.5 + Math.PI * 0.15;
    g.add(mano);

    g.position.set(lado * 0.62, 0.42, 0.06);
    return g;
  };
  const brazoIzq = brazo(-1), brazoDer = brazo(1);
  cuerpo.add(brazoIzq, brazoDer);

  /* --- Piernas cortas --- */
  const piernas = [];
  [-1, 1].forEach(d => {
    const g = new THREE.Group();
    g.position.set(d * 0.32, -0.6, 0);

    const pierna = caja(0.38, 0.58, 0.44, 0.16, mCuerpo);
    pierna.position.y = -0.27;
    g.add(pierna);

    const pie = caja(0.44, 0.22, 0.56, 0.1, mCuerpo);
    pie.position.set(0, -0.6, 0.05);
    g.add(pie);

    cuerpo.add(g);
    piernas.push(g);
  });

  /* ================= CABEZA ================= */
  const cabeza = new THREE.Group();
  cabeza.position.y = 1.36;
  raiz.add(cabeza);

  const casco = caja(1.84, 1.42, 1.12, 0.3, mClaro);
  cabeza.add(casco);

  // Muesca del dibujo: la ranura por donde asoma el brote
  const muesca = caja(0.4, 0.16, 0.42, 0.05, mTinta, false);
  muesca.position.y = 0.66;
  cabeza.add(muesca);

  // Cara: dos puntos y una sonrisa, directamente sobre la chapa
  const CZ = 0.56;
  const ojos = [];
  [-1, 1].forEach(d => {
    const o = bola(0.105, mTinta);
    o.scale.z = 0.5;
    o.position.set(d * 0.31, 0.08, CZ);
    cabeza.add(o); ojos.push(o);
  });
  const sonrisa = new THREE.Mesh(
    new THREE.TorusGeometry(0.2, 0.035, 8, Math.round(22 * seg), Math.PI * 0.86), mTinta);
  sonrisa.position.set(0, -0.14, CZ);
  sonrisa.rotation.z = Math.PI + Math.PI * 0.07;
  cabeza.add(sonrisa);

  // Orejas rectangulares, como en el dibujo
  [-1, 1].forEach(d => {
    const oreja = caja(0.2, 0.46, 0.44, 0.08, mCuerpo);
    oreja.position.set(d * 0.96, -0.06, 0);
    cabeza.add(oreja);
  });

  /* ================= BROTE ================= */
  const brote = new THREE.Group();
  brote.position.y = 0.7;
  cabeza.add(brote);

  brote.add(tubo([[0, 0, 0], [0.04, 0.26, 0.01], [-0.02, 0.5, 0]], 0.045, mHoja, 0.035));

  const hoja = (lado, alt) => {
    const f = new THREE.Shape();
    f.moveTo(0, 0);
    f.bezierCurveTo(0.2, 0.1, 0.42, 0.3, 0.5, 0.56);
    f.bezierCurveTo(0.2, 0.5, 0.05, 0.28, 0, 0);
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(f, {
      depth: 0.05, bevelEnabled: true, bevelSize: 0.02, bevelThickness: 0.02, bevelSegments: 2
    }), mHoja);
    conBorde(m, 0.03);
    m.scale.set(lado * 0.92, 0.92, 1);
    m.position.set(lado * 0.03, alt, -0.028);
    m.rotation.z = lado * -0.42;
    return m;
  };
  const hojaIzq = hoja(-1, 0.3), hojaDer = hoja(1, 0.38);
  brote.add(hojaIzq, hojaDer);

  /* ================= ENCUADRE =================
     En vez de una distancia fija se calcula la que hace falta para el
     encuadre pedido, sea cual sea la forma del hueco: así el robot no se
     corta en un lienzo estrecho ni queda diminuto en uno ancho.

       lejos → el robot entero    (de y=-1.32 a y=2.88, ancho ±1.18)
       cerca → cabeza y hombros   (de y= 0.30 a y=2.88)
  */
  const TAN = Math.tan(15 * Math.PI / 180);   // media apertura de 30°
  const enfoque = (medioAlto, medioAncho) =>
    Math.max(medioAlto, medioAncho / camara.aspect) / TAN;

  const MIRA_LEJOS = 0.78, MIRA_CERCA = 1.6;
  let zLejos = 9, zCerca = 6;
  const encuadrar = () => {
    const a = host.clientWidth, b = host.clientHeight || a;
    if (!a || !b) return;
    camara.aspect = a / b;
    zLejos = enfoque(2.3, 1.3);
    zCerca = enfoque(1.42, 1.28);
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
  const tope = (v, l) => Math.max(-l, Math.min(l, v));

  addEventListener('pointermove', e => {
    meta.x = ((e.clientX / innerWidth) - 0.5) * 2 * LIMITE_X;
    meta.y = ((e.clientY / innerHeight) - 0.5) * 2 * LIMITE_Y;
  }, { passive: true });

  /* En pantalla táctil no hay cursor al que mirar: la cabeza sigue la
     inclinación del aparato, como un cabezón sobre el salpicadero. El
     reposo es la postura en la que se recibió la primera lectura, y va
     corrigiéndose muy despacio para no quedarse trabado si cambia la
     forma de sostener el teléfono. */
  const sinRaton = matchMedia('(pointer: coarse)').matches || matchMedia('(hover: none)').matches;
  if (sinRaton && 'DeviceOrientationEvent' in window) {
    let reposo = null;

    const alInclinar = e => {
      if (e.beta == null && e.gamma == null) return;
      let lado = e.gamma || 0, frente = e.beta || 0;
      const giro = (screen.orientation && screen.orientation.angle) || 0;
      if (giro === 90)  { const t = lado; lado = -frente; frente = t; }
      if (giro === 270) { const t = lado; lado = frente;  frente = -t; }
      if (giro === 180) { lado = -lado; frente = -frente; }

      if (!reposo) reposo = { lado, frente };
      else {
        reposo.lado   += (lado   - reposo.lado)   * 0.0016;
        reposo.frente += (frente - reposo.frente) * 0.0016;
      }
      meta.x = tope((lado - reposo.lado) / 26, 1) * LIMITE_X;
      meta.y = tope((frente - reposo.frente) / 30, 1) * LIMITE_Y;
    };

    // iOS exige pedir permiso, y solo dentro de un gesto del usuario
    if (typeof DeviceOrientationEvent.requestPermission === 'function') {
      addEventListener('pointerdown', () => {
        DeviceOrientationEvent.requestPermission()
          .then(r => { if (r === 'granted') addEventListener('deviceorientation', alInclinar, { passive: true }); })
          .catch(() => {});
      }, { once: true, passive: true });
    } else {
      addEventListener('deviceorientation', alInclinar, { passive: true });
    }
  }

  const caja3D = host.closest('.robot-caja');
  let avance = 0, rxPrev = -1;

  /* Se mide dentro del bucle de render, no en el evento `scroll`: va
     sincronizado con el cuadro y no depende de que el navegador entregue
     eventos, que puede omitir bajo carga. */
  const medirAvance = () => {
    if (!caja3D) { avance = 0; return; }
    const r = escenaEl.getBoundingClientRect();
    avance = Math.min(1, Math.max(0, -r.top / Math.max(r.height - innerHeight, 1)));
    const suave = avance < .5 ? 2 * avance * avance : 1 - Math.pow(-2 * avance + 2, 2) / 2;
    const rx = 4 + suave * 11;
    if (Math.abs(rx - rxPrev) > 0.05) {
      caja3D.style.setProperty('--rx', rx.toFixed(2) + '%');
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
    raiz.rotation.y = avanceSuave * -0.16;
    cabeza.position.y = 1.36 + resp * 0.5;

    /* La cámara se acerca a la cara conforme baja el scroll: al final
       encuadra cabeza y hombros, en vez de cortar al robot por media
       pierna cuando la sección le deja menos sitio. */
    const mira = MIRA_LEJOS + (MIRA_CERCA - MIRA_LEJOS) * avanceSuave;
    camara.position.set(0, mira + 0.05, zLejos + (zCerca - zLejos) * avanceSuave);
    camara.lookAt(0, mira, 0);

    if (t > proxParpadeo) {
      const p = (t - proxParpadeo) / 0.13;
      const s = p < 1 ? Math.abs(Math.sin(p * Math.PI)) : 0;
      ojos.forEach(o => o.scale.y = 1 - s * 0.92);
      if (p >= 1) { proxParpadeo = t + 2.4 + Math.random() * 3.4; ojos.forEach(o => o.scale.y = 1); }
    }

    engrane.rotation.z = -t * 0.45;
    brote.rotation.z = Math.sin(t * 1.1) * 0.1;
    hojaIzq.rotation.z = -0.42 + Math.sin(t * 1.5) * 0.13;
    hojaDer.rotation.z = 0.42 + Math.sin(t * 1.5 + 0.9) * 0.13;
    brazoIzq.rotation.z = Math.sin(t * 0.8) * 0.06;
    brazoDer.rotation.z = -Math.sin(t * 0.8) * 0.06;
    piernas.forEach((p, i) => { p.position.y = -0.6 + Math.sin(t * 0.9 + i * 0.6) * 0.015; });

    render.render(escena, camara);
  }
  bucle();
}
