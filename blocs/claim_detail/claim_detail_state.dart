import 'package:listar_flutter_pro/models/model.dart';

abstract class ClaimDetailState {}

class ClaimDetailLoading extends ClaimDetailState {}

class ClaimDetailSuccess extends ClaimDetailState {
  final ClaimModel item;
  ClaimDetailSuccess(this.item);
}
