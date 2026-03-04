import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_models.dart';

class GeoJsonParser {
  static Future<List<PolygonGeometry>> parseLayerGeoJson(
    String geoJsonText,
    String layerId,
  ) async {
    final decoded = jsonDecode(geoJsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Boundary data is not a GeoJSON object.');
    }

    final features = decoded['features'];
    if (features is! List) {
      throw const FormatException('Boundary data is missing "features" array.');
    }

    final polygons = <PolygonGeometry>[];
    for (final feature in features) {
      if (feature is! Map) continue;

      final geometry = feature['geometry'];
      if (geometry is! Map) continue;
      final label = _extractFeatureLabel(feature['properties'], layerId);

      final geometryType = geometry['type'];
      final coordinates = geometry['coordinates'];

      if (geometryType == 'Polygon') {
        final polygon = _createPolygonGeometry(coordinates);
        if (polygon != null) {
          polygons.add(polygon.withLabel(label));
        }
      } else if (geometryType == 'MultiPolygon' && coordinates is List) {
        polygons.addAll(
          _buildMultiPolygonGeometries(coordinates, featureLabel: label),
        );
      }
    }

    if (polygons.isEmpty) {
      throw const FormatException(
        'No valid Polygon/MultiPolygon features found.',
      );
    }

    return polygons;
  }

  static PolygonGeometry? _createPolygonGeometry(Object? coordinates) {
    if (coordinates is! List || coordinates.isEmpty) return null;

    final outerRing = _parseRing(coordinates.first);
    if (outerRing.length < 3) return null;

    final holes = <List<LatLng>>[];
    for (var i = 1; i < coordinates.length; i++) {
      final holeRing = _parseRing(coordinates[i]);
      if (holeRing.length >= 3) {
        holes.add(_ensureClosedRing(holeRing));
      }
    }

    return PolygonGeometry(
      outerRing: _ensureClosedRing(outerRing),
      holeRings: holes,
    );
  }

  static List<PolygonGeometry> _buildMultiPolygonGeometries(
    List<dynamic> coordinates, {
    String? featureLabel,
  }) {
    final polygons = <PolygonGeometry>[];
    for (final polygonCoords in coordinates) {
      final polygon = _createPolygonGeometry(polygonCoords);
      if (polygon != null) {
        polygons.add(polygon);
      }
    }

    if (polygons.isEmpty || featureLabel == null) {
      return polygons;
    }

    var largestPartIndex = 0;
    var largestPartArea = _ringArea(polygons.first.outerRing);
    for (var i = 1; i < polygons.length; i++) {
      final area = _ringArea(polygons[i].outerRing);
      if (area > largestPartArea) {
        largestPartArea = area;
        largestPartIndex = i;
      }
    }

    return [
      for (var i = 0; i < polygons.length; i++)
        polygons[i].withLabel(i == largestPartIndex ? featureLabel : null),
    ];
  }

  static double _ringArea(List<LatLng> ring) {
    if (ring.length < 3) return 0;

    double signedArea = 0;
    for (var i = 0; i < ring.length; i++) {
      final current = ring[i];
      final next = ring[(i + 1) % ring.length];
      signedArea +=
          (current.longitude * next.latitude) -
          (next.longitude * current.latitude);
    }
    return signedArea.abs() / 2;
  }

  static String? _extractFeatureLabel(Object? properties, String layerId) {
    if (properties is! Map) return null;
    final rawLabel = properties['namecol'];
    if (rawLabel is! String) return null;
    return _normalizeBoundaryLabel(layerId, rawLabel);
  }

  static String? _normalizeBoundaryLabel(String layerId, String raw) {
    final wardPrefixPattern = RegExp(r'^\s*\d+\s*:\s*');
    var label = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (layerId == 'gba_ward') {
      label = label.replaceFirst(wardPrefixPattern, '').trim();
    }
    return label.isEmpty ? null : label;
  }

  static List<LatLng> _parseRing(Object? ringCoordinates) {
    if (ringCoordinates is! List) return const [];

    final points = <LatLng>[];
    for (final point in ringCoordinates) {
      final latLng = _parsePoint(point);
      if (latLng != null) {
        points.add(latLng);
      }
    }

    return points;
  }

