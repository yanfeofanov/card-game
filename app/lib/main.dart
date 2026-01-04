import 'package:card_game/screens/battle_screen.dart';
import 'package:card_game/screens/collection_screen.dart';
import 'package:card_game/screens/home_screen.dart';
import 'package:card_game/screens/profile_screen.dart';
import 'package:card_game/screens/shop_screen.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Запускаем приложение...');

  try {
    // Инициализируем Supabase
    print('🔧 Инициализируем Supabase...');
    await SupabaseService().initialize();
    print('✅ Supabase инициализирован успешно!');
  } catch (e) {
    print('❌ Ошибка инициализации Supabase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameState()),
        Provider(create: (context) => SupabaseService()),
      ],
      child: const CardGameApp(),
    ),
  );
}

class CardGameApp extends StatelessWidget {
  const CardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/collection': (context) => const CollectionScreen(),
        '/battle': (context) => const BattleScreen(),
        '/shop': (context) => const ShopScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
