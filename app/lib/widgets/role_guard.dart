import 'package:flutter/material.dart';

import '../services/firebase/auth_service.dart';
import '../services/firebase/user_profile_service.dart';

class RoleGuard extends StatefulWidget {
  const RoleGuard({
    super.key,
    required this.requiredRole,
    required this.child,
    this.authService,
    this.profileService,
  });

  final String requiredRole;
  final Widget child;
  final AuthService? authService;
  final UserProfileService? profileService;

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  late final AuthService _authService;
  late final UserProfileService _profileService;
  late Future<bool> _authorization;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _profileService = widget.profileService ?? UserProfileService();
    _authorization = _checkAuthorization();
  }

  Future<bool> _checkAuthorization() async {
    final user = _authService.currentUser;
    if (user == null) return false;

    final profile = await _profileService.getProfile(user.uid);
    return profile != null &&
        profile.active &&
        profile.role == widget.requiredRole;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authorization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) return widget.child;

        return Scaffold(
          appBar: AppBar(title: const Text('Acceso restringido')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No tienes permisos para acceder a este módulo.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'El acceso está limitado de acuerdo con el rol asignado al usuario.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
