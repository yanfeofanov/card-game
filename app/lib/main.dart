import 'package:card_game/screens/battle_screen.dart';
import 'package:card_game/screens/collection_screen.dart';
import 'package:card_game/screens/home_screen.dart';
import 'package:card_game/screens/profile_screen.dart';
import 'package:card_game/screens/shop_screen.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart';

// Глобальный ключ для навигации (для возможности навигации из любых мест)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Устанавливаем системную панель навигации в темный режим
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF0F0F23),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  print('🚀 Запускаем приложение...');

  try {
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
      title: 'Strange Battle',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      darkTheme:
          _buildDarkTheme(), // Для единообразия используем темную тему везде
      home: FutureBuilder(
        future: _loadUserStats(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }

  // Создаем современную темную тему
  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    return baseTheme.copyWith(
      // Генерируем ColorScheme из базового цвета
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C4FF2), // Основной фиолетовый
        brightness: Brightness.dark,
        // Переопределяем конкретные цвета при необходимости
        primary: const Color(0xFF6C4FF2),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFF4A32A8),
        onPrimaryContainer: Colors.white,
        secondary: const Color(0xFF00D4AA),
        onSecondary: Colors.black,
        secondaryContainer: const Color(0xFF007A60),
        onSecondaryContainer: Colors.white,
        tertiary: const Color(0xFFFF6B6B),
        onTertiary: Colors.white,
        surface: const Color(0xFF1A1A2E),
        onSurface: Colors.white,
        surfaceVariant: const Color(0xFF2D2D3D),
        onSurfaceVariant: const Color(0xFFB0B0C0),
        background: const Color(0xFF0F0F23),
        onBackground: Colors.white,
        error: const Color(0xFFFF6B6B),
        onError: Colors.white,
        outline: const Color(0xFF3A3A4A),
        outlineVariant: const Color(0xFF2D2D3D),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A2E),
        selectedItemColor: Color(0xFF6C4FF2),
        unselectedItemColor: Colors.grey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Карточки
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E2E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C4FF2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6C4FF2),
          side: const BorderSide(color: Color(0xFF6C4FF2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6C4FF2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Поля ввода
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D3D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6C4FF2), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Диалоги
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E2E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),

      // Разделители
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D2D3D),
        thickness: 1,
        space: 16,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Color(0xFF1E1E2E),
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: Color(0xFF6C4FF2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Прогресс индикатор
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF6C4FF2),
        linearTrackColor: Color(0xFF2D2D3D),
      ),

      // Иконки
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),

      // Текст
      textTheme: TextTheme(
        // Заголовки
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        // Заголовки для дисплея
        displayLarge: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        // Заголовки
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),

        // Основной текст
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.9),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.7),
        ),

        // Подписи
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          color: Colors.white54,
        ),
      ),
    );
  }

  Future<void> _loadUserStats(BuildContext context) async {
    try {
      final gameState = context.read<GameState>();
      final supabaseService = context.read<SupabaseService>();

      print('📊 Загружаем статистику пользователя...');
      final stats = await supabaseService.getUserStats(gameState.userId);

      gameState.setTotalExp(
        stats['total_exp'] as int,
        stats['level'] as int,
      );

      // Также обновляем золото и алмазы из БД
      gameState.addGold((stats['gold'] as int) - gameState.gold);
      gameState.addGems((stats['gems'] as int) - gameState.gems);

      print(
        '✅ Статистика загружена: уровень ${stats['level']}, опыт ${stats['total_exp']}',
      );
    } catch (e) {
      print('⚠️ Не удалось загрузить статистику: $e');
    }
  }
}

// Простой экран загрузки
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Загрузка...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
