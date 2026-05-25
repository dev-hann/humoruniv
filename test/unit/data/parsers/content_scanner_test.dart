import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:humoruniv/data/parsers/content_scanner.dart';
import 'package:humoruniv/domain/entities/content_block.dart';

void main() {
  group('ContentScanner', () {
    group('scan', () {
      test('should extract text as TextBlock', () {
        final doc = html_parser.parse(
          '<div class="body_editor">Hello world</div>',
        );
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks, hasLength(1));
        expect(result.blocks.first, isA<TextBlock>());
        expect((result.blocks.first as TextBlock).text, 'Hello world');
      });

      test('should extract image from img tag', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <div class="simple_attach_img_div">
              <img src="http://example.com/img.jpg" img_file_url="http://example.com/img.jpg" class="img_compress" />
            </div>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks.any((b) => b is ImageBlock), isTrue);
        expect(result.imageUrls, contains('http://example.com/img.jpg'));
      });

      test('should extract image with thumbnail', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <img src="http://example.com/thumb.jpg" img_file_url="http://example.com/full.jpg" class="img_compress" />
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final img = result.blocks.whereType<ImageBlock>().first;
        expect(img.url, 'http://example.com/full.jpg');
        expect(img.thumbnailUrl, 'http://example.com/thumb.jpg');
      });

      test('should preserve order of text and images', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            Text before
            <img src="http://example.com/img.jpg" img_file_url="http://example.com/img.jpg" class="img_compress" />
            Text after
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final types = result.blocks.map((b) => b.runtimeType).toList();
        expect(types, contains(TextBlock));
        expect(types, contains(ImageBlock));

        final textBeforeIdx = result.blocks.indexWhere(
          (b) => b is TextBlock && b.text.contains('Text before'),
        );
        final imgIdx = result.blocks.indexWhere((b) => b is ImageBlock);
        final textAfterIdx = result.blocks.indexWhere(
          (b) => b is TextBlock && b.text.contains('Text after'),
        );

        expect(textBeforeIdx, lessThan(imgIdx));
        expect(imgIdx, lessThan(textAfterIdx));
      });

      test('should skip noise elements', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <div class="comment_thumb_notice">some notice</div>
            <div class="comment_crop_href">crop link</div>
            <div class="comment_crop_href_mp4">mp4 crop</div>
            <iframe src="http://example.com"></iframe>
            <p>Actual content</p>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final texts = result.blocks
            .whereType<TextBlock>()
            .map((b) => b.text)
            .toList();
        expect(texts, isNot(contains('some notice')));
        expect(texts, isNot(contains('crop link')));
        expect(texts, isNot(contains('mp4 crop')));
        expect(texts, contains('Actual content'));
      });

      test('should skip images with /images/ path', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <img src="/images/spacer.gif" />
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks.whereType<ImageBlock>(), isEmpty);
      });

      test('should detect video element as VideoBlock', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <div>
              <video width="480" height="360" poster="http://example.com/thumb.jpg" controls>
                <source src="http://example.com/video.mp4" type="video/mp4">
              </video>
            </div>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks.any((b) => b is VideoBlock), isTrue);
        final video = result.blocks.whereType<VideoBlock>().first;
        expect(video.url, 'http://example.com/video.mp4');
        expect(video.thumbnailUrl, 'http://example.com/thumb.jpg');
        expect(video.width, 480);
        expect(video.height, 360);
      });

      test('should extract YouTube link as VideoBlock', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <span class="autolink"><a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ">youtube link</a></span>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks.any((b) => b is VideoBlock), isTrue);
        final video = result.blocks.whereType<VideoBlock>().first;
        expect(video.url, contains('youtube.com'));
        expect(video.thumbnailUrl, contains('img.youtube.com'));
      });

      test('should extract link as HtmlBlock', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <span class="autolink"><a href="https://example.com/page">visit page</a></span>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks.any((b) => b is HtmlBlock), isTrue);
        final html = result.blocks.whereType<HtmlBlock>().first;
        expect(html.html, contains('href="https://example.com/page"'));
        expect(html.html, contains('visit page'));
      });

      test('should deduplicate URLs', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <div class="simple_attach_img_div">
              <img src="http://example.com/img.jpg" img_file_url="http://example.com/img.jpg" class="img_compress" />
            </div>
            <div class="comment_img_div">
              <img src="http://example.com/img.jpg" img_file_url="http://example.com/img.jpg" class="img_compress" />
            </div>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks.whereType<ImageBlock>(), hasLength(1));
      });

      test('should normalize // URLs to https://', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <img src="//timg.humoruniv.com/thumb.jpg" img_file_url="//timg.humoruniv.com/full.jpg" class="img_compress" />
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final img = result.blocks.whereType<ImageBlock>().first;
        expect(img.url, startsWith('https://'));
        expect(img.thumbnailUrl, startsWith('https://'));
      });

      test('should handle empty container', () {
        final doc = html_parser.parse('<div class="body_editor"></div>');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        expect(result.blocks, isEmpty);
        expect(result.imageUrls, isEmpty);
      });
    });

    group('scanCompact', () {
      test('should extract images from comment body', () {
        final doc = html_parser.parse('''
          <div class="comment_body">
            <span class="comment_text">댓글 내용</span>
            <div class="comment_img_div">
              <img src="http://example.com/comment_img.jpg" img_file_url="http://example.com/comment_img.jpg" class="img_compress" />
            </div>
          </div>
        ''');
        final container = doc.querySelector('.comment_body')!;

        final result = ContentScanner.scanCompact(container);

        expect(result, hasLength(1));
        expect(result.first, isA<ImageBlock>());
      });

      test('should extract video from onclick attribute', () {
        final doc = html_parser.parse('''
          <div class="comment_body">
            <span class="comment_text">댓글</span>
            <div OnClick="comment_mp4_expand('123','http://example.com/video.mp4','http://example.com/thumb.jpg')">
              <img src="http://example.com/thumb.jpg" />
            </div>
          </div>
        ''');
        final container = doc.querySelector('.comment_body')!;

        final result = ContentScanner.scanCompact(container);

        expect(result.any((b) => b is VideoBlock), isTrue);
        final video = result.whereType<VideoBlock>().first;
        expect(video.url, 'http://example.com/video.mp4');
      });

      test('should return empty list for text-only comment', () {
        final doc = html_parser.parse('''
          <div class="comment_body">
            <span class="comment_text">그냥 텍스트 댓글</span>
          </div>
        ''');
        final container = doc.querySelector('.comment_body')!;

        final result = ContentScanner.scanCompact(container);

        expect(result, isEmpty);
      });
    });

    group('scanFull', () {
      test('should scan content container and find inline images', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <img src="http://example.com/img.jpg" img_file_url="http://example.com/img.jpg" class="img_compress" />
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        expect(result.blocks.any((b) => b is ImageBlock), isTrue);
      });

      test('should find download links outside content container', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <p>Some text</p>
          </div>
          <div class="download_area">
            <a href="http://down.humoruniv.com/download.php?url=http://example.com/extra.jpg">
              <img src="http://example.com/extra_thumb.jpg" />
            </a>
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(1));
        expect(imgs.first.url, 'http://example.com/extra.jpg');
      });

      test('should find download video outside content container', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <p>Some text</p>
          </div>
          <div class="download_area">
            <a href="http://down.humoruniv.com/download.php?url=http://example.com/clip.mp4">
              <img src="http://example.com/clip_thumb.jpg" />
            </a>
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        expect(result.blocks.any((b) => b is VideoBlock), isTrue);
        final video = result.blocks.whereType<VideoBlock>().first;
        expect(video.url, 'http://example.com/clip.mp4');
      });

      test(
        'should not duplicate image found both inside and outside container',
        () {
          final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <div class="simple_attach_img_div">
              <img src="http://timg.humoruniv.com/editor/img001.jpg"
                   img_file_url="http://timg.humoruniv.com/editor/img001.jpg"
                   class="img_compress" />
            </div>
          </div>
          <div class="download_area">
            <a href="http://down.humoruniv.com/download.php?url=http://down.humoruniv.com/editor/img001.jpg">
              <img src="http://down.humoruniv.com/editor/img001.jpg" />
            </a>
          </div>
          </body></html>
        ''');
          final container = doc.querySelector('.body_editor')!;

          final result = ContentScanner.scanFull(doc, container);

          final imgs = result.blocks.whereType<ImageBlock>().toList();
          expect(imgs, hasLength(1));
        },
      );

      test('should not duplicate when scheme differs (http vs https)', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <img src="http://timg.humoruniv.com/editor/photo.jpg"
                 img_file_url="http://timg.humoruniv.com/editor/photo.jpg"
                 class="img_compress" />
          </div>
          <div class="download_area">
            <a href="https://down.humoruniv.com/download.php?url=https://down.humoruniv.com/editor/photo.jpg">
              <img src="https://down.humoruniv.com/editor/photo.jpg" />
            </a>
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(1));
      });

      test('should not duplicate when domain differs but path is same', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <img src="http://timg.humoruniv.com/hwiparambbs/data/editor/2505/test.jpg"
                 img_file_url="http://timg.humoruniv.com/hwiparambbs/data/editor/2505/test.jpg"
                 class="img_compress" />
          </div>
          <div class="download_area">
            <a href="download.php?url=http://down.humoruniv.com/hwiparambbs/data/editor/2505/test.jpg">
              <img src="http://down.humoruniv.com/hwiparambbs/data/editor/2505/test.jpg" />
            </a>
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(1));
      });

      test('should allow different images from different paths', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <img src="http://timg.humoruniv.com/editor/img001.jpg"
                 img_file_url="http://timg.humoruniv.com/editor/img001.jpg"
                 class="img_compress" />
          </div>
          <div class="download_area">
            <a href="download.php?url=http://down.humoruniv.com/editor/img002.jpg">
              <img src="http://down.humoruniv.com/editor/img002.jpg" />
            </a>
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(2));
      });

      test('should include both imageUrls for gallery', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <img src="http://example.com/a.jpg"
                 img_file_url="http://example.com/a.jpg"
                 class="img_compress" />
          </div>
          <div class="download_area">
            <a href="download.php?url=http://example.com/b.jpg">
              <img src="http://example.com/b_thumb.jpg" />
            </a>
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        expect(result.imageUrls, hasLength(2));
      });

      test('should skip download links inside content container', () {
        final doc = html_parser.parse('''
          <html><body>
          <div class="body_editor">
            <a href="download.php?url=http://example.com/img.jpg">
              <img src="http://example.com/img.jpg" img_file_url="http://example.com/img.jpg" class="img_compress" />
            </a>
          </div>
          </body></html>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scanFull(doc, container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(1));
      });
    });

    group('daum-wm-content layout (no body_editor)', () {
      test('should extract both image and text from wrap_copy container', () {
        final doc = html_parser.parse('''
          <div class="daum-wm-content">
            <wrap_copy id="wrap_copy">
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr><td align="center">
                  <div id="comment_file_file_2856297_141796028">
                    <div class="comment_img_div">
                      <img src="//timg.humoruniv.com/thumb.php?url=http://down.humoruniv.com/hwiparambbs/data/pds/test.jpg?SIZE=800x1066"
                           img_file_url="//down.humoruniv.com/hwiparambbs/data/pds/test.jpg"
                           class="img_compress" />
                    </div>
                  </div>
                </td></tr>
              </table>
              <p class="content_body_padding">
                웃긴자료 게시글 본문 텍스트입니다.
              </p>
            </wrap_copy>
          </div>
        ''');
        final container = doc.querySelector('.daum-wm-content')!;

        final result = ContentScanner.scan(container);

        final images = result.blocks.whereType<ImageBlock>().toList();
        final texts = result.blocks.whereType<TextBlock>().toList();
        expect(images, hasLength(1));
        expect(texts, isNotEmpty);
        expect(texts.any((t) => t.text.contains('본문 텍스트')), isTrue);
      });

      test('should preserve image-before-text order in daum-wm-content', () {
        final doc = html_parser.parse('''
          <div class="daum-wm-content">
            <wrap_copy id="wrap_copy">
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr><td align="center">
                  <div class="comment_img_div">
                    <img src="http://example.com/img.jpg"
                         img_file_url="http://example.com/img.jpg"
                         class="img_compress" />
                  </div>
                </td></tr>
              </table>
              <p class="content_body_padding">이미지 다음 텍스트</p>
            </wrap_copy>
          </div>
        ''');
        final container = doc.querySelector('.daum-wm-content')!;

        final result = ContentScanner.scan(container);

        final imgIdx = result.blocks.indexWhere((b) => b is ImageBlock);
        final textIdx = result.blocks.indexWhere(
          (b) => b is TextBlock && b.text.contains('이미지 다음'),
        );
        expect(imgIdx, lessThan(textIdx));
      });
    });

    group('NSFW detection', () {
      test('should mark image inside racy_hidden as isNsfw true', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <div class="simple_attach_img_div">
              <div id="racy_show_6475_123" style="text-align:center;">
                <a href="javascript:show_hidden_img('6475_123');">
                  <img src="/images/ai/ansim_man_hupago.gif?tmp=4" width="240">
                </a>
              </div>
              <div id="racy_hidden_6475_123" style="display:none;text-align:center;">
                <img src="http://example.com/nsfw.jpg"
                     img_file_url="http://example.com/nsfw.jpg"
                     class="img_compress" />
              </div>
            </div>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(1));
        expect(imgs.first.isNsfw, isTrue);
        expect(result.hasNsfw, isTrue);
      });

      test('should skip racy_show div contents entirely', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <div class="simple_attach_img_div">
              <div id="racy_show_6475_123" style="text-align:center;">
                <img src="http://example.com/warning.jpg" />
                <div>이미지를 표시하려면 초기화를 클릭하세요.</div>
              </div>
              <div id="racy_hidden_6475_123" style="display:none;text-align:center;">
                <img src="http://example.com/nsfw.jpg"
                     img_file_url="http://example.com/nsfw.jpg"
                     class="img_compress" />
              </div>
            </div>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(1));
        expect(imgs.first.url, 'http://example.com/nsfw.jpg');
      });

      test('should leave normal image as isNsfw false', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <img src="http://example.com/safe.jpg"
                 img_file_url="http://example.com/safe.jpg"
                 class="img_compress" />
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(1));
        expect(imgs.first.isNsfw, isFalse);
        expect(result.hasNsfw, isFalse);
      });

      test('should mark video inside racy_hidden as isNsfw true', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <div id="racy_hidden_100_200" style="display:none;">
              <a href="download.php?url=http://example.com/nsfw.mp4">
                <img src="http://example.com/nsfw_thumb.jpg" />
              </a>
            </div>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final videos = result.blocks.whereType<VideoBlock>().toList();
        expect(videos, hasLength(1));
        expect(videos.first.isNsfw, isTrue);
        expect(result.hasNsfw, isTrue);
      });

      test('should handle mixed NSFW and safe images', () {
        final doc = html_parser.parse('''
          <div class="body_editor">
            <img src="http://example.com/safe.jpg"
                 img_file_url="http://example.com/safe.jpg"
                 class="img_compress" />
            <div id="racy_hidden_1_2" style="display:none;">
              <img src="http://example.com/nsfw.jpg"
                   img_file_url="http://example.com/nsfw.jpg"
                   class="img_compress" />
            </div>
          </div>
        ''');
        final container = doc.querySelector('.body_editor')!;

        final result = ContentScanner.scan(container);

        final imgs = result.blocks.whereType<ImageBlock>().toList();
        expect(imgs, hasLength(2));
        expect(imgs[0].isNsfw, isFalse);
        expect(imgs[1].isNsfw, isTrue);
        expect(result.hasNsfw, isTrue);
      });
    });
  });
}
