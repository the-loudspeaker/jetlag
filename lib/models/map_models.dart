import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class BoundaryLayerDefinition {
  final String id;
  final String label;
  final String assetPath;
  final double borderStrokeWidth;

  const BoundaryLayerDefinition({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.borderStrokeWidth,
  });
}

class MetroLine {
  final String name;
  final String line;
  final Color color;
  final List<List<LatLng>> multiPoints;

  const MetroLine({
    required this.name,
    required this.line,
    required this.color,
    required this.multiPoints,
  });
}

class MetroStation {
  final String name;
  final String line;
  final LatLng location;

  const MetroStation({
    required this.name,
    required this.line,
    required this.location,
  });
}

class PolygonGeometry {
  final List<LatLng> outerRing;
  final List<List<LatLng>> holeRings;
  final String? label;

  const PolygonGeometry({
    required this.outerRing,
    required this.holeRings,
    this.label,
  });

  PolygonGeometry withLabel(String? nextLabel) {
    return PolygonGeometry(
      outerRing: outerRing,
      holeRings: holeRings,
      label: nextLabel,
    );
  }
}

class RailwayStation {
  final String name;
  final LatLng location;

  const RailwayStation(this.name, this.location);
}

class BusStop {
  final String name;
  final LatLng location;

  const BusStop(this.name, this.location);
}

class Lake {
  final String name;
  final LatLng location;

  const Lake(this.name, this.location);
}

class MeghanaFoods {
  final String name;
  final LatLng location;

  const MeghanaFoods(this.name, this.location);
}

class Mall {
  final String name;
  final LatLng location;

  const Mall(this.name, this.location);
}

class Landmark {
  final String name;
  final LatLng location;

  const Landmark(this.name, this.location);
}
