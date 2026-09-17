# EVACUA

[![Flutter CI](https://github.com/USUARIO/EVACUA/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/USUARIO/EVACUA/actions/workflows/flutter_ci.yml)

EVACUA es un prototipo móvil para consultar rutas de evacuación, zonas restringidas y equipos de emergencia de un inmueble. La primera versión utiliza planos simplificados, ubicación aproximada mediante códigos QR y rutas preconfiguradas por tipo de emergencia. El sistema complementa la señalización, los simulacros y los protocolos institucionales; no reemplaza las indicaciones de las brigadas ni de las autoridades.

## Estado

Sprint 0 en preparación. Versión prevista del primer prototipo: `v0.1.0`.

## Estructura

```text
/.github/       Workflows y plantillas de colaboración
/app/           Código base de la aplicación Flutter
/ci/            Scripts auxiliares de integración continua
/docs/          Plan, backlog, arquitectura y comunicación
README.md       Guía principal del repositorio
```

## Requisitos

- Flutter estable y Dart incluidos en el SDK.
- Git.
- Android Studio o VS Code con las extensiones de Flutter y Dart.
- Emulador Android o dispositivo físico para pruebas manuales.

## Preparación y ejecución

```bash
git clone https://github.com/cocobongo2112/EVACUA.git
cd EVACUA/app
flutter create --platforms=android,ios .
flutter pub get
flutter run
```

El comando `flutter create` agrega los runners nativos si todavía no existen. No deben guardarse credenciales, llaves de firma ni archivos de configuración privados en el repositorio.

## Verificación local

```bash
cd app
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
python ../ci/check_coverage.py coverage/lcov.info 70
```

## Flujo de trabajo

- `main`: versión estable y protegida.
- `develop`: integración del siguiente incremento.
- `feature/EVACUA-numero-descripcion`: nuevas funciones.
- `hotfix/EVACUA-numero-descripcion`: correcciones urgentes.
- Cada cambio se integra mediante pull request y al menos una revisión.
- Se usan Conventional Commits, por ejemplo `feat(qr): mostrar zona identificada`.
- Las versiones siguen Semantic Versioning; el prototipo inicial se etiqueta como `v0.1.0`.

## Integración continua

El workflow se ejecuta en cada `push` a `develop` y en cada `pull_request` dirigido a `main` o `develop`. Instala Flutter, descarga dependencias, comprueba el formato, ejecuta el análisis estático, corre las pruebas y valida una cobertura mínima de 70 %.

## Planeación

- [Plan DevOps](docs/PLAN_DEVOPS.md)
- [Plan DevOps en PDF](docs/Plan_DevOps_Proyecto_Movil_EVACUA.pdf)
- [Backlog y Sprint 0](docs/BACKLOG_SFPRINT_0.md)
- [Configuración del board](docs/BOARD_SETUP.md)
- [Carga inicial del board](docs/BOARD_SEED.csv)
- [Guía de comunicación](docs/GUIA_COMUNICACION.md)
- [Arquitectura](docs/ARQUITECTURA.md)

Cuando se cree el repositorio definitivo, sustituir `USUARIO/EVACUA` en la insignia y agregar aquí el enlace del GitHub Project.

## Equipo

- José Felipe García Luna
- Mariana Guadalupe Cano Márquez
- Karol Ximena González López
