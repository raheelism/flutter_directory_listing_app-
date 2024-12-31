import 'package:listar_flutter_pro/api/api.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/models/model.dart';

class BlogRepository {
  ///load list
  static Future<List?> loadBlogList({
    CategoryModel? category,
    SortModel? sort,
    String? keyword,
  }) async {
    Map<String, dynamic> params = {
      "s": keyword,
      "category": category?.id,
      "orderby": sort?.field,
      "order": sort?.value,
    };
    final response = await Api.requestListBlog(params);
    if (response.success) {
      BlogModel? sticky;
      final list = List.from(response.origin['posts']).map((item) {
        return BlogModel.fromJson(item);
      }).toList();
      final categories = List.from(response.origin['categories']).map((item) {
        return CategoryModel.fromJson(item);
      }).toList();
      if (response.origin['sticky'] != null) {
        sticky = BlogModel.fromJson(response.origin['sticky']);
      }
      return [
        list,
        categories,
        sticky,
      ];
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }

  ///load detail blog
  static Future<BlogModel?> loadBlog(id) async {
    final params = {"id": id};
    final response = await Api.requestBlog(params);
    if (response.success) {
      return BlogModel.fromJson(response.origin['data']);
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }
}
