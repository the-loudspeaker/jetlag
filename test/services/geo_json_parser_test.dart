import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetlag/services/geo_json_parser.dart';

void main() {
  group('GeoJsonParser', () {
    test('parseMetroLines correctly parses valid geojson', () {
      final geoJson = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "properties": {
              "name": "Purple Line",
              "line": "Purple",
              "color": "#800080"
            },
            "geometry": {
              "type": "LineString",
              "coordinates": [
                [77.5, 12.9],
                [77.6, 13.0]
              ]
            }
          }
        ]
      };

      final lines = GeoJsonParser.parseMetroLines(geoJson);
      expect(lines.length, 1);
      expect(lines[0].name, 'Purple Line');
      expect(lines[0].line, 'Purple');
      expect(lines[0].color.value, const Color(0xff800080).value);
      expect(lines[0].multiPoints.length, 1);
      expect(lines[0].multiPoints[0].length, 2);
      expect(lines[0].multiPoints[0][0].latitude, 12.9);
      expect(lines[0].multiPoints[0][0].longitude, 77.5);
    });

    test('parseMetroStations correctly parses valid geojson', () {
      final geoJson = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "properties": {
              "name": "Indiranagar",
              "line": "Purple"
            },
            "geometry": {
              "type": "Point",
              "coordinates": [77.6385, 12.9784]
            }
          }
        ]
      };

      final stations = GeoJsonParser.parseMetroStations(geoJson);
      expect(stations.length, 1);
      expect(stations[0].name, 'Indiranagar');
      expect(stations[0].line, 'Purple');
      expect(stations[0].location.latitude, 12.9784);
      expect(stations[0].location.longitude, 77.6385);
    });

    test('parseLayerGeoJson throws error for invalid input', () async {
      const invalidJson = '{"type": "Invalid"}';
      expect(
        () => GeoJsonParser.parseLayerGeoJson(invalidJson, 'test_layer'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
