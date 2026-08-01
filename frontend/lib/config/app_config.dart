/// Central place for environment configuration.
///
/// [predictionApiBaseUrl] points at the deployed Gemini-powered
/// prediction backend. Update this (or the specific endpoint paths in
/// `PredictionApiService`) if your backend's routes/response shape
/// differ from what is assumed here.
class AppConfig {
  AppConfig._();

  static const String predictionApiBaseUrl =
      'https://gemini-jy64.onrender.com';

  /// Render.com free-tier services spin down when idle, so the first
  /// request after inactivity can take 30-60s to "wake up". We use a
  /// generous timeout and show a friendly "waking up the AI model..."
  /// message in the UI while waiting.
  static const Duration predictionTimeout = Duration(seconds: 90);
}