  static LatLng? _parsePoint(Object? rawPoint) {
    if (rawPoint is! List || rawPoint.length < 2) return null;

    final lng = rawPoint[0];
    final lat = rawPoint[1];
    if (lat is! num || lng is! num) return null;

    return LatLng(lat.toDouble(), lng.toDouble());
  }

  static List<LatLng> _ensureClosedRing(List<LatLng> points) {
    if (points.isEmpty) return points;

    final first = points.first;
    final last = points.last;
    if (first.latitude == last.latitude && first.longitude == last.longitude) {
      return points;
    }

    return [...points, first];
  }

  static List<MetroLine> parseMetroLines(Map<String, dynamic> geoJson) {
    final features = (geoJson['features'] as List?) ?? [];
    final List<MetroLine> lines = [];
    for (final feature in features) {
      if (feature is! Map) continue;
      final properties = feature['properties'] as Map<String, dynamic>? ?? {};
      final geometry = feature['geometry'];
      final multiCoords = _readMultiCoordinates(geometry);
      if (multiCoords.isEmpty) continue;
      final name = (properties['name'] as String?)?.trim() ?? 'Metro Line';
      final lineId = (properties['line'] as String?)?.trim() ?? name;
      final color = _colorFromHex(properties['color'] as String?);
      lines.add(
        MetroLine(
          name: name,
          line: lineId,
          color: color,
          multiPoints: multiCoords,
        ),
      );
    }
    return lines;
  }

  static List<MetroStation> parseMetroStations(Map<String, dynamic> geoJson) {
    final features = (geoJson['features'] as List?) ?? [];
    final List<MetroStation> stations = [];
    for (final feature in features) {
      if (feature is! Map) continue;
      final properties = feature['properties'] as Map<String, dynamic>? ?? {};
      final geometry = feature['geometry'];
      final coords = _readCoordinates(geometry, pointOnly: true);
      if (coords.isEmpty) continue;
      final stationName =
          (properties['name'] as String?)?.trim() ?? 'Metro Station';
      final line = (properties['line'] as String?)?.trim() ?? 'Metro';
      stations.add(
        MetroStation(name: stationName, line: line, location: coords.first),
      );
    }
    return stations;
  }

  static List<List<LatLng>> _readMultiCoordinates(dynamic geometry) {
    if (geometry is! Map) return const [];
    final type = geometry['type'];
    final data = geometry['coordinates'];
    if (type == 'LineString' && data is List) {
      return [_coordsFromArray(data)];
    }
    if (type == 'MultiLineString' && data is List) {
      final result = <List<LatLng>>[];
      for (final part in data) {
        if (part is List) {
          result.add(_coordsFromArray(part));
        }
      }
      return result;
    }
    return const [];
  }

  static List<LatLng> _readCoordinates(
    dynamic geometry, {
    bool pointOnly = false,
  }) {
    if (geometry is! Map) return const [];
    final type = geometry['type'];
    final data = geometry['coordinates'];
    if (type == 'Point') {
      if (data is List && data.length >= 2) {
        final lon = data[0];
        final lat = data[1];
        if (lat is num && lon is num) {
          return [LatLng(lat.toDouble(), lon.toDouble())];
        }
      }
      return const [];
    }
    if (type == 'LineString' && data is List) {
      return _coordsFromArray(data);
    }
    if (type == 'MultiLineString' && data is List && !pointOnly) {
      final result = <LatLng>[];
      for (final part in data) {
        result.addAll(_coordsFromArray(part));
      }
      return result;
    }
    return const [];
  }

  static List<LatLng> _coordsFromArray(List<dynamic> raw) {
    final coords = <LatLng>[];
    for (final entry in raw) {
      if (entry is! List || entry.length < 2) continue;
      final lon = entry[0];
      final lat = entry[1];
      if (lat is num && lon is num) {
        coords.add(LatLng(lat.toDouble(), lon.toDouble()));
      }
    }
    return coords;
  }

  static Color _colorFromHex(String? hex) {
    if (hex == null) {
      return const Color(0xff4a4a4a);
    }
    var cleaned = hex.trim();
    if (cleaned.startsWith('#')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.length == 3) {
      cleaned = cleaned.split('').map((part) => '$part$part').join();
    }
    if (cleaned.length == 6) {
      cleaned = 'ff$cleaned';
    }
    final parsed = int.tryParse(cleaned, radix: 16);
    return parsed != null ? Color(parsed) : const Color(0xff4a4a4a);
  }
}
