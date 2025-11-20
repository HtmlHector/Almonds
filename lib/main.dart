import 'package:almonds/features/community/domain/viewmodel/community_viewmodel.dart';
import 'package:almonds/features/community/presentation/screens/community_screen.dart';
import 'package:almonds/features/product_information/domain/description_viewmodel.dart';
import 'package:almonds/features/product_information/presentation/screens/product_information_screen.dart';
import 'package:almonds/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:almonds/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/api/keys.dart';
import 'core/api/urls.dart';
import 'core/theme/theme.dart';
import 'features/community/presentation/screens/user_profile_screen.dart';
import 'features/home/domain/home_viewmodel.dart';
import 'features/home/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseApiUrl, anonKey: supabaseApiKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => DescriptionViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityViewModel(),
        ),
      ],
      child: const MyApp(), // MaterialApp moved inside MyApp
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: HomeScreen(),
    );
  }
}
