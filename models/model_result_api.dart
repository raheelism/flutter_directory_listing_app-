class ResultApiModel {
  final bool success;
  final Map<String, dynamic> origin;
  final String message;

  ResultApiModel({
    required this.success,
    required this.message,
    required this.origin,
  });

  factory ResultApiModel.fromJson(Map<String, dynamic> json) {
    return ResultApiModel(
      success: json['success'] ?? false,
      origin: json,
      message: json['message'] ?? json['msg'] ?? "",
    );
  }
}
