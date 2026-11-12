/// Build-time configuration. Override with `--dart-define`, e.g.
/// `flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=...`
///
/// The defaults point at the local Supabase stack (`supabase start`), so no
/// secrets live in the repository.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
  );

  static const offBaseUrl = 'https://world.openfoodfacts.org/api/v2/product';
}
