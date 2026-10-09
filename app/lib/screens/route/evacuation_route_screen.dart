import 'package:flutter/material.dart';

class EvacuationRouteScreen extends StatelessWidget {
  const EvacuationRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta de evacuación')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Ruta de demostración',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Diseño del flujo de consulta. Las rutas reales se configurarán en el Sprint correspondiente.'),
          const SizedBox(height: 20),
          const _RouteStep(
              icon: Icons.my_location,
              title: 'Origen',
              value: 'Zona de ejemplo A-01'),
          const _RouteStep(
              icon: Icons.directions_walk,
              title: 'Trayecto',
              value: 'Pasillo principal → corredor norte'),
          const _RouteStep(
              icon: Icons.exit_to_app, title: 'Salida', value: 'Salida Norte'),
          const _RouteStep(
              icon: Icons.groups_outlined,
              title: 'Punto de reunión',
              value: 'Punto A'),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                  'En una emergencia real prevalecen los protocolos oficiales y las indicaciones del personal responsable.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStep extends StatelessWidget {
  const _RouteStep(
      {required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: primary.withValues(alpha: 0.10),
          child: Icon(icon, color: primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle:
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(value)),
      ),
    );
  }
}
