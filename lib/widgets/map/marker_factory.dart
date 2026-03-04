import 'package:flutter/material.dart';
import 'package:jetlag/models/map_models.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MarkerFactory {
  static List<Marker> buildRailwayMarkers(
    List<RailwayStation> stations,
    bool show,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (!show) return const [];

    return stations.map((station) {
      return Marker(
        point: station.location,
        width: 90,
        height: 50,
        rotate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.train, size: 16, color: Colors.white),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  station.name,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  static List<Marker> buildBusStopMarkers(
    List<BusStop> stops,
    bool show,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (!show) return const [];

    return stops.map((stop) {
      return Marker(
        point: stop.location,
        width: 90,
        height: 50,
        rotate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_bus,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.deepPurple.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  stop.name,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  static List<Marker> buildLakeMarkers(
    List<Lake> lakes,
    bool show,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (!show) return const [];

    return lakes.map((lake) {
      return Marker(
        point: lake.location,
        width: 90,
        height: 50,
        rotate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.water, size: 16, color: Colors.white),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  lake.name,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  static List<Marker> buildMeghanaMarkers(
    List<MeghanaFoods> shops,
    bool show,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (!show) return const [];

    return shops.map((shop) {
      return Marker(
        point: shop.location,
        width: 90,
        height: 50,
        rotate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Meghana - ${shop.name}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  static List<Marker> buildMallMarkers(
    List<Mall> malls,
    bool show,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (!show) return const [];

    return malls.map((mall) {
      return Marker(
        point: mall.location,
        width: 90,
        height: 50,
        rotate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.pinkAccent.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  mall.name,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  static List<Marker> buildLandmarkMarkers(
    List<Landmark> landmarks,
    bool show,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (!show) return const [];

    return landmarks.map((landmark) {
      return Marker(
        point: landmark.location,
        width: 90,
        height: 50,
        rotate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  landmark.name,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  static List<Marker> buildMetroMarkers(
    List<MetroStation> stations,
    List<MetroLine> lines,
    double currentZoom,
    double minZoom,
    Color Function(String) lineColorFor,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (currentZoom < minZoom) return const [];

    final markers = <Marker>[];

    // Station Markers
    for (final station in stations) {
      markers.add(
        Marker(
          point: station.location,
          width: 90,
          height: 50,
          rotate: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_subway,
                  size: 14,
                  color: lineColorFor(station.line),
                ),
              ),
              const SizedBox(height: 1),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    station.name,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Line Name Markers
    for (final line in lines) {
      if (line.multiPoints.isEmpty) continue;

      List<LatLng> bestSegment = line.multiPoints.first;
      for (final segment in line.multiPoints) {
        if (segment.length > bestSegment.length) {
          bestSegment = segment;
        }
      }

      if (bestSegment.isEmpty) continue;

      final midIndex = bestSegment.length ~/ 2;
      final point = bestSegment[midIndex];

      markers.add(
        Marker(
          point: point,
          width: 80,
          height: 22,
          rotate: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: line.color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 0.8),
            ),
            child: Center(
              child: Text(
                line.name.split('(')[0].trim(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}
