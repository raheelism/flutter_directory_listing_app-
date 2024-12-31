import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoading());

  int page = 1;
  List<ProductModel> listProduct = [];
  List<ProductModel> listProductPending = [];
  List<CommentModel> listComment = [];
  PaginationModel? pagination;
  UserModel? user;
  Timer? timer;

  Future<void> onLoad({
    required FilterModel filter,
    required String keyword,
    required int userID,
    required String currentTab,
  }) async {
    if (currentTab == 'listing') {
      if (listProduct.isEmpty) {
        emit(ProfileLoading());
      }

      ///Listing Load
      final result = await ListRepository.loadAuthorList(
        page: page,
        perPage: Application.setting.perPage,
        keyword: keyword,
        userID: userID,
        filter: filter,
      );
      if (result != null) {
        if (page == 1) {
          listProduct = result[0];
        } else {
          listProduct.addAll(result[0]);
        }

        pagination = result[1];
        user = result[2].copyWith(total: pagination!.total);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.page < pagination!.maxPage,
        ));
      }
    } else if (currentTab == 'pending') {
      if (listProductPending.isEmpty) {
        emit(ProfileLoading());
      }

      ///Listing Load
      final result = await ListRepository.loadAuthorList(
        page: page,
        perPage: Application.setting.perPage,
        keyword: keyword,
        userID: userID,
        filter: filter,
        pending: true,
      );
      if (result != null) {
        if (page == 1) {
          listProductPending = result[0];
        } else {
          listProductPending.addAll(result[0]);
        }

        pagination = result[1];
        user = result[2];
        user = result[2].copyWith(total: pagination!.total);

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.page < pagination!.maxPage,
        ));
      }
    } else {
      if (listComment.isEmpty) {
        emit(ProfileLoading());
      }

      ///Review Load
      final result = await ReviewRepository.loadAuthorReview(
        page: page,
        perPage: Application.setting.perPage,
        keyword: keyword,
        userID: userID,
      );
      if (result != null) {
        if (page == 1) {
          listComment = result[0];
        } else {
          listComment.addAll(result[0]);
        }

        pagination = result[1];

        ///Notify
        emit(ProfileSuccess(
          user: user!,
          listProduct: listProduct,
          listProductPending: listProductPending,
          listComment: listComment,
          canLoadMore: pagination!.page < pagination!.maxPage,
        ));
      }
    }
  }

  void onSearch({
    required FilterModel filter,
    required String keyword,
    required int userID,
    required String currentTab,
  }) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), () async {
      page = 1;

      if (currentTab == 'listing') {
        if (listProduct.isEmpty) {
          emit(ProfileLoading());
        }

        ///Listing Load
        final result = await ListRepository.loadAuthorList(
          page: page,
          perPage: Application.setting.perPage,
          keyword: keyword,
          userID: userID,
          filter: filter,
        );
        if (result != null) {
          listProduct = result[0];
          pagination = result[1];
          user = result[2].copyWith(total: pagination!.total);

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listProductPending: listProductPending,
            listComment: listComment,
            canLoadMore: pagination!.page < pagination!.maxPage,
          ));
        }
      } else if (currentTab == 'pending') {
        if (listProductPending.isEmpty) {
          emit(ProfileLoading());
        }

        ///Listing Load
        final result = await ListRepository.loadAuthorList(
          page: page,
          perPage: Application.setting.perPage,
          keyword: keyword,
          userID: userID,
          filter: filter,
          pending: true,
        );
        if (result != null) {
          listProductPending = result[0];
          pagination = result[1];
          user = result[2].copyWith(total: pagination!.total);

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listProductPending: listProductPending,
            listComment: listComment,
            canLoadMore: pagination!.page < pagination!.maxPage,
          ));
        }
      } else {
        if (listComment.isEmpty) {
          emit(ProfileLoading());
        }

        ///Review Load
        final result = await ReviewRepository.loadAuthorReview(
          page: page,
          perPage: Application.setting.perPage,
          keyword: keyword,
          userID: userID,
        );
        if (result != null) {
          listComment = result[0];
          pagination = result[1];

          ///Notify
          emit(ProfileSuccess(
            user: user!,
            listProduct: listProduct,
            listProductPending: listProductPending,
            listComment: listComment,
            canLoadMore: pagination!.page < pagination!.maxPage,
          ));
        }
      }
    });
  }
}
