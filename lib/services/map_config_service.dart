import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapConfigService {
  static Future<double?> fetchMetroRadius() async {
    try {
      final response = await Supabase.instance.client
          .from('configs')
          .select('value')
          .eq('key', 'metro_radius_meters')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        return double.tryParse(response['value'].toString());
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load metro radius config: $e');
      }
    }
    return null;
  }
}
