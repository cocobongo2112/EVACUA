import 'package:flutter/material.dart';

import '../../models/building.dart';
import '../../models/building_level.dart';
import '../../services/firebase/building_service.dart';

class BuildingsAdminScreen extends StatefulWidget {
  const BuildingsAdminScreen({
    super.key,
    this.service,
  });

  final BuildingService? service;

  @override
  State<BuildingsAdminScreen> createState() => _BuildingsAdminScreenState();
}

class _BuildingsAdminScreenState extends State<BuildingsAdminScreen> {
  late final BuildingService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? BuildingService();
  }

  Future<void> _openBuildingForm([
    Building? building,
  ]) async {
    final result = await showDialog<_BuildingFormValue>(
      context: context,
      builder: (_) => _BuildingFormDialog(
        building: building,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      if (building == null) {
        await _service.createBuilding(
          name: result.name,
          address: result.address,
          description: result.description,
        );
      } else {
        await _service.updateBuilding(
          Building(
            id: building.id,
            name: result.name,
            address: result.address,
            description: result.description,
            active: building.active,
          ),
        );
      }

      _showMessage(
        building == null
            ? 'Edificio registrado correctamente.'
            : 'Edificio actualizado correctamente.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible guardar el edificio.',
      );
    }
  }

  Future<void> _toggleBuilding(
    Building building,
  ) async {
    try {
      await _service.setBuildingActive(
        buildingId: building.id,
        active: !building.active,
      );

      _showMessage(
        building.active ? 'Edificio desactivado.' : 'Edificio activado.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible cambiar el estado del edificio.',
      );
    }
  }

  void _openLevels(
    Building building,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuildingLevelsAdminScreen(
          building: building,
          service: _service,
        ),
      ),
    );
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
        title: const Text('Gestión de edificios'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBuildingForm,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo edificio'),
      ),
      body: StreamBuilder<List<Building>>(
        stream: _service.watchBuildings(),
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
                maxWidth: 1050,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  100,
                ),
                children: [
                  Text(
                    'Edificios y planos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Registra inmuebles y administra sus niveles '
                    'y planos. Los edificios desactivados no se '
                    'muestran en la consulta del usuario.',
                  ),
                  const SizedBox(height: 22),
                  if (buildings.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No hay edificios registrados. '
                          'Usa "Nuevo edificio" para crear el primero.',
                        ),
                      ),
                    )
                  else
                    for (final building in buildings)
                      _AdminBuildingCard(
                        building: building,
                        onLevels: () => _openLevels(
                          building,
                        ),
                        onEdit: () => _openBuildingForm(
                          building,
                        ),
                        onToggle: () => _toggleBuilding(
                          building,
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

class BuildingLevelsAdminScreen extends StatefulWidget {
  const BuildingLevelsAdminScreen({
    super.key,
    required this.building,
    required this.service,
  });

  final Building building;
  final BuildingService service;

  @override
  State<BuildingLevelsAdminScreen> createState() =>
      _BuildingLevelsAdminScreenState();
}

class _BuildingLevelsAdminScreenState extends State<BuildingLevelsAdminScreen> {
  Future<void> _openLevelForm([
    BuildingLevel? level,
  ]) async {
    final result = await showDialog<_LevelFormValue>(
      context: context,
      builder: (_) => _LevelFormDialog(
        level: level,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      if (level == null) {
        await widget.service.createLevel(
          buildingId: widget.building.id,
          name: result.name,
          number: result.number,
          description: result.description,
          planUrl: result.planUrl,
        );
      } else {
        await widget.service.updateLevel(
          BuildingLevel(
            id: level.id,
            buildingId: level.buildingId,
            name: result.name,
            number: result.number,
            description: result.description,
            planUrl: result.planUrl,
            active: level.active,
          ),
        );
      }

      _showMessage(
        level == null
            ? 'Nivel registrado correctamente.'
            : 'Nivel actualizado correctamente.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible guardar el nivel.',
      );
    }
  }

  Future<void> _toggleLevel(
    BuildingLevel level,
  ) async {
    try {
      await widget.service.setLevelActive(
        buildingId: widget.building.id,
        levelId: level.id,
        active: !level.active,
      );

      _showMessage(
        level.active ? 'Nivel desactivado.' : 'Nivel activado.',
      );
    } catch (_) {
      _showMessage(
        'No fue posible cambiar el estado del nivel.',
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
        title: Text(
          widget.building.name,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLevelForm,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo nivel'),
      ),
      body: StreamBuilder<List<BuildingLevel>>(
        stream: widget.service.watchLevels(
          widget.building.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _AdminMessageState(
              icon: Icons.cloud_off_outlined,
              title: 'No fue posible cargar los niveles',
              message: 'Revisa la conexión y vuelve a intentarlo.',
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
                maxWidth: 1050,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  100,
                ),
                children: [
                  Text(
                    'Niveles y planos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.building.address.isEmpty
                        ? 'Administra los niveles de este edificio.'
                        : widget.building.address,
                  ),
                  const SizedBox(height: 22),
                  if (levels.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Este edificio todavía no tiene niveles. '
                          'Usa "Nuevo nivel" para registrar uno.',
                        ),
                      ),
                    )
                  else
                    for (final level in levels)
                      _AdminLevelCard(
                        level: level,
                        onEdit: () => _openLevelForm(
                          level,
                        ),
                        onToggle: () => _toggleLevel(
                          level,
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

class _AdminBuildingCard extends StatelessWidget {
  const _AdminBuildingCard({
    required this.building,
    required this.onLevels,
    required this.onEdit,
    required this.onToggle,
  });

  final Building building;
  final VoidCallback onLevels;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final statusColor = building.active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.apartment_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (building.address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(building.address),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    building.active ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (building.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(building.description),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onLevels,
                  icon: const Icon(Icons.layers_outlined),
                  label: const Text('Niveles y planos'),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                TextButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    building.active
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  label: Text(
                    building.active ? 'Desactivar' : 'Activar',
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

class _AdminLevelCard extends StatelessWidget {
  const _AdminLevelCard({
    required this.level,
    required this.onEdit,
    required this.onToggle,
  });

  final BuildingLevel level;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final statusColor = level.active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Text('${level.number}'),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (level.description.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(level.description),
                      ],
                    ],
                  ),
                ),
                Text(
                  level.active ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _PlanPreview(
              planUrl: level.planUrl,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
                TextButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    level.active
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  label: Text(
                    level.active ? 'Desactivar' : 'Activar',
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

class _PlanPreview extends StatelessWidget {
  const _PlanPreview({
    required this.planUrl,
  });

  final String planUrl;

  @override
  Widget build(BuildContext context) {
    if (planUrl.trim().isEmpty) {
      return const _PlanPlaceholder(
        text: 'Sin plano asignado',
      );
    }

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        planUrl,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const _PlanPlaceholder(
            text: 'No fue posible cargar el plano',
          );
        },
      ),
    );
  }
}

class _PlanPlaceholder extends StatelessWidget {
  const _PlanPlaceholder({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.map_outlined,
            size: 42,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BuildingFormValue {
  const _BuildingFormValue({
    required this.name,
    required this.address,
    required this.description,
  });

  final String name;
  final String address;
  final String description;
}

class _BuildingFormDialog extends StatefulWidget {
  const _BuildingFormDialog({
    this.building,
  });

  final Building? building;

  @override
  State<_BuildingFormDialog> createState() => _BuildingFormDialogState();
}

class _BuildingFormDialogState extends State<_BuildingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.building?.name ?? '',
    );
    _addressController = TextEditingController(
      text: widget.building?.address ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.building?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _BuildingFormValue(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.building == null ? 'Nuevo edificio' : 'Editar edificio',
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
                    labelText: 'Nombre del edificio',
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').length < 2) {
                      return 'Ingresa el nombre del edificio.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación o dirección',
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

class _LevelFormValue {
  const _LevelFormValue({
    required this.name,
    required this.number,
    required this.description,
    required this.planUrl,
  });

  final String name;
  final int number;
  final String description;
  final String planUrl;
}

class _LevelFormDialog extends StatefulWidget {
  const _LevelFormDialog({
    this.level,
  });

  final BuildingLevel? level;

  @override
  State<_LevelFormDialog> createState() => _LevelFormDialogState();
}

class _LevelFormDialogState extends State<_LevelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _planUrlController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.level?.name ?? '',
    );
    _numberController = TextEditingController(
      text: widget.level?.number.toString() ?? '0',
    );
    _descriptionController = TextEditingController(
      text: widget.level?.description ?? '',
    );
    _planUrlController = TextEditingController(
      text: widget.level?.planUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _descriptionController.dispose();
    _planUrlController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _LevelFormValue(
        name: _nameController.text.trim(),
        number: int.parse(
          _numberController.text.trim(),
        ),
        description: _descriptionController.text.trim(),
        planUrl: _planUrlController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.level == null ? 'Nuevo nivel' : 'Editar nivel',
      ),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del nivel',
                    hintText: 'Ej. Planta baja',
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').length < 2) {
                      return 'Ingresa el nombre del nivel.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número / orden',
                    hintText: '0 para planta baja',
                  ),
                  validator: (value) {
                    final number = int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (number == null) {
                      return 'Ingresa un número válido.';
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
                    labelText: 'Descripción',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _planUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'URL del plano',
                    hintText: 'https://.../plano.png',
                    helperText: 'Campo opcional. En este Sprint se guarda '
                        'la referencia al plano mediante URL.',
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
