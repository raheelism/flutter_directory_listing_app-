import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/api/api.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/models/model.dart';

class BookingRepository {
  static Future<List?> loadBookingForm(id) async {
    final response = await Api.requestBookingForm({'resource_id': id});
    if (response.success) {
      late BookingStyleModel bookingStyle;
      switch (response.origin['data']['type']) {
        case 'standard':
          bookingStyle = StandardBookingModel.fromJson(response.origin['data']);
          break;
        case 'daily':
          bookingStyle = DailyBookingModel.fromJson(response.origin['data']);
          break;
        case 'hourly':
          bookingStyle = HourlyBookingModel.fromJson(response.origin['data']);
          break;
        case 'table':
          bookingStyle = TableBookingModel.fromJson(response.origin['data']);
          break;
        case 'slot':
          bookingStyle = SlotBookingModel.fromJson(response.origin['data']);
          break;
        default:
          bookingStyle = StandardBookingModel(
            startDate: DateTime.now(),
            startTime: const TimeOfDay(
              hour: 0,
              minute: 0,
            ),
          );
          break;
      }

      response.origin['payment']['url_success'] = 'v1/booking/return';
      response.origin['payment']['url_cancel'] = 'v1/booking/cancel';

      return [bookingStyle, PaymentModel.fromJson(response.origin['payment'])];
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  static Future<String?> calcPrice(Map<String, dynamic> params) async {
    final response = await Api.requestPrice(params);
    if (response.success) {
      return response.origin['attr']['total_display'];
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  static Future<String?> order(Map<String, dynamic> params) async {
    final response = await Api.requestOrder(params);
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

  static Future<List?> loadList({
    String? keyword,
    int? page,
    int? perPage,
    SortModel? sort,
    SortModel? status,
    required bool request,
  }) async {
    Map<String, dynamic> params = {
      "s": keyword,
      "page": page,
      "per_page": perPage,
    };
    if (sort != null) {
      params['orderby'] = sort.field;
      params['order'] = sort.value;
    }
    if (status != null) {
      params['post_status'] = status.value;
    }
    final response = await Api.requestBookingList(
      params,
      request: request,
    );
    if (response.success) {
      final attr = response.origin['attr'];
      final list = List.from(response.origin['data'] ?? []).map((item) {
        return BookingModel.fromJson(item);
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

  static Future<BookingModel?> loadDetail(int id) async {
    final params = {'id': id};
    final response = await Api.requestBookingDetail(params);
    if (response.success) {
      return BookingModel.fromJson(response.origin['data']);
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  static Future<BookingModel?> cancel(int id) async {
    final params = {'id': id};
    final response = await Api.requestBookingCancel(params);
    if (response.success) {
      return BookingModel.fromJson(response.origin['data']);
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }

  static Future<BookingModel?> accept(int id) async {
    final params = {'id': id};
    final response = await Api.requestBookingAccept(params);
    if (response.success) {
      return BookingModel.fromJson(response.origin['data']);
    } else {
      ///Notify
      AppBloc.messageBloc.add(MessageEvent(message: response.message));
    }
    return null;
  }
}
