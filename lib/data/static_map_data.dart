import 'package:latlong2/latlong.dart';
import '../models/map_models.dart';

class StaticMapData {
  static const List<BoundaryLayerDefinition> layerDefinitions = [
    BoundaryLayerDefinition(
      id: 'gba_zone',
      label: 'GBA Zone',
      assetPath: 'assets/boundaries/gba_zone.geojson',
      borderStrokeWidth: 2.5,
    ),
    BoundaryLayerDefinition(
      id: 'gba_ward',
      label: 'GBA Ward',
      assetPath: 'assets/boundaries/gba_ward.geojson',
      borderStrokeWidth: 1.3,
    ),
  ];

  static const List<RailwayStation> kRailwayStations = [
    RailwayStation('KR Puram', LatLng(13.00065, 77.67533)),
    RailwayStation('KSR Bengaluru', LatLng(12.9783, 77.5694)),
    RailwayStation('Yeshwanthpur', LatLng(13.0232, 77.5514)),
    RailwayStation('Bengaluru Cantonment', LatLng(12.9937, 77.5993)),
    RailwayStation('Whitefield Satellite', LatLng(12.9951, 77.7511)),
    RailwayStation('Kengeri', LatLng(12.9176, 77.4839)),
    RailwayStation('Nayandahalli', LatLng(12.9414, 77.5186)),
    RailwayStation('Bellandur Road', LatLng(12.9365, 77.6961)),
  ];

  static const List<BusStop> kBusStops = [
    BusStop('Hebbal', LatLng(13.0358, 77.5970)),
    BusStop('Majestic', LatLng(12.9774, 77.5708)),
    BusStop('HAL Main Gate', LatLng(12.9585, 77.6651)),
    BusStop('Mysore Road Satellite', LatLng(12.9532, 77.5437)),
    BusStop('BEML Layout 5th Stage', LatLng(12.90836, 77.52091)),
    BusStop('Banashankari TTMC', LatLng(12.91776, 77.57299)),
    BusStop('Royal Meenakshi Mall', LatLng(12.8759, 77.5954)),
    BusStop('Central Silk Board', LatLng(12.9171, 77.6235)),
    BusStop('Electronic City', LatLng(12.8407, 77.6764)),
    BusStop('Tin Factory', LatLng(12.9969, 77.6693)),
    BusStop('Kadugodi', LatLng(12.9957, 77.7585)),
  ];

  static const List<Lake> kLakes = [
    Lake('Halasuru Lake', LatLng(12.9815, 77.6192)),
    Lake('Madiwala Lake', LatLng(12.9058, 77.6147)),
    Lake('Benniganahalli Lake', LatLng(12.9986, 77.6650)),
    Lake('Mahadevapura Lake', LatLng(12.9916, 77.6908)),
    Lake('Hoodi Lake', LatLng(13.0003, 77.7168)),
    Lake('Kengeri Lake', LatLng(12.9161, 77.4881)),
    Lake('Sarakki Lake', LatLng(12.89833, 77.57778)),
    Lake('Sankey Tank', LatLng(13.0100, 77.5700)),
    Lake('Hosakerehalli Lake', LatLng(12.9281, 77.5333)),
    Lake('Lalbagh Lake', LatLng(12.9458, 77.5839)),
    Lake('Chikka Togur Lake', LatLng(12.8567, 77.6597)),
  ];

  static const List<MeghanaFoods> kMeghanaLocations = [
    MeghanaFoods('Koramangala', LatLng(12.9343, 77.6210)),
    MeghanaFoods('Jayanagar', LatLng(12.9293, 77.5824)),
    MeghanaFoods('Residency Road', LatLng(12.9728, 77.6092)),
    MeghanaFoods('Indiranagar', LatLng(12.9784, 77.6385)),
    MeghanaFoods('Marathahalli', LatLng(12.9496, 77.7000)),
    MeghanaFoods('Sarjapur Road', LatLng(12.9128, 77.6746)),
    MeghanaFoods('Kanakapura Road', LatLng(12.8950, 77.5750)),
    MeghanaFoods('Electronic City', LatLng(12.8450, 77.6650)),
    MeghanaFoods('Singasandra', LatLng(12.8850, 77.6450)),
  ];

  static const List<Mall> kMalls = [
    Mall('Nexus Vega City', LatLng(12.9098, 77.6002)),
    Mall('Phoenix Whitefield', LatLng(12.99585, 77.69635)),
    Mall('Forum', LatLng(12.9346, 77.6113)),
    Mall('Gopalan Grand Mall', LatLng(12.9902, 77.6603)),
    Mall('UB City', LatLng(12.9716, 77.5957)),
    Mall('Orion Mall', LatLng(13.0111, 77.5550)),
    Mall('GT World Mall', LatLng(12.9735, 77.5517)),
    Mall('Nexus Koramangala', LatLng(12.9344, 77.6111)),
    Mall('Orion Avenue', LatLng(13.00128, 77.63261)),
    Mall('M5 ECity Mall', LatLng(12.84197, 77.67682)),
  ];

  static const List<Landmark> kLandmarks = [
    Landmark('Manyata Tech Park', LatLng(13.0451, 77.6204)),
    Landmark('National Law School', LatLng(12.9529, 77.5160)),
    Landmark('Shanmukha Temple', LatLng(12.9131, 77.5289)),
    Landmark('Marathahalli Bridge', LatLng(12.9567, 77.7012)),
    Landmark('IKEA', LatLng(13.0495, 77.5018)),
    Landmark('ISKCON', LatLng(13.0101, 77.5511)),
    Landmark('IIM', LatLng(12.8953, 77.6014)),
    Landmark('Bengaluru Palace', LatLng(12.9986, 77.5921)),
  ];
}
