import 'package:listar_flutter_pro/models/model.dart';

abstract class ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewSuccess extends ReviewState {
  final int? id;
  final List<CommentModel> list;
  final RateModel rate;
  final bool submit;

  ReviewSuccess({
    this.id,
    required this.list,
    required this.rate,
    required this.submit
  });
}
