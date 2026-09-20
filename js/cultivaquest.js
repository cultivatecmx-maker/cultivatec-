// ============================================================
// CULTIVAQUEST - motor (v2, con mejor diseño e interacción)
// ============================================================

const QUEST_KEY = 'cultivaquest-progreso';
const LETRAS = ['A', 'B', 'C', 'D', 'E'];

function cargarProgreso() {
  try {
    const guardado = localStorage.getItem(QUEST_KEY);
    return guardado ? JSON.parse(guardado) : { completadas: [] };
  } catch (e) {
    return { completadas: [] };
  }
}
function guardarProgreso(progreso) {
  try { localStorage.setItem(QUEST_KEY, JSON.stringify(progreso)); } catch (e) { /* sin problema */ }
}

const TODAS_LAS_LECCIONES = QUEST_UNITS.flatMap(u => u.lecciones.map(l => ({ ...l, unidad: u.nombre })));
let progreso = cargarProgreso();

const pathEl = document.getElementById('quest-path');

function estadoDeLeccion(index) {
  const leccion = TODAS_LAS_LECCIONES[index];
  if (progreso.completadas.includes(leccion.id)) return 'completa';
  const anterior = TODAS_LAS_LECCIONES[index - 1];
  if (!anterior || progreso.completadas.includes(anterior.id)) return 'desbloqueada';
  return 'bloqueada';
}

function dibujarCamino() {
  if (!pathEl) return;
  pathEl.innerHTML = '';

  TODAS_LAS_LECCIONES.forEach((leccion, i) => {
    const estado = estadoDeLeccion(i);

    const nodo = document.createElement('button');
    nodo.type = 'button';
    nodo.className = 'quest-node ' + (estado === 'bloqueada' ? 'locked' : 'unlocked') + (estado === 'completa' ? ' quest-node-done' : '');
    nodo.disabled = estado === 'bloqueada';

    nodo.innerHTML = `
      <span class="quest-node-circle">
        ${estado === 'bloqueada' ? '<i class="ph-fill ph-lock-simple"></i>' : (estado === 'completa' ? '<i class="ph-fill ph-check-bold"></i>' : `<span class="quest-node-emoji">${leccion.emoji}</span>`)}
      </span>
      <span class="quest-node-label">${leccion.titulo}<br><small>${leccion.unidad}</small></span>
    `;

    if (estado !== 'bloqueada') nodo.addEventListener('click', () => abrirLeccion(i));
    pathEl.appendChild(nodo);
  });
}

// ---- Modal ----
const modal = document.getElementById('quest-modal');
const modalBody = document.getElementById('quest-modal-body');

function cerrarModal() {
  modal.classList.remove('open');
  setTimeout(() => { modalBody.innerHTML = ''; }, 200);
}
document.getElementById('quest-modal-close')?.addEventListener('click', cerrarModal);
modal?.addEventListener('click', e => { if (e.target === modal) cerrarModal(); });

