import 'package:flutter/material.dart';

void main() {
  runApp(const EvacuaApp());
}

class EvacuaApp extends StatelessWidget {
  const EvacuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVACUA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007F76)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EVACUA'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Sistema de evacuación y gestión de emergencias',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Consulta la información preventiva del inmueble y sigue siempre las indicaciones del personal responsable.',
          ),
          SizedBox(height: 24),
          _ActionCard(
            icon: Icons.qr_code_scanner,
            title: 'Escanear ubicación',
            description: 'Identifica el nivel o la zona mediante un código QR.',
          ),
          _ActionCard(
            icon: Icons.route,
            title: 'Consultar ruta',
            description: 'Visualiza la ruta preconfigurada y el punto de reunión.',
          ),
          _ActionCard(
            icon: Icons.fire_extinguisher,
            title: 'Equipos cercanos',
            description: 'Ubica extintores, botiquines, alarmas y otros recursos.',
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

