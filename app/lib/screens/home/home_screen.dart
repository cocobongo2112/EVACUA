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
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Sistema de evacuación y gestión de emergencias',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Prototipo navegable · Sprint 2',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explora las pantallas principales. Las funciones reales de QR, rutas y emergencias se integrarán en los Sprints definidos en la planeación.',
          ),
          const SizedBox(height: 24),
          _HomeCard(
            icon: Icons.qr_code_scanner,
            title: 'Escanear ubicación',
            subtitle: 'Prototipo de lectura de código QR.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.qrScanner),
          ),
          _HomeCard(
            icon: Icons.location_on_outlined,
            title: 'Mi zona',
            subtitle: 'Pantalla de zona y plano del inmueble.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.myZone),
          ),
          _HomeCard(
            icon: Icons.route_outlined,
            title: 'Consultar ruta',
            subtitle: 'Prototipo de ruta, salida y punto de reunión.',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.evacuationRoute),
          ),
          _HomeCard(
            icon: Icons.warning_amber_rounded,
            title: 'Modo de emergencia',
            subtitle: 'Selección visual del tipo de emergencia.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.emergency),
          ),
          _HomeCard(
            icon: Icons.fire_extinguisher,
            title: 'Equipos de emergencia',
            subtitle: 'Prototipo de recursos y equipos disponibles.',
            onTap: () => Navigator.pushNamed(context, AppRoutes.equipment),
          ),
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
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 5), child: Text(subtitle)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
