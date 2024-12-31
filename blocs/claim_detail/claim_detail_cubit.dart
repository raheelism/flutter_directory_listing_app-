import 'package:bloc/bloc.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';

import 'cubit.dart';

class ClaimDetailCubit extends Cubit<ClaimDetailState> {
  ClaimDetailCubit() : super(ClaimDetailLoading());

  void onLoad(int id) async {
    final result = await ClaimRepository.loadDetail(id);
    if (result != null) {
      emit(ClaimDetailSuccess(result));
    }
  }

  Future<PaymentModel?> getClaimPayment() async {
    return await ClaimRepository.getClaimPayment();
  }

  Future<String?> onPayment(int id, String method) async {
    return await ClaimRepository.payment(id, method);
  }

  Future<void> onCancel(int id) async {
    final result = await ClaimRepository.cancel(id);
    if (result != null) {
      emit(ClaimDetailSuccess(result));
    }
  }

  Future<void> onAccept(int id) async {
    final result = await ClaimRepository.accept(id);
    if (result != null) {
      emit(ClaimDetailSuccess(result));
    }
  }
}
