import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';

class FilterModel {
  String keyword;
  final List<CategoryModel> categories;
  final List<CategoryModel> features;
  CategoryModel? country;
  CategoryModel? city;
  CategoryModel? state;
  double? distance;
  double? minPrice;
  double? maxPrice;
  String? color;
  SortModel? sort;
  TimeOfDay? startHour;
  TimeOfDay? endHour;

  FilterModel({
    required this.keyword,
    required this.categories,
    required this.features,
    this.country,
    this.city,
    this.state,
    this.distance,
    this.minPrice,
    this.maxPrice,
    this.color,
    this.sort,
    this.startHour,
    this.endHour,
  });

  Future<Map<String, dynamic>> getParams() async {
    Map<String, dynamic> params = {
      "category[]": categories.map((item) {
        return item.id;
      }).toList(),
      "feature[]": features.map((item) {
        return item.id;
      }).toList(),
    };
    if (keyword.isNotEmpty) {
      params['s'] = keyword;
    }
    if (country != null) {
      params['location'] = country!.id;
    }
    if (city != null) {
      params['location'] = city!.id;
    }
    if (state != null) {
      params['location'] = state!.id;
    }
    if (distance != null) {
      params['distance'] = distance;
    }
    if (minPrice != null) {
      params['price_min'] = minPrice;
    }
    if (maxPrice != null) {
      params['price_max'] = minPrice;
    }
    if (color != null) {
      params['color'] = color;
    }
    if (sort != null) {
      params['orderby'] = sort!.field;
      params['order'] = sort!.value;
    }
    if (startHour != null) {
      params['start_time'] = startHour.toString();
    }
    if (endHour != null) {
      params['end_time'] = endHour.toString();
    }
    return params;
  }

  factory FilterModel.fromDefault() {
    return FilterModel(
      keyword: '',
      categories: [],
      features: [],
      sort: null,
      startHour: Application.setting.startHour,
      endHour: Application.setting.endHour,
    );
  }

  factory FilterModel.fromSource(FilterModel source) {
    return FilterModel(
      keyword: source.keyword,
      categories: List<CategoryModel>.from(source.categories),
      features: List<CategoryModel>.from(source.features),
      country: source.country,
      city: source.city,
      state: source.state,
      distance: source.distance,
      minPrice: source.minPrice,
      maxPrice: source.maxPrice,
      color: source.color,
      sort: source.sort,
      startHour: source.startHour,
      endHour: source.endHour,
    );
  }

  FilterModel clone() {
    return FilterModel.fromSource(this);
  }
}
