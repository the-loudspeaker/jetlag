import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<LatLng?> fetchSeekerLocation() async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .eq('id', 'seeker')
          .maybeSingle();

      if (response != null) {
        return LatLng(
          (response['latitude'] as num).toDouble(),
          (response['longitude'] as num).toDouble(),
        );
      }
    } catch (e) {
      // Log error internally if needed
    }
    return null;
  }

  Future<void> updateSeekerLocation(double latitude, double longitude) async {
    try {
      await _client.from('locations').upsert({
        'id': 'seeker',
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error internally if needed
    }
  }
}
