import 'package:listar_flutter_pro/models/model.dart';

abstract class BookingState {}

class FormLoading extends BookingState {}

class FormSuccess extends BookingState {
  final BookingStyleModel bookingStyle;
  final PaymentModel payment;

  FormSuccess({
    required this.bookingStyle,
    required this.payment,
  });
}
