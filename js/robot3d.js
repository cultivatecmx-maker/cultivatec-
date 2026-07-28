/* ============================================================
   CULTIVATEC — Robot 3D del hero

   Carga diferida y condicionada: el modelo pesa ~1.9 MB, así que sólo
   entra cuando el visitante puede permitírselo. Mientras tanto (y siempre
   en móvil o con datos limitados) se queda el robot en SVG, que pesa cero.
   ============================================================ */

const CDN = 'https://esm.sh/three@0.160.0';

function puedeCargar() {
  // Respeta la preferencia de movimiento reducido
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return false;
  // Sólo en pantallas grandes: en móvil el SVG cumple y ahorra datos
  if (!matchMedia('(min-width: 961px)').matches) return false;

  const con = navigator.connection;
  if (con) {
    if (con.saveData) return false;
    if (['slow-2g', '2g', '3g'].includes(con.effectiveType)) return false;
  }
  return true;
}

export async function montarRobot3D(host) {
  if (!host || !puedeCargar()) return;

  const [THREE, { GLTFLoader }] = await Promise.all([
    import(CDN),
    import(`${CDN}/examples/jsm/loaders/GLTFLoader.js`)
  ]);

  const ancho = host.clientWidth;
  const alto = host.clientHeight || ancho;

  const escena = new THREE.Scene();

  const camara = new THREE.PerspectiveCamera(34, ancho / alto, 0.1, 100);
  camara.position.set(0, 0, 5);

  const render = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  render.setSize(ancho, alto);
  render.setPixelRatio(Math.min(devicePixelRatio, 2));
  render.outputColorSpace = THREE.SRGBColorSpace;
  render.toneMapping = THREE.ACESFilmicToneMapping;
  render.toneMappingExposure = 1.15;
  host.appendChild(render.domElement);

  // Luces: cálida al frente, azul de marca por detrás para recortar la silueta
  escena.add(new THREE.HemisphereLight(0xffffff, 0xbfd4f5, 2.1));

  const principal = new THREE.DirectionalLight(0xffffff, 2.4);
  principal.position.set(2.5, 3, 4);
  escena.add(principal);

  const contra = new THREE.DirectionalLight(0x3b82f6, 3);
  contra.position.set(-3, 1.5, -3);
  escena.add(contra);

  const relleno = new THREE.DirectionalLight(0x22d3ee, 1.2);
  relleno.position.set(-2, -1.5, 2);
  escena.add(relleno);

  const pivote = new THREE.Group();
  escena.add(pivote);

  const gltf = await new GLTFLoader().loadAsync(host.dataset.glb);
  const modelo = gltf.scene;

  // Centrar y escalar para que ocupe el alto disponible
  const caja = new THREE.Box3().setFromObject(modelo);
  const centro = caja.getCenter(new THREE.Vector3());
  const tam = caja.getSize(new THREE.Vector3());
  modelo.position.sub(centro);
  pivote.scale.setScalar(2.5 / Math.max(tam.x, tam.y, tam.z));
  pivote.add(modelo);

  host.classList.add('listo');   // oculta el SVG de reserva

  // --- Movimiento ---
  let raton = { x: 0, y: 0 };
  let objetivo = { x: 0, y: 0 };
  const hero = host.closest('.hero') || document.body;

  hero.addEventListener('pointermove', e => {
    const r = hero.getBoundingClientRect();
    objetivo.x = ((e.clientX - r.left) / r.width - 0.5) * 0.6;
    objetivo.y = ((e.clientY - r.top) / r.height - 0.5) * 0.4;
  });
  hero.addEventListener('pointerleave', () => { objetivo.x = 0; objetivo.y = 0; });

  let visible = true;
  new IntersectionObserver(([e]) => { visible = e.isIntersecting; },
    { threshold: 0 }).observe(host);
  document.addEventListener('visibilitychange', () => { visible = !document.hidden; });

  const reloj = new THREE.Clock();
  let giro = 0;

  function bucle() {
    requestAnimationFrame(bucle);
    if (!visible) return;

    const dt = Math.min(reloj.getDelta(), 0.05);
    const t = reloj.elapsedTime;

    // Vuelta de exposición constante
    giro += dt * 0.42;

    // El ratón inclina; la inercia evita el efecto de imán
    raton.x += (objetivo.x - raton.x) * 0.06;
    raton.y += (objetivo.y - raton.y) * 0.06;

    pivote.rotation.y = giro + raton.x;
    pivote.rotation.x = raton.y * 0.6 + Math.sin(t * 0.7) * 0.045;
    pivote.position.y = Math.sin(t * 0.9) * 0.14;

    render.render(escena, camara);
  }
  bucle();

  // Mantener proporción al redimensionar
  const ro = new ResizeObserver(() => {
    const a = host.clientWidth, b = host.clientHeight || a;
    if (!a || !b) return;
    camara.aspect = a / b;
    camara.updateProjectionMatrix();
    render.setSize(a, b);
  });
  ro.observe(host);
}
