import 'dart:io';

const _baseUrl = 'https://m.humoruniv.com';
const _mobileUA =
    'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36';

Future<String> fetchHtml(String path) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('$_baseUrl$path'));
    request.headers.set('User-Agent', _mobileUA);
    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      [],
      (acc, chunk) => acc..addAll(chunk),
    );

    final tempFile = File(
      '${Directory.systemTemp.path}/smoke_${DateTime.now().millisecondsSinceEpoch}.html',
    );
    await tempFile.writeAsBytes(bytes);

    final result = await Process.run(
      'iconv',
      ['-f', 'cp949', '-t', 'utf-8', tempFile.path],
    );
    await tempFile.delete();

    if (result.exitCode != 0) {
      throw Exception('iconv failed: ${result.stderr}');
    }

    return result.stdout as String;
  } finally {
    client.close();
  }
}
