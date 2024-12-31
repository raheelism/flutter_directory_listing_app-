import 'package:listar_flutter_pro/models/model.dart';

abstract class WishListState {}

class WishListLoading extends WishListState {}

class WishListSuccess extends WishListState {
  final int? updateID;
  final List<ProductModel> list;
  final bool canLoadMore;

  WishListSuccess({
    this.updateID,
    required this.list,
    required this.canLoadMore,
  });
}
