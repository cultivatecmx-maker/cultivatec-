/* ============================================================
   CULTIVAQUEST — vista previa de la ruta de niveles
   ============================================================ */

.sim-hero{
  padding:140px 0 40px;
  background:linear-gradient(165deg, var(--sim-bg) 0%, #fff 100%);
  text-align:center;
}
.sim-hero .crumbs{justify-content:center}
.sim-hero .tag-dark{
  color:var(--sim-dk);background:#fff;border:1px solid var(--sim-bd);
  display:inline-flex;align-items:center;gap:8px;
  padding:8px 16px;border-radius:var(--r-full);margin-bottom:16px;
  font-weight:600;font-size:.875rem;
}

.quest-path{
  max-width:420px;margin:0 auto;
  display:flex;flex-direction:column;align-items:center;gap:8px;
  position:relative;
}
/* Línea punteada detrás de los nodos */
.quest-path::before{
  content:"";
  position:absolute;top:0;bottom:0;left:50%;
  border-left:3px dashed var(--slate-200);
  transform:translateX(-50%);
  z-index:0;
}

.quest-node{
  position:relative;z-index:1;
  display:flex;flex-direction:column;align-items:center;gap:8px;
  padding:18px 0;
  /* Zigzag: nodos pares a la izquierda, impares a la derecha */
  align-self:center;
}
.quest-node:nth-child(even){ transform:translateX(-70px); }
.quest-node:nth-child(odd){ transform:translateX(70px); }
@media (max-width:480px){
  .quest-node:nth-child(even){ transform:translateX(-32px); }
  .quest-node:nth-child(odd){ transform:translateX(32px); }
}

.quest-node-circle{
  width:68px;height:68px;border-radius:50%;
  display:flex;align-items:center;justify-content:center;
  font-size:1.6rem;
  box-shadow:var(--sh-md);
  border:4px solid #fff;
}
.quest-node.unlocked .quest-node-circle{
  background:linear-gradient(160deg, var(--sim), var(--sim-dk));
  color:#fff;
}
.quest-node.locked .quest-node-circle{
  background:var(--slate-200);
  color:var(--slate-400);
}
.quest-node-boss .quest-node-circle{
  width:78px;height:78px;font-size:1.9rem;
}

.quest-node-label{
  text-align:center;font-size:.8125rem;font-weight:600;color:var(--slate-600);
  line-height:1.4;
}
.quest-node-label small{font-weight:400;color:var(--slate-400)}
.quest-node.locked .quest-node-label{color:var(--slate-400)}

.quest-note{
  text-align:center;color:var(--slate-500);font-size:.875rem;
  display:flex;align-items:center;justify-content:center;gap:8px;
  margin-top:32px;
}
.quest-note i{color:var(--sim-dk)}

/* ============================================================
   MOTOR DE LECCIONES (modal, tarjetas, cuestionario) — v2
   ============================================================ */

.quest-node{
  cursor:pointer; border:none; background:none; font-family:inherit;
  transition:transform .15s var(--ease);
}
.quest-node:hover:not(:disabled){ transform:scale(1.06) translateX(var(--tx, 0)); }
.quest-node:nth-child(even):hover:not(:disabled){ transform:translateX(-70px) scale(1.06); }
.quest-node:nth-child(odd):hover:not(:disabled){ transform:translateX(70px) scale(1.06); }
.quest-node:disabled{ cursor:not-allowed }
.quest-node-emoji{ font-size:1.6rem; line-height:1 }
.quest-node.quest-node-done .quest-node-circle{
  background:linear-gradient(160deg,#059669,#047857); color:#fff;
  animation:questPop .4s var(--ease);
}
@keyframes questPop{ 0%{transform:scale(.7)} 60%{transform:scale(1.12)} 100%{transform:scale(1)} }

/* ---- Fondo oscuro + caja del modal ---- */
.quest-modal{
  position:fixed; inset:0; z-index:200;
  background:rgba(15,23,42,.6);
  backdrop-filter:blur(3px);
  display:none; align-items:center; justify-content:center; padding:20px;
  opacity:0; transition:opacity .2s var(--ease);
}
.quest-modal.open{ display:flex; opacity:1 }
.quest-modal-box{
  background:#fff; border-radius:24px; max-width:540px; width:100%;
  max-height:88vh; overflow-y:auto; position:relative;
  box-shadow:0 24px 60px -12px rgba(15,23,42,.35);
  transform:scale(.92) translateY(12px); transition:transform .25s cubic-bezier(.34,1.56,.64,1);
}
.quest-modal.open .quest-modal-box{ transform:scale(1) translateY(0) }

.quest-modal-close{
  position:absolute; top:16px; right:16px; z-index:2;
  width:34px; height:34px; border-radius:50%; border:none;
  background:rgba(255,255,255,.9); color:var(--slate-600); cursor:pointer;
  display:flex; align-items:center; justify-content:center;
  box-shadow:var(--sh-sm);
  transition:background .15s var(--ease), transform .15s var(--ease);
}
.quest-modal-close:hover{ background:#fff; transform:rotate(90deg) }

/* ---- Encabezado con el emoji de la lección ---- */
.quest-modal-header{
  background:linear-gradient(155deg, var(--sim), var(--sim-dk));
  padding:28px 28px 20px; color:#fff; text-align:center;
  border-radius:24px 24px 0 0;
}
.quest-modal-emoji{
  width:64px;height:64px;margin:0 auto 10px;border-radius:50%;
  background:rgba(255,255,255,.18); display:flex;align-items:center;justify-content:center;
  font-size:2rem; box-shadow:0 0 0 6px rgba(255,255,255,.12);
}
.quest-modal-header h2{ font-family:var(--font-display); font-size:1.15rem; margin:0; }

.quest-modal-body{ padding:24px 28px 28px }

/* ---- Barra de progreso ---- */
.quest-progress-bar{
  height:6px; border-radius:var(--r-full); background:var(--slate-100); overflow:hidden; margin-bottom:20px;
}
.quest-progress-bar-fill{
  height:100%; background:linear-gradient(90deg, var(--sim), var(--sim-dk));
  border-radius:var(--r-full); transition:width .35s var(--ease);
}

/* ---- Tarjetas de contenido ---- */
.quest-card{
  text-align:left; animation:questFadeIn .3s var(--ease);
  border-left:4px solid var(--sim-dk); background:var(--slate-50);
  border-radius:0 var(--r-md) var(--r-md) 0; padding:20px 20px 20px 18px;
}
.quest-card-ejemplo{ border-color:#7C3AED; background:#F5F3FF }
.quest-card-dato{ border-color:#F59E0B; background:#FFFBEB }
.quest-card-consejo{ border-color:#059669; background:#ECFDF5 }
@keyframes questFadeIn{ from{opacity:0; transform:translateX(10px)} to{opacity:1; transform:translateX(0)} }

.quest-card-tag{
  display:inline-flex; align-items:center; gap:6px;
  font-size:.6875rem; font-weight:700; text-transform:uppercase; letter-spacing:.04em;
  padding:4px 10px; border-radius:var(--r-full); margin-bottom:12px;
  background:#fff; color:var(--sim-dk); box-shadow:var(--sh-sm);
}
.quest-card h3{ font-family:var(--font-display); font-size:1.2rem; color:var(--slate-800); margin:0 0 8px }
.quest-card p{ color:var(--slate-600); line-height:1.65; margin:0; font-size:.9375rem }

.quest-modal-nav{
  display:flex; align-items:center; justify-content:flex-end;
  margin-top:22px;
}
.quest-modal-nav .btn{ width:100%; justify-content:center }

/* ---- Cuestionario ---- */
.quest-quiz{ animation:questFadeIn .3s var(--ease) }
.quest-quiz h3{ font-family:var(--font-display); font-size:1.15rem; color:var(--slate-800); margin:0 0 18px }
.quest-options{ display:flex; flex-direction:column; gap:10px }
.quest-option{
  display:flex; align-items:center; gap:12px; text-align:left;
  padding:14px 16px; border-radius:14px;
  border:2px solid var(--slate-200); background:#fff; cursor:pointer;
  font-size:.9375rem; color:var(--slate-700);
  transition:border-color .15s var(--ease), background .15s var(--ease), transform .1s var(--ease);
}
.quest-option:hover:not(:disabled){ border-color:var(--sim-bd); background:var(--sim-bg); transform:translateX(3px) }
.quest-option:active:not(:disabled){ transform:scale(.98) }
.quest-option:disabled{ cursor:default }
.quest-option-badge{
  width:26px;height:26px;flex-shrink:0;border-radius:50%;
  background:var(--slate-100); color:var(--slate-500);
  display:flex;align-items:center;justify-content:center;
  font-size:.75rem; font-weight:700;
  transition:background .15s var(--ease), color .15s var(--ease);
}
.quest-option.correct{ border-color:#059669; background:#ECFDF5; color:#047857; font-weight:600; animation:questPop .3s var(--ease) }
.quest-option.correct .quest-option-badge{ background:#059669; color:#fff }
.quest-option.wrong{ border-color:#DC2626; background:#FEF2F2; color:#B91C1C }
.quest-option.wrong .quest-option-badge{ background:#DC2626; color:#fff }

.quest-explicacion{
  display:flex; align-items:flex-start; gap:10px;
  background:var(--slate-50); border-radius:14px; padding:14px 16px;
  font-size:.875rem; color:var(--slate-600); margin:18px 0;
  animation:questFadeIn .25s var(--ease);
}
.quest-explicacion i{ color:var(--sim-dk); flex-shrink:0; margin-top:2px; font-size:1.1rem }

/* ---- Resultado final ---- */
.quest-result{
  text-align:center; display:flex; flex-direction:column; align-items:center; gap:8px;
  animation:questFadeIn .3s var(--ease);
}
.quest-result-icon{
  width:84px;height:84px;border-radius:50%;
  display:flex;align-items:center;justify-content:center; font-size:2.5rem;
  margin-bottom:6px; animation:questBounce .6s var(--ease);
}
.quest-result.ok .quest-result-icon{ background:linear-gradient(160deg,#FDE68A,#F59E0B); color:#fff }
.quest-result.retry .quest-result-icon{ background:var(--slate-100); color:var(--slate-400) }
@keyframes questBounce{
  0%{ transform:scale(0) } 50%{ transform:scale(1.15) } 75%{ transform:scale(.95) } 100%{ transform:scale(1) }
}
.quest-result h3{ font-family:var(--font-display); font-size:1.3rem; color:var(--slate-800); margin:0 }
.quest-result p{ color:var(--slate-500); margin:0 0 6px }
.quest-result-xp{
  font-weight:700; color:#B45309; background:#FFFBEB; border:1px solid #FDE68A;
  padding:4px 14px; border-radius:var(--r-full); font-size:.8125rem; margin-bottom:8px;
}
.quest-result .btn{ width:100%; justify-content:center }