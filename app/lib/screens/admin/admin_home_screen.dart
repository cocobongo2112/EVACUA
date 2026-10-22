import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/firebase/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({
    super.key,
    this.authService,
  });

  final AuthService? authService;

  Future<void> _logout(BuildContext context) async {
    await (authService ?? AuthService()).signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVACUA Admin'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Panel administrativo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Administra la información disponible en EVACUA. '
                'Los módulos se habilitan conforme avanza cada Sprint.',
              ),
              const SizedBox(height: 22),
              _AdminModuleCard(
                icon: Icons.apartment_outlined,
                title: 'Gestión de edificios',
                subtitle: 'Registrar edificios, niveles y planos.',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.adminBuildings,
                ),
              ),
              _AdminModuleCard(
                icon: Icons.route_outlined,
                title: 'Gestión de rutas',
                subtitle: 'Configurar rutas, salidas y puntos de reunión.',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.adminEvacuationRoutes,
                ),
              ),
              const _AdminModuleCard(
                icon: Icons.layers_outlined,
                title: 'Gestión de zonas',
              ),
              const _AdminModuleCard(
                icon: Icons.warning_amber_rounded,
                title: 'Gestión de emergencias',
              ),
              const _AdminModuleCard(
                icon: Icons.manage_accounts_outlined,
                title: 'Gestión de usuarios',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminModuleCard extends StatelessWidget {
  const _AdminModuleCard({
    required this.icon,
    required this.title,
    this.subtitle = 'Próximamente',
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          onTap == null ? Icons.lock_clock_outlined : Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}
