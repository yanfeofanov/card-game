import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static final Logger _logger = Logger();
  late SupabaseClient _client;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      // Загружаем .env файл из assets
      await dotenv.load(fileName: "assets/.env");

      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      _logger.i('Initializing Supabase with URL: $url');

      if (url == null || anonKey == null) {
        throw Exception('Supabase credentials not found in .env file');
      }

      // Инициализируем Supabase
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        //   authCallbackUrlHostname: 'login-callback',
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      _logger.i('✅ Supabase initialized successfully');
      _logger.i('📊 Project URL: $url');
    } catch (e, stack) {
      _logger.e('❌ Failed to initialize Supabase', error: e, stackTrace: stack);
      rethrow;
    }
  }

  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Получить все карты
  Future<List<Map<String, dynamic>>> getAllCards() async {
    try {
      _logger.d('Fetching all cards from Supabase...');
      final response =
          await _client.from('cards').select().order('id', ascending: true);

      _logger.i('✅ Successfully fetched ${response.length} cards');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      _logger.e('❌ Error fetching cards', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // Получить карту по ID
  Future<Map<String, dynamic>> getCardById(int id) async {
    try {
      final response =
          await _client.from('cards').select().eq('id', id).single();
      return response as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error getting card $id: $e');
      rethrow;
    }
  }

  // Добавить новую карту
  Future<Map<String, dynamic>> addCard(Map<String, dynamic> cardData) async {
    try {
      final response =
          await _client.from('cards').insert(cardData).select().single();

      _logger.i('✅ Card added successfully: ${response['name']}');
      return response as Map<String, dynamic>;
    } catch (e, stack) {
      _logger.e('❌ Error adding card', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // Обновить карту
  Future<void> updateCard(int id, Map<String, dynamic> updates) async {
    try {
      await _client.from('cards').update(updates).eq('id', id);

      _logger.i('✅ Card $id updated successfully');
    } catch (e, stack) {
      _logger.e('❌ Error updating card $id', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // Удалить карту
  Future<void> deleteCard(int id) async {
    try {
      await _client.from('cards').delete().eq('id', id);

      _logger.i('✅ Card $id deleted successfully');
    } catch (e, stack) {
      _logger.e('❌ Error deleting card $id', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // Подписка на изменения в реальном времени
  RealtimeChannel getCardsRealtimeChannel() {
    return _client
        .channel('cards-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'cards',
          callback: (payload) {
            _logger.d('🔄 Real-time update: $payload');
            // Здесь можно обработать изменения
          },
        )
        .subscribe();
  }
}
