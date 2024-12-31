class GPSModel {
  final String? name;
  final bool editable;
  final double longitude;
  final double latitude;
  final double? zoom;

  GPSModel({
    required this.longitude,
    required this.latitude,
    this.name,
    this.editable = false,
    this.zoom
  });

  factory GPSModel.fromJson(Map<String, dynamic> json) {
    return GPSModel(
      name: json['name'],
      editable: json['editable'] ?? false,
      longitude: json['map_center'] != null ? (json['map_center'][1] as num).toDouble() : (double.tryParse(json['longitude']) ?? 0.0),
      latitude: json['map_center'] != null ? (json['map_center'][0] as num).toDouble() : (double.tryParse(json['latitude']) ?? 0.0),
      zoom: json['map_zoom'] != null ? (json['map_zoom'] is String ? double.tryParse(json['map_zoom']) : (json['map_zoom'] as num).toDouble()) : null,
    );
  }
}