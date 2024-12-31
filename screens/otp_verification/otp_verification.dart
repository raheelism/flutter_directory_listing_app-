import 'dart:async';

import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/models/model_request_otp.dart';
import 'package:listar_flutter_pro/repository/repository.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerification extends StatefulWidget {
  final RequestOTPModel requestOTPModel;

  const OtpVerification({
    Key? key,
    required this.requestOTPModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OtpVerificationState();
  }
}

class _OtpVerificationState extends State<OtpVerification> {
  final _otpController = TextEditingController();
  int _resendTimeout = 0;
  Timer? _timer;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _getOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer(int time) {
    _resendTimeout = time;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout > 0) {
        setState(() {
          _resendTimeout--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _getOtp() async {
    final response = await UserRepository.getOtp(
      email: widget.requestOTPModel.email,
    );
    if (response != null) {
      _startResendTimer(response.expTime);
      setState(() {
        _errorCode = null;
      });
    }
    _otpController.clear();
  }

  void _verifyOtp() async {
    Utils.hiddenKeyboard(context);
    final otp = _otpController.text;
    if (otp.isEmpty || otp.length < 6) return;
    final result = await widget.requestOTPModel.onVerify(otp);
    if (!mounted) return;

    if (result[0] == true) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorCode = result[1];
        _resendTimeout = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Translate.of(context).translate('otp_verification')),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 16),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  Translate.of(context).translate('otp_sent'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.normal),
                ),
                Text(
                  widget.requestOTPModel.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    setState(() {
                      _errorCode = null;
                    });
                  },
                  controller: _otpController,
                  autoDisposeControllers: false,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 55,
                    fieldWidth: 45,
                    inactiveColor: Theme.of(context).colorScheme.onSurface,
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  keyboardType: TextInputType.number,
                  onCompleted: (value) {
                    _verifyOtp();
                  },
                ),
                const SizedBox(height: 8),
                if (_errorCode != null && mounted)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.info, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          Translate.of(context).translate(_errorCode),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                // const SizedBox(height: 20),
                if (_resendTimeout > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(Translate.of(context).translate('otp_resend')),
                      Text(
                        '$_resendTimeout',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                AppButton(
                  Translate.of(context).translate('otp_verify'),
                  mainAxisSize: MainAxisSize.max,
                  onPressed: _verifyOtp,
                  disabled: _errorCode != null || _otpController.text.isEmpty,
                ),
                const SizedBox(height: 4),
                if (_resendTimeout == 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(Translate.of(context).translate('otp_again')),
                      AppButton(
                        Translate.of(context).translate('resend'),
                        onPressed: _getOtp,
                        type: ButtonType.text,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
