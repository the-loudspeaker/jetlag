import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/static_map_data.dart';
import '../../models/map_models.dart';
import '../../services/geo_json_parser.dart';
import '../../services/map_config_service.dart';
import '../../themes/app_themes.dart';
import '../../widgets/map/map_ui_overlays.dart';
import '../../widgets/map/marker_factory.dart';

class LocationMap extends StatefulWidget {
  final LatLng? currentLocation;
  final LatLng? seekerLocation;
  final bool isFetching;
  final String? errorMessage;

  const LocationMap({
    super.key,
    required this.currentLocation,
    this.seekerLocation,
    required this.isFetching,
    required this.errorMessage,
  });

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  static const LatLng _fallbackCenter = LatLng(12.9716, 77.5946);
  static const double _defaultZoom = 13.0;
  static const double _zoneLabelMinZoom = 11.5;
  static const double _wardLabelMinZoom = 14.0;
  static const double _metroStationDotMinZoom = 12.5;
  static const double _metroLabelMinZoom = 12.5;
  static const double _metroRadiusMinZoom = 12.5;
  static const double _metroInfoHeight = 100.0;
  static const double _metroInfoSpacing = 8.0;
  static const double _mapPanelDefaultHeight = 520.0;
  static const int _tileErrorThreshold = 5;

  static const List<double> _darkTileContrastMatrix = <double>[
    1.15,
    0,
    0,
    0,
    12,
    0,
    1.18,
    0,
    0,
    14,
    0,
    0,
    1.22,
    0,
    18,
    0,
    0,
    0,
    1,
    0,
  ];
  static const Color _darkTileTintOverlay = Color(0x140A1B2E);

  final MapController _mapController = MapController();
  final Map<String, List<PolygonGeometry>> _layerGeometryCache = {};

  String? _selectedLayerId;
  bool _showRailwayStations = false;
  bool _showBusStops = false;
  bool _showLakes = false;
  bool _showMeghanaFoods = false;
  bool _showMalls = false;
  bool _showLandmarks = false;
  bool _isLoadingLayer = false;
  String? _layerError;

  bool _isMapReady = false;
  int _tileErrorCount = 0;
  bool _hasTileConnectivityIssue = false;
  double _currentZoom = _defaultZoom;
  double _currentRotation = 0;
  final Distance _distanceCalculator = const Distance();
  List<MetroLine> _metroLines = [];
  List<MetroStation> _metroStations = [];
  bool _isLoadingMetro = true;
  String? _metroError;
  MetroStation? _nearestStation;
  double? _nearestDistanceMeters;
  double _metroRadiusMeters = 700.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final results = await Future.wait([
      MapConfigService.fetchMetroRadius(),
      _loadMetroData(),
    ]);

