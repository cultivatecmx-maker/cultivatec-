// ============================================================
// CULTIVALAB — Vista previa 3D (primer paso hacia el editor completo)
// Un LED en 3D que puedes girar con el mouse. Mismo patrón que
// robot3d.js: Three.js por ESM, con una reserva en 2D si no carga.
// ============================================================

const CDN = 'https://esm.sh/three@0.160.0';

export async function montarComponente3D(host) {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return false;

  const THREE = await import(CDN);

  const w = host.clientWidth, h = host.clientHeight;
  const escena = new THREE.Scene();
  const camara = new THREE.PerspectiveCamera(38, w / h, 0.1, 50);
  camara.position.set(0, 0.4, 4.2);

  const render = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  render.setSize(w, h);
  render.setPixelRatio(Math.min(devicePixelRatio, 2));
  host.appendChild(render.domElement);

  // Luces
  escena.add(new THREE.AmbientLight(0xffffff, 0.7));
  const luz = new THREE.DirectionalLight(0xffffff, 1.1);
  luz.position.set(2, 3, 4);
  escena.add(luz);

  // ---- Grupo del LED ----
  const led = new THREE.Group();

  // Dos patitas
  const matPata = new THREE.MeshStandardMaterial({ color: 0x9CA3AF, metalness: 0.7, roughness: 0.35 });
  const geoPata = new THREE.CylinderGeometry(0.035, 0.035, 1.1, 10);
  const pataA = new THREE.Mesh(geoPata, matPata); pataA.position.set(-0.18, -1.0, 0);
  const pataB = new THREE.Mesh(geoPata, matPata); pataB.position.set(0.18, -1.0, 0);
  led.add(pataA, pataB);

  // Base plástica (el "cuerpo" cuadrado típico del LED de 5mm)
  const base = new THREE.Mesh(
    new THREE.CylinderGeometry(0.42, 0.42, 0.22, 24),
    new THREE.MeshStandardMaterial({ color: 0x1E293B, roughness: 0.5 })
  );
  base.position.y = -0.48;
  led.add(base);

  // El domo del LED — material emissive para que "brille" de verdad
  const matDomo = new THREE.MeshPhysicalMaterial({
    color: 0x3D9CF9, emissive: 0x0958C2, emissiveIntensity: 0.6,
    transparent: true, opacity: 0.88, roughness: 0.15, transmission: 0.35, thickness: 0.6,
  });
  const domo = new THREE.Mesh(new THREE.CapsuleGeometry(0.4, 0.55, 8, 20), matDomo);
  domo.position.y = 0.1;
  led.add(domo);

  escena.add(led);

  // ---- Interacción: arrastrar para girar, y gira solo cuando no lo tocas ----
  let girando = true, arrastrando = false, prevX = 0, velocidad = 0.01;

  render.domElement.style.cursor = 'grab';
  render.domElement.addEventListener('pointerdown', e => {
    arrastrando = true; girando = false; prevX = e.clientX;
    render.domElement.style.cursor = 'grabbing';
  });
  window.addEventListener('pointerup', () => {
    arrastrando = false;
    render.domElement.style.cursor = 'grab';
    setTimeout(() => girando = true, 1800);
  });
  window.addEventListener('pointermove', e => {
    if (!arrastrando) return;
    const dx = e.clientX - prevX; prevX = e.clientX;
    led.rotation.y += dx * 0.01;
  });

  // Pulso de brillo, como un LED de verdad parpadeando suave
  let t = 0;
  function animar() {
    requestAnimationFrame(animar);
    t += 0.02;
    matDomo.emissiveIntensity = 0.55 + Math.sin(t * 1.6) * 0.35;
    if (girando) led.rotation.y += velocidad;
    render.render(escena, camara);
  }
  animar();

  // Reajustar si cambia el tamaño del contenedor
  new ResizeObserver(() => {
    const nw = host.clientWidth, nh = host.clientHeight;
    if (!nw || !nh) return;
    camara.aspect = nw / nh; camara.updateProjectionMatrix();
    render.setSize(nw, nh);
  }).observe(host);

  return true;
}
