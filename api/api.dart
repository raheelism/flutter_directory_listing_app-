import 'dart:async';

import 'package:listar_flutter_pro/api/http_manager.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';

class Api {
  static final httpManager = HTTPManager();

  ///URL API
  static const String login = "/jwt-auth/v1/token";
  static const String authValidate = "/jwt-auth/v1/token/validate";
  static const String user = "/listar/v1/auth/user";
  static const String register = "/listar/v1/auth/register";
  static const String forgotPassword = "/listar/v1/auth/reset_password";
  static const String changePassword = "/wp/v2/users/me";
  static const String changeProfile = "/wp/v2/users/me";
  static const String setting = "/listar/v1/setting/init";
  static const String submitSetting = "/listar/v1/place/form";
  static const String home = "/listar/v1/home/init";
  static const String homeWidget = "/listar/v1/home/widget";
  static const String categories = "/listar/v1/category/list";
  static const String discovery = "/listar/v1/category/list_discover";
  static const String withLists = "/listar/v1/wishlist/list";
  static const String addWishList = "/listar/v1/wishlist/save";
  static const String removeWishList = "/listar/v1/wishlist/remove";
  static const String clearWithList = "/listar/v1/wishlist/reset";
  static const String list = "/listar/v1/place/list";
  static const String listBlog = "/listar/v1/post/home";
  static const String deleteProduct = "/listar/v1/place/delete";
  static const String authorList = "/listar/v1/author/listing";
  static const String authorReview = "/listar/v1/author/comments";
  static const String tags = "/listar/v1/place/terms";
  static const String comments = "/listar/v1/comments";
  static const String saveComment = "/wp/v2/comments";
  static const String product = "/listar/v1/place/view";
  static const String post = "/listar/v1/post/view";
  static const String saveProduct = "/listar/v1/place/save";
  static const String locations = "/listar/v1/location/list";
  static const String uploadImage = "/wp/v2/media";
  static const String bookingForm = "/listar/v1/booking/form";
  static const String calcPrice = "/listar/v1/booking/cart";
  static const String order = "/listar/v1/booking/order";
  static const String bookingDetail = "/listar/v1/booking/view";
  static const String bookingList = "/listar/v1/booking/list";
  static const String bookingRequestList = "/listar/v1/author/booking";
  static const String bookingCancel = "/listar/v1/booking/cancel_by_id";
  static const String bookingAccept = "/listar/v1/booking/accept_by_id";
  static const String deactivate = "/listar/v1/auth/deactivate";
  static const String getPaymentConfig = "/listar/v1/setting/payment";
  static const String claimForm = "/listar/v1/claim/form";
  static const String claim = "/listar/v1/claim/submit";
  static const String claimList = "/listar/v1/claim/list";
  static const String claimDetail = "/listar/v1/claim/view";
  static const String claimPay = "/listar/v1/claim/pay";
  static const String claimCancel = "/listar/v1/claim/cancel_by_id";
  static const String claimAccept = "/listar/v1/claim/accept_by_id";
  static const String gpsPicked = "/listar/v1/place/form";
  static const String getOtp = "/listar/v1/auth/otp";

