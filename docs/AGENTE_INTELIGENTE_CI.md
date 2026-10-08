# EVACUA Quality Agent

## Propósito

EVACUA Quality Agent es un agente automatizado que interpreta la evidencia del Pipeline CI y la presenta de manera gráfica. Su objetivo es que el equipo identifique rápidamente qué fase fue ejecutada, cuál falló y qué acción debe realizarse antes de fusionar un Pull Request.

## Información que analiza

1. Descarga correcta del código fuente.
2. Configuración del entorno Node.js.
3. Instalación reproducible de dependencias con `npm ci`.
4. Resultado de las pruebas AAA de Jest y Supertest.
5. Cobertura de líneas, ramas, funciones y sentencias.
6. Resultado del análisis y Quality Gate de SonarQube.

## Comportamiento inteligente

El agente usa reglas transparentes y verificables. No inventa información: consume los archivos JSON producidos por Jest, el resumen de cobertura y los estados reales de GitHub Actions. Después:

- asigna a cada fase el estado **Aprobado**, **Falló**, **Omitido** o **Sin datos**;
- calcula una puntuación global de 0 a 100;
- emite la decisión **APROBADO**, **REVISAR** o **BLOQUEADO**;
- propone acciones distintas según la causa detectada;
- bloquea el Pipeline si existen pruebas fallidas, cobertura menor de 80 % o un Quality Gate fallido;
- publica o actualiza un comentario automático en el Pull Request;
- guarda un tablero HTML y un diagrama SVG como evidencia descargable.

La decisión automática complementa, pero no reemplaza, la aprobación de un integrante del equipo.

## Archivos principales

| Archivo | Función |
|---|---|
| `ci/evacua-quality-agent.cjs` | Motor de análisis y generador del tablero. |
| `ci/ejecutar-agente-local.ps1` | Ejecución local guiada para Windows. |
| `.github/workflows/api-quality.yml` | Automatiza pruebas, SonarQube, comentario y artefacto. |
| `api/reports/jest-results.json` | Resultado estructurado generado por Jest. |
| `api/coverage/coverage-summary.json` | Métricas estructuradas de cobertura. |
| `reports/quality-agent/index.html` | Tablero gráfico autocontenido. |
| `reports/quality-agent/pipeline.svg` | Diagrama visual del Pipeline CI. |

## Ejecución local en Windows

Desde la raíz del repositorio:

```powershell
powershell -ExecutionPolicy Bypass -File .\ci\ejecutar-agente-local.ps1
```

El navegador abrirá automáticamente el archivo `reports\quality-agent\index.html`.

## Ejecución en GitHub

Al abrir o actualizar un Pull Request hacia `develop` o `main`, GitHub Actions ejecuta automáticamente el workflow **EVACUA CI y Agente de Calidad**. Al finalizar:

1. el resumen del job muestra la evaluación por fases;
2. el Pull Request recibe un comentario del agente;
3. la sección **Artifacts** ofrece el archivo `EVACUA-Quality-Agent-*`;
4. al descargarlo y abrir `index.html` se observa el tablero completo;
5. el último paso permite o bloquea el merge de acuerdo con la evidencia.

## Evidencias recomendadas

- Workflow completo con todos los pasos en verde.
- Comentario automático del agente dentro del Pull Request.
- Tablero HTML con puntuación, etapas y recomendaciones.
- Lista de ocho casos de prueba aprobados.
- Artefacto `EVACUA-Quality-Agent-*` disponible para descarga.
- Quality Gate de SonarQube aprobado.
