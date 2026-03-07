import 'package:flutter_test/flutter_test.dart';
import 'package:jetlag/data/static_map_data.dart';

void main() {
  group('StaticMapData', () {
    test('contains layer definitions', () {
      expect(StaticMapData.layerDefinitions, isNotEmpty);
      expect(StaticMapData.layerDefinitions.any((layer) => layer.id == 'gba_zone'), isTrue);
    });

    test('contains railway stations', () {
      expect(StaticMapData.kRailwayStations, isNotEmpty);
    });

    test('contains bus stops', () {
      expect(StaticMapData.kBusStops, isNotEmpty);
    });

    test('contains lakes', () {
      expect(StaticMapData.kLakes, isNotEmpty);
    });

    test('contains meghana locations', () {
      expect(StaticMapData.kMeghanaLocations, isNotEmpty);
    });

    test('contains malls', () {
      expect(StaticMapData.kMalls, isNotEmpty);
    });

    test('contains landmarks', () {
      expect(StaticMapData.kLandmarks, isNotEmpty);
    });
  });
}
