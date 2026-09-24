# Guía de contribución de EVACUA

## Flujo de trabajo

El proyecto utiliza GitHub Flow. La rama `main` contiene la versión estable y no debe recibir cambios directos.

1. Crear una rama a partir de `main`.
2. Implementar un cambio pequeño y verificable.
3. Realizar commits con Conventional Commits.
4. Abrir un Pull Request hacia `main`.
5. Esperar la ejecución satisfactoria del CI.
6. Obtener al menos una aprobación.
7. Fusionar el cambio mediante el Pull Request.

## Convención de ramas

- `feature/nombre`: funcionalidad nueva.
- `fix/nombre`: corrección de un defecto.
- `docs/nombre`: documentación.
- `hotfix/nombre`: corrección urgente de producción.

Ejemplos:

- `feature/login-validation`
- `fix/invalid-email-message`
- `docs/update-readme`

## Convención de commits

Se adopta Conventional Commits:

- `feat:` nueva funcionalidad.
- `fix:` corrección de error.
- `test:` creación o modificación de pruebas.
- `docs:` documentación.
- `ci:` configuración de integración continua.
- `chore:` mantenimiento.
- `refactor:` mejora interna sin cambiar el comportamiento.

Ejemplos:

- `feat: add login validation`
- `test: add email validator tests`
- `ci: configure Flutter workflow`

## Política de Pull Requests

Todo Pull Request debe:

- Dirigirse hacia `main`.
- Explicar el cambio realizado.
- Estar relacionado con un issue cuando corresponda.
- Tener los checks del CI aprobados.
- Obtener al menos una aprobación.
- No contener contraseñas, tokens o credenciales.
- Resolver las observaciones antes del merge.

## Versionado

Se utiliza versionado semántico:

- `MAJOR`: cambios incompatibles.
- `MINOR`: funcionalidad compatible nueva.
- `PATCH`: correcciones compatibles.

La versión inicial del prototipo será:

`v0.1.0 (build 1)`

En Flutter se representa dentro de `pubspec.yaml` como:

`version: 0.1.0+1`
