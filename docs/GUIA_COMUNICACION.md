# Guía de comunicación del equipo

## Herramienta seleccionada

Discord se utilizará como canal operativo durante el prototipo por su acceso gratuito, organización por canales, voz, video, pantalla compartida y compatibilidad móvil. GitHub conserva la evidencia técnica definitiva: requisitos, decisiones relacionadas con código, incidencias, pull requests y versiones.

## Canales

- `#anuncios`: decisiones, entregas, cambios de alcance y avisos que todos deben confirmar.
- `#dev`: implementación Flutter, API, arquitectura y revisiones técnicas.
- `#qa`: casos de prueba, defectos, evidencia y resultados de CI.
- `#ops`: versiones, Firebase, monitoreo, credenciales y fallas operativas sin publicar secretos.
- `#dudas`: preguntas que requieren respuesta o acuerdo.
- `#random`: convivencia; no se registran decisiones del proyecto.
- `Daily EVACUA`: canal de voz para reuniones breves y demostraciones.

## Normas

1. Usar un hilo por tema y colocar el identificador de la incidencia, por ejemplo `[US-02]`.
2. Registrar en GitHub toda decisión que cambie alcance, código, criterios o versiones.
3. Usar `@equipo` solo para bloqueos, cambios de horario o incidentes que afecten a todos.
4. No compartir contraseñas, tokens, llaves de firma ni datos personales en mensajes.
5. Las dudas ordinarias se responden en un máximo de ocho horas dentro del horario acordado; un bloqueo activo se reconoce en dos horas.
6. Fuera del horario acordado no se exige respuesta, salvo que el equipo programe una liberación.
7. Un incidente debe publicarse con formato: impacto, versión, pasos, evidencia, responsable y siguiente actualización.
8. Las reuniones terminan con acuerdos, responsables y fecha; el resumen se enlaza en `#anuncios`.

## Integraciones

- Webhook o bot de GitHub para pull requests y ejecuciones de CI en `#dev` o `#qa`.
- Enlace fijado al GitHub Project en `#anuncios`.
- Calendario compartido para dailies, revisión y retrospectiva.
- Alertas de Crashlytics dirigidas a `#ops` cuando se habilite el ambiente beta.

