import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:humoruniv/core/network/html_client.dart';

class HtmlClientImpl implements HtmlClient {
  HtmlClientImpl({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://m.humoruniv.com',
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
                    '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36',
              },
              responseType: ResponseType.bytes,
            ),
          );
  final Dio _dio;

  @override
  Future<String> get(String path) async {
    final response = await _dio.get<List<int>>(path);
    final bytes = response.data ?? <int>[];

    final decoded = await CharsetConverter.decode(
      'euc-kr',
      Uint8List.fromList(bytes),
    );
    return decoded;
  }
}
