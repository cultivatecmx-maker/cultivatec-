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
      └ cabeza   (casco, pantalla, orejas)     — sigue al cursor
          └ brote (maceta, tallo y hojas)      — se mece
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

const CLARO  = 0xC3DDFA;
const MEDIO  = 0x63A0E8;
const VIVO   = 0x2563EB;
const HONDO  = 0x1B4A96;
const CONTOR = 0x143A72;
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
  const pintura = c => new THREE.MeshStandardMaterial({ color: c, roughness: 0.38, metalness: 0.06 });
  const mClaro = pintura(CLARO);
  const mMedio = pintura(MEDIO);
  const mVivo  = pintura(VIVO);
  const mHondo = pintura(HONDO);
  const mMetal = new THREE.MeshStandardMaterial({ color: 0x9FB6D8, roughness: 0.3, metalness: 0.5 });
  const mPantalla = new THREE.MeshStandardMaterial({ color: 0x0E2A5A, roughness: 0.14, metalness: 0.25 });
  const mBrote = pintura(BROTE);
  const mBorde = new THREE.MeshBasicMaterial({ color: CONTOR, side: THREE.BackSide });
  const emisivo = (c, i) => new THREE.MeshStandardMaterial({
    color: c, emissive: c, emissiveIntensity: i, roughness: 0.2, metalness: 0
  });
  const mOjo    = emisivo(0xEAFBFF, 1.5);
  const mBrillo = new THREE.MeshBasicMaterial({ color: 0xffffff });
  const mRubor  = emisivo(0x67E8F9, 1.4);
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

  // Peto: chapa clara, redonda, sin líneas de panel
  const peto = caja(0.98, 0.8, 0.1, 0.32, mMedio);
  peto.position.set(0, -0.3, 0.53);
  cuerpo.add(peto);

  // Dial con el engrane, redondo en lugar de encajonado
  const dial = cil(0.27, 0.07, mHondo);
  dial.rotation.x = Math.PI / 2;
  dial.position.set(0, -0.26, 0.58);
  cuerpo.add(dial);

  const engrane = new THREE.Group();
  engrane.position.set(0, -0.26, 0.62);
  cuerpo.add(engrane);
  engrane.add(new THREE.Mesh(
    new THREE.TorusGeometry(0.12, 0.045, 9, Math.round(22 * seg)), mMetal));
  for (let i = 0; i < 7; i++) {
    const d = new THREE.Mesh(new RoundedBoxGeometry(0.07, 0.07, 0.07, 2, 0.025), mMetal);
    const a = (i / 7) * Math.PI * 2;
    d.position.set(Math.cos(a) * 0.16, Math.sin(a) * 0.16, 0);
    d.rotation.z = a;
    engrane.add(d);
  }
  const eje = cil(0.045, 0.1, mVivo);
  eje.rotation.x = Math.PI / 2;
  eje.position.set(0, -0.26, 0.63);
  cuerpo.add(eje);

  // Tres luces de estado bajo el dial
  const leds = [];
  [[-0.2, mLedA], [0, mLedB], [0.2, mLedC]].forEach(([x, m]) => {
    const l = bola(0.052, m);
    l.position.set(x, -0.58, 0.58);
    cuerpo.add(l); leds.push(l);
  });

  // Cuello corto: la cabeza casi se apoya en los hombros
  const cuello = cil(0.3, 0.26, mMetal);
  cuello.position.y = 0.34;
  cuerpo.add(cuello);

  /* --- Brazos cortos y regordetes, con manoplas redondas --- */
  const brazo = lado => {
    const g = new THREE.Group();
    g.add(bola(0.19, mMetal));                        // hombro

    const sup = caja(0.36, 0.66, 0.36, 0.17, mClaro);
    sup.position.y = -0.42;
    g.add(sup);

    const puno = caja(0.34, 0.3, 0.34, 0.15, mVivo);  // manopla
    puno.position.y = -0.86;
    g.add(puno);

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

  // Pantalla facial: una sola pieza, sin marco ni juntas
  const pantalla = caja(1.48, 1.0, 0.12, 0.3, mPantalla, false);
  pantalla.position.set(0, 0.02, 0.55);
  cabeza.add(pantalla);

  // Ojos grandes y redondos con su brillo
  const ojos = [];
  [-1, 1].forEach(d => {
    const o = bola(0.2, mOjo);
    o.scale.z = 0.55;
    o.position.set(d * 0.35, 0.14, 0.6);
    cabeza.add(o); ojos.push(o);

    const b = new THREE.Mesh(new THREE.SphereGeometry(0.062, 12, 10), mBrillo);
    b.scale.z = 0.4;
    b.position.set(d * 0.35 - 0.06, 0.22, 0.71);
    cabeza.add(b);

    // Rubor: dos manchas suaves dentro de la pantalla
    const r = bola(0.13, mRubor);
    r.scale.set(1.3, 0.72, 0.22);
    r.position.set(d * 0.6, -0.19, 0.61);
    cabeza.add(r);
  });

  const sonrisa = new THREE.Mesh(
    new THREE.TorusGeometry(0.2, 0.036, 8, Math.round(22 * seg), Math.PI * 0.9), mOjo);
  sonrisa.position.set(0, -0.13, 0.6);
  sonrisa.rotation.z = Math.PI + Math.PI * 0.05;
  cabeza.add(sonrisa);

  // Orejas: discos limpios, sin pernos
  [-1, 1].forEach(d => {
    const oreja = cil(0.26, 0.24, mVivo);
    conBorde(oreja, 0.045);
    oreja.rotation.z = Math.PI / 2;
    oreja.position.set(d * 1.02, -0.08, 0);
    cabeza.add(oreja);

    const centro = cil(0.11, 0.28, mMetal);
    centro.rotation.z = Math.PI / 2;
    centro.position.set(d * 1.06, -0.08, 0);
    cabeza.add(centro);
  });

  /* ================= BROTE ================= */
  const brote = new THREE.Group();
  brote.position.y = 0.78;
  cabeza.add(brote);

  const maceta = new THREE.Mesh(
    new THREE.CylinderGeometry(0.15, 0.2, 0.16, Math.round(18 * seg)), mVivo);
  conBorde(maceta, 0.035);
  maceta.position.y = 0.03;
  brote.add(maceta);

  const tallo = new THREE.Mesh(new THREE.TubeGeometry(
    new THREE.CatmullRomCurve3([
      new THREE.Vector3(0, 0.08, 0), new THREE.Vector3(0.05, 0.36, 0.02),
      new THREE.Vector3(-0.02, 0.62, 0)]), 16, 0.045, 7, false), mBrote);
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
  const hojaIzq = hoja(-1, 0.34), hojaDer = hoja(1, 0.5);
  brote.add(hojaIzq, hojaDer);

  const punta = bola(0.05, emisivo(0x7FFFD8, 2.4));
  punta.position.set(-0.02, 0.64, 0);
  brote.add(punta);

  /* ================= ENCUADRE =================
     En vez de una distancia fija, se calcula la que hace falta para que
     quepa el encuadre pedido, sea cual sea la forma del hueco: así el
     robot no se corta en un lienzo estrecho ni queda diminuto en uno ancho.

       lejos → el robot entero    (de y=-1.83 a y=2.75, ancho ±1.2)
       cerca → cabeza y hombros   (de y= 0.21 a y=2.75)
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
    cabeza.position.y = 1.02 + resp * 0.5;

    /* La cámara se acerca a la cara conforme baja el scroll. Al principio
       encuadra al robot entero (mide 4.3 de alto y su centro está en 0.30);
       al final se queda en la cabeza, así el cuerpo sale de cuadro por
       abajo en vez de verse cortado a media pierna. */
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
    punta.material.emissiveIntensity = 1.6 + Math.abs(Math.sin(t * 1.2)) * 1.4;

    engrane.rotation.z = -t * 0.5;
    brote.rotation.z = Math.sin(t * 1.1) * 0.1;
    hojaIzq.rotation.z = -0.34 + Math.sin(t * 1.5) * 0.14;
    hojaDer.rotation.z = 0.34 + Math.sin(t * 1.5 + 0.9) * 0.14;
    brazoIzq.rotation.z = -0.14 + Math.sin(t * 0.8) * 0.05;
    brazoDer.rotation.z = 0.14 - Math.sin(t * 0.8) * 0.05;
    pies.forEach((p, i) => { p.position.y = -1.62 + Math.sin(t * 0.9 + i * 0.6) * 0.02; });

    render.render(escena, camara);
  }
  bucle();
}