    final radius = results[0] as double?;
    if (radius != null && mounted) {
      setState(() {
        _metroRadiusMeters = radius;
      });
    }
  }

  @override
  void didUpdateWidget(covariant LocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSameLocation(oldWidget.currentLocation, widget.currentLocation)) {
      return;
    }

    if (widget.currentLocation != null) {
      _updateNearestStation();
    }
    if (_isMapReady && widget.currentLocation != null) {
      _recenterOnCurrentLocation();
    }
  }

  void _handleMapReady() {
    if (!mounted) return;
    setState(() {
      _isMapReady = true;
      _currentZoom = _mapController.camera.zoom;
      _currentRotation = _mapController.camera.rotation;
    });
    _recenterOnCurrentLocation();
  }

  void _handleMapPositionChanged(MapCamera camera) {
    final nextZoom = camera.zoom;
    final nextRotation = camera.rotation;
    final selectedLayerId = _selectedLayerId;
    final currentLayerLabelVisible = selectedLayerId != null
        ? _shouldShowLabelsForLayer(selectedLayerId, _currentZoom)
        : false;
    final nextLayerLabelVisible = selectedLayerId != null
        ? _shouldShowLabelsForLayer(selectedLayerId, nextZoom)
        : false;

    final zoomDelta = (_currentZoom - nextZoom).abs();
    final rotationDelta = (_currentRotation - nextRotation).abs();
    if (zoomDelta < 0.1 &&
        currentLayerLabelVisible == nextLayerLabelVisible &&
        rotationDelta < 0.1) {
      _currentZoom = nextZoom;
      _currentRotation = nextRotation;
      return;
    }

    if (!mounted) return;
    setState(() {
      _currentZoom = nextZoom;
      _currentRotation = nextRotation;
    });
  }

  void _recenterOnCurrentLocation() {
    final location = widget.currentLocation;
    if (!_isMapReady || location == null) return;

    final camera = _mapController.camera;
    final zoom = camera.zoom.isFinite ? camera.zoom : _defaultZoom;
    _mapController.move(location, zoom);
  }

  Future<void> _handleLayerMenuSelection(String layerId) async {
    if (layerId.startsWith('toggle_')) {
      if (!mounted) return;
      setState(() {
        if (layerId == 'toggle_railways') {
          _showRailwayStations = !_showRailwayStations;
        }
        if (layerId == 'toggle_bus_stops') {
          _showBusStops = !_showBusStops;
        }
        if (layerId == 'toggle_lakes') {
          _showLakes = !_showLakes;
        }
        if (layerId == 'toggle_meghana') {
          _showMeghanaFoods = !_showMeghanaFoods;
        }
        if (layerId == 'toggle_malls') {
          _showMalls = !_showMalls;
        }
        if (layerId == 'toggle_landmarks') {
          _showLandmarks = !_showLandmarks;
        }
      });
      return;
    }

    if (_isLoadingLayer) return;

    if (layerId == '__none__') {
      if (!mounted) return;
      setState(() {
        _selectedLayerId = null;
        _layerError = null;
      });
      return;
    }

    final layer = _layerDefinitionFromId(layerId);
    if (layer == null) {
      setState(() {
        _layerError = 'Unknown layer: $layerId';
      });
      return;
    }

    if (_layerGeometryCache.containsKey(layer.id)) {
      if (!mounted) return;
      setState(() {
        _selectedLayerId = layer.id;
        _layerError = null;
      });
      return;
    }

    final previousLayerId = _selectedLayerId;
    setState(() {
      _isLoadingLayer = true;
      _layerError = null;
      _selectedLayerId = layer.id;
    });

    try {
      final geoJsonText = await rootBundle.loadString(layer.assetPath);
      final geometries = await GeoJsonParser.parseLayerGeoJson(
        geoJsonText,
        layer.id,
      );
      if (!mounted) return;
      setState(() {
        _layerGeometryCache[layer.id] = geometries;
        _layerError = null;
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Failed to load ${layer.id}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      if (!mounted) return;
      setState(() {
        _selectedLayerId = previousLayerId;
        _layerError = _describeLayerLoadError(layer, error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLayer = false;
        });
      }
    }
  }

  Future<void> _loadMetroData() async {
    setState(() {
      _isLoadingMetro = true;
      _metroError = null;
    });
    try {
      final linesText = await rootBundle.loadString(
        'assets/metro/bengaluru_metro_lines.geojson',
      );
      final stationsText = await rootBundle.loadString(
        'assets/metro/bengaluru_metro_stations.geojson',
      );

      final parsedLines = GeoJsonParser.parseMetroLines(jsonDecode(linesText));
      final parsedStations = GeoJsonParser.parseMetroStations(
        jsonDecode(stationsText),
      );

      if (mounted) {
        setState(() {
          _metroLines = parsedLines;
          _metroStations = parsedStations;
        });
        _updateNearestStation();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _metroError = 'Could not load metro data.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMetro = false;
        });
      }
    }
  }

  void _updateNearestStation() {
    if (widget.currentLocation == null || _metroStations.isEmpty) {
      if (!mounted) return;
      setState(() {
        _nearestStation = null;
        _nearestDistanceMeters = null;
      });
      return;
    }
    final current = widget.currentLocation!;
    MetroStation? best;
    double bestDistance = double.infinity;
    for (final station in _metroStations) {
      final distance = _distanceCalculator.as(
        LengthUnit.Meter,
        current,
        station.location,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        best = station;
      }
    }
    if (!mounted) return;
    setState(() {
      _nearestStation = best;
      _nearestDistanceMeters = bestDistance.isFinite ? bestDistance : null;
    });
  }

  Color _lineColorFor(String line) {
    final candidate = _metroLines.firstWhere(
      (entry) => entry.line.toLowerCase() == line.toLowerCase(),
      orElse: () => MetroLine(
        name: '',
        line: line,
        color: const Color(0xff9e9e9e),
        multiPoints: const [],
      ),
    );
    return candidate.color;
  }

  void _onTileLoadError(TileImage tile, Object error, StackTrace? stackTrace) {
    if (_hasTileConnectivityIssue) return;
    _tileErrorCount += 1;
    if (_tileErrorCount < _tileErrorThreshold) return;
    if (kDebugMode) debugPrint('Map tile error (${tile.coordinates}): $error');
    if (!mounted) return;
    setState(() {
      _hasTileConnectivityIssue = true;
    });
  }

  List<Polygon> _buildLayerPolygons(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final selectedLayerId = _selectedLayerId;
    if (selectedLayerId == null) return const [];

    final geometry = _layerGeometryCache[selectedLayerId];
    if (geometry == null || geometry.isEmpty) return const [];

    final layerDefinition = _layerDefinitionFromId(selectedLayerId);
    if (layerDefinition == null) return const [];

    final showLabels = _shouldShowLabelsForLayer(selectedLayerId, _currentZoom);
    final labelStyle = (textTheme.bodySmall ?? const TextStyle(fontSize: 11))
        .copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600);

    return geometry
        .map(
          (polygon) => Polygon(
            points: polygon.outerRing,
            holePointsList: polygon.holeRings.isEmpty
                ? null
                : polygon.holeRings,
            color: _layerFillColor(selectedLayerId, colorScheme),
            borderColor: _layerBorderColor(selectedLayerId, colorScheme),
            borderStrokeWidth: layerDefinition.borderStrokeWidth,
            label: showLabels ? polygon.label : null,
            labelStyle: labelStyle,
          ),
        )
        .toList(growable: false);
  }

  bool _shouldShowLabelsForLayer(String layerId, double zoom) {
    if (layerId == 'gba_zone') {
      return zoom >= _zoneLabelMinZoom;
    }
    if (layerId == 'gba_ward') {
      return zoom >= _wardLabelMinZoom;
    }
    return false;
  }

  Color _layerFillColor(String layerId, ColorScheme colorScheme) {
    if (layerId == 'gba_zone') {
      return colorScheme.primary.withValues(alpha: 0.14);
    }
    if (layerId == 'gba_ward') {
      return colorScheme.tertiary.withValues(alpha: 0.1);
    }
    return colorScheme.primary.withValues(alpha: 0.1);
  }

  Color _layerBorderColor(String layerId, ColorScheme colorScheme) {
    if (layerId == 'gba_zone') {
      return colorScheme.primary;
    }
    if (layerId == 'gba_ward') {
      return colorScheme.tertiary;
    }
    return colorScheme.primary;
  }

  BoundaryLayerDefinition? _layerDefinitionFromId(String layerId) {
    for (final layer in StaticMapData.layerDefinitions) {
      if (layer.id == layerId) return layer;
    }
    return null;
  }

  String _describeLayerLoadError(BoundaryLayerDefinition layer, Object error) {
    if (error is FlutterError || error is FormatException) {
      return 'Could not parse ${layer.label} boundary data.';
    }
    if (error is PlatformException) {
      return 'Could not load ${layer.label} boundary asset.';
    }
    return 'Failed to load ${layer.label}. Please retry.';
  }

  TileBuilder? _tileBuilderForBrightness(Brightness brightness) {
    if (brightness != Brightness.dark) return null;
    return (context, tileWidget, tile) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(_darkTileContrastMatrix),
            child: tileWidget,
          ),
          const IgnorePointer(child: ColoredBox(color: _darkTileTintOverlay)),
        ],
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    if (widget.currentLocation == null) {
      return LocationPlaceholder(
        isFetching: widget.isFetching,
        currentLocation: widget.currentLocation,
        errorMessage: widget.errorMessage,
      );
    }

    final mapPolygons = _buildLayerPolygons(colorScheme, textTheme);
    final metroLinePolylines = _buildMetroLines();

    final showMetroMarkers = _currentZoom >= _metroLabelMinZoom;
    final showMetroDots =
        _currentZoom >= _metroStationDotMinZoom && !showMetroMarkers;

    final metroStationCircles = !showMetroDots
        ? const <CircleMarker>[]
        : _metroStations
              .map(
                (station) => CircleMarker(
                  point: station.location,
                  color: _lineColorFor(station.line),
                  radius: 6,
                  borderColor: Colors.white,
                  borderStrokeWidth: 1,
                ),
              )
              .toList(growable: false);

    final showMetroRadius = _currentZoom >= _metroRadiusMinZoom;
    final metroRadiusCircles = !showMetroRadius
        ? const <CircleMarker>[]
        : _metroStations
              .map(
                (station) => CircleMarker(
                  point: station.location,
                  color: Colors.transparent,
                  radius: _metroRadiusMeters,
                  useRadiusInMeter: true,
                  borderColor: _lineColorFor(
                    station.line,
                  ).withValues(alpha: 0.3),
                  borderStrokeWidth: 2,
                ),
              )
              .toList(growable: false);

    final allCircles = [...metroRadiusCircles, ...metroStationCircles];

    final markers = [
      ...MarkerFactory.buildMetroMarkers(
        _metroStations,
        _metroLines,
        _currentZoom,
        _metroLabelMinZoom,
        _lineColorFor,
        colorScheme,
        textTheme,
      ),
      ...MarkerFactory.buildRailwayMarkers(
        StaticMapData.kRailwayStations,
        _showRailwayStations,
        colorScheme,
        textTheme,
      ),
      ...MarkerFactory.buildBusStopMarkers(
        StaticMapData.kBusStops,
        _showBusStops,
        colorScheme,
        textTheme,
      ),
      ...MarkerFactory.buildLakeMarkers(
        StaticMapData.kLakes,
        _showLakes,
        colorScheme,
        textTheme,
      ),
      ...MarkerFactory.buildMeghanaMarkers(
        StaticMapData.kMeghanaLocations,
        _showMeghanaFoods,
        colorScheme,
        textTheme,
      ),
      ...MarkerFactory.buildMallMarkers(
        StaticMapData.kMalls,
        _showMalls,
        colorScheme,
        textTheme,
      ),
      ...MarkerFactory.buildLandmarkMarkers(
        StaticMapData.kLandmarks,
        _showLandmarks,
        colorScheme,
        textTheme,
      ),
      if (widget.seekerLocation != null)
        _buildUserMarker(
          widget.seekerLocation!,
          Colors.red,
          -_currentRotation * math.pi / 180,
        ),
      _buildUserMarker(
        widget.currentLocation!,
        colorScheme.primary,
        -_currentRotation * math.pi / 180,
        shadowColor: colorScheme.shadow,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : _mapPanelDefaultHeight + _metroInfoHeight + _metroInfoSpacing;
        final mapHeight = (totalHeight - _metroInfoHeight - _metroInfoSpacing)
            .clamp(0.0, double.infinity);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: mapHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            widget.currentLocation ?? _fallbackCenter,
                        initialZoom: _defaultZoom,
                        onMapReady: _handleMapReady,
                        onPositionChanged: (camera, hasGesture) =>
                            _handleMapPositionChanged(camera),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: AppThemes.tileLayerUrl(brightness),
                          fallbackUrl: AppThemes.mapTileFallbackUrl,
                          subdomains: AppThemes.mapTileSubdomains,
                          userAgentPackageName: 'com.example.jetlag',
                          errorTileCallback: _onTileLoadError,
                          tileBuilder: _tileBuilderForBrightness(brightness),
                          tileProvider: NetworkTileProvider(
                            cachingProvider:
                                BuiltInMapCachingProvider.getOrCreateInstance(
                                  maxCacheSize: 50 * 1024 * 1024,
                                ),
                          ),
                        ),
                        if (metroLinePolylines.isNotEmpty)
                          PolylineLayer(polylines: metroLinePolylines),
                        if (allCircles.isNotEmpty)
                          CircleLayer(circles: allCircles),
                        if (mapPolygons.isNotEmpty)
                          PolygonLayer(polygons: mapPolygons),
                        MarkerLayer(markers: markers),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: LayerMenu(
                        isLoadingLayer: _isLoadingLayer,
                        selectedLayerId: _selectedLayerId,
                        showRailwayStations: _showRailwayStations,
                        showBusStops: _showBusStops,
                        showLakes: _showLakes,
                        showMeghanaFoods: _showMeghanaFoods,
                        showMalls: _showMalls,
                        showLandmarks: _showLandmarks,
                        onLayerSelected: _handleLayerMenuSelection,
                        colorScheme: colorScheme,
                      ),
                    ),
                    if (_isLoadingLayer) _buildLoadingOverlay(colorScheme),
                    if (_layerError != null)
                      _buildErrorOverlay(colorScheme, context),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: MapRecenterButton(
                        onPressed: widget.currentLocation == null
                            ? null
                            : _recenterOnCurrentLocation,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _metroInfoSpacing),
            SizedBox(
              height: _metroInfoHeight,
              child: NearestStationCard(
                currentLocation: widget.currentLocation,
                isLoadingMetro: _isLoadingMetro,
                metroError: _metroError,
                nearestStation: _nearestStation,
                nearestDistanceMeters: _nearestDistanceMeters,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Polyline> _buildMetroLines() {
    final polylines = <Polyline>[];
    for (final line in _metroLines) {
      for (final points in line.multiPoints) {
        if (points.isNotEmpty) {
          polylines.add(
            Polyline(
              points: points,
              color: Colors.black.withValues(alpha: 0.5),
              strokeWidth: 6.5,
            ),
          );
          polylines.add(
            Polyline(points: points, color: line.color, strokeWidth: 4.5),
          );
        }
      }
    }
    return polylines;
  }

  Marker _buildUserMarker(
    LatLng point,
    Color color,
    double rotation, {
    Color? shadowColor,
  }) {
    return Marker(
      point: point,
      width: 44,
      height: 44,
      child: Transform.rotate(
        angle: rotation,
        child: Icon(
          Icons.location_on,
          color: color,
          size: 40,
          shadows: [
            Shadow(
              color: (shadowColor ?? Colors.black).withValues(alpha: 0.45),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(ColorScheme colorScheme) {
    return Positioned(
      top: 10,
      left: 10,
      child: Chip(
        avatar: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
        label: const Text('Loading layer...'),
      ),
    );
  }

  Widget _buildErrorOverlay(ColorScheme colorScheme, BuildContext context) {
    return Positioned(
      top: 56,
      left: 10,
      right: 10,
      child: Material(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            _layerError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

bool _isSameLocation(LatLng? a, LatLng? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return a.latitude == b.latitude && a.longitude == b.longitude;
}
