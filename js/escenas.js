/* Escenas de scroll: robot que se arma, mosaico con paralaje y titular que se ilumina. Sin librerías. */
(() => {
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const clamp = (v, a = 0, b = 1) => Math.min(b, Math.max(a, v));
  const arm = document.querySelector('.armado');
  const lis = arm ? [...arm.querySelectorAll('.pasos li')] : [];
  const mos = document.querySelector('[data-mosaico]');
  const tit = document.querySelector('[data-palabras]');
  if (tit) { tit.innerHTML = tit.textContent.trim().split(/\s+/).map(w => `<span class="w">${w}</span>`).join(' '); }
  const ws = tit ? [...tit.querySelectorAll('.w')] : [];
  let actual = -1;
  const poner = (i) => {
    if (!arm || actual === i) return;
    actual = i; arm.dataset.paso = i;
    lis.forEach((li, k) => { li.classList.toggle('on', k <= i); li.classList.toggle('act', k === i); });
    [1, 2, 3].forEach(n => arm.classList.toggle('p' + n, i >= n));
  };
  if (reduce) { poner(3); ws.forEach(w => w.classList.add('on')); return; }
  poner(0);
  const items = [];
  const reg = (el, fn) => { if (el) items.push({ el, fn, vis: false }); };
  reg(arm, el => {
    const r = el.getBoundingClientRect(), p = clamp(-r.top / Math.max(1, r.height - innerHeight));
    el.style.setProperty('--ap', p.toFixed(3));
    poner(Math.min(3, Math.floor(p * 4)));
  });
  reg(mos, el => {
    const r = el.getBoundingClientRect();
    el.style.setProperty('--mp', clamp((innerHeight - r.top) / (innerHeight + r.height)).toFixed(3));
  });
  reg(tit, el => {
    const r = el.getBoundingClientRect(), p = clamp((innerHeight * .9 - r.top) / (innerHeight * .45));
    ws.forEach((w, i) => w.classList.toggle('on', p * ws.length >= i + .4));
  });
  if (!('IntersectionObserver' in window)) { poner(3); ws.forEach(w => w.classList.add('on')); return; }
  const io = new IntersectionObserver(es => es.forEach(e => { items.find(t => t.el === e.target).vis = e.isIntersecting; }), { rootMargin: '10% 0px' });
  items.forEach(t => io.observe(t.el));
  let espera = false;
  const cuadro = () => { espera = false; items.forEach(t => t.vis && t.fn(t.el)); };
  const pedir = () => { if (!espera) { espera = true; requestAnimationFrame(cuadro); } };
  addEventListener('scroll', pedir, { passive: true }); addEventListener('resize', pedir); pedir();
})();
