import 'dart:ui';

import 'package:listar_flutter_pro/utils/utils.dart';

class ClaimModel {
  final int id;
  final String title;
  final String status;
  final String address;
  final Color statusColor;
  final String priceDisplay;
  final DateTime? date;
  final DateTime? dueDate;
  final String? paymentName;
  final String? payment;
  final String? transactionID;
  final int? total;
  final String? currency;
  final String? totalDisplay;
  final String? billFirstName;
  final String? billLastName;
  final String? billPhone;
  final String? billEmail;
  final String? billAddress;
  final bool? allowCancel;
  final bool? allowPayment;
  final bool? allowAccept;
  final String? createdOn;
  final String? paidOn;
  final String? createdVia;
  final String? createdBy;

  ClaimModel({
    required this.id,
    required this.title,
    required this.status,
    required this.address,
    required this.statusColor,
    required this.priceDisplay,
    required this.date,
    required this.dueDate,
    this.paymentName,
    this.payment,
    this.transactionID,
    this.total,
    this.currency,
    this.totalDisplay,
    this.billFirstName,
    this.billLastName,
    this.billPhone,
    this.billEmail,
    this.billAddress,
    this.allowCancel,
    this.allowPayment,
    this.allowAccept,
    this.createdOn,
    this.paidOn,
    this.createdVia,
    this.createdBy,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: json['claim_id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status_name'] ?? '',
      address: json['address'] ?? '',
      statusColor: UtilColor.getColorFromHex(json['status_color']),
      priceDisplay: json['total_display'] ?? '',
      date: DateTime.tryParse(
        json['date'] ?? json['created_on'],
      ),
      dueDate: DateTime.tryParse(
        json['due_date'] ?? json['created_on'],
      ),
      paymentName: json['payment_name'] ?? '',
      payment: json['payment'] ?? '',
      transactionID: json['txn_id'] ?? '',
      total: json['total'] ?? 0,
      currency: json['currency'] ?? '',
      totalDisplay: json['total_display'] ?? '',
      billFirstName: json['billing_first_name'] ?? '',
      billLastName: json['billing_last_name'] ?? '',
      billPhone: json['billing_phone'] ?? '',
      billEmail: json['billing_email'] ?? '',
      billAddress: json['billing_address_1'] ?? '',
      allowCancel: json['allow_cancel'] ?? false,
      allowPayment: json['allow_payment'] ?? false,
      allowAccept: json['allow_accept'] ?? false,
      createdOn: json['created_on'] ?? '',
      paidOn: json['paid_date'] ?? '',
      createdVia: json['create_via'] ?? '',
      createdBy: '${json['first_name']} ${json['last_name']}',
    );
  }
}
