import 'package:listar_flutter_pro/api/api.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/models/model.dart';

class ClaimRepository {
  ///submit
  static Future<bool> submit({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String message,
  }) async {
    Map<String, dynamic> params = {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "memo": message,
    };
    final response = await Api.requestClaim(params);
    if (response.success) {
      return true;
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return false;
  }

  ///load list
  static Future<List?> loadList({
    int? page,
    int? perPage,
    SortModel? status,
    SortModel? sort,
    String? keyword,
  }) async {
    Map<String, dynamic> params = {
      "page": page,
      "per_page": perPage,
      "s": keyword,
      "post_status": status?.value,
      "orderby": sort?.field,
      "order": sort?.value,
    };
    final response = await Api.requestClaimList(params);
    if (response.success) {
      final attr = response.origin['attr'];
      final list = List.from(response.origin['data'] ?? []).map((item) {
        return ClaimModel.fromJson(item);
      }).toList();

      final pagination = PaginationModel.fromJson(
        response.origin['pagination'],
      );
      final listSort = List.from(attr['sort'] ?? []).map((item) {
        return SortModel.fromJson(item);
      }).toList();

      final listStatus = List.from(attr['status'] ?? []).map((item) {
        return SortModel.fromJson(item);
      }).toList();

      return [list, pagination, listSort, listStatus];
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }

  ///Load Detail
  static Future<ClaimModel?> loadDetail(int id) async {
    final params = {'id': id};
    final response = await Api.requestClaimDetail(params);
    if (response.success) {
      return ClaimModel.fromJson(response.origin['data']);
    } else {
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  ///Claim form
  static Future<PaymentModel?> getClaimPayment() async {
    final response = await Api.requestPaymentConfig();
    if (response.success) {
      response.origin['payment']['url_success'] = 'v1/claim/return';
      response.origin['payment']['url_cancel'] = 'v1/claim/cancel';
      return PaymentModel.fromJson(response.origin['payment']);
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  ///Cancel
  static Future<String?> payment(int id, String method) async {
    final params = {'id': id, 'payment_method': method};
    final response = await Api.requestClaimPayment(params);
    if (response.success) {
      String url = "";
      switch (params['payment_method']) {
        case 'paypal':
          url = response.origin['payment']['links'][1]['href'];
          break;
        case 'stripe':
          url = response.origin['payment']['url'];
          break;
      }
      return url;
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  ///Cancel
  static Future<ClaimModel?> cancel(int id) async {
    final params = {'id': id};
    final response = await Api.requestClaimCancel(params);
    if (response.success) {
      return ClaimModel.fromJson(response.origin['data']);
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  ///Accept
  static Future<ClaimModel?> accept(int id) async {
    final params = {'id': id};
    final response = await Api.requestClaimAccept(params);
    if (response.success) {
      return ClaimModel.fromJson(response.origin['data']);
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }
}
