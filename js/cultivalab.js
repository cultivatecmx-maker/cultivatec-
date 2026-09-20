// ============================================================
// CULTIVALAB
//   1) Pestañas
//   2) Bloques (seleccionar y agrandar)
//   3) Circuitos (arrastrar, pines, cables, simulación)
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

    // La primera vez que se abre "Code", arrancamos Python en segundo plano
    if (target === 'code') cargarPython();
  });
});

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
  bateria:     { icono: 'ph-battery-full',      texto: 'Batería 9V' },
  boton:       { icono: 'ph-record',            texto: 'Botón'      },
  led:         { icono: 'ph-lightbulb',         texto: 'LED'        },
  resistencia: { icono: 'ph-sliders-horizontal',texto: 'Resistencia'},
};

const board = document.getElementById('sim-board');
const boardEmpty = document.getElementById('sim-board-empty');
const svgWires = document.getElementById('sim-wires');

let contador = 0;                 // id incremental para componentes
const circuito = { componentes: [], cables: [] }; // "memoria" del circuito
let pinSeleccionado = null;       // pin esperando su cable

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
    <i class="ph-fill ${info.icono}"></i>
    <span>${info.texto}</span>
    ${tipo === 'resistencia' ? '<span class="sim-comp-value" data-value>220 Ω</span>' : ''}
    <span class="sim-pin pin-a" data-pin="a"></span>
    <span class="sim-pin pin-b" data-pin="b"></span>
  `;

  // Guardamos este componente en nuestra "memoria" del circuito
  const dato = { id, tipo, presionado: false, ohms: 220 };
  circuito.componentes.push(dato);

  // Botón: clic en el cuerpo lo presiona/suelta
  if (tipo === 'boton') {
    el.addEventListener('click', e => {
      if (e.target.classList.contains('sim-pin')) return; // los pines tienen su propio clic
      dato.presionado = !dato.presionado;
      el.classList.toggle('presionado', dato.presionado);
      evaluarCircuito();
    });
  }

  // Resistencia: clic en el cuerpo permite cambiar su valor
  if (tipo === 'resistencia') {
    el.addEventListener('click', e => {
      if (e.target.classList.contains('sim-pin')) return;
      const nuevo = prompt('Nuevo valor de la resistencia (en ohms):', dato.ohms);
      if (nuevo === null) return;
      const num = parseFloat(nuevo);
      if (Number.isNaN(num) || num < 0) return;
      dato.ohms = num;
      el.querySelector('[data-value]').textContent = num + ' Ω';
    });
  }

  // Los dos pines: clic para empezar/terminar un cable
  el.querySelectorAll('.sim-pin').forEach(pinEl => {
    pinEl.addEventListener('click', e => {
      e.stopPropagation();
      manejarClicPin(id, pinEl.dataset.pin, pinEl);
    });
  });

  return el;
}

// ---- Arrastrar desde la paleta ----
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

// ---- Limpiar tablero ----
const btnLimpiar = document.getElementById('btn-limpiar');
if (btnLimpiar) {
  btnLimpiar.addEventListener('click', () => {
    board.querySelectorAll('.sim-comp').forEach(c => c.remove());
    circuito.componentes.length = 0;
    circuito.cables.length = 0;
    pinSeleccionado = null;
    svgWires.innerHTML = '';
    if (boardEmpty) boardEmpty.style.display = '';
  });
}

// ---- Manejar el clic en un pin: primer clic = origen, segundo clic = destino ----
function manejarClicPin(compId, lado, pinEl) {
  if (!pinSeleccionado) {
    pinSeleccionado = { compId, lado, pinEl };
    pinEl.classList.add('seleccionado');
    return;
  }

  // Si vuelve a hacer clic en el mismo pin, cancela la selección
  if (pinSeleccionado.compId === compId && pinSeleccionado.lado === lado) {
    pinEl.classList.remove('seleccionado');
    pinSeleccionado = null;
    return;
  }

  // Ya tenemos origen y destino: creamos el cable
  const origen = pinSeleccionado;
  origen.pinEl.classList.remove('seleccionado');
  crearCable(origen, { compId, lado, pinEl });
  pinSeleccionado = null;
}

// ---- Dibujar y guardar un cable entre dos pines ----
function crearCable(origen, destino) {
  circuito.cables.push({ a: origen, b: destino });

  const linea = document.createElementNS('http://www.w3.org/2000/svg', 'line');
  linea.setAttribute('class', 'sim-wire-line');
  actualizarLinea(linea, origen.pinEl, destino.pinEl);
  svgWires.appendChild(linea);

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

// ---- El "cerebro": decide qué LEDs deben encender ----
// Idea: armamos un grafo donde cada pin es un nodo. Dos pines quedan
// conectados si: (a) hay un cable entre ellos, o (b) son los dos pines
// del MISMO componente y ese componente "deja pasar la corriente"
// (una batería y un LED siempre; un botón solo si está presionado).
// Luego caminamos el grafo desde la batería: todo lo que se alcance
// está "con corriente".
function evaluarCircuito() {
  const vecinos = {}; // pinId -> [pinId, pinId, ...]
  const agregarArista = (p1, p2) => {
    (vecinos[p1] = vecinos[p1] || []).push(p2);
    (vecinos[p2] = vecinos[p2] || []).push(p1);
  };

  circuito.componentes.forEach(c => {
    const pinA = c.id + '-a', pinB = c.id + '-b';
    const conduce = c.tipo === 'boton' ? c.presionado : true;
    if (conduce) agregarArista(pinA, pinB);
  });

  circuito.cables.forEach(cable => {
    agregarArista(cable.a.compId + '-' + cable.a.lado, cable.b.compId + '-' + cable.b.lado);
  });

  const bateria = circuito.componentes.find(c => c.tipo === 'bateria');
  let conCorriente = new Set();

  if (bateria) {
    // Recorrido en anchura (BFS) desde el pin "a" de la batería
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

  // Un LED enciende solo si SUS DOS pines están alcanzados por la corriente
  // (es decir, forma parte de un camino cerrado con la batería)
  circuito.componentes.filter(c => c.tipo === 'led').forEach(led => {
    const encendido = conCorriente.has(led.id + '-a') && conCorriente.has(led.id + '-b');
    const elLed = document.getElementById(led.id);
    if (elLed) elLed.classList.toggle('encendido', encendido);
  });
}

// ============================================================
// 4) CODE - Python real en el navegador con Pyodide
// ============================================================
let pyodideListo = null; // promesa: evita cargar Pyodide dos veces

const btnRun = document.getElementById('btn-run-code');
const codeInput = document.getElementById('code-input');
const codeOutput = document.getElementById('code-output');
const codeStatus = document.getElementById('code-status');

function cargarPython() {
  if (pyodideListo) return pyodideListo; // ya se está cargando o ya cargó

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

      // Capturamos todo lo que el código imprima con print()
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

// Si llegamos desde un link tipo cultivalab.html#circuitos, abrimos esa pestaña directo
const tabDesdeHash = window.location.hash.replace('#', '');
if (tabDesdeHash) {
  const tabObjetivo = document.querySelector(`.lab-tab[data-tab="${tabDesdeHash}"]`);
  if (tabObjetivo) tabObjetivo.click();
}

console.log('CultivaLab: circuitos + bloques + code, listos 🚀');
