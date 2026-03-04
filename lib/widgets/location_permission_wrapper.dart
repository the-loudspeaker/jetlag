import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../screens/shared/role_selection_screen.dart';
import '../screens/hiders/hider_home.dart';
import '../screens/seekers/seeker_home.dart';

class LocationPermissionWrapper extends StatefulWidget {
  final String? initialRole;

  const LocationPermissionWrapper({super.key, this.initialRole});

  @override
  State<LocationPermissionWrapper> createState() =>
      _LocationPermissionWrapperState();
}

class _LocationPermissionWrapperState extends State<LocationPermissionWrapper>
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  bool _isLocationEnabled = false;
  LocationPermission _permission = LocationPermission.denied;
  bool _isPrecise = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await _locationService.isLocationServiceEnabled();
    LocationPermission permission = await _locationService.checkPermission();

    LocationAccuracyStatus accuracy = LocationAccuracyStatus.reduced;
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      try {
        accuracy = await _locationService.getLocationAccuracy();
      } catch (e) {
        accuracy = LocationAccuracyStatus.reduced;
      }
    }

    if (mounted) {
      setState(() {
        _isLocationEnabled = serviceEnabled;
        _permission = permission;
        _isPrecise = accuracy == LocationAccuracyStatus.precise;
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePermissionAction() async {
    if (!_isLocationEnabled) {
      await _locationService.openLocationSettings();
    } else if (_permission == LocationPermission.denied) {
      await _locationService.requestPermission();
    } else {
      await _locationService.openAppSettings();
    }
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool hasValidPermission =
        (_permission == LocationPermission.always ||
            _permission == LocationPermission.whileInUse) &&
        _isPrecise;

    if (_isLocationEnabled && hasValidPermission) {
      if (widget.initialRole == null) {
        return const RoleSelectionScreen();
      } else {
        return widget.initialRole == 'seeker'
            ? const SeekerHome()
            : const HiderHome();
      }
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusTitleStyle = (textTheme.headlineSmall ?? const TextStyle())
        .copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary);
    final statusDescriptionStyle =
        (textTheme.bodyMedium ?? const TextStyle(fontSize: 16)).copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              !_isLocationEnabled ? Icons.location_off : Icons.gps_fixed,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              _getStatusTitle(),
              style: statusTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getStatusDescription(),
              textAlign: TextAlign.center,
              style: statusDescriptionStyle,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handlePermissionAction,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                !_isLocationEnabled
                    ? "Open Location Settings"
                    : (_permission == LocationPermission.denied
                          ? "Grant Permission"
                          : "Enable Precise Location"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusTitle() {
    if (!_isLocationEnabled) return "Location Services Disabled";
    if (_permission == LocationPermission.denied) return "Permission Required";
    if (!_isPrecise) return "Precise Location Required";
    return "Permission Required";
  }

  String _getStatusDescription() {
    if (!_isLocationEnabled) {
      return "Your device location is turned off. Please enable GPS to play JetLag.";
    }
    if (!_isPrecise) {
      return "You have granted 'Approximate' location, but JetLag requires 'Precise Location' to track the game accurately.";
    }
    return "To play JetLag, we need your precise location to update the game map and calculate distances in real-time.";
  }
}
