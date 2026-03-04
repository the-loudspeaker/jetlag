import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../services/supabase_service.dart';
import '../../services/storage_service.dart';
import '../shared/location_map.dart';
import '../shared/location_provider_state.dart';
import '../shared/role_selection_screen.dart';
import 'elapsed_time_display.dart';
import '../../widgets/hider/distance_card.dart';
import '../../widgets/shared/confirmation_dialog.dart';

class HiderHome extends StatefulWidget {
  const HiderHome({super.key});

  @override
  State<HiderHome> createState() => _HiderHomeState();
}

class _HiderHomeState extends State<HiderHome>
    with LocationProviderState<HiderHome>, WidgetsBindingObserver {
  final SupabaseService _supabaseService = SupabaseService();
  final StorageService _storageService = StorageService();
  
  DateTime? _startTime;
  LatLng? _seekerLocation;
  Timer? _fetchTimer;

  static const double _mapHeight = 520;
  static const double _mapContainerExtra = 88;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
    initLocationProvider();
    _startFetching();
  }

  Future<void> _loadInitialData() async {
    _startTime = await _storageService.getStartTime();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startFetching();
    } else {
      _fetchTimer?.cancel();
    }
  }

  void _startFetching() {
    _fetchTimer?.cancel();
    _fetchSeekerLocation();
    _fetchTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _fetchSeekerLocation(),
    );
  }

  Future<void> _fetchSeekerLocation() async {
    final location = await _supabaseService.fetchSeekerLocation();
    if (location != null && mounted) {
      setState(() {
        _seekerLocation = location;
      });
    }
  }

  Future<void> _confirmStartTimer() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Confirm Start Timer?',
          content: 'This will record the start time and begin the countdown.',
          confirmLabel: 'Confirm',
          onConfirm: () async {
            final now = DateTime.now();
            await _storageService.setStartTime(now);
            setState(() {
              _startTime = now;
            });
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Confirm Logout?',
          content: 'This will log you out & end the timer.',
          confirmLabel: 'Logout',
          confirmColor: Theme.of(context).colorScheme.error,
          onConfirm: () async {
            await _storageService.clearAll();
            if (!context.mounted) return;
            Navigator.pop(context); // Close sheet
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RoleSelectionScreen(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Hider!'),
        actions: [
          IconButton(
            onPressed: () async => await _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_startTime == null)
              FloatingActionButton.small(
                onPressed: _confirmStartTimer,
                backgroundColor: Colors.lightGreen,
                child: const Text("Start Timer"),
              ),
            if (_startTime != null) ElapsedTimeDisplay(startTime: _startTime!),
            const SizedBox(height: 8),
            DistanceCard(
              currentLocation: currentLocation,
              seekerLocation: _seekerLocation,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: _mapHeight + _mapContainerExtra,
              child: LocationMap(
                currentLocation: currentLocation,
                seekerLocation: _seekerLocation,
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
