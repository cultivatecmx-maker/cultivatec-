const fs = require('fs');
const path = require('path');

const blogDir = path.join(__dirname, 'blog');

// Specific files to process (the ones that don't have images yet)
const filesToProcess = [
  { name: 'competencias-robotica-mexico.html', img: '1581091226825-a6a2a5aee158' },
  { name: 'curso-completo-robotica-12-sesiones.html', img: '1517077304055-6e89af32c589' },
  { name: 'curso-de-verano-robotica-escuelas.html', img: '1503676260728-1c00da094a0b' },
  { name: 'curso-programacion-bloques-10-sesiones.html', img: '1519389953810-c5ccc89d414a' },
  { name: 'diseno-3d-en-primaria.html', img: '1620138546344-7b2c38516fc5' }, // 3d
  { name: 'ecosistema-stem-baja-california-nuevo-leon.html', img: '1504384308090-c894fdcc538d' },
  { name: 'eventos-robotica-ninos-mexico.html', img: '1509062522246-3755977927d7' },
  { name: 'habilidades-blandas-robotica-desarrolla.html', img: '1521737604893-d14cc237f11d' },
  { name: 'ia-socratica-en-el-aula.html', img: '1516321318423-f06f85e504b3' },
  { name: 'laboratorio-robotica-bajo-presupuesto.html', img: '1580894732444-8ecdaf068222' },
  { name: 'ley-de-ohm-sin-quemar-leds.html', img: '1517077304055-6e89af32c589' },
  { name: 'por-que-escuela-necesita-equipo-robotica-2027.html', img: '1503676260728-1c00da094a0b' },
  { name: 'preparar-equipo-torneo-robotica.html', img: '1509062522246-3755977927d7' },
  { name: 'programacion-por-bloques-a-codigo.html', img: '1498050108023-c5249f4df085' },
  { name: 'robot-seguidor-de-linea-paso-a-paso.html', img: '1581091226825-a6a2a5aee158' },
  { name: 'rol-padres-competencias-robotica.html', img: '1521737604893-d14cc237f11d' },
  { name: 'tendencias-robotica-educativa-2026-2027.html', img: '1519389953810-c5ccc89d414a' }
];

filesToProcess.forEach(fileObj => {
  const filePath = path.join(blogDir, fileObj.name);
  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Check if it already has the image to prevent duplicates
    if (!content.includes('<figure style="margin:0 0 32px 0;">')) {
      const figureHTML = `
      <figure style="margin:0 0 32px 0;">
        <img src="https://images.unsplash.com/photo-${fileObj.img}?q=80&w=1200&auto=format&fit=crop" alt="Imagen representativa del artículo" style="width:100%; border-radius:var(--r-md); box-shadow:var(--sh-sm); object-fit:cover; max-height:400px;">
      </figure>
`;
      content = content.replace('<div class="article">\n      ', '<div class="article">\n      ' + figureHTML);
      fs.writeFileSync(filePath, content, 'utf8');
      console.log('Updated ' + fileObj.name);
    }
  } else {
    console.log('File not found: ' + fileObj.name);
  }
});

console.log('Done.');
