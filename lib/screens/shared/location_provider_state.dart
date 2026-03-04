import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location_service.dart';

mixin LocationProviderState<T extends StatefulWidget> on State<T> {
  final LocationService _locationService = LocationService();
  LatLng? currentLocation;
  bool isFetchingLocation = true;
  String? locationError;

  void initLocationProvider() {
    _fetchLocation();
  }

  Future<void> refreshLocation() => _fetchLocation();

  Future<void> _fetchLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        locationError = null;
        isFetchingLocation = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        locationError = error.toString();
        isFetchingLocation = false;
      });
    }
  }
}
