import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../hiders/hider_home.dart';
import '../seekers/seeker_home.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    await StorageService().setUserRole(role);
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            role == 'seeker' ? const SeekerHome() : const HiderHome(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectRole(context, 'seeker'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              child: const Text('SEEKER', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'hider'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 60),
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              child: const Text('HIDER', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
