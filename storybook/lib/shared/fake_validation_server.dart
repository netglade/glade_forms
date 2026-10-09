/// Simulates a backend used by async validation examples.
class FakeValidationServer {
  final Set<String> takenUsernames = {'admin', 'glade', 'petr'};

  /// Allowed email domain per organisation.
  final Map<String, String> organisationDomains = {'acme': 'acme.com', 'netglade': 'netglade.cz'};

  Duration delay;
  bool isFailing;

  int requestCount = 0;

  FakeValidationServer({this.delay = const Duration(milliseconds: 800), this.isFailing = false});

  Future<bool> isUsernameAvailable(String username) async {
    requestCount++;

    // Simulates network round trip.
    await Future<void>.delayed(delay);

    if (isFailing) throw Exception('Server unavailable');

    return !takenUsernames.contains(username.trim().toLowerCase());
  }

  Future<bool> isEmailAllowedInOrganisation(String email, String organisation) async {
    requestCount++;

    // Simulates network round trip.
    await Future<void>.delayed(delay);

    if (isFailing) throw Exception('Server unavailable');

    final domain = organisationDomains[organisation];

    return domain == null || email.trim().toLowerCase().endsWith('@$domain');
  }
}
