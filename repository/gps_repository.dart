import 'package:listar_flutter_pro/api/api.dart';
import 'package:listar_flutter_pro/models/model.dart';

class GpsRepository {
  static Future<GPSModel?> fetchGPSData() async {
    final response = await Api.requestGps();
    if (response.origin['map_center'] && response.origin['map_zoom']) {
      return GPSModel.fromJson(response.origin);
    } else {
      return null;
    }
  }
}
