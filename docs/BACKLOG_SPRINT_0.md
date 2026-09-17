# Backlog inicial y Sprint 0

## Historias de usuario

| ID | Historia | Prioridad | Puntos | Criterios de aceptación resumidos |
|---|---|---:|---:|---|
| US-01 | Como ocupante, quiero consultar instrucciones por tipo de emergencia para saber cómo actuar. | Must | 3 | Se muestran incendio, sismo y fuga; cada opción presenta instrucciones autorizadas. |
| US-02 | Como ocupante, quiero escanear un QR para identificar mi zona y nivel. | Must | 5 | Un QR válido carga la zona; uno inválido muestra un mensaje y no cambia la ubicación. |
| US-03 | Como ocupante, quiero visualizar el plano simplificado del piso para orientarme. | Must | 5 | El plano corresponde a la zona detectada, permite ampliación y muestra una leyenda. |
| US-04 | Como ocupante, quiero ver una ruta preconfigurada para llegar al punto de reunión. | Must | 8 | La ruta parte de la zona actual, evita zonas bloqueadas y señala el punto de reunión. |
| US-05 | Como ocupante, quiero localizar equipos de emergencia cercanos. | Should | 5 | Se filtran por piso y tipo; cada elemento muestra ubicación y estado disponible. |
| US-06 | Como usuario, quiero consultar la información esencial sin conexión. | Should | 8 | La última versión sincronizada de planos, rutas e instrucciones queda disponible. |
| US-07 | Como administrador, quiero registrar inmuebles, niveles y zonas. | Must | 8 | Se validan campos obligatorios y los cambios quedan asociados a un usuario. |
| US-08 | Como administrador, quiero configurar rutas, salidas y puntos de reunión. | Must | 8 | La ruta tiene origen y destino válidos y puede asociarse a tipos de emergencia. |
| US-09 | Como responsable autorizado, quiero bloquear una zona para evitar recomendar rutas inseguras. | Must | 5 | El cambio exige permisos, registra fecha y deja de mostrar rutas relacionadas. |
| US-10 | Como ocupante, quiero confirmar mi llegada al punto de reunión. | Could | 5 | La confirmación solicita consentimiento y registra el evento sin exponer ubicación pública. |

## Objetivo de Sprint 0

Preparar un entorno reproducible y una base técnica verificable antes de desarrollar las historias funcionales. Duración propuesta: dos semanas.

## Trabajo comprometido

| ID | Actividad | Responsable propuesto | Criterio de hecho |
|---|---|---|---|
| S0-01 | Crear repositorio, ramas y protección de `main`. | José Felipe | Ramas publicadas y merge directo bloqueado. |
| S0-02 | Inicializar Flutter y navegación base. | Mariana | App abre y muestra la pantalla inicial. |
| S0-03 | Configurar workflow de CI. | José Felipe | Format, analyze y test finalizan correctamente. |
| S0-04 | Definir arquitectura y contrato inicial de datos. | Gabino | Diagrama y entidades revisados por el equipo. |
| S0-05 | Crear backlog, criterios INVEST y board. | Karol | Diez historias visibles y priorizadas. |
| S0-06 | Configurar servidor y canales de comunicación. | Karol | Canales, permisos y normas publicados. |
| S0-07 | Crear prueba widget y umbral de cobertura. | Mariana | Prueba ejecutada y cobertura de al menos 70 %. |
| S0-08 | Preparar demo de QR simulado. | Gabino | Un identificador de prueba abre una zona simulada. |

Los responsables son una propuesta inicial y pueden reasignarse durante la planeación. Cada integrante debe actualizar su trabajo en el board y enlazar el pull request correspondiente.

