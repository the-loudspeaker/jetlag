import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location_service.dart';

class DistanceCard extends StatelessWidget {
  final LatLng? currentLocation;
  final LatLng? seekerLocation;

  const DistanceCard({
    super.key,
    required this.currentLocation,
    required this.seekerLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null || seekerLocation == null) {
      return const SizedBox.shrink();
    }

    final distanceMeters = LocationService().calculateDistance(
      currentLocation!.latitude,
      currentLocation!.longitude,
      seekerLocation!.latitude,
      seekerLocation!.longitude,
    );

    final distanceStr = distanceMeters < 1000
        ? '${distanceMeters.toStringAsFixed(0)} m'
        : '${(distanceMeters / 1000).toStringAsFixed(2)} km';

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.radar, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance to Seeker',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  distanceStr,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
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
