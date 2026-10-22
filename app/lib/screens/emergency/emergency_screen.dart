import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  void _select(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '$value seleccionado. La lógica contextual se implementará en el Sprint 8.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo de emergencia')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Selecciona el tipo de emergencia',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Prototipo visual del flujo que posteriormente mostrará instrucciones y rutas específicas.'),
          const SizedBox(height: 22),
          _EmergencyCard(
              icon: Icons.local_fire_department_outlined,
              title: 'Incendio',
              subtitle: 'Evacuación y recursos contra incendio.',
              onTap: () => _select(context, 'Incendio')),
          _EmergencyCard(
              icon: Icons.vibration_outlined,
              title: 'Sismo',
              subtitle: 'Indicaciones y evacuación cuando corresponda.',
              onTap: () => _select(context, 'Sismo')),
          _EmergencyCard(
              icon: Icons.air_outlined,
              title: 'Fuga de gas',
              subtitle: 'Evitar áreas comprometidas y seguir instrucciones.',
              onTap: () => _select(context, 'Fuga de gas')),
          _EmergencyCard(
              icon: Icons.domain_disabled_outlined,
              title: 'Riesgo estructural',
              subtitle: 'Evitar accesos o niveles inseguros.',
              onTap: () => _select(context, 'Riesgo estructural')),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading:
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 4), child: Text(subtitle)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
