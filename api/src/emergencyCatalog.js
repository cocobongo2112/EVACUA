const emergencyCatalog = {
  fire: {
    name: 'Incendio',
    priority: 'critical',
    instructions: [
      'Activar la alarma y reportar la emergencia.',
      'Evacuar por la ruta segura más cercana.',
      'No utilizar elevadores.',
    ],
  },
  earthquake: {
    name: 'Sismo',
    priority: 'high',
    instructions: [
      'Conservar la calma y alejarse de objetos que puedan caer.',
      'Atender las indicaciones de la brigada.',
      'Evacuar cuando termine el movimiento y la ruta sea segura.',
    ],
  },
  gas_leak: {
    name: 'Fuga de gas',
    priority: 'critical',
    instructions: [
      'No encender ni apagar equipos eléctricos.',
      'Alejarse del área y avisar a la brigada.',
      'Evacuar hacia el punto de reunión indicado.',
    ],
  },
};

module.exports = emergencyCatalog;
