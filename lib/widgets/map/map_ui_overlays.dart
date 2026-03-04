import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/map_models.dart';
import '../../data/static_map_data.dart';

class NearestStationCard extends StatelessWidget {
  final LatLng? currentLocation;
  final bool isLoadingMetro;
  final String? metroError;
  final MetroStation? nearestStation;
  final double? nearestDistanceMeters;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const NearestStationCard({
    super.key,
    required this.currentLocation,
    required this.isLoadingMetro,
    required this.metroError,
    required this.nearestStation,
    required this.nearestDistanceMeters,
    required this.colorScheme,
    required this.textTheme,
  });

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ) ??
        TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface);

    String status = 'Waiting for location...';
    String detail = 'Metro lines appear here shortly.';

    if (currentLocation == null) {
      status = 'Waiting for location...';
      detail = 'Enable GPS so we can show the closest metro station.';
    } else if (metroError != null) {
      status = 'Metro data unavailable';
      detail = metroError!;
    } else if (isLoadingMetro) {
      status = 'Loading metro data...';
      detail = 'Updating local metro assets.';
    } else if (nearestStation != null && nearestDistanceMeters != null) {
      status = nearestStation!.name;
      detail =
          '${nearestStation!.line} • ${_formatDistance(nearestDistanceMeters!)}';
    } else {
      status = 'No station data';
      detail = 'Metro station list is not yet loaded.';
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nearest Metro', style: titleStyle),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  status,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (nearestDistanceMeters != null)
                Text(
                  _formatDistance(nearestDistanceMeters!),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class LocationPlaceholder extends StatelessWidget {
  final bool isFetching;
  final LatLng? currentLocation;
  final String? errorMessage;

  const LocationPlaceholder({
    super.key,
    required this.isFetching,
    required this.currentLocation,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isLoading = isFetching && currentLocation == null;
    final hasError = errorMessage != null && currentLocation == null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator()
              else
                Icon(
                  hasError ? Icons.location_off : Icons.map_outlined,
                  color: hasError ? colorScheme.error : colorScheme.primary,
                  size: 32,
                ),
              const SizedBox(height: 12),
              Text(
                isLoading
                    ? 'Fetching your location...'
                    : hasError
                    ? 'Unable to fetch location.'
                    : 'Map unavailable.',
                style: textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              if (hasError) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MapRecenterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;

  const MapRecenterButton({
    super.key,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      onPressed: onPressed,
      child: const Icon(Icons.my_location),
    );
  }
}

class LayerMenu extends StatelessWidget {
  final bool isLoadingLayer;
  final String? selectedLayerId;
  final bool showRailwayStations;
  final bool showBusStops;
  final bool showLakes;
  final bool showMeghanaFoods;
  final bool showMalls;
  final bool showLandmarks;
  final Function(String) onLayerSelected;
  final ColorScheme colorScheme;

  const LayerMenu({
    super.key,
    required this.isLoadingLayer,
    required this.selectedLayerId,
    required this.showRailwayStations,
    required this.showBusStops,
    required this.showLakes,
    required this.showMeghanaFoods,
    required this.showMalls,
    required this.showLandmarks,
    required this.onLayerSelected,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.94),
      elevation: 2,
      shape: const CircleBorder(),
      child: PopupMenuButton<String>(
        enabled: !isLoadingLayer,
        tooltip: 'Map Layers',
        icon: Icon(Icons.layers_outlined, color: colorScheme.onSurface),
        onSelected: onLayerSelected,
        itemBuilder: (_) {
          return [
            CheckedPopupMenuItem<String>(
              value: 'toggle_railways',
              checked: showRailwayStations,
              child: const Text('Railway Stations'),
            ),
            CheckedPopupMenuItem<String>(
              value: 'toggle_bus_stops',
              checked: showBusStops,
              child: const Text('Bus Stops'),
            ),
            CheckedPopupMenuItem<String>(
              value: 'toggle_lakes',
              checked: showLakes,
              child: const Text('Lakes'),
            ),
            CheckedPopupMenuItem<String>(
              value: 'toggle_meghana',
              checked: showMeghanaFoods,
              child: const Text('Meghana Foods'),
            ),
            CheckedPopupMenuItem<String>(
              value: 'toggle_malls',
              checked: showMalls,
              child: const Text('Malls'),
            ),
            CheckedPopupMenuItem<String>(
              value: 'toggle_landmarks',
              checked: showLandmarks,
              child: const Text('Landmarks'),
            ),
            const PopupMenuDivider(),
            CheckedPopupMenuItem<String>(
              value: '__none__',
              checked: selectedLayerId == null,
              child: const Text('None'),
            ),
            ...StaticMapData.layerDefinitions.map(
              (layer) => CheckedPopupMenuItem<String>(
                value: layer.id,
                checked: selectedLayerId == layer.id,
                child: Text(layer.label),
              ),
            ),
          ];
        },
      ),
    );
  }
}
