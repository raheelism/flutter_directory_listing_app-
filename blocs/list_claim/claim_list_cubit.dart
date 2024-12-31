import 'package:bloc/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';

import 'claim_list_state.dart';

class ClaimListCubit extends Cubit<ClaimListState> {
  ClaimListCubit() : super(ClaimListLoading());

  int page = 1;
  List<ClaimModel> list = [];
  PaginationModel? pagination;
  List<SortModel> sortOptions = [];
  List<SortModel> statusOptions = [];

  Future<void> onLoad({
    String? keyword,
    SortModel? sort,
    SortModel? status,
  }) async {
    ///Fetch API
    final result = await ClaimRepository.loadList(
      keyword: keyword,
      page: page,
      perPage: Application.setting.perPage,
      sort: sort,
      status: status,
    );
    if (result != null) {
      if (page == 1) {
        list = result[0];
      } else {
        list.addAll(result[0]);
      }
      pagination = result[1];
      sortOptions = result[2];
      statusOptions = result[3];
      emit(ClaimListSuccess(
        list: list,
        canLoadMore: pagination!.page < pagination!.maxPage,
      ));
    }
  }
}
