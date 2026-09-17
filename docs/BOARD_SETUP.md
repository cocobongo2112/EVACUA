# Configuración del board

Crear un GitHub Project en vista Board con el nombre `EVACUA Desarrollo`.

## Estados

1. Backlog
2. To-Do
3. In-Progress
4. Review
5. Done

## Campos

- Prioridad: Must, Should, Could, Won't por ahora.
- Iteración: Sprint 0, Sprint 1, Sprint 2.
- Puntos: 1, 2, 3, 5, 8.
- Tipo: Historia, Tarea, Error, Riesgo.
- Responsable.

## Automatizaciones mínimas

- Una incidencia nueva entra a Backlog.
- Al abrir un pull request vinculado, el elemento pasa a Review.
- Al cerrar la incidencia o integrar el pull request, pasa a Done.
- Los elementos cerrados se archivan después de la revisión del sprint.

## Carga inicial

Crear como incidencias las diez historias y las ocho tareas de Sprint 0 incluidas en `BACKLOG_SPRINT_0.md`. Al iniciar el sprint, mover S0-01 a S0-08 a To-Do; solo debe haber una o dos tareas simultáneas por integrante en In-Progress.

El archivo `BOARD_SEED.csv` conserva la carga inicial con prioridad, iteración, estimación, estado y responsable para facilitar su captura uniforme en GitHub Projects.
