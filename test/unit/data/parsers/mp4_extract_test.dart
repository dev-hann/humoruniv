import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:humoruniv/data/parsers/content_scanner.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

void main() {
  ContentScanResult scan(String innerHtml) {
    final doc = html_parser.parse(
      '<html><body><div id="body_editor">$innerHtml</div></body></html>',
    );
    return ContentScanner.scanFull(doc, doc.querySelector('#body_editor')!);
  }

  group('comment_mp4_expand video extraction', () {
    test('should extract VideoBlock from OnClick comment_mp4_expand', () {
      final result = scan(
        '<div onclick="javascript:comment_mp4_expand(\'cf123\', \'//down-mp4.humoruniv.com/c9/test.mp4\', \'//timg.humoruniv.com/thumb.php?url=t.jpg\', \'300\')">'
        'thumb</div>',
      );
      final videos = result.blocks.whereType<VideoBlock>().toList();
      expect(videos, hasLength(1));
      expect(videos.first.url, contains('down-mp4.humoruniv.com'));
      expect(videos.first.url, contains('.mp4'));
    });

    test('should produce both ImageBlock and VideoBlock when img + onclick', () {
      final result = scan(
        '<div onclick="javascript:comment_mp4_expand(\'cf123\', \'//down-mp4.humoruniv.com/c9/test.mp4\', \'//timg.humoruniv.com/thumb.php?url=t.jpg\', \'300\')">'
        '<img src="//timg.humoruniv.com/thumb.php?url=t.jpg" /></div>',
      );
      expect(result.blocks.whereType<VideoBlock>(), hasLength(1));
      expect(result.blocks.whereType<ImageBlock>(), hasLength(1));
    });

    test('should not produce VideoBlock without comment_mp4_expand', () {
      final result = scan(
        '<div onclick="javascript:some_other_fn(\'id\')">text</div>',
      );
      expect(result.blocks.whereType<VideoBlock>(), isEmpty);
    });
  });
}
