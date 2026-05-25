import 'dart:async';
import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:humoruniv/core/network/html_client.dart';

class HtmlClientImpl implements HtmlClient {
  final Dio _dio;
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(seconds: 2);

  HtmlClientImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://m.humoruniv.com',
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
                        '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36',
              },
              responseType: ResponseType.bytes,
            ));

  @override
  Future<String> get(String path) async {
    await _enforceRateLimit();

    final response = await _dio.get<List<int>>(path);
    final bytes = response.data ?? <int>[];

    final decoded = await CharsetConverter.decode(
      'euc-kr',
      Uint8List.fromList(bytes),
    );
    return decoded;
  }

  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        final waitDuration = _minRequestInterval - elapsed;
        await Future<void>.delayed(waitDuration);
      }
    }
    _lastRequestTime = DateTime.now();
  }
}
