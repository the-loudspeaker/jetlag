import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';
import '../../services/storage_service.dart';
import '../shared/location_map.dart';
import '../shared/location_provider_state.dart';
import '../shared/role_selection_screen.dart';

class SeekerHome extends StatefulWidget {
  const SeekerHome({super.key});

  @override
  State<SeekerHome> createState() => _SeekerHomeState();
}

class _SeekerHomeState extends State<SeekerHome>
    with LocationProviderState<SeekerHome>, WidgetsBindingObserver {
  final SupabaseService _supabaseService = SupabaseService();
  final StorageService _storageService = StorageService();

  static const double _mapHeight = 520;
  static const double _mapContainerExtra = 88;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initLocationProvider();
    _startSyncing();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSyncing();
    } else {
      _syncTimer?.cancel();
    }
  }

  void _startSyncing() {
    _syncTimer?.cancel();
    _pushLocation();
    _syncTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _pushLocation(),
    );
  }

  Future<void> _pushLocation() async {
    await refreshLocation();
    if (currentLocation != null) {
      await _supabaseService.updateSeekerLocation(
        currentLocation!.latitude,
        currentLocation!.longitude,
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _storageService.clearAll();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Seeker!'),
        actions: [
          IconButton(
            onPressed: () async => await _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _mapHeight + _mapContainerExtra,
              child: LocationMap(
                currentLocation: currentLocation,
                isFetching: isFetchingLocation,
                errorMessage: locationError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
