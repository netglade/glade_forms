abstract class RegexPatterns {
  /// Email regex pattern.
  static const email = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  /// URL with optional HTTP(S) scheme.
  static const urlWithOptionalHttp = r'^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&\(\)\*\+,;=.]+$';

  /// URL with HTTP(S) scheme.
  static const urlWithHttp =
      r'[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';
}
