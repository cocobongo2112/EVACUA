import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'EVACUA',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sistema integral de apoyo para evacuaciones y gestión de emergencias.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 18),
              Text(
                'Consulta rutas, zonas, puntos de reunión y equipos de emergencia de forma rápida.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                  );
                },
                child: const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.register,
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: const Text('Crear cuenta'),
              ),
              const SizedBox(height: 18),
              Text(
                'EVACUA es una herramienta informativa. '
                'En una emergencia prevalecen los protocolos oficiales.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
