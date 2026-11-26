import 'package:dio/dio.dart';

String apiErrorMessage(Object error) {
  if (error is! DioException) {
    if (error is FormatException) {
      return 'The search service returned data the app could not read.';
    }
    return 'Could not search songs. Please try again.';
  }

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return 'The song service timed out. Please try again.';
  }

  if (error.type == DioExceptionType.connectionError) {
    return 'Could not reach the song service. Check that the backend is '
        'running and API_BASE_URL is configured for this device.';
  }

  final detail = _responseDetail(error.response?.data);
  if (detail != null) {
    return detail;
  }

  final statusCode = error.response?.statusCode;
  if (statusCode != null) {
    return 'The song service returned an error ($statusCode). Please try again.';
  }

  return 'Could not search songs. Please try again.';
}

String? _responseDetail(Object? data) {
  if (data is! Map) {
    return null;
  }

  final detail = data['detail'];
  if (detail is String && detail.isNotEmpty) {
    return detail;
  }

  if (detail is List) {
    final messages = detail
        .whereType<Map>()
        .map((item) => item['msg'])
        .whereType<String>()
        .toList();
    if (messages.isNotEmpty) {
      return messages.join(' ');
    }
  }

  return null;
}
