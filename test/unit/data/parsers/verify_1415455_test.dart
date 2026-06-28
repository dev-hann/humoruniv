import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:humoruniv/data/parsers/content_scanner.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

void main() {
  test('verify post 1415455: video extraction from real HTML', () {
    final html = File('test/fixtures/pds_1415455.html').readAsStringSync();
    final doc = html_parser.parse(html);
    final bodyEditor = doc.querySelector('.body_editor');
    print('body_editor found: ${bodyEditor != null}');

    final mp4Divs = doc.querySelectorAll('[onclick*="comment_mp4_expand"]');
    print('mp4_expand elements: ${mp4Divs.length}');
    for (int i = 0; i < mp4Divs.length; i++) {
      final inBody = bodyEditor?.contains(mp4Divs[i]) ?? false;
      print('  [$i] inBodyEditor=$inBody');
    }

    final result = ContentScanner.scanFull(doc, bodyEditor ?? doc.body!);
    print('blocks: ${result.blocks.length}');
    for (final b in result.blocks) {
      if (b is VideoBlock)
        print('  Video: ${b.url}');
      else if (b is ImageBlock)
        print('  Image: ${b.url}');
      else if (b is TextBlock) {
        final t = b.text.substring(0, b.text.length > 40 ? 40 : b.text.length);
        print('  Text: $t');
      }
    }

    final videos = result.blocks.whereType<VideoBlock>().toList();
    print('VideoBlocks: ${videos.length}');
    expect(videos, isNotEmpty, reason: 'Post 1415455 should have VideoBlocks');
    expect(videos.first.url, contains('.mp4'));
  });
}
