#!/usr/bin/env node

/**
 * EVACUA Quality Agent
 * Interpreta resultados reales del Pipeline CI y genera un diagnóstico visual.
 * No utiliza servicios externos ni modifica el código de la aplicación.
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const OUTPUT = path.join(ROOT, 'reports', 'quality-agent');
const TEST_RESULTS = path.join(ROOT, 'api', 'reports', 'jest-results.json');
const COVERAGE = path.join(ROOT, 'api', 'coverage', 'coverage-summary.json');
const MIN_COVERAGE = Number(process.env.MIN_COVERAGE || 80);

const readJson = (file) => {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (_error) {
    return null;
  }
};

const safe = (value) => String(value ?? '')
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;');

const normalizeOutcome = (value) => {
  if (value === 'success') return 'success';
  if (['failure', 'cancelled', 'timed_out'].includes(value)) return 'failure';
  if (value === 'skipped') return 'skipped';
  return 'unknown';
};

const statusLabel = {
  success: 'Aprobado',
  failure: 'Falló',
  skipped: 'Omitido',
  unknown: 'Sin datos',
};

const statusIcon = {
  success: '✅',
  failure: '❌',
  skipped: '⏭️',
  unknown: '⚪',
};

function enforce(file) {
  const report = readJson(path.resolve(file));
  if (!report) {
    console.error('No se pudo leer el reporte del agente.');
    process.exit(1);
  }
  console.log(`Decisión del agente: ${report.decision} (${report.score}/100)`);
  process.exit(report.blockMerge ? 1 : 0);
}

if (process.argv[2] === '--enforce') {
  enforce(process.argv[3]);
}

const jest = readJson(TEST_RESULTS);
const coverage = readJson(COVERAGE);
const testOutcomeFromFile = jest
  ? (jest.success && jest.numFailedTests === 0 ? 'success' : 'failure')
  : normalizeOutcome(process.env.TEST_OUTCOME);

const stages = [
  {
    id: 'source',
    name: 'Código fuente',
    detail: 'Checkout del repositorio y lectura del commit',
    status: normalizeOutcome(process.env.CHECKOUT_OUTCOME || 'success'),
  },
  {
    id: 'environment',
    name: 'Entorno Node.js',
    detail: 'Node.js 20 y restauración de caché npm',
    status: normalizeOutcome(process.env.NODE_OUTCOME || 'success'),
  },
  {
    id: 'dependencies',
    name: 'Dependencias',
    detail: 'Instalación reproducible mediante npm ci',
    status: normalizeOutcome(process.env.INSTALL_OUTCOME || 'success'),
  },
  {
    id: 'tests',
    name: 'Pruebas AAA',
    detail: jest
      ? `${jest.numPassedTests}/${jest.numTotalTests} pruebas aprobadas`
      : 'Ejecución automática con Jest y Supertest',
    status: testOutcomeFromFile,
  },
  {
    id: 'coverage',
    name: 'Cobertura',
    detail: coverage
      ? `${coverage.total.lines.pct}% de líneas (mínimo ${MIN_COVERAGE}%)`
      : 'No se encontró coverage-summary.json',
    status: coverage
      ? (coverage.total.lines.pct >= MIN_COVERAGE ? 'success' : 'failure')
      : (testOutcomeFromFile === 'failure' ? 'skipped' : 'unknown'),
  },
  {
    id: 'sonar',
    name: 'SonarQube',
    detail: 'Análisis estático, seguridad y Quality Gate',
    status: normalizeOutcome(process.env.SONAR_OUTCOME),
  },
];

const recommendations = [];
if (stages.find((stage) => stage.id === 'dependencies').status === 'failure') {
  recommendations.push('Revisar package-lock.json y ejecutar npm ci dentro de la carpeta api.');
}
if (testOutcomeFromFile === 'failure') {
  const failedNames = (jest?.testResults || [])
    .flatMap((suite) => suite.assertionResults || [])
    .filter((test) => test.status === 'failed')
    .map((test) => test.fullName);
  recommendations.push(failedNames.length
    ? `Corregir las pruebas fallidas: ${failedNames.join('; ')}.`
    : 'Consultar el registro de Jest y corregir la prueba o implementación que produjo el fallo.');
}
if (coverage && coverage.total.lines.pct < MIN_COVERAGE) {
  recommendations.push(`Agregar pruebas para elevar la cobertura de líneas de ${coverage.total.lines.pct}% a por lo menos ${MIN_COVERAGE}%.`);
}
if (!coverage) {
  recommendations.push('Generar cobertura con npm run test:ci para que el agente pueda evaluarla.');
}
const sonarStage = stages.find((stage) => stage.id === 'sonar');
if (sonarStage.status === 'failure') {
  recommendations.push('Abrir el análisis de SonarQube y resolver vulnerabilidades, bugs o condiciones incumplidas del Quality Gate.');
} else if (['unknown', 'skipped'].includes(sonarStage.status)) {
  recommendations.push('Verificar SONAR_TOKEN, SONAR_PROJECT_KEY y SONAR_ORGANIZATION para completar el Quality Gate.');
}
if (!recommendations.length) {
  recommendations.push('El pipeline cumple los controles definidos; el cambio puede continuar a revisión humana.');
}

const failures = stages.filter((stage) => stage.status === 'failure').length;
const unknowns = stages.filter((stage) => ['unknown', 'skipped'].includes(stage.status)).length;
const score = Math.max(0, 100 - (failures * 25) - (unknowns * 5));
const blockMerge = failures > 0 || ['unknown', 'skipped'].includes(sonarStage.status);
const decision = failures > 0 ? 'BLOQUEADO' : (blockMerge ? 'REVISAR' : 'APROBADO');

const testCases = (jest?.testResults || []).flatMap((suite) =>
  (suite.assertionResults || []).map((test) => ({
    title: test.title,
    fullName: test.fullName,
    status: test.status === 'passed' ? 'success' : 'failure',
    duration: test.duration ?? 0,
    failureMessage: (test.failureMessages || []).join('\n').slice(0, 500),
  })),
);

const report = {
  generatedAt: new Date().toISOString(),
  project: process.env.GITHUB_REPOSITORY || 'cocobongo2112/EVACUA',
  branch: process.env.GITHUB_REF_NAME || 'ejecución local',
  commit: (process.env.GITHUB_SHA || 'local').slice(0, 7),
  runUrl: process.env.GITHUB_RUN_ID
    ? `${process.env.GITHUB_SERVER_URL || 'https://github.com'}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID}`
    : '',
  decision,
  score,
  blockMerge,
  minimumCoverage: MIN_COVERAGE,
  stages,
  tests: {
    total: jest?.numTotalTests ?? 0,
    passed: jest?.numPassedTests ?? 0,
    failed: jest?.numFailedTests ?? 0,
    cases: testCases,
  },
  coverage: coverage?.total || null,
  recommendations,
};

function stageCards() {
  return report.stages.map((stage, index) => `
    <article class="stage ${stage.status}" style="--delay:${index * 90}ms">
      <div class="stage-number">${index + 1}</div>
      <div class="stage-icon">${statusIcon[stage.status]}</div>
      <div>
        <h3>${safe(stage.name)}</h3>
        <p>${safe(stage.detail)}</p>
        <span class="badge">${statusLabel[stage.status]}</span>
      </div>
    </article>`).join('');
}

function testRows() {
  if (!report.tests.cases.length) {
    return '<tr><td colspan="3">No existe un archivo de resultados de Jest.</td></tr>';
  }
  return report.tests.cases.map((test) => `
    <tr><td>${test.status === 'success' ? '✅' : '❌'}</td><td>${safe(test.title)}</td><td>${safe(test.duration)} ms</td></tr>`).join('');
}

function metric(label, value) {
  return `<div class="metric"><strong>${safe(value)}</strong><span>${safe(label)}</span></div>`;
}

function createHtml() {
  const coverageValue = report.coverage ? `${report.coverage.lines.pct}%` : 'N/D';
  const decisionClass = report.decision.toLowerCase();
  return `<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>EVACUA Quality Agent</title>
  <style>
    :root{--navy:#092746;--blue:#0b73ce;--cyan:#20b8d5;--green:#14a673;--red:#d9485f;--amber:#e6a117;--ink:#172638;--muted:#617287;--paper:#f4f8fc;--line:#d9e4ef}
    *{box-sizing:border-box}body{margin:0;background:linear-gradient(135deg,#edf7ff,#f7fbff 45%,#e9f4f6);color:var(--ink);font-family:Inter,Segoe UI,Arial,sans-serif}.shell{max-width:1180px;margin:auto;padding:30px 22px 50px}.hero{position:relative;overflow:hidden;background:linear-gradient(120deg,var(--navy),#0b548b 65%,#0b7897);color:white;border-radius:24px;padding:32px;box-shadow:0 18px 45px #123c6430}.hero:after{content:"";position:absolute;width:290px;height:290px;border:48px solid #ffffff12;border-radius:50%;right:-95px;top:-115px}.eyebrow{margin:0 0 8px;color:#78e4f2;font-weight:800;letter-spacing:.13em;font-size:12px}.hero h1{margin:0;font-size:clamp(28px,5vw,46px)}.hero p{max-width:720px;color:#d9edf9;line-height:1.55}.summary{display:flex;gap:24px;align-items:center;flex-wrap:wrap;margin-top:24px}.score{--score:${report.score};width:116px;height:116px;border-radius:50%;display:grid;place-items:center;background:conic-gradient(#56e0c1 calc(var(--score)*1%),#ffffff25 0);position:relative}.score:before{content:"";position:absolute;inset:10px;background:var(--navy);border-radius:50%}.score b,.score span{position:relative;z-index:1;text-align:center}.score b{font-size:32px;display:block}.score span{font-size:11px;color:#bcd9e8}.decision{font-weight:900;font-size:24px}.decision.aprobado{color:#60e6bd}.decision.revisar{color:#ffd166}.decision.bloqueado{color:#ff8191}.meta{font-size:13px;color:#c6ddeb;line-height:1.7}.metrics{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin:22px 0}.metric{background:white;border:1px solid var(--line);border-radius:16px;padding:18px;box-shadow:0 8px 24px #31547610}.metric strong{font-size:25px;display:block;color:var(--navy)}.metric span{color:var(--muted);font-size:13px}.section{background:#ffffffd9;border:1px solid var(--line);border-radius:22px;padding:24px;margin-top:20px;box-shadow:0 10px 30px #31547610}.section h2{margin:0 0 18px;color:var(--navy)}.pipeline{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}.stage{display:grid;grid-template-columns:34px 38px 1fr;gap:10px;align-items:start;border:1px solid var(--line);border-left:5px solid #9eb0bf;border-radius:15px;padding:16px;background:white;animation:rise .5s both;animation-delay:var(--delay)}.stage.success{border-left-color:var(--green)}.stage.failure{border-left-color:var(--red)}.stage.skipped,.stage.unknown{border-left-color:var(--amber)}.stage-number{width:28px;height:28px;border-radius:9px;background:#e8f2fb;color:var(--blue);display:grid;place-items:center;font-weight:800}.stage-icon{font-size:22px}.stage h3{font-size:15px;margin:1px 0 6px}.stage p{font-size:12px;color:var(--muted);margin:0 0 9px;line-height:1.45}.badge{font-size:11px;font-weight:800;padding:4px 8px;border-radius:99px;background:#edf2f7}.success .badge{color:#087c58;background:#dff8ee}.failure .badge{color:#a71e39;background:#fde7eb}.unknown .badge,.skipped .badge{color:#8a5a00;background:#fff3d2}.recommendations{margin:0;padding-left:20px}.recommendations li{padding:7px 0;line-height:1.5}table{border-collapse:collapse;width:100%;font-size:13px}th,td{text-align:left;padding:11px;border-bottom:1px solid var(--line)}th{color:var(--navy);background:#edf5fb}.footer{text-align:center;color:var(--muted);font-size:12px;margin-top:22px}@keyframes rise{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:none}}@media(max-width:820px){.metrics{grid-template-columns:repeat(2,1fr)}.pipeline{grid-template-columns:1fr}}@media(max-width:480px){.metrics{grid-template-columns:1fr}.hero{padding:24px}.shell{padding:15px 12px 30px}}
  </style>
</head>
<body>
  <main class="shell">
    <header class="hero">
      <p class="eyebrow">AGENTE INTELIGENTE DE INTEGRACIÓN CONTINUA</p>
      <h1>EVACUA Quality Agent</h1>
      <p>Diagnóstico automático del pipeline: interpreta pruebas, cobertura y análisis estático para explicar si un cambio puede continuar o debe corregirse.</p>
      <div class="summary"><div class="score"><div><b>${report.score}</b><span>puntos</span></div></div><div><div class="decision ${decisionClass}">${report.decision}</div><div class="meta">Proyecto: ${safe(report.project)}<br>Rama: ${safe(report.branch)} · Commit: ${safe(report.commit)}</div></div></div>
    </header>
    <section class="metrics">${metric('Pruebas aprobadas', `${report.tests.passed}/${report.tests.total}`)}${metric('Cobertura de líneas', coverageValue)}${metric('Umbral mínimo', `${report.minimumCoverage}%`)}${metric('Fases aprobadas', `${report.stages.filter((s) => s.status === 'success').length}/${report.stages.length}`)}</section>
    <section class="section"><h2>Flujo gráfico del Pipeline CI</h2><div class="pipeline">${stageCards()}</div></section>
    <section class="section"><h2>Diagnóstico y acciones sugeridas</h2><ol class="recommendations">${report.recommendations.map((item) => `<li>${safe(item)}</li>`).join('')}</ol></section>
    <section class="section"><h2>Casos de prueba ejecutados</h2><table><thead><tr><th>Estado</th><th>Caso</th><th>Duración</th></tr></thead><tbody>${testRows()}</tbody></table></section>
    <p class="footer">Reporte generado automáticamente el ${safe(report.generatedAt)}. La aprobación técnica no sustituye la revisión humana del Pull Request.</p>
  </main>
</body>
</html>`;
}

function createSvg() {
  const width = 1200;
  const boxWidth = 172;
  const gap = 24;
  const startX = 22;
  const colors = { success: '#14a673', failure: '#d9485f', skipped: '#e6a117', unknown: '#8293a5' };
  const boxes = report.stages.map((stage, index) => {
    const x = startX + index * (boxWidth + gap);
    const connector = index < report.stages.length - 1
      ? `<path d="M ${x + boxWidth} 92 H ${x + boxWidth + gap - 5}" stroke="#9bb1c5" stroke-width="4" marker-end="url(#arrow)"/>`
      : '';
    return `${connector}<g><rect x="${x}" y="40" width="${boxWidth}" height="104" rx="14" fill="#fff" stroke="${colors[stage.status]}" stroke-width="4"/><circle cx="${x + 25}" cy="65" r="10" fill="${colors[stage.status]}"/><text x="${x + 44}" y="70" font-size="15" font-weight="700" fill="#092746">${safe(stage.name)}</text><text x="${x + 16}" y="101" font-size="12" fill="#617287">${safe(statusLabel[stage.status])}</text><text x="${x + 16}" y="124" font-size="11" fill="#617287">Paso ${index + 1}</text></g>`;
  }).join('');
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="190" viewBox="0 0 ${width} 190"><defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z" fill="#9bb1c5"/></marker></defs><rect width="100%" height="100%" rx="18" fill="#f4f8fc"/><text x="22" y="26" font-size="15" font-weight="700" fill="#092746">EVACUA · Pipeline CI · ${safe(report.decision)}</text>${boxes}</svg>`;
}

function markdown(includeMarker = false) {
  const rows = report.stages.map((stage, index) =>
    `| ${index + 1} | ${stage.name} | ${statusIcon[stage.status]} ${statusLabel[stage.status]} | ${stage.detail} |`,
  ).join('\n');
  const recs = report.recommendations.map((item) => `- ${item}`).join('\n');
  const runLink = report.runUrl ? `[Abrir ejecución completa](${report.runUrl})` : 'Ejecución local';
  return `${includeMarker ? '<!-- EVACUA_QUALITY_AGENT -->\n' : ''}## 🤖 EVACUA Quality Agent

**Decisión:** ${statusIcon[report.blockMerge ? 'failure' : 'success']} **${report.decision}** · **Puntuación:** ${report.score}/100 · ${runLink}

| Paso | Fase | Estado | Interpretación |
|---:|---|---|---|
${rows}

### Diagnóstico

${recs}

> El agente analiza evidencia producida por el CI. La revisión humana del Pull Request continúa siendo obligatoria.
`;
}

fs.mkdirSync(OUTPUT, { recursive: true });
fs.writeFileSync(path.join(OUTPUT, 'report.json'), JSON.stringify(report, null, 2));
fs.writeFileSync(path.join(OUTPUT, 'index.html'), createHtml());
fs.writeFileSync(path.join(OUTPUT, 'pipeline.svg'), createSvg());
fs.writeFileSync(path.join(OUTPUT, 'summary.md'), markdown(false));
fs.writeFileSync(path.join(OUTPUT, 'pr-comment.md'), markdown(true));

console.log(`EVACUA Quality Agent: ${report.decision} (${report.score}/100)`);
console.log(`Tablero generado en ${path.relative(ROOT, path.join(OUTPUT, 'index.html'))}`);
