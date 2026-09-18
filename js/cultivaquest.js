// ============================================================
// CULTIVAQUEST — motor
//   - Dibuja el camino de niveles a partir de QUEST_UNITS
//   - Abre una lección en una ventana modal (tarjetas → cuestionario)
//   - Guarda el progreso en localStorage (por navegador, no en la nube)
// ============================================================

const QUEST_KEY = 'cultivaquest-progreso';

function cargarProgreso() {
  try {
    const guardado = localStorage.getItem(QUEST_KEY);
    return guardado ? JSON.parse(guardado) : { completadas: [] };
  } catch (e) {
    return { completadas: [] };
  }
}

function guardarProgreso(progreso) {
  try { localStorage.setItem(QUEST_KEY, JSON.stringify(progreso)); } catch (e) { /* si falla, no pasa nada grave */ }
}

// Aplana todas las lecciones de todas las unidades en un solo arreglo ordenado
const TODAS_LAS_LECCIONES = QUEST_UNITS.flatMap(u => u.lecciones.map(l => ({ ...l, unidad: u.nombre })));

let progreso = cargarProgreso();

// ---- Dibujar el camino ----
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

    if (estado !== 'bloqueada') {
      nodo.addEventListener('click', () => abrirLeccion(i));
    }

    pathEl.appendChild(nodo);
  });
}

// ---- Modal de la lección ----
const modal = document.getElementById('quest-modal');
const modalBody = document.getElementById('quest-modal-body');

function cerrarModal() {
  modal.classList.remove('open');
  modalBody.innerHTML = '';
}
document.getElementById('quest-modal-close')?.addEventListener('click', cerrarModal);
modal?.addEventListener('click', e => { if (e.target === modal) cerrarModal(); });

function abrirLeccion(index) {
  const leccion = TODAS_LAS_LECCIONES[index];
  let paso = 0; // 0..N-1 = tarjetas, N = cuestionario

  function render() {
    if (paso < leccion.cards.length) {
      renderTarjeta(leccion, paso);
    } else {
      renderCuestionario(leccion, index);
    }
  }

  function renderTarjeta(leccion, i) {
    const card = leccion.cards[i];
    const esUltima = i === leccion.cards.length - 1;
    modalBody.innerHTML = `
      <div class="quest-card quest-card-${card.tipo}">
        <span class="quest-card-tag">${etiquetaTipo(card.tipo)}</span>
        <h3>${card.titulo}</h3>
        <p>${card.texto}</p>
      </div>
      <div class="quest-modal-nav">
        <span class="quest-progress-dots">${leccion.cards.map((_, j) => `<i class="${j === i ? 'on' : ''}"></i>`).join('')}</span>
        <button class="btn btn-primary" id="quest-next">${esUltima ? 'Ir al cuestionario' : 'Siguiente'} <i class="ph-bold ph-arrow-right"></i></button>
      </div>
    `;
    document.getElementById('quest-next').addEventListener('click', () => { paso++; render(); });
  }

  function renderCuestionario(leccion, index, preguntaIdx = 0, aciertos = 0) {
    if (preguntaIdx >= leccion.preguntas.length) {
      // Terminó el cuestionario
      const gano = aciertos >= Math.ceil(leccion.preguntas.length * 0.6); // 60% para pasar
      modalBody.innerHTML = `
        <div class="quest-result ${gano ? 'ok' : 'retry'}">
          <i class="ph-fill ${gano ? 'ph-trophy' : 'ph-arrow-counter-clockwise'}"></i>
          <h3>${gano ? '¡Lección completada!' : 'Casi… ¡inténtalo de nuevo!'}</h3>
          <p>Acertaste ${aciertos} de ${leccion.preguntas.length} preguntas.</p>
          ${leccion.practice ? `<button class="btn btn-soft" id="quest-practicar"><i class="ph-bold ph-flask"></i> ${leccion.practice.etiqueta}</button>` : ''}
          <button class="btn btn-primary" id="quest-cerrar">${gano ? 'Continuar' : 'Reintentar'}</button>
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
        cerrarModal();
        dibujarCamino();
      });
      return;
    }

    const p = leccion.preguntas[preguntaIdx];
    modalBody.innerHTML = `
      <div class="quest-quiz">
        <span class="quest-card-tag">Pregunta ${preguntaIdx + 1} de ${leccion.preguntas.length}</span>
        <h3>${p.pregunta}</h3>
        <div class="quest-options" id="quest-options">
          ${p.opciones.map((op, i) => `<button class="quest-option" data-i="${i}">${op}</button>`).join('')}
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
          <button class="btn btn-primary" id="quest-siguiente-pregunta">Siguiente <i class="ph-bold ph-arrow-right"></i></button>
        `;
        document.getElementById('quest-siguiente-pregunta').addEventListener('click', () => {
          renderCuestionario(leccion, index, preguntaIdx + 1, aciertos + (correcto ? 1 : 0));
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

dibujarCamino();