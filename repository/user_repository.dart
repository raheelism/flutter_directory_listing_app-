import 'dart:convert';

import 'package:listar_flutter_pro/api/api.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';

class UserRepository {
  ///Fetch api login
  static Future<List> login({
    required String username,
    required String password,
    String? code,
  }) async {
    final Map<String, dynamic> params = {
      "username": username,
      "password": password,
      "code": code,
    };
    final response = await Api.requestLogin(params);
    if (response.success) {
      return [true, UserModel.fromJson(response.origin['data'])];
    }

    AppBloc.messageBloc.add(MessageEvent(message: response.message));

    return [false, response.origin['code'], response.origin['data']['email']];
  }

  ///Fetch api validToken
  static Future<bool> validateToken() async {
    final response = await Api.requestValidateToken();
    if (response.success) {
      return true;
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return false;
  }

  ///Fetch api deactivate
  static Future<bool> deactivate() async {
    final response = await Api.requestDeactivate();
    if (response.success) {
      return true;
    }
    return false;
  }

  ///Fetch api change Password
  static Future<bool> changePassword({
    required String password,
  }) async {
    final Map<String, dynamic> params = {"password": password};
    final response = await Api.requestChangePassword(params);
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return true;
    }
    return false;
  }

  ///Fetch api forgot Password
  static Future<List> forgotPassword({
    required String email,
    String? code,
  }) async {
    final Map<String, dynamic> params = {"email": email, "code": code};
    final response = await Api.requestForgotPassword(params);
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return [true, response.origin['code']];
    }
    return [false, response.origin['code']];
  }

  ///Fetch api register account
  static Future<bool> register({
    required String username,
    required String password,
    required String email,
  }) async {
    final Map<String, dynamic> params = {
      "username": username,
      "password": password,
      "email": email,
    };
    final response = await Api.requestRegister(params);
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    if (response.success) {
      return true;
    }
    return false;
  }

  ///Fetch api forgot Password
  static Future<bool> changeProfile({
    required String name,
    required String email,
    required String url,
    required String description,
    int? imageID,
  }) async {
    Map<String, dynamic> params = {
      "name": name,
      "email": email,
      "url": url,
      "description": description,
    };
    if (imageID != null) {
      params['listar_user_photo'] = imageID;
    }
    final response = await Api.requestChangeProfile(params);
    AppBloc.messageBloc.add(MessageEvent(message: response.message));

    ///Case success
    if (response.success) {
      return true;
    }
    return false;
  }

  ///Save User
  static Future<bool> saveUser({required UserModel user}) async {
    return await Preferences.setString(
      Preferences.user,
      jsonEncode(user.toJson()),
    );
  }

  ///Load User
  static Future<UserModel?> loadUser() async {
    final result = Preferences.getString(Preferences.user);
    if (result != null) {
      return UserModel.fromJson(jsonDecode(result));
    }
    return null;
  }

  ///Fetch User
  static Future<UserModel?> fetchUser() async {
    final response = await Api.requestUser();
    if (response.success) {
      response.origin['data']['token'] = AppBloc.userCubit.state?.token;
      return UserModel.fromJson(response.origin['data']);
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }

  ///Delete User
  static Future<bool> deleteUser() async {
    return await Preferences.remove(Preferences.user);
  }

  ///Get & resend OTP
  static Future<OtpModel?> getOtp({required String email}) async {
    final response = await Api.requestGetOtp({"email": email});
    if (response.success) {
      return OtpModel.fromJson(response.origin);
    }
    AppBloc.messageBloc.add(MessageEvent(message: response.message));
    return null;
  }
}
