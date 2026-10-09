import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class MyZoneScreen extends StatelessWidget {
  const MyZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi zona')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Zona identificada',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'Información de demostración para el prototipo navegable.'),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edificio piloto · Planta baja',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 10),
                  Text('Zona de ejemplo: A-01'),
                  SizedBox(height: 6),
                  Text('Estado visual: disponible'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 62),
                  SizedBox(height: 12),
                  Text('Vista previa del plano',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('El plano real se integrará en un Sprint posterior.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.evacuationRoute),
            icon: const Icon(Icons.route_outlined),
            label: const Text('Consultar ruta'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.equipment),
            icon: const Icon(Icons.fire_extinguisher),
            label: const Text('Ver equipos de emergencia'),
          ),
        ],
      ),
    );
  }
}
