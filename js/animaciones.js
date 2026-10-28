/* Animaciones ligadas al scroll, sin librerías. Solo calcula lo que está en pantalla. */
(() => {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) {
    document.querySelectorAll('.pasos.cuatro li').forEach(li => li.classList.add('on'));
    return;
  }
  const barra = document.querySelector('.progreso');
  const ruta = document.querySelector('.ruta');
  const pasos = ruta ? [...ruta.querySelectorAll('.pasos li')] : [];
  let esperando = false, rutaVisible = false;
  const prog = (el, inicio, largo) => {
    const r = el.getBoundingClientRect();
    return Math.min(1, Math.max(0, (innerHeight * inicio - r.top) / (r.height * largo)));
  };
  const cuadro = () => {
    esperando = false;
    if (barra) barra.style.setProperty('--sp', (scrollY / Math.max(1, document.documentElement.scrollHeight - innerHeight)).toFixed(4));
    if (ruta && rutaVisible) {
      const p = prog(ruta, .75, .7);
      ruta.style.setProperty('--p', p.toFixed(3));
      pasos.forEach((li, i) => li.classList.toggle('on', p >= i / (pasos.length - 1) - .02));
      ruta.classList.toggle('llego', p > .98);
    }
  };
  const pedir = () => { if (!esperando) { esperando = true; requestAnimationFrame(cuadro); } };
  if (ruta && 'IntersectionObserver' in window)
    new IntersectionObserver(es => { rutaVisible = es[0].isIntersecting; pedir(); }, { rootMargin: '15% 0px' }).observe(ruta);
  addEventListener('scroll', pedir, { passive: true });
  addEventListener('resize', pedir);
  pedir();
})();
