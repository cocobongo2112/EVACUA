import 'package:flutter/material.dart';

import '../../models/building.dart';
import '../../models/building_level.dart';
import '../../services/firebase/building_service.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({
    super.key,
    this.service,
  });

  final BuildingService? service;

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {
  late final BuildingService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BuildingService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edificios y planos'),
      ),
      body: StreamBuilder<List<Building>>(
        stream: _service.watchBuildings(
          onlyActive: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'No fue posible consultar los edificios',
              message: 'Verifica tu conexión y los permisos de Firestore.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final buildings = snapshot.data!;

          if (buildings.isEmpty) {
            return const _MessageState(
              icon: Icons.apartment_outlined,
              title: 'Aún no hay edificios disponibles',
              message:
                  'Cuando un administrador registre un edificio aparecerá aquí.',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Consulta de inmuebles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona un edificio para consultar sus niveles '
                    'y los planos disponibles.',
                  ),
                  const SizedBox(height: 22),
                  for (final building in buildings)
                    _BuildingCard(
                      building: building,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BuildingLevelsScreen(
                              building: building,
                              service: _service,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BuildingLevelsScreen extends StatelessWidget {
  const BuildingLevelsScreen({
    super.key,
    required this.building,
    required this.service,
  });

  final Building building;
  final BuildingService service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(building.name),
      ),
      body: StreamBuilder<List<BuildingLevel>>(
        stream: service.watchLevels(
          building.id,
          onlyActive: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'No fue posible consultar los niveles',
              message: 'Verifica tu conexión y vuelve a intentarlo.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final levels = snapshot.data!;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 950,
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _BuildingHeader(
                    building: building,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Niveles disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (levels.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Este edificio aún no tiene niveles '
                          'o planos disponibles.',
                        ),
                      ),
                    )
                  else
                    for (final level in levels)
                      _LevelCard(
                        level: level,
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BuildingHeader extends StatelessWidget {
  const _BuildingHeader({
    required this.building,
  });

  final Building building;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.apartment_outlined,
                  size: 34,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (building.address.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(building.address),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (building.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(building.description),
            ],
          ],
        ),
      ),
    );
  }
}

class _BuildingCard extends StatelessWidget {
  const _BuildingCard({
    required this.building,
    required this.onTap,
  });

  final Building building;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          child: Icon(
            Icons.apartment_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          building.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            building.address.isEmpty
                ? 'Consulta niveles y planos disponibles.'
                : building.address,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
  });

  final BuildingLevel level;

  @override
  Widget build(BuildContext context) {
    final hasPlan = level.planUrl.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(
              18,
              14,
              18,
              14,
            ),
            leading: CircleAvatar(
              child: Text(
                '${level.number}',
              ),
            ),
            title: Text(
              level.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: level.description.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(level.description),
                  ),
          ),
          if (hasPlan)
            Container(
              constraints: const BoxConstraints(
                minHeight: 190,
                maxHeight: 360,
              ),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Image.network(
                level.planUrl,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const _PlanUnavailable();
                },
              ),
            )
          else
            const _PlanUnavailable(),
        ],
      ),
    );
  }
}

class _PlanUnavailable extends StatelessWidget {
  const _PlanUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Column(
        children: [
          Icon(
            Icons.map_outlined,
            size: 44,
          ),
          SizedBox(height: 10),
          Text(
            'Plano no disponible',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
