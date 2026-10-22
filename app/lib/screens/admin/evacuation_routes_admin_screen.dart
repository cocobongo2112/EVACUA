import 'package:flutter/material.dart';

import '../../models/building.dart';
import '../../models/building_level.dart';
import '../../models/evacuation_exit.dart';
import '../../models/evacuation_route.dart';
import '../../models/meeting_point.dart';
import '../../services/firebase/building_service.dart';
import '../../services/firebase/evacuation_route_service.dart';

class EvacuationRoutesAdminScreen extends StatefulWidget {
  const EvacuationRoutesAdminScreen({
    super.key,
    this.buildingService,
    this.routeService,
  });

  final BuildingService? buildingService;
  final EvacuationRouteService? routeService;

  @override
  State<EvacuationRoutesAdminScreen> createState() =>
      _EvacuationRoutesAdminScreenState();
}

class _EvacuationRoutesAdminScreenState
    extends State<EvacuationRoutesAdminScreen> {
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
        title: const Text('Gestión de rutas'),
      ),
      body: StreamBuilder<List<Building>>(
        stream: _buildingService.watchBuildings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _AdminMessageState(
              icon: Icons.cloud_off_outlined,
              title: 'No fue posible cargar los edificios',
              message: 'Revisa la conexión y los permisos de Firestore.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final buildings = snapshot.data!;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 950,
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Rutas, salidas y puntos de reunión',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona un edificio para configurar '
                    'la información de evacuación.',
                  ),
                  const SizedBox(height: 22),
                  if (buildings.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Text(
                          'Primero registra un edificio en '
                          'Gestión de edificios.',
                        ),
                      ),
                    )
                  else
                    for (final building in buildings)
                      Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(18),
                          leading: Icon(
                            Icons.apartment_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            building.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            building.active
                                ? 'Edificio activo'
                                : 'Edificio inactivo',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BuildingEvacuationAdminScreen(
                                  building: building,
                                  buildingService: _buildingService,
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

class BuildingEvacuationAdminScreen extends StatefulWidget {
  const BuildingEvacuationAdminScreen({
    super.key,
    required this.building,
    required this.buildingService,
    required this.routeService,
  });

  final Building building;
  final BuildingService buildingService;
  final EvacuationRouteService routeService;

  @override
  State<BuildingEvacuationAdminScreen> createState() =>
      _BuildingEvacuationAdminScreenState();
}

class _BuildingEvacuationAdminScreenState
    extends State<BuildingEvacuationAdminScreen> {
  Future<void> _openExitForm([
    EvacuationExit? exit,
  ]) async {
    final levels =
        await widget.buildingService.watchLevels(widget.building.id).first;

    if (!mounted) {
      return;
    }

    if (levels.isEmpty) {
      _showMessage(
        'Primero registra al menos un nivel para este edificio.',
      );
      return;
    }

    final result = await showDialog<_ExitFormValue>(
      context: context,
      builder: (_) => _ExitFormDialog(
        levels: levels,
        exit: exit,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      if (exit == null) {
        await widget.routeService.createExit(
          buildingId: widget.building.id,
          levelId: result.level.id,
          levelName: result.level.name,
          name: result.name,
          description: result.description,
        );
      } else {
        await widget.routeService.updateExit(
          EvacuationExit(
            id: exit.id,
            buildingId: exit.buildingId,
            levelId: result.level.id,
            levelName: result.level.name,
            name: result.name,
            description: result.description,
            active: exit.active,
          ),
        );
      }

      _showMessage(
        exit == null
            ? 'Salida registrada correctamente.'
            : 'Salida actualizada correctamente.',
      );
    } catch (_) {
      _showMessage('No fue posible guardar la salida.');
    }
  }

  Future<void> _openMeetingPointForm([
    MeetingPoint? point,
  ]) async {
    final result = await showDialog<_MeetingPointFormValue>(
      context: context,
      builder: (_) => _MeetingPointFormDialog(
        point: point,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      if (point == null) {
        await widget.routeService.createMeetingPoint(
          buildingId: widget.building.id,
          name: result.name,
          location: result.location,
          description: result.description,
        );
      } else {
        await widget.routeService.updateMeetingPoint(
          MeetingPoint(
            id: point.id,
            buildingId: point.buildingId,
            name: result.name,
            location: result.location,
            description: result.description,
            active: point.active,
          ),
        );
      }

      _showMessage(
        point == null
            ? 'Punto de reunión registrado correctamente.'
            : 'Punto de reunión actualizado correctamente.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible guardar el punto de reunión.',
      );
    }
  }

  Future<void> _openRouteForm([
    EvacuationRoute? route,
  ]) async {
    final values = await Future.wait<dynamic>([
      widget.buildingService.watchLevels(widget.building.id).first,
      widget.routeService
          .watchExits(widget.building.id, onlyActive: true)
          .first,
      widget.routeService
          .watchMeetingPoints(widget.building.id, onlyActive: true)
          .first,
    ]);

    if (!mounted) {
      return;
    }

    final levels = values[0] as List<BuildingLevel>;
    final exits = values[1] as List<EvacuationExit>;
    final points = values[2] as List<MeetingPoint>;

    if (levels.isEmpty || exits.isEmpty || points.isEmpty) {
      _showMessage(
        'Para crear una ruta necesitas al menos un nivel, '
        'una salida activa y un punto de reunión activo.',
      );
      return;
    }

    final result = await showDialog<_RouteFormValue>(
      context: context,
      builder: (_) => _RouteFormDialog(
        levels: levels,
        exits: exits,
        points: points,
        route: route,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      if (route == null) {
        await widget.routeService.createRoute(
          buildingId: widget.building.id,
          levelId: result.level.id,
          levelName: result.level.name,
          name: result.name,
          origin: result.origin,
          instructions: result.instructions,
          exitId: result.exit.id,
          exitName: result.exit.name,
          meetingPointId: result.point.id,
          meetingPointName: result.point.name,
        );
      } else {
        await widget.routeService.updateRoute(
          EvacuationRoute(
            id: route.id,
            buildingId: route.buildingId,
            levelId: result.level.id,
            levelName: result.level.name,
            name: result.name,
            origin: result.origin,
            instructions: result.instructions,
            exitId: result.exit.id,
            exitName: result.exit.name,
            meetingPointId: result.point.id,
            meetingPointName: result.point.name,
            active: route.active,
          ),
        );
      }

      _showMessage(
        route == null
            ? 'Ruta registrada correctamente.'
            : 'Ruta actualizada correctamente.',
      );
    } catch (_) {
      _showMessage('No fue posible guardar la ruta.');
    }
  }

  Future<void> _toggleExit(
    EvacuationExit exit,
  ) async {
    try {
      await widget.routeService.setExitActive(
        buildingId: widget.building.id,
        exitId: exit.id,
        active: !exit.active,
      );
      _showMessage(
        exit.active ? 'Salida desactivada.' : 'Salida activada.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible cambiar el estado de la salida.',
      );
    }
  }

  Future<void> _togglePoint(
    MeetingPoint point,
  ) async {
    try {
      await widget.routeService.setMeetingPointActive(
        buildingId: widget.building.id,
        pointId: point.id,
        active: !point.active,
      );
      _showMessage(
        point.active
            ? 'Punto de reunión desactivado.'
            : 'Punto de reunión activado.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible cambiar el estado del punto.',
      );
    }
  }

  Future<void> _toggleRoute(
    EvacuationRoute route,
  ) async {
    try {
      await widget.routeService.setRouteActive(
        buildingId: widget.building.id,
        routeId: route.id,
        active: !route.active,
      );
      _showMessage(
        route.active ? 'Ruta desactivada.' : 'Ruta activada.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible cambiar el estado de la ruta.',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.building.name),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Configuración de evacuación',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configura primero las salidas y puntos de reunión. '
                'Después crea las rutas que los relacionan.',
              ),
              const SizedBox(height: 26),
              _SectionTitle(
                icon: Icons.exit_to_app,
                title: 'Salidas',
                buttonText: 'Nueva salida',
                onPressed: _openExitForm,
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<EvacuationExit>>(
                stream: widget.routeService.watchExits(widget.building.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final exits = snapshot.data!;
                  if (exits.isEmpty) {
                    return const _EmptyCard(
                      text: 'No hay salidas registradas.',
                    );
                  }

                  return Column(
                    children: [
                      for (final exit in exits)
                        _ManagementCard(
                          title: exit.name,
                          subtitle: exit.levelName.isEmpty
                              ? exit.description
                              : '${exit.levelName} · ${exit.description}',
                          active: exit.active,
                          onEdit: () => _openExitForm(exit),
                          onToggle: () => _toggleExit(exit),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              _SectionTitle(
                icon: Icons.groups_outlined,
                title: 'Puntos de reunión',
                buttonText: 'Nuevo punto',
                onPressed: _openMeetingPointForm,
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<MeetingPoint>>(
                stream:
                    widget.routeService.watchMeetingPoints(widget.building.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final points = snapshot.data!;
                  if (points.isEmpty) {
                    return const _EmptyCard(
                      text: 'No hay puntos de reunión registrados.',
                    );
                  }

                  return Column(
                    children: [
                      for (final point in points)
                        _ManagementCard(
                          title: point.name,
                          subtitle: point.location.isEmpty
                              ? point.description
                              : '${point.location} · ${point.description}',
                          active: point.active,
                          onEdit: () => _openMeetingPointForm(point),
                          onToggle: () => _togglePoint(point),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              _SectionTitle(
                icon: Icons.route_outlined,
                title: 'Rutas',
                buttonText: 'Nueva ruta',
                onPressed: _openRouteForm,
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<EvacuationRoute>>(
                stream: widget.routeService.watchRoutes(widget.building.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final routes = snapshot.data!;
                  if (routes.isEmpty) {
                    return const _EmptyCard(
                      text: 'No hay rutas registradas.',
                    );
                  }

                  return Column(
                    children: [
                      for (final route in routes)
                        _RouteManagementCard(
                          route: route,
                          onEdit: () => _openRouteForm(route),
                          onToggle: () => _toggleRoute(route),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: Text(buttonText),
        ),
      ],
    );
  }
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onEdit,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitle.trim().isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(subtitle),
              ),
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              active ? 'Activo' : 'Inactivo',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
            IconButton(
              tooltip: 'Editar',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: active ? 'Desactivar' : 'Activar',
              onPressed: onToggle,
              icon: Icon(
                active
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteManagementCard extends StatelessWidget {
  const _RouteManagementCard({
    required this.route,
    required this.onEdit,
    required this.onToggle,
  });

  final EvacuationRoute route;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  route.active ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: route.active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '${route.levelName} · ${route.origin}',
            ),
            const SizedBox(height: 4),
            Text(
              'Salida: ${route.exitName} · '
              'Punto: ${route.meetingPointName}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                TextButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    route.active
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  label: Text(
                    route.active ? 'Desactivar' : 'Activar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(text),
      ),
    );
  }
}

class _ExitFormValue {
  const _ExitFormValue({
    required this.level,
    required this.name,
    required this.description,
  });

  final BuildingLevel level;
  final String name;
  final String description;
}

class _ExitFormDialog extends StatefulWidget {
  const _ExitFormDialog({
    required this.levels,
    this.exit,
  });

  final List<BuildingLevel> levels;
  final EvacuationExit? exit;

  @override
  State<_ExitFormDialog> createState() => _ExitFormDialogState();
}

class _ExitFormDialogState extends State<_ExitFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late BuildingLevel _level;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _level = widget.levels.firstWhere(
      (level) => level.id == widget.exit?.levelId,
      orElse: () => widget.levels.first,
    );
    _nameController = TextEditingController(
      text: widget.exit?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.exit?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _ExitFormValue(
        level: _level,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.exit == null ? 'Nueva salida' : 'Editar salida',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<BuildingLevel>(
                  initialValue: _level,
                  decoration: const InputDecoration(
                    labelText: 'Nivel',
                  ),
                  items: [
                    for (final level in widget.levels)
                      DropdownMenuItem(
                        value: level,
                        child: Text(level.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _level = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la salida',
                    hintText: 'Ej. Salida Norte',
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').length < 2) {
                      return 'Ingresa el nombre de la salida.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción / ubicación',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _MeetingPointFormValue {
  const _MeetingPointFormValue({
    required this.name,
    required this.location,
    required this.description,
  });

  final String name;
  final String location;
  final String description;
}

class _MeetingPointFormDialog extends StatefulWidget {
  const _MeetingPointFormDialog({
    this.point,
  });

  final MeetingPoint? point;

  @override
  State<_MeetingPointFormDialog> createState() =>
      _MeetingPointFormDialogState();
}

class _MeetingPointFormDialogState extends State<_MeetingPointFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.point?.name ?? '',
    );
    _locationController = TextEditingController(
      text: widget.point?.location ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.point?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _MeetingPointFormValue(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.point == null
            ? 'Nuevo punto de reunión'
            : 'Editar punto de reunión',
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej. Punto A',
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').length < 2) {
                      return 'Ingresa el nombre del punto.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    hintText: 'Ej. Estacionamiento principal',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _RouteFormValue {
  const _RouteFormValue({
    required this.level,
    required this.exit,
    required this.point,
    required this.name,
    required this.origin,
    required this.instructions,
  });

  final BuildingLevel level;
  final EvacuationExit exit;
  final MeetingPoint point;
  final String name;
  final String origin;
  final String instructions;
}

class _RouteFormDialog extends StatefulWidget {
  const _RouteFormDialog({
    required this.levels,
    required this.exits,
    required this.points,
    this.route,
  });

  final List<BuildingLevel> levels;
  final List<EvacuationExit> exits;
  final List<MeetingPoint> points;
  final EvacuationRoute? route;

  @override
  State<_RouteFormDialog> createState() => _RouteFormDialogState();
}

class _RouteFormDialogState extends State<_RouteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late BuildingLevel _level;
  late EvacuationExit _exit;
  late MeetingPoint _point;

  late final TextEditingController _nameController;
  late final TextEditingController _originController;
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();

    _level = widget.levels.firstWhere(
      (item) => item.id == widget.route?.levelId,
      orElse: () => widget.levels.first,
    );

    _exit = widget.exits.firstWhere(
      (item) => item.id == widget.route?.exitId,
      orElse: () => widget.exits.first,
    );

    _point = widget.points.firstWhere(
      (item) => item.id == widget.route?.meetingPointId,
      orElse: () => widget.points.first,
    );

    _nameController = TextEditingController(
      text: widget.route?.name ?? '',
    );
    _originController = TextEditingController(
      text: widget.route?.origin ?? '',
    );
    _instructionsController = TextEditingController(
      text: widget.route?.instructions ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _RouteFormValue(
        level: _level,
        exit: _exit,
        point: _point,
        name: _nameController.text.trim(),
        origin: _originController.text.trim(),
        instructions: _instructionsController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.route == null ? 'Nueva ruta' : 'Editar ruta',
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la ruta',
                    hintText: 'Ej. Ruta PB Norte',
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').length < 2) {
                      return 'Ingresa el nombre de la ruta.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<BuildingLevel>(
                  initialValue: _level,
                  decoration: const InputDecoration(
                    labelText: 'Nivel',
                  ),
                  items: [
                    for (final level in widget.levels)
                      DropdownMenuItem(
                        value: level,
                        child: Text(level.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _level = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _originController,
                  decoration: const InputDecoration(
                    labelText: 'Origen',
                    hintText: 'Ej. Recepción / zona administrativa',
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').length < 2) {
                      return 'Ingresa el origen de la ruta.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _instructionsController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Trayecto / instrucciones',
                    hintText: 'Ej. Avanzar por pasillo principal...',
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').length < 5) {
                      return 'Describe el trayecto de la ruta.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<EvacuationExit>(
                  initialValue: _exit,
                  decoration: const InputDecoration(
                    labelText: 'Salida',
                  ),
                  items: [
                    for (final exit in widget.exits)
                      DropdownMenuItem(
                        value: exit,
                        child: Text(exit.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _exit = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<MeetingPoint>(
                  initialValue: _point,
                  decoration: const InputDecoration(
                    labelText: 'Punto de reunión',
                  ),
                  items: [
                    for (final point in widget.points)
                      DropdownMenuItem(
                        value: point,
                        child: Text(point.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _point = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _AdminMessageState extends StatelessWidget {
  const _AdminMessageState({
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
