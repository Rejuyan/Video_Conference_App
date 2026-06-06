import 'dart:math';

class MeetingCodeGenerator {
  static const _chars = 'abcdefghijklmnopqrstuvwxyz';
  static final _random = Random();

  /// Generates a randomized, hyphenated meeting ID in the format: vmt-xxx-xxx
  static String generate() {
    String segment1 = _getRandomString(3);
    String segment2 = _getRandomString(3);
    return 'vmt-$segment1-$segment2';
  }

  static String _getRandomString(int length) {
    return List.generate(length, (index) {
      return _chars[_random.nextInt(_chars.length)];
    }).join();
  }

  /// Validates if the meeting ID matches the vmt-xxx-xxx format (or simply has length > 5)
  static bool isValid(String code) {
    final cleaned = code.trim().toLowerCase();
    // Support either clean "vmt-xxx-xxx" or "xxx-xxx" or plain code formats
    final regex = RegExp(r'^(vmt-)?[a-z]{3}-[a-z]{3}$');
    return regex.hasMatch(cleaned) || cleaned.length >= 6;
  }

  /// Standardizes code: pads it with "vmt-" if the user only typed the 6-letter room code
  static String standardize(String code) {
    final cleaned = code.trim().toLowerCase().replaceAll(' ', '');
    if (cleaned.startsWith('vmt-')) {
      return cleaned;
    }
    if (RegExp(r'^[a-z]{3}-[a-z]{3}$').hasMatch(cleaned)) {
      return 'vmt-$cleaned';
    }
    return cleaned;
  }
}
