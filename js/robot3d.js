/* ============================================================
   CULTIVATEC — La mascota, en 3D

   Reconstrucción del dibujo original: cabeza cuadrada redondeada con la
   cara enmarcada, brote de dos hojas arriba, panza con engrane y pistas
   de circuito, brazos delgados curvos con pinza en C y piernas cortas.

   Se arma con primitivas, no con una malla importada, por dos motivos:
   la cabeza necesita ser su propio grupo para girar sola hacia el cursor,
   y el contorno oscuro se consigue clonando cada pieza algo más grande
   con las caras traseras y material sin luz — el mismo truco de casco
   invertido que usan las series animadas.

   Jerarquía:
     raiz
      ├ cuerpo   (panza, engrane, brazos, piernas)   — casi quieto
      └ cabeza   (casco, cara, orejas)               — sigue al cursor
          └ brote (tallo y hojas)                    — se mece
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

const CUERPO = 0x9CC7F2;   // azul del dibujo
const CARA   = 0xBFDCFA;   // el panel de la cara, un tono más claro
const TINTA  = 0x16345C;   // contorno y facciones
const VERDE  = 0x6FBF73;   // hojas del brote

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
  const pintura = c => new THREE.MeshStandardMaterial({ color: c, roughness: 0.45, metalness: 0.04 });
  const mCuerpo = pintura(CUERPO);
  const mCara   = pintura(CARA);
  const mTinta  = new THREE.MeshStandardMaterial({ color: TINTA, roughness: 0.4, metalness: 0.15 });
  const mVerde  = pintura(VERDE);
  const mBorde  = new THREE.MeshBasicMaterial({ color: TINTA, side: THREE.BackSide });
  const mBrillo = new THREE.MeshBasicMaterial({ color: 0xffffff });
  const emisivo = (c, i) => new THREE.MeshStandardMaterial({
    color: c, emissive: c, emissiveIntensity: i, roughness: 0.2, metalness: 0
  });
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
  const caja = (w, h, d, r = 0.08, mat = mCuerpo, borde = true) => {
    const m = new THREE.Mesh(new RoundedBoxGeometry(w, h, d, alta ? 5 : 3, r), mat);
    return borde ? conBorde(m) : m;
  };
  const bola = (r, mat = mTinta) =>
    new THREE.Mesh(new THREE.SphereGeometry(r, Math.round(22 * seg), Math.round(16 * seg)), mat);
  const cil = (r, h, mat = mTinta) =>
    new THREE.Mesh(new THREE.CylinderGeometry(r, r, h, Math.round(18 * seg)), mat);
  /* Pista de circuito: una barrita fina pegada a la superficie */
  const pista = (w, h, x, y, z, giro = 0) => {
    const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, 0.02), mTinta);
    m.position.set(x, y, z);
    m.rotation.z = giro;
    return m;
  };

  /* ---------- escena ---------- */
  const escena = new THREE.Scene();
  const camara = new THREE.PerspectiveCamera(30, 1, 0.1, 100);

  const render = new THREE.WebGLRenderer({ antialias: alta, alpha: true });
  render.setPixelRatio(Math.min(devicePixelRatio, alta ? 2 : 1.5));
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping;
  render.toneMappingExposure = 1.06;
  host.appendChild(render.domElement);

  escena.add(new THREE.HemisphereLight(0xffffff, 0x86ADDE, 2.2));
  const clave = new THREE.DirectionalLight(0xffffff, 1.9);
  clave.position.set(2.6, 3.6, 4.4); escena.add(clave);
  const contra = new THREE.DirectionalLight(0x2563eb, 2.2);
  contra.position.set(-3.6, 1.0, -2.4); escena.add(contra);
  const relleno = new THREE.DirectionalLight(0x9BD4FF, 1.2);
  relleno.position.set(-1.6, -2.2, 2.6); escena.add(relleno);

  const raiz = new THREE.Group();
  escena.add(raiz);

  /* ================= CUERPO ================= */
  const cuerpo = new THREE.Group();
  raiz.add(cuerpo);

  const panza = caja(1.38, 1.32, 1.0, 0.28, mCuerpo);
  panza.position.y = -0.42;
  cuerpo.add(panza);

  // Engrane del pecho, como en el dibujo
  const engrane = new THREE.Group();
  engrane.position.set(0, -0.42, 0.5);
  cuerpo.add(engrane);
  engrane.add(new THREE.Mesh(
    new THREE.TorusGeometry(0.15, 0.055, 9, Math.round(24 * seg)), mTinta));
  engrane.add(bola(0.055, mCara));
  for (let i = 0; i < 8; i++) {
    const d = new THREE.Mesh(new RoundedBoxGeometry(0.075, 0.075, 0.075, 2, 0.026), mTinta);
    const a = (i / 8) * Math.PI * 2;
    d.position.set(Math.cos(a) * 0.19, Math.sin(a) * 0.19, 0);
    d.rotation.z = a;
    engrane.add(d);
  }

  // Pistas de circuito saliendo del engrane
  const nodos = [];
  const trazas = [
    [0.30, 0.035, -0.42, 0.16, 0], [0.035, 0.24, -0.55, 0.26, 0],
    [0.30, 0.035, 0.42, 0.16, 0], [0.035, 0.20, 0.55, 0.24, 0],
    [0.26, 0.035, -0.40, -0.30, 0], [0.035, 0.22, -0.51, -0.40, 0],
    [0.34, 0.035, 0.40, -0.34, 0], [0.035, 0.18, 0.55, -0.42, 0]
  ];
  trazas.forEach(([w, h, x, y, g]) => cuerpo.add(pista(w, h, x, -0.42 + y, 0.49, g)));
  [[-0.55, 0.38], [0.55, 0.34], [-0.51, -0.51], [0.55, -0.51]].forEach(([x, y]) => {
    const n = bola(0.06, mTinta);
    n.position.set(x, -0.42 + y, 0.5);
    cuerpo.add(n);
  });

  // Tres luces de estado en la parte baja de la panza
  const leds = [];
  [[-0.2, mLedA], [0, mLedB], [0.2, mLedC]].forEach(([x, m]) => {
    const l = bola(0.05, m);
    l.position.set(x, -0.92, 0.5);
    cuerpo.add(l); leds.push(l);
  });

  // Cuello corto
  const cuello = cil(0.26, 0.22, mCuerpo);
  conBorde(cuello, 0.04);
  cuello.position.y = 0.3;
  cuerpo.add(cuello);

  /* --- Brazos: tubo curvo con pinza en C, como los del dibujo --- */
  const brazo = lado => {
    const g = new THREE.Group();

    const curva = new THREE.CatmullRomCurve3([
      new THREE.Vector3(0, 0.04, 0),
      new THREE.Vector3(lado * 0.26, -0.32, 0.03),
      new THREE.Vector3(lado * 0.38, -0.72, 0.02),
      new THREE.Vector3(lado * 0.28, -1.02, 0)
    ]);
    const tubo = new THREE.Mesh(
      new THREE.TubeGeometry(curva, Math.round(24 * seg), 0.125, Math.round(10 * seg), false), mCuerpo);
    conBorde(tubo, 0.042);
    g.add(tubo);

    const hombro = bola(0.16, mCuerpo);
    conBorde(hombro, 0.042);
    hombro.position.y = 0.04;
    g.add(hombro);

    const pinza = new THREE.Mesh(
      new THREE.TorusGeometry(0.145, 0.058, 8, Math.round(22 * seg), Math.PI * 1.35), mCuerpo);
    conBorde(pinza, 0.04);
    pinza.position.set(lado * 0.28, -1.16, 0);
    pinza.rotation.z = lado > 0 ? -0.55 : Math.PI + 0.55;
    g.add(pinza);

    g.position.set(lado * 0.6, -0.16, 0.02);
    return g;
  };
  const brazoIzq = brazo(-1), brazoDer = brazo(1);
  cuerpo.add(brazoIzq, brazoDer);

  /* --- Piernas cortas con pies redondeados --- */
  const pies = [];
  [-1, 1].forEach(d => {
    const pierna = caja(0.36, 0.44, 0.42, 0.16, mCuerpo);
    pierna.position.set(d * 0.3, -1.3, 0);
    cuerpo.add(pierna);

    const pie = caja(0.46, 0.26, 0.54, 0.12, mCuerpo);
    pie.position.set(d * 0.3, -1.6, 0.07);
    cuerpo.add(pie);
    pies.push(pie);
  });

  /* ================= CABEZA ================= */
  const cabeza = new THREE.Group();
  cabeza.position.y = 1.0;
  raiz.add(cabeza);

  const casco = caja(1.9, 1.5, 1.1, 0.3, mCuerpo);
  cabeza.add(casco);

  /* La cara del dibujo no es una pantalla oscura sino un recuadro con
     borde: se consigue con una placa de tinta y encima otra más clara y
     algo menor, que deja el borde a la vista. */
  const marco = caja(1.4, 1.0, 0.07, 0.26, mTinta, false);
  marco.position.set(0, 0.02, 0.52);
  cabeza.add(marco);
  const cara = caja(1.26, 0.86, 0.08, 0.21, mCara, false);
  cara.position.set(0, 0.02, 0.55);
  cabeza.add(cara);

  // Ojos sencillos, oscuros, con un punto de luz
  const ojos = [];
  [-1, 1].forEach(d => {
    const o = bola(0.115, mTinta);
    o.scale.set(0.88, 1, 0.45);
    o.position.set(d * 0.29, 0.13, 0.6);
    cabeza.add(o); ojos.push(o);

    const b = new THREE.Mesh(new THREE.SphereGeometry(0.036, 10, 8), mBrillo);
    b.scale.z = 0.4;
    b.position.set(d * 0.29 - 0.035, 0.175, 0.65);
    cabeza.add(b);
  });

  const sonrisa = new THREE.Mesh(
    new THREE.TorusGeometry(0.17, 0.034, 8, Math.round(22 * seg), Math.PI * 0.85), mTinta);
  sonrisa.position.set(0, -0.13, 0.6);
  sonrisa.rotation.z = Math.PI + Math.PI * 0.075;
  cabeza.add(sonrisa);

  // Orejas: dos tabiques pequeños a los lados, igual que en el dibujo
  [-1, 1].forEach(d => {
    const oreja = caja(0.17, 0.42, 0.42, 0.08, mCuerpo);
    oreja.position.set(d * 0.99, -0.05, 0);
    cabeza.add(oreja);
  });

  /* ================= BROTE ================= */
  const brote = new THREE.Group();
  brote.position.y = 0.74;
  cabeza.add(brote);

  const tallo = new THREE.Mesh(new THREE.TubeGeometry(
    new THREE.CatmullRomCurve3([
      new THREE.Vector3(0, 0, 0), new THREE.Vector3(0.04, 0.3, 0.02),
      new THREE.Vector3(-0.01, 0.58, 0)]),
    Math.round(16 * seg), 0.042, Math.round(8 * seg), false), mVerde);
  conBorde(tallo, 0.032);
  brote.add(tallo);

  const hoja = (lado, alt) => {
    const f = new THREE.Shape();
    f.moveTo(0, 0);
    f.bezierCurveTo(0.2, 0.14, 0.42, 0.34, 0.54, 0.6);
    f.bezierCurveTo(0.24, 0.54, 0.06, 0.3, 0, 0);
    const m = new THREE.Mesh(new THREE.ExtrudeGeometry(f, {
      depth: 0.05, bevelEnabled: true, bevelSize: 0.022, bevelThickness: 0.022, bevelSegments: 2
    }), mVerde);
    conBorde(m, 0.032);
    m.scale.x = lado;
    m.position.set(lado * 0.03, alt, -0.028);
    m.rotation.z = lado * -0.3;
    return m;
  };
  const hojaIzq = hoja(-1, 0.3), hojaDer = hoja(1, 0.44);
  brote.add(hojaIzq, hojaDer);

  /* ================= ENCUADRE =================
     En vez de una distancia fija, se calcula la que hace falta para que
     quepa el encuadre pedido, sea cual sea la forma del hueco: así el
     robot no se corta en un lienzo estrecho ni queda diminuto en uno ancho.

       lejos → el robot entero    (de y=-1.77 a y=2.70, ancho ±1.24)
       cerca → cabeza y hombros   (de y= 0.25 a y=2.70)
  */
  const TAN = Math.tan(15 * Math.PI / 180);   // media apertura de 30°
  const enfoque = (medioAlto, medioAncho) =>
    Math.max(medioAlto, medioAncho / camara.aspect) / TAN;

  const MIRA_LEJOS = 0.42, MIRA_CERCA = 1.48;
  let zLejos = 9, zCerca = 6;
  const encuadrar = () => {
    const a = host.clientWidth, b = host.clientHeight || a;
    if (!a || !b) return;
    camara.aspect = a / b;
    zLejos = enfoque(2.45, 1.35);
    zCerca = enfoque(1.42, 1.32);
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

  /* En el teléfono no hay cursor: la cabeza sigue la inclinación del
     aparato. El punto neutro es la postura con la que se empezó a leer y
     va corrigiéndose muy despacio, para que quien lea recostado no se
     encuentre la cabeza clavada en el tope. */
  if (matchMedia('(pointer: coarse)').matches && typeof DeviceOrientationEvent !== 'undefined') {
    let cero = null;
    addEventListener('deviceorientation', e => {
      if (e.beta == null && e.gamma == null) return;
      let lado = e.gamma || 0, frente = e.beta || 0;
      const giro = (screen.orientation && screen.orientation.angle) || 0;
      if (giro === 90)  { const t = lado; lado = -frente; frente = t; }
      if (giro === 270) { const t = lado; lado = frente;  frente = -t; }
      if (!cero) cero = { lado, frente };
      else {
        cero.lado   += (lado   - cero.lado)   * 0.0018;
        cero.frente += (frente - cero.frente) * 0.0018;
      }
      meta.x = tope((lado   - cero.lado)   / 26, 1) * LIMITE_X;
      meta.y = tope((frente - cero.frente) / 30, 1) * LIMITE_Y;
    }, { passive: true });

    // iOS solo entrega la lectura si se pide permiso dentro de un gesto
    if (typeof DeviceOrientationEvent.requestPermission === 'function') {
      addEventListener('pointerdown', () => {
        DeviceOrientationEvent.requestPermission().catch(() => {});
      }, { once: true, passive: true });
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
    cabeza.position.y = 1.0 + resp * 0.5;

    /* La cámara se acerca a la cara conforme baja el scroll: al final
       encuadra cabeza y hombros, en vez de cortar al robot a media pierna. */
    const mira = MIRA_LEJOS + (MIRA_CERCA - MIRA_LEJOS) * avanceSuave;
    camara.position.set(0, mira + 0.05, zLejos + (zCerca - zLejos) * avanceSuave);
    camara.lookAt(0, mira, 0);

    if (t > proxParpadeo) {
      const p = (t - proxParpadeo) / 0.13;
      const s = p < 1 ? Math.abs(Math.sin(p * Math.PI)) : 0;
      ojos.forEach(o => o.scale.y = 1 - s * 0.92);
      if (p >= 1) { proxParpadeo = t + 2.4 + Math.random() * 3.4; ojos.forEach(o => o.scale.y = 1); }
    }

    leds.forEach((l, i) => {
      l.material.emissiveIntensity = 1.1 + Math.abs(Math.sin(t * 1.6 + i * 0.8)) * 1.6;
    });

    engrane.rotation.z = -t * 0.5;
    brote.rotation.z = Math.sin(t * 1.1) * 0.1;
    hojaIzq.rotation.z = -0.3 + Math.sin(t * 1.5) * 0.13;
    hojaDer.rotation.z = 0.3 + Math.sin(t * 1.5 + 0.9) * 0.13;
    brazoIzq.rotation.z = Math.sin(t * 0.8) * 0.05;
    brazoDer.rotation.z = -Math.sin(t * 0.8) * 0.05;
    pies.forEach((p, i) => { p.position.y = -1.6 + Math.sin(t * 0.9 + i * 0.6) * 0.02; });

    render.render(escena, camara);
  }
  bucle();
}
