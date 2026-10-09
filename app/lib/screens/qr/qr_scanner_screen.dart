import 'package:flutter/material.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear ubicación')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.qr_code_scanner,
                  size: 82, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Identifica tu zona mediante un código QR',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Los códigos QR estarán asociados a zonas o pisos del inmueble para mostrar la información correspondiente.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                  'Prototipo visual del Sprint 2. La cámara, permisos y lectura real del QR se implementarán en el Sprint 6.'),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Lectura real de QR programada para el Sprint 6.')),
              );
            },
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Iniciar escaneo'),
          ),
        ],
      ),
    );
  }
}
