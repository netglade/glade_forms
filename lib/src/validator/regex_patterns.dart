class RegexPatterns {
  static const email = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const urlWithOptionalHttp = r'^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&\(\)\*\+,;=.]+$';
  static const urlWithHttp =
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
}
