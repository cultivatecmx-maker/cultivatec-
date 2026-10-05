// ============================================================
// CULTIVALAB
//   1) Pestañas
//   2) Bloques (seleccionar y agrandar)
//   3) Circuitos (arrastrar, MOVER, pines, cables borrables, simulación, sonido)
//   4) Code (Python real con Pyodide, carga diferida)
// ============================================================

// ---- 1) Pestañas ----
const tabs = document.querySelectorAll('.lab-tab');
const panels = document.querySelectorAll('.lab-panel');

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    const target = tab.dataset.tab;
    tabs.forEach(t => { t.classList.remove('active'); t.setAttribute('aria-selected', 'false'); });
    panels.forEach(p => { p.classList.remove('active'); p.hidden = true; });
    tab.classList.add('active');
    tab.setAttribute('aria-selected', 'true');
    const panel = document.getElementById('tab-' + target);
    panel.classList.add('active');
    panel.hidden = false;

    if (target === 'code') cargarPython();
    if (target === '3d') cargarVisor3D();
  });
});

// ---- Visor 3D (carga diferida, solo cuando se abre la pestaña) ----
let visor3DListo = null;
function cargarVisor3D() {
  if (visor3DListo) return visor3DListo;
  const host = document.getElementById('comp3d-host');
  if (!host) return;
  visor3DListo = import('./js/componente3d.js')
    .then(m => m.montarComponente3D(host))
    .catch(() => {
      host.innerHTML = '<p style="padding:40px;color:var(--slate-400)">No se pudo cargar la vista 3D en este navegador.</p>';
    });
  return visor3DListo;
}

// ============================================================
// 2) BLOQUES - clic para seleccionar y agrandar
// ============================================================
const blockChips = document.querySelectorAll('.block-chip');
blockChips.forEach(chip => {
  chip.addEventListener('click', () => {
    const yaEstaba = chip.classList.contains('selected');
    blockChips.forEach(c => c.classList.remove('selected'));
    if (!yaEstaba) chip.classList.add('selected');
  });
});

// ============================================================
// 3) CIRCUITOS
// ============================================================

const COMPONENTES = {
  bateria:      { icono: 'ph-battery-full',       texto: 'Batería 9V'  },
  boton:        { icono: 'ph-record',             texto: 'Botón'       },
  interruptor:  { icono: 'ph-toggle-left',         texto: 'Interruptor' },
  led:          { icono: 'ph-lightbulb',           texto: 'LED'         },
  resistencia:  { icono: 'ph-sliders-horizontal',  texto: 'Resistencia' },
  zumbador:     { icono: 'ph-speaker-high',        texto: 'Zumbador'    },
};

const board = document.getElementById('sim-board');
const boardEmpty = document.getElementById('sim-board-empty');
const svgWires = document.getElementById('sim-wires');

let contador = 0;
const circuito = { componentes: [], cables: [] };
let pinSeleccionado = null;

// ---- Crear un componente nuevo ----
function crearComponente(tipo, x, y) {
  contador++;
  const id = 'comp-' + contador;
  const info = COMPONENTES[tipo];

  const el = document.createElement('div');
  el.className = 'sim-comp sim-comp-' + tipo;
  el.id = id;
  el.dataset.type = tipo;
  el.style.left = x + 'px';
  el.style.top = y + 'px';

  el.innerHTML = `
    <button class="sim-comp-borrar" title="Quitar este componente" aria-label="Quitar">
      <i class="ph-bold ph-x"></i>
    </button>
    <i class="ph-fill ${info.icono}"></i>
    <span>${info.texto}</span>
    ${tipo === 'resistencia' ? '<span class="sim-comp-value" data-value>220 Ω</span>' : ''}
    <span class="sim-pin pin-a" data-pin="a"></span>
    <span class="sim-pin pin-b" data-pin="b"></span>
  `;

  const dato = { id, tipo, presionado: false, ohms: 220 };
  circuito.componentes.push(dato);

  if (tipo === 'boton') {
    el.addEventListener('click', e => {
      if (e.target.closest('.sim-pin, .sim-comp-borrar')) return;
      dato.presionado = !dato.presionado;
      el.classList.toggle('presionado', dato.presionado);
      evaluarCircuito();
    });
  }

  if (tipo === 'interruptor') {
    el.addEventListener('click', e => {
      if (e.target.closest('.sim-pin, .sim-comp-borrar')) return;
      dato.presionado = !dato.presionado;
      el.classList.toggle('presionado', dato.presionado);
      el.querySelector('i').className = 'ph-fill ' + (dato.presionado ? 'ph-toggle-right' : 'ph-toggle-left');
      evaluarCircuito();
    });
  }

  if (tipo === 'resistencia') {
    el.addEventListener('click', e => {
      if (e.target.closest('.sim-pin, .sim-comp-borrar')) return;
      const nuevo = prompt('Nuevo valor de la resistencia (en ohms):', dato.ohms);
      if (nuevo === null) return;
      const num = parseFloat(nuevo);
      if (Number.isNaN(num) || num < 0) return;
      dato.ohms = num;
      el.querySelector('[data-value]').textContent = num + ' Ω';
    });
  }

  el.querySelectorAll('.sim-pin').forEach(pinEl => {
    pinEl.addEventListener('click', e => {
      e.stopPropagation();
      manejarClicPin(id, pinEl.dataset.pin, pinEl);
    });
  });

  el.querySelector('.sim-comp-borrar').addEventListener('click', e => {
    e.stopPropagation();
    borrarComponente(id);
  });

  el.addEventListener('mousedown', e => {
    if (e.target.closest('.sim-pin, .sim-comp-borrar')) return;
    e.preventDefault();
    const rectBoard = board.getBoundingClientRect();
    const mover = (ev) => {
      let nx = ev.clientX - rectBoard.left;
      let ny = ev.clientY - rectBoard.top;
      nx = Math.max(0, Math.min(rectBoard.width, nx));
      ny = Math.max(0, Math.min(rectBoard.height, ny));
      el.style.left = nx + 'px';
      el.style.top = ny + 'px';
      redibujarCables();
    };
    const soltar = () => {
      document.removeEventListener('mousemove', mover);
      document.removeEventListener('mouseup', soltar);
    };
    document.addEventListener('mousemove', mover);
    document.addEventListener('mouseup', soltar);
  });

  return el;
}

