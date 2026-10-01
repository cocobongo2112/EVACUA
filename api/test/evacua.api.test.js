const request = require('supertest');
const app = require('../src/app');

describe('EVACUA API REST', () => {
  test('CP-API-01 responde el estado de salud del servicio', async () => {
    // Arrange
    const endpoint = '/api/health';

    // Act
    const response = await request(app).get(endpoint);

    // Assert
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok', service: 'EVACUA API' });
  });

  test('CP-API-02 devuelve el catálogo de emergencias', async () => {
    // Arrange
    const endpoint = '/api/emergencies';

    // Act
    const response = await request(app).get(endpoint);

    // Assert
    expect(response.status).toBe(200);
    expect(response.body.emergencies).toHaveLength(3);
    expect(response.body.emergencies[0]).toHaveProperty('instructions');
  });

  test('CP-API-03 devuelve instrucciones para una emergencia válida', async () => {
    // Arrange
    const emergencyType = 'fire';

    // Act
    const response = await request(app).get(`/api/emergencies/${emergencyType}`);

    // Assert
    expect(response.status).toBe(200);
    expect(response.body.type).toBe(emergencyType);
    expect(response.body.name).toBe('Incendio');
    expect(response.body.instructions.length).toBeGreaterThan(0);
  });

  test('CP-API-04 devuelve 404 para una emergencia inexistente', async () => {
    // Arrange
    const emergencyType = 'inundacion_desconocida';

    // Act
    const response = await request(app).get(`/api/emergencies/${emergencyType}`);

    // Assert
    expect(response.status).toBe(404);
    expect(response.body.error).toBe('Tipo de emergencia no encontrado');
  });

  test('CP-API-05 valida como segura una ruta sin zonas bloqueadas', async () => {
    // Arrange
    const route = {
      origin: 'Laboratorio',
      destination: 'Punto de reunión A',
      blockedZones: ['Pasillo norte'],
    };

    // Act
    const response = await request(app).post('/api/routes/validate').send(route);

    // Assert
    expect(response.status).toBe(200);
    expect(response.body.safe).toBe(true);
    expect(response.body.reason).toBeNull();
  });

  test('CP-API-06 rechaza una ruta cuyo destino está bloqueado', async () => {
    // Arrange
    const route = {
      origin: 'Laboratorio',
      destination: 'Salida norte',
      blockedZones: ['Salida norte'],
    };

    // Act
    const response = await request(app).post('/api/routes/validate').send(route);

    // Assert
    expect(response.status).toBe(200);
    expect(response.body.safe).toBe(false);
    expect(response.body.reason).toBe('El destino se encuentra bloqueado');
  });

  test('CP-API-07 devuelve 400 cuando faltan datos de la ruta', async () => {
    // Arrange
    const incompleteRoute = {
      origin: 'Laboratorio',
    };

    // Act
    const response = await request(app)
      .post('/api/routes/validate')
      .send(incompleteRoute);

    // Assert
    expect(response.status).toBe(400);
    expect(response.body.error).toContain('origin, destination');
  });

  test('CP-API-08 devuelve 404 para una ruta no registrada', async () => {
    // Arrange
    const endpoint = '/api/not-found';

    // Act
    const response = await request(app).get(endpoint);

    // Assert
    expect(response.status).toBe(404);
    expect(response.body.error).toBe('Ruta no encontrada');
  });
});