function abrirLeccion(index) {
  const leccion = TODAS_LAS_LECCIONES[index];
  let paso = 0;

  function render() {
    if (paso < leccion.cards.length) renderTarjeta(paso);
    else renderCuestionario(index, 0, 0);
  }

  function encabezado(porcentaje) {
    return `
      <div class="quest-modal-header">
        <div class="quest-modal-emoji">${leccion.emoji}</div>
        <h2>${leccion.titulo}</h2>
      </div>
      <div class="quest-modal-body">
        <div class="quest-progress-bar"><div class="quest-progress-bar-fill" style="width:${porcentaje}%"></div></div>
        <div id="quest-slot"></div>
      </div>
    `;
  }

  function renderTarjeta(i) {
    const card = leccion.cards[i];
    const esUltima = i === leccion.cards.length - 1;
    const porcentaje = Math.round(((i) / (leccion.cards.length + leccion.preguntas.length)) * 100);

    modalBody.innerHTML = encabezado(porcentaje);
    document.getElementById('quest-slot').innerHTML = `
      <div class="quest-card quest-card-${card.tipo}">
        <span class="quest-card-tag"><i class="ph-fill ${iconoTipo(card.tipo)}"></i> ${etiquetaTipo(card.tipo)}</span>
        <h3>${card.titulo}</h3>
        <p>${card.texto}</p>
      </div>
      <div class="quest-modal-nav">
        <button class="btn btn-primary" id="quest-next">${esUltima ? 'Ir al cuestionario' : 'Siguiente'} <i class="ph-bold ph-arrow-right"></i></button>
      </div>
    `;
    document.getElementById('quest-next').addEventListener('click', () => { paso++; render(); });
  }

  function renderCuestionario(index, preguntaIdx, aciertos) {
    const leccion = TODAS_LAS_LECCIONES[index];

    if (preguntaIdx >= leccion.preguntas.length) {
      const gano = aciertos >= Math.ceil(leccion.preguntas.length * 0.6);
      const xp = gano ? aciertos * 10 : 0;

      modalBody.innerHTML = `
        <div class="quest-modal-header">
          <div class="quest-modal-emoji">${gano ? '🎉' : '💪'}</div>
          <h2>${gano ? '¡Lección completada!' : 'Casi lo logras'}</h2>
        </div>
        <div class="quest-modal-body">
          <div class="quest-result ${gano ? 'ok' : 'retry'}">
            <div class="quest-result-icon">${gano ? '<img src="img/valeonpulgararriba.png" alt="Vale celebrando" class="quest-result-vale">' : '<i class="ph-fill ph-arrow-counter-clockwise"></i>'}</div>
            ${gano ? `<span class="quest-result-xp">+${xp} XP</span>` : ''}
            <h3>Acertaste ${aciertos} de ${leccion.preguntas.length}</h3>
            <p>${gano ? '¡Muy bien hecho! Sigues avanzando en tu ruta.' : 'Repasa las tarjetas e inténtalo otra vez.'}</p>
            ${leccion.practice ? `<button class="btn btn-soft" id="quest-practicar"><i class="ph-bold ph-flask"></i> ${leccion.practice.etiqueta}</button>` : ''}
            <button class="btn btn-primary" id="quest-cerrar">${gano ? 'Continuar' : 'Reintentar'}</button>
          </div>
        </div>
      `;

      if (gano && !progreso.completadas.includes(leccion.id)) {
        progreso.completadas.push(leccion.id);
        guardarProgreso(progreso);
      }
      document.getElementById('quest-practicar')?.addEventListener('click', () => {
        window.location.href = 'cultivalab.html#' + leccion.practice.tipo;
      });
      document.getElementById('quest-cerrar').addEventListener('click', () => {
        if (gano) { cerrarModal(); dibujarCamino(); }
        else { paso = 0; render(); } // reintentar desde las tarjetas
      });
      return;
    }

    const p = leccion.preguntas[preguntaIdx];
    const porcentaje = Math.round(((leccion.cards.length + preguntaIdx) / (leccion.cards.length + leccion.preguntas.length)) * 100);

    modalBody.innerHTML = encabezado(porcentaje);
    document.getElementById('quest-slot').innerHTML = `
      <div class="quest-quiz">
        <span class="quest-card-tag"><i class="ph-fill ph-question"></i> Pregunta ${preguntaIdx + 1} de ${leccion.preguntas.length}</span>
        <h3>${p.pregunta}</h3>
        <div class="quest-options" id="quest-options">
          ${p.opciones.map((op, i) => `
            <button class="quest-option" data-i="${i}">
              <span class="quest-option-badge">${LETRAS[i]}</span> ${op}
            </button>`).join('')}
        </div>
        <div id="quest-feedback"></div>
      </div>
    `;

    document.querySelectorAll('.quest-option').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.quest-option').forEach(b => b.disabled = true);
        const i = parseInt(btn.dataset.i, 10);
        const correcto = i === p.correcta;
        btn.classList.add(correcto ? 'correct' : 'wrong');
        if (!correcto) document.querySelector(`.quest-option[data-i="${p.correcta}"]`).classList.add('correct');

        document.getElementById('quest-feedback').innerHTML = `
          <p class="quest-explicacion"><i class="ph-fill ${correcto ? 'ph-check-circle' : 'ph-x-circle'}"></i> ${p.explicacion}</p>
          <button class="btn btn-primary" id="quest-siguiente-pregunta" style="width:100%;justify-content:center">Siguiente <i class="ph-bold ph-arrow-right"></i></button>
        `;
        document.getElementById('quest-siguiente-pregunta').addEventListener('click', () => {
          renderCuestionario(index, preguntaIdx + 1, aciertos + (correcto ? 1 : 0));
        });
      });
    });
  }

  modal.classList.add('open');
  render();
}

function etiquetaTipo(tipo) {
  return { concepto: 'Concepto', ejemplo: 'Ejemplo', dato: 'Dato curioso', consejo: 'Consejo' }[tipo] || tipo;
}
function iconoTipo(tipo) {
  return { concepto: 'ph-lightbulb', ejemplo: 'ph-eye', dato: 'ph-sparkle', consejo: 'ph-hand-heart' }[tipo] || 'ph-info';
}

dibujarCamino();
