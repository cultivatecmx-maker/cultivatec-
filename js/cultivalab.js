// ============================================================
// CULTIVALAB
// Por ahora este archivo hace 2 cosas:
//   1) Cambiar entre pestañas (Circuitos / Code / Diseño 3D)
//   2) Dejar el terreno listo para el simulador de circuitos,
//      que programaremos a fondo en los siguientes pasos.
// ============================================================

// ---- 1) Pestañas ----
const tabs = document.querySelectorAll('.lab-tab');
const panels = document.querySelectorAll('.lab-panel');

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    const target = tab.dataset.tab;

    // Quita "active" de todas las pestañas y paneles
    tabs.forEach(t => {
      t.classList.remove('active');
      t.setAttribute('aria-selected', 'false');
    });
    panels.forEach(p => {
      p.classList.remove('active');
      p.hidden = true;
    });

    // Activa solo la pestaña y el panel elegidos
    tab.classList.add('active');
    tab.setAttribute('aria-selected', 'true');
    const panel = document.getElementById('tab-' + target);
    panel.classList.add('active');
    panel.hidden = false;
  });
});

console.log('CultivaLab listo para el paso 2 🚀');