import 'package:listar_flutter_pro/models/model.dart';

class SubmitSettingModel {
  final List<CategoryModel> categories;
  final List<CategoryModel> features;
  final List<CategoryModel> countries;
  List<CategoryModel>? states;
  List<CategoryModel>? cities;

  SubmitSettingModel({
    required this.categories,
    required this.features,
    required this.countries,
    required this.states,
    required this.cities,
  });

  factory SubmitSettingModel.fromJson(Map<String, dynamic> json) {
    return SubmitSettingModel(
      categories: List.from(json['categories'] ?? []).map((e) {
        return CategoryModel.fromJson(e);
      }).toList(),
      features: List.from(json['features'] ?? []).map((e) {
        return CategoryModel.fromJson(e);
      }).toList(),
      countries: List.from(json['countries'] ?? []).map((e) {
        return CategoryModel.fromJson(e);
      }).toList(),
      states: List.from(json['states'] ?? []).map((e) {
        return CategoryModel.fromJson(e);
      }).toList(),
      cities: List.from(json['cities'] ?? []).map((e) {
        return CategoryModel.fromJson(e);
      }).toList(),
    );
  }
}
