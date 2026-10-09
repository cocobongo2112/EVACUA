import 'package:flutter/material.dart';

class EmergencyEquipmentScreen extends StatelessWidget {
  const EmergencyEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipos de emergencia')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Recursos disponibles',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Datos de demostración para validar la interfaz del Sprint 2.'),
          const SizedBox(height: 20),
          const _EquipmentTile(
              icon: Icons.fire_extinguisher,
              title: 'Extintor',
              location: 'Ubicación demo · Pasillo principal'),
          const _EquipmentTile(
              icon: Icons.water_drop_outlined,
              title: 'Hidrante',
              location: 'Ubicación demo · Acceso norte'),
          const _EquipmentTile(
              icon: Icons.medical_services_outlined,
              title: 'Botiquín',
              location: 'Ubicación demo · Área administrativa'),
          const _EquipmentTile(
              icon: Icons.notifications_active_outlined,
              title: 'Alarma',
              location: 'Ubicación demo · Corredor central'),
          const _EquipmentTile(
              icon: Icons.health_and_safety_outlined,
              title: 'DEA',
              location: 'Ubicación demo · Recepción'),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                  'El registro y consulta real de equipos se implementará en un Sprint posterior.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile(
      {required this.icon, required this.title, required this.location});
  final IconData icon;
  final String title;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 4), child: Text(location)),
      ),
    );
  }
}
