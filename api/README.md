# EVACUA API

Módulo REST de apoyo para consultar instrucciones de emergencia y validar rutas de evacuación.

## Instalación

```powershell
cd api
npm install
```

## Pruebas y cobertura

```powershell
npm run test:coverage
```

El proyecto exige un mínimo global de 80 % en líneas, sentencias, funciones y ramas.

## Ejecución local

```powershell
npm start
```

Endpoints principales:

- `GET /api/health`
- `GET /api/emergencies`
- `GET /api/emergencies/:type`
- `POST /api/routes/validate`
