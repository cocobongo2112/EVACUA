# Plan DevOps del Proyecto Móvil EVACUA

Este directorio contiene la versión operativa del plan. El documento formal en Word y PDF desarrolla el caso, la arquitectura, el ciclo DevOps, Sprint 0, versionamiento, CI/CD, pruebas, despliegue, monitoreo, riesgos, runbook y selección de la herramienta de comunicación.

## Decisiones principales

- Aplicación móvil: Flutter.
- Gestión de trabajo: GitHub Projects.
- Repositorio y CI: GitHub y GitHub Actions.
- Distribución alfa y beta: Firebase App Distribution.
- Monitoreo: Firebase Crashlytics y métricas de producto.
- Comunicación operativa: Discord.
- Ramificación: `main`, `develop`, `feature/*` y `hotfix/*`.
- Primer tag: `v0.1.0`.
- Cobertura mínima inicial: 70 % de líneas para el código incluido en el pipeline.

## Criterio de liberación

Una versión se libera cuando el alcance aprobado está integrado, todos los checks están en verde, no existen defectos críticos abiertos, la evidencia de pruebas está vinculada, el artefacto está versionado y una persona distinta al autor aprueba el pull request.

