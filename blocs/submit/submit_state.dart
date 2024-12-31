import 'package:listar_flutter_pro/models/model.dart';

abstract class SubmitState {}

class SubmitLoading extends SubmitState {}

class ReadySubmit extends SubmitState {
  final SubmitSettingModel setting;
  final ProductModel? product;

  ReadySubmit({required this.setting, this.product});
}

class Submitted extends SubmitState {}
