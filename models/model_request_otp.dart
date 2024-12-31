class RequestOTPModel {
  final String email;
  final Future<List> Function(String otp) onVerify;

  RequestOTPModel({required this.email, required this.onVerify});
}
