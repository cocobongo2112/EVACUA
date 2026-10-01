const express = require('express');
const emergencyCatalog = require('./emergencyCatalog');

const app = express();

app.disable('x-powered-by');

app.use(express.json());

app.get('/api/health', (_request, response) => {
  response.status(200).json({
    status: 'ok',
    service: 'EVACUA API',
  });
});

app.get('/api/emergencies', (_request, response) => {
  const emergencies = Object.entries(emergencyCatalog).map(([type, data]) => ({
    type,
    ...data,
  }));

  response.status(200).json({ emergencies });
});

app.get('/api/emergencies/:type', (request, response) => {
  const type = request.params.type.toLowerCase();
  const emergency = emergencyCatalog[type];

  if (!emergency) {
    return response.status(404).json({
      error: 'Tipo de emergencia no encontrado',
    });
  }

  return response.status(200).json({
    type,
    ...emergency,
  });
});

app.post('/api/routes/validate', (request, response) => {
  const { origin, destination, blockedZones = [] } = request.body;

  if (!origin || !destination || !Array.isArray(blockedZones)) {
    return response.status(400).json({
      error: 'origin, destination y blockedZones son obligatorios y válidos',
    });
  }

  const normalizedDestination = destination.trim().toLowerCase();
  const normalizedBlockedZones = blockedZones.map((zone) =>
    String(zone).trim().toLowerCase(),
  );
  const safe = !normalizedBlockedZones.includes(normalizedDestination);

  return response.status(200).json({
    origin,
    destination,
    safe,
    reason: safe ? null : 'El destino se encuentra bloqueado',
  });
});

app.use((_request, response) => {
  response.status(404).json({
    error: 'Ruta no encontrada',
  });
});

module.exports = app;
