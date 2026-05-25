import 'package:flutter/material.dart';

class NsfwWarningDialog extends StatelessWidget {
  final VoidCallback onAcknowledge;

  const NsfwWarningDialog({super.key, required this.onAcknowledge});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAcknowledge,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          NsfwWarningDialog(onAcknowledge: onAcknowledge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('콘텐츠 경고'),
      content: const Text(
        '이 앱은 웃긴자료 커뮤니티의 콘텐츠를 보여줍니다.\n'
        '일부 게시물에 성인 콘텐츠가 포함될 수 있습니다.\n\n'
        '계속하시겠습니까?',
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onAcknowledge();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
