import 'package:bloc/bloc.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';

import 'cubit.dart';

class WishListCubit extends Cubit<WishListState> {
  WishListCubit() : super(WishListLoading());

  int page = 1;
  List<ProductModel> list = [];
  PaginationModel? pagination;

  Future<void> onLoad({int? updateID}) async {
    final result = await ListRepository.loadWishList(
      page: page,
      perPage: Application.setting.perPage,
    );
    if (result != null) {
      if (page == 1) {
        list = result[0];
      } else {
        list.addAll(result[0]);
      }
      pagination = result[1];

      ///Notify
      emit(WishListSuccess(
        updateID: updateID,
        list: list,
        canLoadMore: pagination!.page < pagination!.maxPage,
      ));
    }
  }

  void onAdd(int id) async {
    final result = await ListRepository.addWishList(id);
    if (result) {
      onLoad(updateID: id);
    }
  }

  void onRemove(int? id) async {
    if (id != null) {
      await ListRepository.removeWishList(id);
    } else {
      await ListRepository.clearWishList();
    }
    onLoad(updateID: id);
  }
}
