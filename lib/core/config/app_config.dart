/// App-wide configuration. Replace with a proper environment setup (T007)
/// when a real backend is available.
class AppConfig {
  AppConfig._();

  /// Base URL for the auth/API backend.
  static const String apiBaseUrl = 'https://api.example.com';

  /// When true, auth calls are simulated locally (no backend needed) so the
  /// app is demoable end-to-end. Set to `false` once [apiBaseUrl] points at a
  /// real API — the real network path in AuthRemoteDataSource then takes over.
  static const bool useMockAuth = true;
}
