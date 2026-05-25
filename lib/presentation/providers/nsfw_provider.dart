import 'package:flutter_riverpod/flutter_riverpod.dart';

final nsfwProvider = StateNotifierProvider<NsfwNotifier, bool>(
  (ref) => NsfwNotifier(),
);

class NsfwNotifier extends StateNotifier<bool> {
  NsfwNotifier() : super(true);

  void toggle() => state = !state;
  void setEnabled(bool enabled) => state = enabled;
}
