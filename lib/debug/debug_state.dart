import 'package:flutter/foundation.dart';

/// Global debug state for development tools
class DebugState {
  /// Force unlock all content regardless of progress or availability
  static final ValueNotifier<bool> forceUnlockContent = ValueNotifier(false);
}