function borrarComponente(id) {
  circuito.componentes = circuito.componentes.filter(c => c.id !== id);
  circuito.cables = circuito.cables.filter(cable => {
    const afecta = cable.a.compId === id || cable.b.compId === id;
    if (afecta) cable.linea.remove();
    return !afecta;
  });
  document.getElementById(id)?.remove();
  if (circuito.componentes.length === 0 && boardEmpty) boardEmpty.style.display = '';
  evaluarCircuito();
}

document.querySelectorAll('.sim-piece').forEach(pieza => {
  pieza.addEventListener('dragstart', e => {
    e.dataTransfer.setData('text/plain', pieza.dataset.type);
  });
});

if (board) {
  board.addEventListener('dragover', e => {
    e.preventDefault();
    board.classList.add('drag-over');
  });
  board.addEventListener('dragleave', () => board.classList.remove('drag-over'));

  board.addEventListener('drop', e => {
    e.preventDefault();
    board.classList.remove('drag-over');
    const tipo = e.dataTransfer.getData('text/plain');
    if (!tipo) return;

    const rect = board.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const comp = crearComponente(tipo, x, y);
    board.appendChild(comp);
    if (boardEmpty) boardEmpty.style.display = 'none';
  });
}

const btnLimpiar = document.getElementById('btn-limpiar');
if (btnLimpiar) {
  btnLimpiar.addEventListener('click', () => {
    board.querySelectorAll('.sim-comp').forEach(c => c.remove());
    circuito.componentes.length = 0;
    circuito.cables.length = 0;
    pinSeleccionado = null;
    svgWires.innerHTML = '';
    if (boardEmpty) boardEmpty.style.display = '';
    pararZumbadores();
  });
}

function manejarClicPin(compId, lado, pinEl) {
  if (!pinSeleccionado) {
    pinSeleccionado = { compId, lado, pinEl };
    pinEl.classList.add('seleccionado');
    return;
  }

  if (pinSeleccionado.compId === compId && pinSeleccionado.lado === lado) {
    pinEl.classList.remove('seleccionado');
    pinSeleccionado = null;
    return;
  }

  const origen = pinSeleccionado;
  origen.pinEl.classList.remove('seleccionado');
  crearCable(origen, { compId, lado, pinEl });
  pinSeleccionado = null;
}

function crearCable(origen, destino) {
  const linea = document.createElementNS('http://www.w3.org/2000/svg', 'line');
  linea.setAttribute('class', 'sim-wire-line');
  linea.style.cursor = 'pointer';

  const cable = { a: origen, b: destino, linea };
  circuito.cables.push(cable);

  actualizarLinea(linea, origen.pinEl, destino.pinEl);
  svgWires.appendChild(linea);

  linea.addEventListener('click', () => {
    circuito.cables = circuito.cables.filter(c => c !== cable);
    linea.remove();
    evaluarCircuito();
  });

  evaluarCircuito();
}

function actualizarLinea(linea, pinA, pinB) {
  const rectBoard = board.getBoundingClientRect();
  const a = pinA.getBoundingClientRect();
  const b = pinB.getBoundingClientRect();
  linea.setAttribute('x1', a.left + a.width / 2 - rectBoard.left);
  linea.setAttribute('y1', a.top + a.height / 2 - rectBoard.top);
  linea.setAttribute('x2', b.left + b.width / 2 - rectBoard.left);
  linea.setAttribute('y2', b.top + b.height / 2 - rectBoard.top);
}

