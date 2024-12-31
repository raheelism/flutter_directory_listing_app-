import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';

class HTTPManager {
  bool _resetToken = false;
  final exceptionCode = [
    'jwt_auth_bad_iss',
    'jwt_auth_invalid_token',
    'jwt_auth_failed',
    'jwt_auth_invalid_token'
  ];
  final _pendingRequests = Queue<RequestOptions>();
  late final Dio _dio;

  HTTPManager() {
    ///Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: '${Application.domain}/index.php/wp-json',
        connectTimeout: const Duration(seconds: 30000),
        receiveTimeout: const Duration(seconds: 30000),
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
      ),
    );

    ///Interceptors dio
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          Map<String, dynamic> headers = {
            "Device-Id": Application.device?.uuid,
            "Device-Model": Application.device?.model,
            "Device-Version": Application.device?.version,
            "Type": Application.device?.type,
            "Device-Token": Application.device?.token,
            "Language": Preferences.getString(Preferences.language),
          };
          final token = AppBloc.userCubit.state?.token;
          if (token != null) {
            headers.addAll({
              "Authorization": "Bearer $token",
            });
          }
          options.headers.addAll(headers);
          _printRequest(options);
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final errorData = error.response?.data;
          if (error.response?.data is Map) {
            final code = errorData['code'];
            if (code is String && exceptionCode.contains(code)) {
              _pendingRequests.add(error.requestOptions);
              if (!_resetToken) {
                _resetToken = true;
                await AppBloc.authenticateCubit.onLogout();
                while (_pendingRequests.isNotEmpty) {
                  final pendingRequest = _pendingRequests.removeFirst();
                  pendingRequest.headers.remove('Authorization');
                  final result = await _dio.fetch(pendingRequest);
                  return handler.resolve(result);
                }
                _resetToken = false;
              }
            }
            final response = Response(
              requestOptions: error.requestOptions,
              data: error.response?.data,
            );
            return handler.resolve(response);
          }

          return handler.next(error);
        },
      ),
    );
  }

  ///Post method
  Future<dynamic> post({
    required String url,
    dynamic data,
    FormData? formData,
    Function(num)? progress,
    bool? loading,
    bool? location = false,
  }) async {
    final options = Options(headers: {});

    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    if (location == true) {
      GPSModel? gps = await Utils.getLocations();
      options.headers?.addAll({
        "Longitude": gps?.longitude,
        "Latitude": gps?.latitude,
      });
    }

    try {
      final response = await _dio.post(
        url,
        data: data ?? formData,
        options: options,
        onSendProgress: (received, total) {
          if (progress != null) {
            progress((received / total) / 0.01);
          }
        },
      );
      return response.data;
    } on DioException catch (error) {
      return _errorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  ///Get method
  Future<dynamic> get({
    required String url,
    dynamic params,
    bool? loading,
    bool? location = false,
  }) async {
    try {
      final options = Options(headers: {});

      if (loading == true) {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
        SVProgressHUD.show();
      }
      if (location == true) {
        GPSModel? gps = await Utils.getLocations();
        options.headers?.addAll({
          "Longitude": gps?.longitude,
          "Latitude": gps?.latitude,
        });
      }

      final response = await _dio.get(
        url,
        queryParameters: params,
        options: options,
      );
      return response.data;
    } on DioException catch (error) {
      return _errorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  ///Post method
  Future<dynamic> download({
    required String url,
    required String filePath,
    dynamic params,
    Function(num)? progress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }
    try {
      final response = await _dio.download(
        url,
        filePath,
        queryParameters: params,
        onReceiveProgress: (received, total) {
          if (progress != null) {
            progress((received / total) / 0.01);
          }
        },
      );
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": File(filePath),
          "message": 'download_success',
        };
      }
      return {
        "success": false,
        "message": 'download_fail',
      };
    } on DioException catch (error) {
      return _errorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  ///On change domain
  void changeDomain(String domain) {
    _dio.options.baseUrl = '$domain/index.php/wp-json';
  }

  ///Print request info
  void _printRequest(RequestOptions options) {
    UtilLogger.log("BEFORE REQUEST ====================================");
    UtilLogger.log("${options.method} URL", options.uri);
    UtilLogger.log("HEADERS", options.headers);
    if (options.method == 'GET') {
      UtilLogger.log("PARAMS", options.queryParameters);
    } else {
      UtilLogger.log("DATA", options.data);
    }
  }

  ///Error common handle
  Map<String, dynamic> _errorHandle(DioException error) {
    String message = "unknown_error";
    Map<String, dynamic> data = {};

    switch (error.type) {
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "request_time_out";
        break;

      case DioExceptionType.unknown:
        if (error.error is FormatException) {
          message = "something_went_wrong";
        }
        break;

      default:
        message = "cannot_connect_server";
        break;
    }

    return {
      "success": false,
      "message": message,
      "data": data,
    };
  }
}
