/* sitio.js — comportamientos del modelo comercial (sin librerias) */
(function () {
  'use strict';
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };

  /* Barra fija en movil: se oculta cuando el formulario esta a la vista */
  var barra = $('#cta-movil');
  if (barra) {
    document.body.classList.add('tiene-cta-movil');
    var destino = $('#formulario');
    if (destino && 'IntersectionObserver' in window) {
      new IntersectionObserver(function (es) { barra.classList.toggle('oculta', es[0].isIntersecting); }, { threshold: 0.15 }).observe(destino);
    }
  }

  /* Compartir */
  function aviso(txt) {
    var t = $('.toast') || document.body.appendChild(Object.assign(document.createElement('div'), { className: 'toast', role: 'status' }));
    t.textContent = txt; t.classList.add('visible');
    setTimeout(function () { t.classList.remove('visible'); }, 2400);
  }
  $$('[data-compartir]').forEach(function (b) {
    b.addEventListener('click', function () {
      var datos = { title: document.title, url: location.href.split('#')[0] };
      if (navigator.share) { navigator.share(datos).catch(function () {}); return; }
      if (navigator.clipboard) { navigator.clipboard.writeText(datos.url).then(function () { aviso('Enlace copiado'); }); }
      else { aviso(datos.url); }
    });
  });

  /* Formularios: validacion accesible + envio real a FormSubmit */
  var RE_MAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
  $$('form[data-formulario]').forEach(function (f) {
    var estado = $('.form-estado', f);
    var boton = $('button[type="submit"]', f);
    function error(campo, msg) {
      var p = $('#err-' + campo.id, f);
      campo.setAttribute('aria-invalid', msg ? 'true' : 'false');
      if (p) p.textContent = msg || '';
    }
    $$('[required]', f).forEach(function (c) {
      c.addEventListener('input', function () { if (c.getAttribute('aria-invalid') === 'true') validar(c); });
    });
    function validar(c) {
      var v = (c.type === 'checkbox') ? c.checked : c.value.trim();
      if (!v) { error(c, c.type === 'checkbox' ? 'Necesitas aceptar el aviso de privacidad para enviar.' : 'Este campo es obligatorio.'); return false; }
      if (c.type === 'email' && !RE_MAIL.test(v)) { error(c, 'Escribe un correo válido, por ejemplo nombre@escuela.mx.'); return false; }
      error(c, ''); return true;
    }
    f.addEventListener('submit', function (e) {
      e.preventDefault();
      if ($('.hp input', f) && $('.hp input', f).value) return;
      var primero = null;
      $$('[required]', f).forEach(function (c) { if (!validar(c) && !primero) primero = c; });
      if (primero) { estado.className = 'form-estado error'; estado.textContent = 'Revisa los campos marcados para poder enviar.'; primero.focus(); return; }
      var accion = f.getAttribute('action').replace('formsubmit.co/', 'formsubmit.co/ajax/');
      boton.disabled = true; var txt = boton.textContent; boton.textContent = 'Enviando…';
      estado.className = 'form-estado ok'; estado.textContent = 'Enviando tu solicitud…';
      fetch(accion, { method: 'POST', headers: { Accept: 'application/json' }, body: new FormData(f) })
        .then(function (r) { return r.json().catch(function () { return {}; }).then(function (j) { if (!r.ok || j.success === 'false') throw new Error('x'); }); })
        .then(function () { location.href = f.getAttribute('data-gracias') || 'gracias.html'; })
        .catch(function () {
          boton.disabled = false; boton.textContent = txt;
          estado.className = 'form-estado error';
          estado.innerHTML = 'No pudimos enviar el formulario. Inténtalo de nuevo o escríbenos a <a href="mailto:ventas@cultivatec.com.mx">ventas@cultivatec.com.mx</a>.';
        });
    });
  });
})();
