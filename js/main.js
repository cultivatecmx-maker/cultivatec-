/* ============================================================
   CULTIVATEC — Interacciones compartidas por todas las páginas
   ============================================================ */

const App = {

  init() {
    this.navbar();
    this.navPanel();
    this.mobileMenu();
    this.activeLink();
    this.tabs();
    this.faq();
    this.reveal();
    this.counters();
    this.backToTop();
    this.contactForm();
    this.year();
    this.heroParallax();
    this.heroForm();
  },

  isMobile: () => window.matchMedia('(max-width: 960px)').matches,

  /* --- Barra superior: sólida al bajar --- */
  navbar() {
    const nav = document.querySelector('.navbar');
    if (!nav) return;

    // `on-hero` sólo aplica arriba del todo, en páginas con hero azul.
    const onHero = nav.dataset.onHero === 'true';

    const update = () => {
      const y = window.scrollY;
      nav.classList.toggle('scrolled', y > 40);
      if (onHero) nav.classList.toggle('on-hero', y <= 40 && !this.isMobile());
    };

    window.addEventListener('scroll', update, { passive: true });
    window.addEventListener('resize', update);
    update();
  },

  /* --- Panel desplegable de navegación --- */
  navPanel() {
    const triggers = [...document.querySelectorAll('[data-panel]')];
    if (!triggers.length) return;

    const closeAll = except => {
      triggers.forEach(t => {
        if (t === except) return;
        const panel = document.getElementById(t.dataset.panel);
        panel?.classList.remove('open');
        t.setAttribute('aria-expanded', 'false');
      });
    };

    triggers.forEach(trigger => {
      const panel = document.getElementById(trigger.dataset.panel);
      if (!panel) return;

      trigger.addEventListener('click', e => {
        e.stopPropagation();
        const open = panel.classList.toggle('open');
        trigger.setAttribute('aria-expanded', String(open));
        closeAll(trigger);
      });

      // En escritorio también se abre al pasar el cursor
      const wrap = trigger.parentElement;
      wrap.addEventListener('mouseenter', () => {
        if (this.isMobile()) return;
        closeAll(trigger);
        panel.classList.add('open');
        trigger.setAttribute('aria-expanded', 'true');
      });
      wrap.addEventListener('mouseleave', () => {
        if (this.isMobile()) return;
        panel.classList.remove('open');
        trigger.setAttribute('aria-expanded', 'false');
      });
    });

    document.addEventListener('click', () => closeAll(null));
    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeAll(null); });
  },

  /* --- Menú móvil --- */
  mobileMenu() {
    const burger = document.querySelector('.hamburger');
    const menu = document.getElementById('nav-menu');
    if (!burger || !menu) return;

    const close = () => {
      burger.classList.remove('active');
      menu.classList.remove('open');
      burger.setAttribute('aria-expanded', 'false');
      document.body.style.overflow = '';
    };

    burger.addEventListener('click', e => {
      e.stopPropagation();
      const open = menu.classList.toggle('open');
      burger.classList.toggle('active', open);
      burger.setAttribute('aria-expanded', String(open));
      document.body.style.overflow = open ? 'hidden' : '';
    });

    // Cerrar al elegir un destino (no al abrir un submenú)
    menu.querySelectorAll('a').forEach(a => a.addEventListener('click', close));

    document.addEventListener('keydown', e => { if (e.key === 'Escape') close(); });
    window.addEventListener('resize', () => { if (!this.isMobile()) close(); });
  },

  /* --- Marca el enlace de la página actual --- */
  activeLink() {
    const file = (location.pathname.split('/').pop() || 'index.html').toLowerCase();

    document.querySelectorAll('.nav-item[href], .nav-panel-link[href]').forEach(a => {
      const href = (a.getAttribute('href') || '').split('/').pop().toLowerCase();
      if (!href || href.startsWith('#') || href.startsWith('http')) return;
      if (href === file) {
        a.classList.add('active');
        // Si vive dentro de un panel, resalta también su disparador
        const panel = a.closest('.nav-panel');
        if (panel) document.querySelector(`[data-panel="${panel.id}"]`)?.classList.add('active');
      }
    });
  },

  /* --- Pestañas --- */
  tabs() {
    const groups = [...document.querySelectorAll('[data-tabs]')];
    if (!groups.length) return;

    groups.forEach(group => {
      const tabs = [...group.querySelectorAll('.tab')];
      const panels = [...document.querySelectorAll(`[data-tabpanels="${group.dataset.tabs}"] .tab-panel`)];

      const activate = tab => {
        const id = tab.dataset.tab;
        tabs.forEach(t => {
          const on = t === tab;
          t.classList.toggle('active', on);
          t.setAttribute('aria-selected', String(on));
        });
        panels.forEach(p => {
          const on = p.dataset.panel === id;
          p.classList.toggle('active', on);
          p.hidden = !on;
        });
      };

      tabs.forEach((tab, i) => {
        tab.addEventListener('click', () => activate(tab));
        tab.addEventListener('keydown', e => {
          if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
          e.preventDefault();
          const next = e.key === 'ArrowRight'
            ? tabs[(i + 1) % tabs.length]
            : tabs[(i - 1 + tabs.length) % tabs.length];
          next.focus();
          activate(next);
        });
      });
    });
  },

  /* --- Acordeón de preguntas frecuentes --- */
  faq() {
    document.querySelectorAll('.faq-item').forEach(item => {
      const q = item.querySelector('.faq-q');
      const a = item.querySelector('.faq-a');
      if (!q || !a) return;

      q.setAttribute('aria-expanded', 'false');
      q.addEventListener('click', () => {
        const open = item.classList.toggle('open');
        q.setAttribute('aria-expanded', String(open));
        a.style.maxHeight = open ? a.scrollHeight + 'px' : '';
      });
    });
  },

  /* --- Animaciones al aparecer --- */
  reveal() {
    const els = document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .stagger');
    if (!els.length) return;

    if (!('IntersectionObserver' in window)) {
      els.forEach(el => el.classList.add('visible'));
      return;
    }

    const io = new IntersectionObserver((entries, obs) => {
      entries.forEach(e => {
        if (!e.isIntersecting) return;
        e.target.classList.add('visible');
        obs.unobserve(e.target);
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -60px 0px' });

    els.forEach(el => io.observe(el));

    // Red de seguridad: si el observador nunca dispara, no dejar la página en blanco.
    setTimeout(() => {
      els.forEach(el => {
        if (el.classList.contains('visible')) return;
        const r = el.getBoundingClientRect();
        if (r.top < innerHeight && r.bottom > 0) el.classList.add('visible');
      });
    }, 2500);
  },

  /* --- Contadores --- */
  counters() {
    const nums = document.querySelectorAll('[data-count]');
    if (!nums.length) return;

    const write = el => {
      el.textContent = Number(el.dataset.count).toLocaleString('es-MX') + (el.dataset.suffix || '');
    };

    if (!('IntersectionObserver' in window)) return nums.forEach(write);

    const io = new IntersectionObserver((entries, obs) => {
      entries.forEach(e => {
        if (!e.isIntersecting) return;
        this.animate(e.target);
        obs.unobserve(e.target);
      });
    }, { threshold: 0.5 });

    nums.forEach(n => io.observe(n));
  },

  animate(el) {
    const target = Number(el.dataset.count) || 0;
    const suffix = el.dataset.suffix || '';
    const start = performance.now();
    const ease = t => 1 - Math.pow(1 - t, 3);

    const step = now => {
      const p = Math.min((now - start) / 1800, 1);
      el.textContent = Math.round(target * ease(p)).toLocaleString('es-MX') + suffix;
      if (p < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  },

  /* --- Volver arriba --- */
  backToTop() {
    const btn = document.querySelector('.back-to-top');
    if (!btn) return;
    window.addEventListener('scroll', () => {
      btn.classList.toggle('visible', window.scrollY > 700);
    }, { passive: true });
    btn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
  },

  /* --- Formulario: sin backend, abre el correo del visitante --- */
  contactForm() {
    const form = document.getElementById('contact-form');
    if (!form) return;

    form.addEventListener('submit', e => {
      e.preventDefault();

      const btn = form.querySelector('.form-submit');
      const original = btn.innerHTML;
      const val = name => (form.elements[name]?.value || '').trim();
      const to = form.dataset.to || 'contacto@cultivatec.com.mx';

      const subject = `${val('interes') || 'Contacto'} — ${val('institucion') || val('nombre') || 'CultivaTec'}`;
      const body = [
        `Nombre: ${val('nombre')}`,
        `Correo: ${val('correo')}`,
        `Institución: ${val('institucion') || '—'}`,
        `Teléfono: ${val('telefono') || '—'}`,
        `Interés: ${val('interes') || '—'}`,
        '', 'Mensaje:', val('mensaje')
      ].join('\n');

      btn.innerHTML = '<i class="ph-bold ph-circle-notch spin"></i> Abriendo tu correo…';
      btn.disabled = true;

      location.href = `mailto:${to}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;

      setTimeout(() => {
        btn.innerHTML = '<i class="ph-bold ph-check-circle"></i> ¡Listo! Revisa tu correo';
        btn.style.background = 'linear-gradient(135deg,#047857,#34D399)';
        setTimeout(() => {
          form.reset();
          btn.innerHTML = original;
          btn.style.background = '';
          btn.disabled = false;
        }, 4000);
      }, 1200);
    });
  },

  /* --- Parallax suave de las tarjetas del hero ---
     Usa la propiedad `translate`, no `transform`, para no pisar las
     animaciones de entrada y flotación que sí usan transform. */
  heroParallax() {
    const card = document.querySelector('.hero');
    if (!card) return;
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    if (!matchMedia('(hover: hover) and (pointer: fine)').matches) return;

    const items = [...card.querySelectorAll('[data-par]')];
    if (!items.length) return;

    let frame = null;
    const move = e => {
      if (frame) return;
      frame = requestAnimationFrame(() => {
        frame = null;
        const r = card.getBoundingClientRect();
        const x = (e.clientX - r.left) / r.width - .5;
        const y = (e.clientY - r.top) / r.height - .5;
        items.forEach(el => {
          const d = parseFloat(el.dataset.par) || 12;
          el.style.setProperty('--px', (x * d).toFixed(1) + 'px');
          el.style.setProperty('--py', (y * d).toFixed(1) + 'px');
        });
        // La esfera se mueve mucho menos: da profundidad sin marear
        const orbe = card.querySelector('.orbe');
        if (orbe) {
          orbe.style.setProperty('--ox', (x * 26).toFixed(1) + 'px');
          orbe.style.setProperty('--oy', (y * 18).toFixed(1) + 'px');
        }
      });
    };

    const reset = () => {
      items.forEach(el => {
        el.style.setProperty('--px', '0px');
        el.style.setProperty('--py', '0px');
      });
      const orbe = card.querySelector('.orbe');
      if (orbe) { orbe.style.setProperty('--ox', '0px'); orbe.style.setProperty('--oy', '0px'); }
    };

    card.addEventListener('pointermove', move);
    card.addEventListener('pointerleave', reset);
  },

  year() {
    document.querySelectorAll('#year, .js-year').forEach(el => {
      el.textContent = new Date().getFullYear();
    });
  }
};

document.addEventListener('DOMContentLoaded', () => App.init());

const spin = document.createElement('style');
spin.textContent = '.spin{display:inline-block;animation:spin 1s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}';
document.head.appendChild(spin);
