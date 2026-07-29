/* ============================================================
   CULTIVATEC — Mascota en 3D

   Construida con primitivas para poder separar la cabeza en su propio
   grupo: así gira sola hacia el cursor, cosa imposible con una malla
   fusionada.

   La lectura de "mascota" y no de "maqueta" viene de tres cosas:
   proporción de peluche (la cabeza mide casi lo mismo que el cuerpo),
   todo con radios muy generosos, y el contorno oscuro — un clon de cada
   pieza, algo mayor, con las caras traseras y material sin luz.

   Jerarquía:
     raiz
      ├ cuerpo   (torso, brazos, piernas)      — quieto
      └ cabeza   (casco, cara, orejas)         — sigue al cursor / al giro
          └ brote (tallo y dos hojas)          — se mece
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

const CLARO  = 0xC3DDFA;
const MEDIO  = 0x63A0E8;
const VIVO   = 0x2563EB;
const HONDO  = 0x1B4A96;
const CONTOR = 0x143A72;
const BROTE  = 0x7CC24C;   // verde hoja del dibujo

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
  const pintura = c => new THREE.MeshStandardMaterial({ color: c, roughness: 0.38, metalness: 0.06 });
  const mClaro = pintura(CLARO);
  const mMedio = pintura(MEDIO);
  const mVivo  = pintura(VIVO);
  const mHondo = pintura(HONDO);
  const mMetal = new THREE.MeshStandardMaterial({ color: 0x9FB6D8, roughness: 0.3, metalness: 0.5 });
  const mBrote = pintura(BROTE);
  const mBorde = new THREE.MeshBasicMaterial({ color: CONTOR, side: THREE.BackSide });
  const emisivo = (c, i) => new THREE.MeshStandardMaterial({
    color: c, emissive: c, emissiveIntensity: i, roughness: 0.2, metalness: 0
  });
  const mFaccion = new THREE.MeshStandardMaterial({ color: 0x122E52, roughness: 0.32, metalness: 0.1 });
  const mBrillo = new THREE.MeshBasicMaterial({ color: 0xffffff });
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
    new THREE.Mesh(new THREE.SphereGeometry(r, Math.round(22 * seg), Math.round(16 * seg)), mat);
  const cil = (r, h, mat = mMetal) =>
    new THREE.Mesh(new THREE.CylinderGeometry(r, r, h, Math.round(18 * seg)), mat);

  /* ---------- escena ---------- */
  const escena = new THREE.Scene();
  const camara = new THREE.PerspectiveCamera(30, 1, 0.1, 100);

  const render = new THREE.WebGLRenderer({ antialias: alta, alpha: true });
  render.setPixelRatio(Math.min(devicePixelRatio, alta ? 2 : 1.5));
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping;
  render.toneMappingExposure = 1.05;
  host.appendChild(render.domElement);

  escena.add(new THREE.HemisphereLight(0xffffff, 0x7FA9E0, 2.1));
  const clave = new THREE.DirectionalLight(0xffffff, 2.0);
  clave.position.set(2.6, 3.6, 4.4); escena.add(clave);
  const contra = new THREE.DirectionalLight(0x2563eb, 2.4);
  contra.position.set(-3.6, 1.0, -2.4); escena.add(contra);
  const relleno = new THREE.DirectionalLight(0x7DD3FC, 1.3);
  relleno.position.set(-1.6, -2.2, 2.6); escena.add(relleno);

  const raiz = new THREE.Group();
  escena.add(raiz);

  /* ================= CUERPO =================
     Panza redonda de una sola pieza: los dos bloques y la cintura a la
     vista que tenía antes lo volvían anguloso. */
  const cuerpo = new THREE.Group();
  raiz.add(cuerpo);

  const torso = caja(1.5, 1.3, 1.1, 0.4, mClaro);
  torso.position.y = -0.34;
  cuerpo.add(torso);

  /* Peto: la chapa que aloja el engrane y las pistas. Va algo mayor que
     el dibujo para que ninguna pista se salga a la superficie del torso,
     donde pelearían por el mismo plano. */
  const peto = caja(1.18, 1.0, 0.1, 0.3, mMedio);
  peto.position.set(0, -0.3, 0.5);
  cuerpo.add(peto);

  /* Engrane grande al centro de la panza, la marca del dibujo. Antes era
     un dial pequeño; aquí manda él. */
  const engrane = new THREE.Group();
  engrane.position.set(0, -0.3, 0.6);
  cuerpo.add(engrane);
  const aro = new THREE.Mesh(
    new THREE.TorusGeometry(0.2, 0.07, 10, Math.round(26 * seg)), mVivo);
  conBorde(aro, 0.035);
  engrane.add(aro);
  for (let i = 0; i < 8; i++) {
    const d = new THREE.Mesh(new RoundedBoxGeometry(0.105, 0.11, 0.105, 2, 0.035), mVivo);
    const a = (i / 8) * Math.PI * 2;
    d.position.set(Math.cos(a) * 0.255, Math.sin(a) * 0.255, 0);
    d.rotation.z = a;
    conBorde(d, 0.03);
    engrane.add(d);
  }
  const eje = cil(0.075, 0.12, mHondo);
  eje.rotation.x = Math.PI / 2;
  engrane.add(eje);

  /* Pistas de circuito saliendo del engrane, con sus nodos: es lo que
     hace que la panza se lea como la del dibujo y no como una chapa. */
  const pista = (w, h, x, y) => {
    const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, 0.02), mVivo);
    m.position.set(x, -0.3 + y, 0.57);
    return m;
  };
  [[0.24, 0.045, -0.4, 0.2], [0.045, 0.2, -0.5, 0.29],
   [0.24, 0.045, 0.4, 0.2], [0.045, 0.16, 0.5, 0.27],
   [0.2, 0.045, -0.38, -0.24], [0.045, 0.18, -0.46, -0.32],
   [0.28, 0.045, 0.4, -0.28], [0.045, 0.14, 0.52, -0.34]
  ].forEach(p => cuerpo.add(pista(...p)));
  [[-0.5, 0.38], [0.5, 0.34], [-0.46, -0.41], [0.52, -0.41]].forEach(([x, y]) => {
    const n = bola(0.055, mVivo);
    conBorde(n, 0.028);
    n.position.set(x, -0.3 + y, 0.58);
    cuerpo.add(n);
  });

  // Tres luces de estado bajo la panza
  const leds = [];
  [[-0.2, mLedA], [0, mLedB], [0.2, mLedC]].forEach(([x, m]) => {
    const l = bola(0.05, m);
    l.position.set(x, -0.78, 0.48);
    cuerpo.add(l); leds.push(l);
  });

  // Cuello corto: la cabeza casi se apoya en los hombros
  const cuello = cil(0.3, 0.26, mMetal);
  cuello.position.y = 0.34;
  cuerpo.add(cuello);

  /* --- Brazos cortos y regordetes, rematados en pinza --- */
  const brazo = lado => {
    const g = new THREE.Group();
    g.add(bola(0.19, mMetal));                        // hombro

    const sup = caja(0.36, 0.66, 0.36, 0.17, mClaro);
    sup.position.y = -0.42;
    g.add(sup);

    const muneca = cil(0.115, 0.18, mMedio);
    conBorde(muneca, 0.035);
    muneca.position.y = -0.8;
    g.add(muneca);

    /* Pinza en C. Dos cuidados que antes no estaban:

       El contorno no puede salir de `conBorde`. Escalar un toro entero
       agranda también el radio del anillo, con lo que el borde se mete
       por dentro del hueco en vez de rodear el tubo. Se hace con un
       segundo toro del mismo radio y el tubo más grueso.

       Y el reflejo se hace girando media vuelta sobre Y, no sumando
       Math.PI al giro sobre Z: eso no refleja el arco, lo rota, y por eso
       cada mano apuntaba a un sitio distinto. */
    const n = Math.round(26 * seg), R = 0.175, ARCO = Math.PI * 1.42;
    const pinza = new THREE.Group();
    pinza.add(new THREE.Mesh(new THREE.TorusGeometry(R, 0.075, 9, n, ARCO), mVivo));
    pinza.add(new THREE.Mesh(new THREE.TorusGeometry(R, 0.115, 8, n, ARCO), mBorde));
    pinza.rotation.z = -0.32;      // la abertura mira hacia abajo y afuera

    const mano = new THREE.Group();
    mano.add(pinza);
    mano.position.y = -1.0;
    if (lado < 0) mano.rotation.y = Math.PI;
    g.add(mano);

    g.position.set(lado * 0.9, 0.02, 0.02);
    g.rotation.z = lado * 0.14;
    return g;
  };
  const brazoIzq = brazo(-1), brazoDer = brazo(1);
  cuerpo.add(brazoIzq, brazoDer);

  /* --- Piernas cortas con botitas --- */
  const pies = [];
  [-1, 1].forEach(d => {
    const cadera = bola(0.17, mMetal);
    cadera.position.set(d * 0.36, -0.96, 0);
    cuerpo.add(cadera);

    const pierna = caja(0.42, 0.5, 0.44, 0.19, mMedio);
    pierna.position.set(d * 0.36, -1.28, 0);
    cuerpo.add(pierna);

    const bota = caja(0.52, 0.32, 0.62, 0.15, mVivo);
    bota.position.set(d * 0.36, -1.62, 0.1);
    cuerpo.add(bota);
    pies.push(bota);
  });

  /* ================= CABEZA ================= */
  const cabeza = new THREE.Group();
  cabeza.position.y = 1.02;
  raiz.add(cabeza);

  // Casco muy redondeado: es lo que separa "peluche" de "caja"
  const casco = caja(2.0, 1.62, 1.16, 0.46, mClaro);
  cabeza.add(casco);

  /* Cara al desnudo: ojos y sonrisa directamente sobre el casco, como en
     el dibujo. Sin pantalla, sin rubor y sin recuadros. */
  const ojos = [], brillos = [];
  [-1, 1].forEach(d => {
    const o = bola(0.185, mFaccion);
    o.scale.z = 0.5;
    o.position.set(d * 0.34, 0.13, 0.53);
    o.userData.base = o.position.clone();
    cabeza.add(o); ojos.push(o);

    const b = new THREE.Mesh(new THREE.SphereGeometry(0.058, 12, 10), mBrillo);
    b.scale.z = 0.4;
    b.position.set(d * 0.34 - 0.055, 0.2, 0.63);
    b.userData.base = b.position.clone();
    cabeza.add(b); brillos.push(b);
  });

  const sonrisa = new THREE.Mesh(
    new THREE.TorusGeometry(0.2, 0.038, 8, Math.round(22 * seg), Math.PI * 0.9), mFaccion);
  sonrisa.position.set(0, -0.16, 0.56);
  sonrisa.rotation.z = Math.PI + Math.PI * 0.05;
  cabeza.add(sonrisa);

  // Orejas: tabiques azules a los costados, como en el dibujo
  const orejas = [];
  [-1, 1].forEach(d => {
    const oreja = caja(0.22, 0.5, 0.46, 0.1, mVivo);
    oreja.position.set(d * 1.02, -0.08, 0);
    cabeza.add(oreja); orejas.push(oreja);
  });

  // Pestaña superior: el escalón que el dibujo tiene sobre la frente
  const pestana = caja(0.62, 0.16, 0.5, 0.06, mMedio);
  pestana.position.set(0, 0.78, 0.16);
  cabeza.add(pestana);

  /* ================= BROTE ================= */
  const brote = new THREE.Group();
  brote.position.y = 0.78;
  cabeza.add(brote);

  /* Dos hojas abriéndose en V desde un mismo punto, sin maceta: es como
     está en el dibujo. */
  const tallo = new THREE.Mesh(new THREE.TubeGeometry(
    new THREE.CatmullRomCurve3([
      new THREE.Vector3(0, -0.04, 0), new THREE.Vector3(0.01, 0.16, 0.01),
      new THREE.Vector3(0, 0.34, 0)]),
    Math.round(14 * seg), 0.04, Math.round(8 * seg), false), mBrote);
  conBorde(tallo, 0.03);
  brote.add(tallo);

  const rama = lado => {
    const g = new THREE.Group();

    const t = new THREE.Mesh(new THREE.TubeGeometry(
      new THREE.CatmullRomCurve3([
        new THREE.Vector3(0, 0, 0), new THREE.Vector3(lado * 0.12, 0.16, 0),
        new THREE.Vector3(lado * 0.26, 0.28, 0)]),
      Math.round(12 * seg), 0.033, Math.round(7 * seg), false), mBrote);
    conBorde(t, 0.026);
    g.add(t);

    const f = new THREE.Shape();
    f.moveTo(0, 0);
    f.bezierCurveTo(0.2, 0.1, 0.44, 0.26, 0.56, 0.5);
    f.bezierCurveTo(0.26, 0.48, 0.07, 0.26, 0, 0);
    const hoja = new THREE.Mesh(new THREE.ExtrudeGeometry(f, {
      depth: 0.05, bevelEnabled: true, bevelSize: 0.022, bevelThickness: 0.022, bevelSegments: 2
    }), mBrote);
    conBorde(hoja, 0.03);
    hoja.scale.x = lado;
    hoja.position.set(lado * 0.2, 0.22, -0.028);
    hoja.rotation.z = lado * -0.22;
    g.add(hoja);

    g.position.y = 0.3;
    return g;
  };
  const hojaIzq = rama(-1), hojaDer = rama(1);
  brote.add(hojaIzq, hojaDer);

  /* ================= ENCUADRE =================
     En vez de una distancia fija, se calcula la que hace falta para que
     quepa el encuadre pedido, sea cual sea la forma del hueco: así el
     robot no se corta en un lienzo estrecho ni queda diminuto en uno ancho.

     El robot entra entero en los dos extremos y el punto de mira no se
     mueve: al bajar solo se acerca un poco. Antes terminaba en un primer
     plano de la cara, que partía el cuerpo contra el borde del lienzo.

       modelo: de y=-1.83 a y=2.87 (media altura 2.35), ancho ±1.33
  */
  const TAN = Math.tan(15 * Math.PI / 180);   // media apertura de 30°
  const enfoque = (medioAlto, medioAncho) =>
    Math.max(medioAlto, medioAncho / camara.aspect) / TAN;

  const MIRA = 0.52;               // centro real del modelo
  let zLejos = 9, zCerca = 8;
  const encuadrar = () => {
    const a = host.clientWidth, b = host.clientHeight || a;
    if (!a || !b) return;
    camara.aspect = a / b;
    zLejos = enfoque(2.60, 1.42);
    zCerca = enfoque(2.42, 1.40);
    camara.updateProjectionMatrix();
    render.setSize(a, b);
  };
  encuadrar();
  new ResizeObserver(encuadrar).observe(host);
  host.classList.add('listo');

  /* ================= MOVIMIENTO ================= */
  const escenaEl = host.closest('.escena') || document.body;
  const reloj = new THREE.Clock();
  const meta = { x: 0, y: 0 };
  const act = { x: 0, y: 0 };

  let ultimoGesto = -99;   // cuándo se movió el cursor por última vez

  addEventListener('pointermove', e => {
    meta.x = ((e.clientX / innerWidth) - 0.5) * 2 * LIMITE_X;
    meta.y = ((e.clientY / innerHeight) - 0.5) * 2 * LIMITE_Y;
    ultimoGesto = reloj.getElapsedTime();
  }, { passive: true });

  /* En el teléfono no hay cursor: la cabeza sigue la inclinación del
     aparato. El punto neutro es la postura con la que se empezó a leer y
     se corrige muy despacio, para que quien lea recostado no se encuentre
     la cabeza clavada en el tope. */
  if (matchMedia('(pointer: coarse)').matches && typeof DeviceOrientationEvent !== 'undefined') {
    const tope = (v, l) => Math.max(-l, Math.min(l, v));
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

  /* Dónde acaba el viaje horizontal. Un porcentaje fijo no sirve: el hueco
     que dejan las tarjetas cambia de ancho con la ventana, y con 15% el
     robot quedaba pegado a las tarjetas en pantallas anchas. Se mide el
     hueco y se centra dentro de él. */
  let rxFinal = 15;
  const medirHueco = () => {
    const lista = document.querySelector('.caminos-lista');
    if (!lista || !caja3D) return;
    const r = lista.getBoundingClientRect();
    const centro = (r.right + innerWidth) / 2;
    rxFinal = Math.max(1, (innerWidth - centro - caja3D.offsetWidth / 2) / innerWidth * 100);
  };
  medirHueco();
  addEventListener('resize', medirHueco, { passive: true });

  /* Se mide dentro del bucle de render, no en el evento `scroll`: va
     sincronizado con el cuadro y no depende de que el navegador entregue
     eventos, que puede omitir bajo carga. */
  const medirAvance = () => {
    if (!caja3D) { avance = 0; return; }
    const r = escenaEl.getBoundingClientRect();
    avance = Math.min(1, Math.max(0, -r.top / Math.max(r.height - innerHeight, 1)));
    const suave = avance < .5 ? 2 * avance * avance : 1 - Math.pow(-2 * avance + 2, 2) / 2;

    const rx = 4 + suave * (rxFinal - 4);
    if (Math.abs(rx - rxPrev) > 0.05) {
      caja3D.style.setProperty('--rx', rx.toFixed(2) + '%');
      rxPrev = rx;
    }
  };
  medirAvance();

  let visible = true;
  new IntersectionObserver(([e]) => { visible = e.isIntersecting; }).observe(host);
  document.addEventListener('visibilitychange', () => { visible = !document.hidden; });

  let proxParpadeo = 2 + Math.random() * 3, doble = false;
  let avanceSuave = 0;
  let broteGiro = 0, broteVel = 0;          // arrastre de la planta
  let proxSaludo = 6 + Math.random() * 5, saludo = 0;
  let proxLadeo = 9 + Math.random() * 6, ladeo = 0;    // ladear la cabeza
  let proxBrinco = 14 + Math.random() * 8, brinco = 0; // brinco de alegría
  let previoGiro = 0;
  const entrada = { e: 0.82, y: -0.5 };     // aparición con rebote

  function bucle() {
    requestAnimationFrame(bucle);
    if (!visible) return;
    const t = reloj.getElapsedTime();
    medirAvance();

    /* Aparición: un resorte sobreamortiguado, no un salto brusco. */
    entrada.e += (1 - entrada.e) * 0.06;
    entrada.y += (0 - entrada.y) * 0.055;

    /* Si nadie mueve el cursor, mira alrededor por su cuenta en vez de
       quedarse clavado al frente. */
    if (t - ultimoGesto > 3.5) {
      meta.x = Math.sin(t * 0.31) * 0.62 + Math.sin(t * 0.13) * 0.3;
      meta.y = Math.sin(t * 0.24 + 1.4) * 0.2;
    }

    act.x += (meta.x - act.x) * INERCIA;
    act.y += (meta.y - act.y) * INERCIA;

    /* Los ojos llegan antes que la cabeza: miran, y la cabeza les sigue.
       Ese desfase es lo que separa "mira" de "gira el cuello". */
    const previo = act.x;
    cabeza.rotation.y = act.x;
    cabeza.rotation.x = act.y;
    cabeza.rotation.z = act.x * -0.14 + ladeo;
    cuerpo.rotation.y = act.x * 0.2;

    const adelanto = (meta.x - act.x) * 0.075;
    ojos.forEach(o => {
      o.position.x = o.userData.base.x + adelanto;
      o.position.y = o.userData.base.y - act.y * 0.03;
    });
    brillos.forEach(b => {
      b.position.x = b.userData.base.x + adelanto;
      b.position.y = b.userData.base.y - act.y * 0.03;
    });

    // Las orejas acusan el frenazo del giro
    const vel = act.x - previoGiro;
    previoGiro = previo;
    orejas.forEach((o, i) => { o.rotation.x = vel * (i ? 2.6 : -2.6); });

    avanceSuave += (avance - avanceSuave) * 0.09;
    /* Respiración con dos ritmos: uno solo hace un balanceo de metrónomo. */
    const resp = Math.sin(t * 0.9) * 0.032 + Math.sin(t * 0.37) * 0.014;

    /* Ladear la cabeza de vez en cuando, con cara de curiosidad. */
    if (t > proxLadeo) {
      const p = (t - proxLadeo) / 2.6;
      if (p >= 1) { proxLadeo = t + 10 + Math.random() * 9; ladeo = 0; }
      else ladeo = Math.sin(p * Math.PI) * 0.3 * (proxLadeo % 2 < 1 ? 1 : -1);
    }

    /* Brinco: se despega del suelo y aterriza aplastándose un poco. */
    if (t > proxBrinco) {
      const p = (t - proxBrinco) / 0.85;
      if (p >= 1) { proxBrinco = t + 16 + Math.random() * 12; brinco = 0; }
      else brinco = Math.sin(p * Math.PI) * 0.34;
    }
    // Aplastar y estirar: al subir se alarga, al caer se achata
    const estira = 1 + brinco * 0.14 - Math.max(0, -Math.cos(t * 0.9)) * 0.008;

    raiz.position.y = resp + entrada.y + brinco;
    raiz.rotation.y = avanceSuave * -0.16 + Math.sin(t * 0.23) * 0.05;
    raiz.rotation.z = Math.sin(t * 0.31) * 0.016;
    raiz.scale.set(entrada.e * (2 - estira), entrada.e * estira, entrada.e * (2 - estira));
    cabeza.position.y = 1.02 + resp * 0.5 + brinco * 0.06;

    /* Al bajar solo se acerca; el punto de mira se queda en el centro del
       modelo, así que el robot nunca se descuadra ni se sale del lienzo. */
    camara.position.set(0, MIRA + 0.05, zLejos + (zCerca - zLejos) * avanceSuave);
    camara.lookAt(0, MIRA, 0);

    /* Parpadeo: a veces sencillo y a veces doble, que es como parpadea
       cualquiera. Uno siempre igual delata la máquina. */
    if (t > proxParpadeo) {
      const dur = doble ? 0.34 : 0.14;
      const p = (t - proxParpadeo) / dur;
      const ciclos = doble ? 2 : 1;
      const s = p < 1 ? Math.abs(Math.sin(p * Math.PI * ciclos)) : 0;
      ojos.forEach(o => o.scale.y = 1 - s * 0.92);
      if (p >= 1) {
        ojos.forEach(o => o.scale.y = 1);
        proxParpadeo = t + 2.2 + Math.random() * 3.6;
        doble = Math.random() < 0.28;
      }
    }

    leds.forEach((l, i) => {
      l.material.emissiveIntensity = 1.1 + Math.abs(Math.sin(t * 1.6 + i * 0.8)) * 1.6;
    });

    engrane.rotation.z = -t * 0.5;

    /* Arrastre del brote: la planta llega tarde al giro de la cabeza y se
       pasa un poco de largo. Es lo que más vida da al conjunto. */
    broteVel += (act.x - broteGiro) * 0.055;
    broteVel *= 0.86;
    broteGiro += broteVel;
    brote.rotation.z = (act.x - broteGiro) * 1.5 + Math.sin(t * 1.1) * 0.07;
    brote.rotation.x = -act.y * 0.25;
    hojaIzq.rotation.z = Math.sin(t * 1.5) * 0.11;
    hojaDer.rotation.z = Math.sin(t * 1.5 + 0.9) * 0.11;

    /* Saludo: cada tantos segundos levanta una mano y la agita. */
    if (t > proxSaludo) {
      const p = (t - proxSaludo) / 2.2;
      if (p >= 1) { proxSaludo = t + 11 + Math.random() * 9; saludo = 0; }
      else {
        // sube, agita tres veces y baja
        const sobre = Math.min(1, p / 0.22, (1 - p) / 0.22);
        saludo = sobre * (1.55 + Math.sin(p * Math.PI * 6) * 0.28);
      }
    }
    // Al brincar los brazos se van hacia fuera; al saludar, uno arriba
    const vuelo = brinco * 1.1;
    brazoIzq.rotation.z = -0.14 + Math.sin(t * 0.8) * 0.05 - vuelo;
    brazoDer.rotation.z = 0.14 - Math.sin(t * 0.8) * 0.05 + vuelo + saludo;

    // La sonrisa se ensancha mientras saluda o brinca
    const contento = Math.max(saludo / 1.6, brinco / 0.34);
    sonrisa.scale.set(1 + contento * 0.16, 1 + contento * 0.2, 1);

    pies.forEach((p, i) => { p.position.y = -1.62 + Math.sin(t * 0.9 + i * 0.6) * 0.02; });

    render.render(escena, camara);
  }
  bucle();
}