  ///Login api
  static Future<ResultApiModel> requestLogin(params) async {
    final result = await httpManager.post(
      url: login,
      data: params,
      loading: true,
      location: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Validate token valid
  static Future<ResultApiModel> requestValidateToken() async {
    Map<String, dynamic> result = await httpManager.post(url: authValidate);
    result['success'] = result['code'] == 'jwt_auth_valid_token';
    result['message'] = result['code'] ?? result['message'];
    return ResultApiModel.fromJson(result);
  }

  ///Forgot password
  static Future<ResultApiModel> requestForgotPassword(params) async {
    Map<String, dynamic> result = await httpManager.post(
      url: forgotPassword,
      data: params,
      loading: true,
    );
    result['message'] = result['code'] ?? result['msg'];
    return ResultApiModel.fromJson(result);
  }

  ///Register account
  static Future<ResultApiModel> requestRegister(params) async {
    final result = await httpManager.post(
      url: register,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson({
      "success": result['code'] == 200 || result['code'] == 'auth_otp_require',
      "message": result['message'],
      "data": result
    });
  }

  ///Change Profile
  static Future<ResultApiModel> requestChangeProfile(params) async {
    final result = await httpManager.post(
      url: changeProfile,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson({
      "success": result['code'] == null,
      "message": result['code'] ?? "update_info_success",
      "data": result
    });
  }

  ///change password
  static Future<ResultApiModel> requestChangePassword(params) async {
    final result = await httpManager.post(
      url: changePassword,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson({
      "success": result['code'] == null,
      "message": result['code'] ?? "change_password_success",
      "data": result
    });
  }

  ///Get User
  static Future<ResultApiModel> requestUser() async {
    final result = await httpManager.get(url: user);
    return ResultApiModel.fromJson(result);
  }

  ///Get Setting
  static Future<ResultApiModel> requestSetting() async {
    final result = await httpManager.get(
      url: setting,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Submit Setting
  static Future<ResultApiModel> requestSubmitSetting(params) async {
    final result = await httpManager.get(
      url: submitSetting,
      params: params,
    );
    return ResultApiModel.fromJson(
      {"success": result['countries'] != null, "data": result},
    );
  }

  ///Get Area
  static Future<ResultApiModel> requestLocation(params) async {
    final result = await httpManager.get(
      url: locations,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Category
  static Future<ResultApiModel> requestCategory(params) async {
    final result = await httpManager.get(url: categories, params: params);
    return ResultApiModel.fromJson(result);
  }

  ///Get Discovery
  static Future<ResultApiModel> requestDiscovery() async {
    final result = await httpManager.get(
      url: discovery,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Home
  static Future<ResultApiModel> requestHome(params) async {
    final result = await httpManager.get(
      url: home,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Home Widget
  static Future<ResultApiModel> requestHomeWidget(params) async {
    final result = await httpManager.get(
      url: homeWidget,
      params: params,
      location: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get ProductDetail
  static Future<ResultApiModel> requestProduct(params) async {
    final result = await httpManager.get(
      url: product,
      params: params,
      location: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get BlogDetail
  static Future<ResultApiModel> requestBlog(params) async {
    final result = await httpManager.get(
      url: post,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Wish List
  static Future<ResultApiModel> requestWishList(params) async {
    final result = await httpManager.get(url: withLists, params: params);
    return ResultApiModel.fromJson(result);
  }

  ///Save Wish List
  static Future<ResultApiModel> requestAddWishList(params) async {
    final result = await httpManager.post(url: addWishList, data: params);
    return ResultApiModel.fromJson(result);
  }

  ///Save Product
  static Future<ResultApiModel> requestSaveProduct(params) async {
    final result = await httpManager.post(
      url: saveProduct,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Remove Wish List
  static Future<ResultApiModel> requestRemoveWishList(params) async {
    final result = await httpManager.post(
      url: removeWishList,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Clear Wish List
  static Future<ResultApiModel> requestClearWishList() async {
    final result = await httpManager.post(url: clearWithList, loading: true);
    return ResultApiModel.fromJson(result);
  }

  ///Get Product List
  static Future<ResultApiModel> requestList(params) async {
    final result = await httpManager.get(
      url: list,
      params: params,
      location: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Product Blog
  static Future<ResultApiModel> requestListBlog(params) async {
    final result = await httpManager.get(
      url: listBlog,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Tags List
  static Future<ResultApiModel> requestTags(params) async {
    final result = await httpManager.get(url: tags, params: params);
    return ResultApiModel.fromJson(result);
  }

  ///Clear Wish List
  static Future<ResultApiModel> requestDeleteProduct(params) async {
    final result = await httpManager.post(
      url: deleteProduct,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Author Product List
  static Future<ResultApiModel> requestAuthorList(params) async {
    final result = await httpManager.get(
      url: authorList,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Author Review List
  static Future<ResultApiModel> requestAuthorReview(params) async {
    final result = await httpManager.get(
      url: authorReview,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Review
  static Future<ResultApiModel> requestReview(params) async {
    final result = await httpManager.get(url: comments, params: params);
    return ResultApiModel.fromJson(result);
  }

  ///Save Review
  static Future<ResultApiModel> requestSaveReview(params) async {
    final result = await httpManager.post(
      url: saveComment,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson({
      "success": result['code'] == null,
      "message": result['message'] ?? "save_data_success",
      "data": result
    });
  }

  ///Upload image
  static Future<ResultApiModel> requestUploadImage(formData, progress) async {
    var result = await httpManager.post(
      url: uploadImage,
      formData: formData,
      progress: progress,
    );

    return ResultApiModel.fromJson(
      {
        "success": result['id'] != null,
        "data": result,
        "message": result['message']
      },
    );
  }

  ///Get booking form
  static Future<ResultApiModel> requestBookingForm(params) async {
    final result = await httpManager.get(
      url: bookingForm,
      params: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Price
  static Future<ResultApiModel> requestPrice(params) async {
    final result = await httpManager.post(
      url: calcPrice,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Order
  static Future<ResultApiModel> requestOrder(params) async {
    final result = await httpManager.post(
      url: order,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Booking Detail
  static Future<ResultApiModel> requestBookingDetail(params) async {
    final result = await httpManager.get(
      url: bookingDetail,
      params: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Booking List
  static Future<ResultApiModel> requestBookingList(
    params, {
    required bool request,
  }) async {
    final result = await httpManager.get(
      url: request ? bookingRequestList : bookingList,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Booking Cancel
  static Future<ResultApiModel> requestBookingCancel(params) async {
    final result = await httpManager.post(
      url: bookingCancel,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Booking Cancel
  static Future<ResultApiModel> requestBookingAccept(params) async {
    final result = await httpManager.post(
      url: bookingAccept,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Claim Listing
  static Future<ResultApiModel> requestClaim(params) async {
    final result = await httpManager.post(
      url: claim,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Claim List
  static Future<ResultApiModel> requestClaimList(params) async {
    final result = await httpManager.get(
      url: claimList,
      params: params,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get Booking Detail
  static Future<ResultApiModel> requestClaimDetail(params) async {
    final result = await httpManager.get(
      url: claimDetail,
      params: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Claim Pay
  static Future<ResultApiModel> requestClaimPayment(params) async {
    final result = await httpManager.post(
      url: claimPay,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Claim Return
  static Future<ResultApiModel> requestClaimCancel(params) async {
    final result = await httpManager.post(
      url: claimCancel,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Claim Cancel
  static Future<ResultApiModel> requestClaimAccept(params) async {
    final result = await httpManager.post(
      url: claimAccept,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Claim Pay
  static Future<ResultApiModel> requestPaymentConfig() async {
    final result = await httpManager.get(
      url: getPaymentConfig,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Download file
  static Future<ResultApiModel> requestDownloadFile({
    required FileModel file,
    required progress,
    String? directory,
  }) async {
    directory ??= await UtilFile.getFilePath();
    final filePath = '$directory/${file.name}.${file.type}';
    final result = await httpManager.download(
      url: file.url,
      filePath: filePath,
      progress: progress,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Deactivate account
  static Future<ResultApiModel> requestDeactivate() async {
    final result = await httpManager.post(
      url: deactivate,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Get & resend otp login
  static Future<ResultApiModel> requestGetOtp(params) async {
    final result = await httpManager.post(
      url: getOtp,
      data: params,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Gps picker
  static Future<ResultApiModel> requestGps() async {
    final result = await httpManager.get(
      url: gpsPicked,
      loading: true,
    );
    return ResultApiModel.fromJson(result);
  }

  ///Singleton factory
  static final Api _instance = Api._internal();

  factory Api() {
    return _instance;
  }

  Api._internal();
}
