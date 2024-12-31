import 'package:bloc/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';

import 'cubit.dart';

class BookingListCubit extends Cubit<BookingManagementState> {
  BookingListCubit() : super(BookingListLoading());

  int page = 1;
  List<BookingModel> listBooking = [];
  List<BookingModel> listRequest = [];
  PaginationModel? paginationRequest;
  PaginationModel? paginationBooking;
  SortModel? sortRequest;
  SortModel? sortBooking;
  SortModel? statusRequest;
  SortModel? statusBooking;
  List<SortModel> sortOptionRequest = [];
  List<SortModel> sortOptionBooking = [];
  List<SortModel> statusOptionRequest = [];
  List<SortModel> statusOptionBooking = [];

  Future<void> onLoad({
    SortModel? sort,
    SortModel? status,
    String? keyword,
    required bool request,
  }) async {
    bool canLoadMore = false;
    if (request) {
      ///Fetch API
      final result = await BookingRepository.loadList(
        page: page,
        perPage: Application.setting.perPage,
        sort: sort,
        status: status,
        keyword: keyword,
        request: request,
      );
      if (result != null) {
        if (page == 1) {
          listRequest = result[0];
        } else {
          listRequest.addAll(result[0]);
        }
        paginationRequest = result[1];
        canLoadMore = paginationRequest!.page < paginationRequest!.maxPage;
        if (sortOptionRequest.isEmpty) {
          sortOptionRequest = result[2];
        }
        if (statusOptionRequest.isEmpty) {
          statusOptionRequest = result[3];
        }
      }
    } else {
      ///Fetch API
      final result = await BookingRepository.loadList(
        page: page,
        perPage: Application.setting.perPage,
        sort: sort,
        status: status,
        keyword: keyword,
        request: request,
      );
      if (result != null) {
        if (page == 1) {
          listBooking = result[0];
        } else {
          listBooking.addAll(result[0]);
        }
        paginationBooking = result[1];
        canLoadMore = paginationBooking!.page < paginationBooking!.maxPage;
        if (sortOptionBooking.isEmpty) {
          sortOptionBooking = result[2];
        }
        if (statusOptionBooking.isEmpty) {
          statusOptionBooking = result[3];
        }
      }
    }

    ///Notify
    emit(BookingListSuccess(
      listBooking: listBooking,
      listRequest: listRequest,
      canLoadMore: canLoadMore,
    ));
  }
}
