import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/firebase/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.authService});

  final AuthService? authService;

  Future<void> _logout(BuildContext context) async {
    await (authService ?? AuthService()).signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.welcome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVACUA'),
        actions: [
          IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Sistema de evacuación y gestión de emergencias',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Consulta información preventiva del inmueble y sigue siempre las indicaciones del personal responsable.'),
          const SizedBox(height: 24),
          _HomeCard(
              icon: Icons.qr_code_scanner,
              title: 'Escanear ubicación',
              subtitle: 'Identifica el nivel o la zona mediante un código QR.',
              onTap: () {}),
          _HomeCard(
              icon: Icons.route_outlined,
              title: 'Consultar ruta',
              subtitle:
                  'Visualiza la ruta preconfigurada y el punto de reunión.',
              onTap: () {}),
          _HomeCard(
              icon: Icons.fire_extinguisher,
              title: 'Equipos cercanos',
              subtitle:
                  'Ubica extintores, hidrantes, botiquines, alarmas y DEA.',
              onTap: () {}),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard(
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 5), child: Text(subtitle)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
