import 'package:flutter/material.dart';

import '../../models/building.dart';
import '../../models/evacuation_route.dart';
import '../../services/firebase/building_service.dart';
import '../../services/firebase/evacuation_route_service.dart';

class EvacuationRouteScreen extends StatefulWidget {
  const EvacuationRouteScreen({
    super.key,
    this.buildingService,
    this.routeService,
  });

  final BuildingService? buildingService;
  final EvacuationRouteService? routeService;

  @override
  State<EvacuationRouteScreen> createState() => _EvacuationRouteScreenState();
}

class _EvacuationRouteScreenState extends State<EvacuationRouteScreen> {
  late final BuildingService _buildingService;
  late final EvacuationRouteService _routeService;

  @override
  void initState() {
    super.initState();
    _buildingService = widget.buildingService ?? BuildingService();
    _routeService = widget.routeService ?? EvacuationRouteService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas de evacuación'),
      ),
      body: StreamBuilder<List<Building>>(
        stream: _buildingService.watchBuildings(
          onlyActive: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'No fue posible consultar las rutas',
              message: 'Verifica la conexión y los permisos de Firestore.',
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
              title: 'No hay edificios disponibles',
              message: 'Primero debe existir un edificio activo '
                  'con rutas configuradas.',
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
                    'Selecciona un edificio',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Consulta las rutas de evacuación, salidas '
                    'y puntos de reunión configurados.',
                  ),
                  const SizedBox(height: 22),
                  for (final building in buildings)
                    Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(18),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.10),
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
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            building.address.isEmpty
                                ? 'Ver rutas disponibles'
                                : building.address,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BuildingRoutesScreen(
                                building: building,
                                routeService: _routeService,
                              ),
                            ),
                          );
                        },
                      ),
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

class BuildingRoutesScreen extends StatelessWidget {
  const BuildingRoutesScreen({
    super.key,
    required this.building,
    required this.routeService,
  });

  final Building building;
  final EvacuationRouteService routeService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(building.name),
      ),
      body: StreamBuilder<List<EvacuationRoute>>(
        stream: routeService.watchRoutes(
          building.id,
          onlyActive: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'No fue posible cargar las rutas',
              message: 'Verifica tu conexión e inténtalo nuevamente.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final routes = snapshot.data!;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 950,
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Rutas disponibles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    building.address.isEmpty
                        ? 'Consulta el trayecto recomendado.'
                        : building.address,
                  ),
                  const SizedBox(height: 22),
                  if (routes.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Text(
                          'Este edificio todavía no tiene '
                          'rutas activas configuradas.',
                        ),
                      ),
                    )
                  else
                    for (final route in routes)
                      _RouteCard(
                        route: route,
                      ),
                  const SizedBox(height: 10),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'En una emergencia real prevalecen los '
                        'protocolos oficiales, la señalización del '
                        'inmueble y las indicaciones del personal '
                        'responsable.',
                      ),
                    ),
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

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
  });

  final EvacuationRoute route;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.10),
                  child: Icon(
                    Icons.route_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (route.levelName.isNotEmpty) Text(route.levelName),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RouteDetail(
              icon: Icons.my_location_outlined,
              label: 'Origen',
              value: route.origin,
            ),
            _RouteDetail(
              icon: Icons.directions_walk_outlined,
              label: 'Trayecto',
              value: route.instructions,
            ),
            _RouteDetail(
              icon: Icons.exit_to_app,
              label: 'Salida',
              value: route.exitName,
            ),
            _RouteDetail(
              icon: Icons.groups_outlined,
              label: 'Punto de reunión',
              value: route.meetingPointName,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteDetail extends StatelessWidget {
  const _RouteDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: value.isEmpty ? 'Sin información' : value,
                  ),
                ],
              ),
            ),
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
