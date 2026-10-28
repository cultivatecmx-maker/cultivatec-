const fs = require('fs');
const path = require('path');

const baseUrl = 'https://cultivatec.com.mx';
const EXCLUIR = ['404.html', 'gracias.html', 'school.html', 'cultivalab.html', 'cultivaquest.html', 'kits.html', 'plataforma.html'];
const _n = 'noticias'; // eslint-disable-line
const EXCLUIR_BLOG = ['rol-ia-socratica-aula-futuro.html', 'ia-socratica-en-el-aula.html'];
const rootDir = __dirname;
const blogDir = path.join(__dirname, 'blog');

let urls = [];

// Get root HTML files
const rootFiles = fs.readdirSync(rootDir).filter(f => f.endsWith('.html') && !EXCLUIR.includes(f));
rootFiles.forEach(f => {
  const urlPath = f === 'index.html' ? '' : f;
  urls.push({
    loc: baseUrl + '/' + urlPath,
    lastmod: new Date().toISOString().split('T')[0],
    priority: f === 'index.html' ? '1.0' : '0.8'
  });
});

// Get blog HTML files
if (fs.existsSync(blogDir)) {
  const blogFiles = fs.readdirSync(blogDir).filter(f => f.endsWith('.html'));
  blogFiles.forEach(f => {
    urls.push({
      loc: baseUrl + '/blog/' + f,
      lastmod: new Date().toISOString().split('T')[0],
      priority: '0.64'
    });
  });
}

// Guías de recursos
const recDir = path.join(__dirname, 'recursos');
if (fs.existsSync(recDir)) {
  fs.readdirSync(recDir).filter(f => f.endsWith('.html')).forEach(f => {
    urls.push({ loc: baseUrl + '/recursos/' + f, lastmod: new Date().toISOString().split('T')[0], priority: '0.7' });
  });
}

// Noticias
const notDir = path.join(__dirname, 'noticias');
if (fs.existsSync(notDir)) {
  fs.readdirSync(notDir).filter(f => f.endsWith('.html')).forEach(f => {
    urls.push({ loc: baseUrl + '/noticias/' + f, lastmod: new Date().toISOString().split('T')[0], priority: '0.6' });
  });
}

// Generate XML
let xml = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n';

urls.forEach(u => {
  xml += '  <url>\n    <loc>' + u.loc + '</loc>\n    <lastmod>' + u.lastmod + '</lastmod>\n    <priority>' + u.priority + '</priority>\n  </url>\n';
});

xml += '</urlset>';

fs.writeFileSync(path.join(rootDir, 'sitemap.xml'), xml, 'utf8');
console.log('sitemap.xml generated with ' + urls.length + ' URLs.');

// Generate robots.txt
const bots = ["OAI-SearchBot", "ChatGPT-User", "GPTBot", "Claude-SearchBot", "Claude-User", "ClaudeBot", "PerplexityBot", "Perplexity-User", "Google-Extended", "Applebot-Extended"];
const robotsTxt = 'User-agent: *\nAllow: /\n\n' + bots.map(b => 'User-agent: ' + b + '\nAllow: /\n\n').join('') + 'Sitemap: ' + baseUrl + '/sitemap.xml\n';

fs.writeFileSync(path.join(rootDir, 'robots.txt'), robotsTxt, 'utf8');
console.log('robots.txt generated.');
