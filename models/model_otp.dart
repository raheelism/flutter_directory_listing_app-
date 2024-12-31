class OtpModel {
  final int expTime;
  final String? msg;

  OtpModel({
    required this.expTime,
    this.msg,
  });

  factory OtpModel.fromJson(Map<String, dynamic> json){
    return OtpModel(
        expTime: json['data']['exp_time'] ?? 60,
        msg: json['msg']
    );
  }
}
