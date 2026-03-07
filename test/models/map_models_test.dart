import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:jetlag/models/map_models.dart';

void main() {
  group('Map Models', () {
    test('BoundaryLayerDefinition instantiation', () {
      const layer = BoundaryLayerDefinition(
        id: 'test_id',
        label: 'Test Label',
        assetPath: 'test/path.geojson',
        borderStrokeWidth: 2.0,
      );

      expect(layer.id, 'test_id');
      expect(layer.label, 'Test Label');
      expect(layer.assetPath, 'test/path.geojson');
      expect(layer.borderStrokeWidth, 2.0);
    });

    test('PolygonGeometry withLabel updates label', () {
      const polygon = PolygonGeometry(
        outerRing: [LatLng(0, 0), LatLng(1, 1), LatLng(0, 1)],
        holeRings: [],
      );

      final labeledPolygon = polygon.withLabel('New Label');
      expect(labeledPolygon.label, 'New Label');
      expect(labeledPolygon.outerRing, polygon.outerRing);
    });
  });
}
