import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/community_repository.dart';
import 'data/repositories/diet_repository.dart';
import 'data/repositories/history_repository.dart';
import 'data/services/additive_catalog.dart';
import 'data/services/open_food_facts_client.dart';
import 'data/services/product_service.dart';
import 'data/services/scoring_engine.dart';
import 'features/auth/auth_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';
import 'state/auth_controller.dart';
import 'state/community_controller.dart';
import 'state/diet_controller.dart';
import 'state/history_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  final catalog = await AdditiveCatalog.load();

  runApp(AlmondsApp(catalog: catalog, client: Supabase.instance.client));
}

class AlmondsApp extends StatelessWidget {
  const AlmondsApp({super.key, required this.catalog, required this.client});

  final AdditiveCatalog catalog;
  final SupabaseClient client;

  @override
  Widget build(BuildContext context) {
    final communityRepo = CommunityRepository(client);
    return MultiProvider(
      providers: [
        Provider(create: (_) => OpenFoodFactsClient()),
        Provider(create: (_) => ScoringEngine(catalog)),
        ProxyProvider2<OpenFoodFactsClient, ScoringEngine, ProductService>(
          update: (_, client, engine, _) =>
              ProductService(client: client, engine: engine),
        ),
        Provider.value(value: communityRepo),
        ChangeNotifierProvider(
          create: (_) => AuthController(AuthRepository(client)),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryController(HistoryRepository(client)),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityController(communityRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => DietController(DietRepository(client)),
        ),
      ],
      child: CupertinoApp(
        title: 'Almonds',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _Root(),
      ),
    );
  }
}

/// Shows the auth screen or the app, and wipes cached data on sign-out so
/// one user never sees another's history.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool? _wasSignedIn;

  @override
  Widget build(BuildContext context) {
    final signedIn = context.select<AuthController, bool>((a) => a.signedIn);
    if (_wasSignedIn == true && !signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<HistoryController>().clear();
        context.read<CommunityController>().clear();
        context.read<DietController>().clear();
      });
    }
    _wasSignedIn = signedIn;
    return signedIn ? const MainShell() : const AuthScreen();
  }
}

/// Shows onboarding once, then hands over to the auth gate.
class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  static const _key = 'onboarding_done_v1';
  bool? _seen;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var seen = false;
    try {
      seen = (await SharedPreferences.getInstance()).getBool(_key) ?? false;
    } catch (_) {
      /* treat as first launch */
    }
    if (mounted) setState(() => _seen = seen);
  }

  Future<void> _finish() async {
    setState(() => _seen = true);
    try {
      await (await SharedPreferences.getInstance()).setBool(_key, true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_seen == null) {
      // Brief blank frame while preferences load.
      return const CupertinoPageScaffold(child: SizedBox.shrink());
    }
    return _seen! ? const _AuthGate() : OnboardingScreen(onDone: _finish);
  }
}
