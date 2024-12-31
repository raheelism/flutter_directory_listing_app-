import 'dart:async';

import 'package:listar_flutter_pro/models/model.dart';

class PaymentModel {
  final bool use;
  final String term;
  final List<PaymentMethodModel> listMethod;
  final List<BankAccountModel> listAccount;
  final String urlSuccess;
  final String urlCancel;
  PaymentMethodModel? method;
  Future<String?> Function()? onPayment;

  PaymentModel({
    required this.use,
    required this.term,
    required this.urlSuccess,
    required this.urlCancel,
    required this.listMethod,
    required this.listAccount,
    this.method,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    PaymentMethodModel? method;
    if (json['use'] == true) {
      method = PaymentMethodModel.fromJson(
          List.from(json['list'] ?? []).firstWhere((e) {
        return e['method'] == json['default'];
      }, orElse: () {
        return json['list'][0];
      }));
    }
    return PaymentModel(
      use: json['use'] ?? false,
      term: json['term_condition_page'] ?? '',
      urlSuccess: json['url_success'],
      urlCancel: json['url_cancel'],
      listMethod: List.from(json['list'] ?? []).map((e) {
        return PaymentMethodModel.fromJson(e);
      }).toList(),
      listAccount: List.from(json['bank_account_list'] ?? []).map((e) {
        return BankAccountModel.fromJson(e);
      }).toList(),
      method: method,
    );
  }
}
