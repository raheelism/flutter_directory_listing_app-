import 'package:listar_flutter_pro/api/api.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/models/model.dart';

class ListRepository {
  ///load list
  static Future<List?> loadList({
    int? page,
    int? perPage,
    FilterModel? filter,
    String? keyword,
  }) async {
    Map<String, dynamic> params = {
      "page": page,
      "per_page": perPage,
      "s": keyword,
    };
    if (filter != null) {
      params.addAll(await filter.getParams());
    }
    final response = await Api.requestList(params);
    if (response.success) {
      final list = List.from(response.origin['data'] ?? []).map((item) {
        return ProductModel.fromJson(item);
      }).toList();

      return [list, PaginationModel.fromJson(response.origin['pagination'])];
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }

  ///load wish list
  static Future<List?> loadWishList({
    int? page,
    int? perPage,
  }) async {
    Map<String, dynamic> params = {
      "page": page,
      "per_page": perPage,
    };
    final response = await Api.requestWishList(params);
    if (response.success) {
      final list = List.from(response.origin['data'] ?? []).map((item) {
        return ProductModel.fromJson(item);
      }).toList();

      return [list, PaginationModel.fromJson(response.origin['pagination'])];
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }

  ///add wishList
  static Future<bool> addWishList(id) async {
    final response = await Api.requestAddWishList({"post_id": id});
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return true;
    }
    return false;
  }

  ///remove wishList
  static Future<bool> removeWishList(id) async {
    final response = await Api.requestRemoveWishList({"post_id": id});
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return true;
    }
    return false;
  }

  ///clear wishList
  static Future<bool> clearWishList() async {
    final response = await Api.requestClearWishList();
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return true;
    }
    return false;
  }

  ///load author post
  static Future<List?> loadAuthorList({
    required int page,
    required int perPage,
    required String keyword,
    required int userID,
    required FilterModel filter,
    bool? pending,
  }) async {
    Map<String, dynamic> params = {
      "page": page,
      "per_page": perPage,
      "s": keyword,
      "user_id": userID,
    };
    if (pending == true) {
      params['post_status'] = 'pending';
    }
    params.addAll(await filter.getParams());
    final response = await Api.requestAuthorList(params);
    if (response.success) {
      final list = List.from(response.origin['data'] ?? []).map((item) {
        return ProductModel.fromJson(item);
      }).toList();
      return [
        list,
        PaginationModel.fromJson(response.origin['pagination']),
        UserModel.fromJson(response.origin["user"])
      ];
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }

  ///load detail
  static Future<ProductModel?> loadProduct(id) async {
    final params = {"id": id};
    final response = await Api.requestProduct(params);
    if (response.success) {
      return ProductModel.fromJson(response.origin['data']);
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }

  ///save product
  static Future<bool> saveProduct(params) async {
    final response = await Api.requestSaveProduct(params);
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return true;
    }
    return false;
  }

  ///Delete author item
  static Future<bool> removeProduct(id) async {
    final response = await Api.requestDeleteProduct({"post_id": id});
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return true;
    }
    return false;
  }
}
