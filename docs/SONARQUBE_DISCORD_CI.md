# SonarQube y notificación de fallos en Discord

## Objetivo

El Pipeline CI de EVACUA ejecuta las pruebas automatizadas del API, genera cobertura, envía el análisis a SonarQube y notifica en Discord cuando la ejecución termina con error. La URL del webhook se almacena como un secreto de GitHub Actions y nunca se escribe directamente en el repositorio.

## Configuración requerida en GitHub

En **Settings → Secrets and variables → Actions** deben existir:

### Secrets

| Nombre | Contenido |
|---|---|
| `SONAR_TOKEN` | Token privado generado en SonarQube Cloud. |
| `DISCORD_WEBHOOK_URL` | URL completa del webhook del canal de Discord. |

### Variables

| Nombre | Contenido |
|---|---|
| `SONAR_PROJECT_KEY` | Identificador del proyecto EVACUA en SonarQube. |
| `SONAR_ORGANIZATION` | Identificador de la organización de SonarQube Cloud. |

## Flujo implementado

1. GitHub descarga el repositorio.
2. Configura Node.js 20.
3. Instala las dependencias con `npm ci`.
4. Ejecuta las pruebas AAA con Jest y Supertest.
5. Genera la cobertura en formato LCOV y JSON.
6. SonarQube analiza código, seguridad, mantenibilidad y cobertura.
7. EVACUA Quality Agent interpreta todos los resultados.
8. GitHub publica el diagnóstico y guarda el tablero HTML.
9. El Quality Gate permite o bloquea la integración.
10. Cuando el job falla, GitHub ejecuta el webhook y Discord recibe una tarjeta roja con el repositorio, rama, workflow, commit, responsable y enlace a la ejecución.

## Demostración segura del fallo

El workflow incluye el parámetro manual `simulate_failure`. Esta opción produce un fallo controlado después de completar los análisis. No modifica el código, no altera las pruebas y no se integra en `main`.

Para probarlo:

1. Abrir la pestaña **Actions** del repositorio.
2. Seleccionar **EVACUA CI y Agente de Calidad**.
3. Pulsar **Run workflow**.
4. Seleccionar la rama donde está configurado el agente.
5. Activar **Simular un fallo para comprobar la notificación de Discord**.
6. Pulsar **Run workflow**.
7. Esperar el fallo controlado y comprobar el mensaje en Discord.

Después debe ejecutarse nuevamente con `simulate_failure = false` para conservar una evidencia final satisfactoria.

## Seguridad

- No publicar ni mostrar en el video la URL del webhook.
- No escribir tokens o URLs privadas dentro del archivo YAML.
- Si una URL fue visible en una captura o video, eliminar ese webhook y generar uno nuevo.
- La demostración debe realizarse en una rama de trabajo, no directamente en `main`.