function redibujarCables() {
  circuito.cables.forEach(cable => actualizarLinea(cable.linea, cable.a.pinEl, cable.b.pinEl));
}

function evaluarCircuito() {
  const vecinos = {};
  const agregarArista = (p1, p2) => {
    (vecinos[p1] = vecinos[p1] || []).push(p2);
    (vecinos[p2] = vecinos[p2] || []).push(p1);
  };

  circuito.componentes.forEach(c => {
    const pinA = c.id + '-a', pinB = c.id + '-b';
    const conduce = (c.tipo === 'boton' || c.tipo === 'interruptor') ? c.presionado : true;
    if (conduce) agregarArista(pinA, pinB);
  });

  circuito.cables.forEach(cable => {
    agregarArista(cable.a.compId + '-' + cable.a.lado, cable.b.compId + '-' + cable.b.lado);
  });

  const bateria = circuito.componentes.find(c => c.tipo === 'bateria');
  let conCorriente = new Set();

  if (bateria) {
    const inicio = bateria.id + '-a';
    const visitados = new Set([inicio]);
    const cola = [inicio];
    while (cola.length) {
      const actual = cola.shift();
      (vecinos[actual] || []).forEach(vec => {
        if (!visitados.has(vec)) { visitados.add(vec); cola.push(vec); }
      });
    }
    conCorriente = visitados;
  }

  circuito.componentes.filter(c => c.tipo === 'led').forEach(led => {
    const encendido = conCorriente.has(led.id + '-a') && conCorriente.has(led.id + '-b');
    document.getElementById(led.id)?.classList.toggle('encendido', encendido);
  });

  circuito.componentes.filter(c => c.tipo === 'zumbador').forEach(zum => {
    const encendido = conCorriente.has(zum.id + '-a') && conCorriente.has(zum.id + '-b');
    const el = document.getElementById(zum.id);
    if (el) el.classList.toggle('encendido', encendido);
    if (encendido) iniciarZumbador(zum.id); else detenerZumbador(zum.id);
  });
}

let audioCtx = null;
const osciladores = {};
function iniciarZumbador(id) {
  if (osciladores[id]) return;
  try {
    audioCtx = audioCtx || new (window.AudioContext || window.webkitAudioContext)();
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.type = 'square';
    osc.frequency.value = 440;
    gain.gain.value = 0.05;
    osc.connect(gain).connect(audioCtx.destination);
    osc.start();
    osciladores[id] = { osc, gain };
  } catch (e) { /* si el navegador bloquea audio sin interaccion, no pasa nada grave */ }
}
function detenerZumbador(id) {
  if (osciladores[id]) {
    osciladores[id].osc.stop();
    delete osciladores[id];
  }
}
function pararZumbadores() {
  Object.keys(osciladores).forEach(detenerZumbador);
}

// ============================================================
// 4) CODE - Python real en el navegador con Pyodide
// ============================================================
let pyodideListo = null;

const btnRun = document.getElementById('btn-run-code');
const codeInput = document.getElementById('code-input');
const codeOutput = document.getElementById('code-output');
const codeStatus = document.getElementById('code-status');

function cargarPython() {
  if (pyodideListo) return pyodideListo;

  if (codeStatus) codeStatus.textContent = 'Cargando Python... (solo la primera vez, ~10s)';
  if (btnRun) btnRun.disabled = true;

  pyodideListo = new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = 'https://cdn.jsdelivr.net/pyodide/v0.26.4/full/pyodide.js';
    script.onload = async () => {
      try {
        const pyodide = await loadPyodide();
        if (codeStatus) codeStatus.textContent = 'Python listo ✅';
        if (btnRun) btnRun.disabled = false;
        resolve(pyodide);
      } catch (err) {
        reject(err);
      }
    };
    script.onerror = () => reject(new Error('No se pudo descargar Pyodide'));
    document.body.appendChild(script);
  });

  return pyodideListo;
}

if (btnRun) {
  btnRun.addEventListener('click', async () => {
    btnRun.disabled = true;
    codeOutput.classList.remove('error');
    codeOutput.textContent = 'Ejecutando...';

    try {
      const pyodide = await cargarPython();
      let salida = '';
      pyodide.setStdout({ batched: (msg) => { salida += msg + '\n'; } });
      pyodide.setStderr({ batched: (msg) => { salida += msg + '\n'; } });
      await pyodide.runPythonAsync(codeInput.value);
      codeOutput.textContent = salida || '(el código no imprimió nada - usa print() para ver resultados)';
    } catch (err) {
      codeOutput.classList.add('error');
      codeOutput.textContent = String(err);
    } finally {
      btnRun.disabled = false;
    }
  });
}

const tabDesdeHash = window.location.hash.replace('#', '');
if (tabDesdeHash) {
  const tabObjetivo = document.querySelector(`.lab-tab[data-tab="${tabDesdeHash}"]`);
  if (tabObjetivo) tabObjetivo.click();
}

console.log('CultivaLab: circuitos + bloques + code, listos 🚀');
