import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _userCardsKey = 'cached_user_cards';
  static const String _lastSyncKey = 'last_sync_time';
  static const int _cacheDurationHours = 1; // Кэш на 1 час

  // In-memory кэш
  List<CardModel>? _memoryCache;
  DateTime? _lastMemoryCacheTime;

  Future<void> _saveToFileAsync(int userId, List<CardModel> cards) async {
    // Используем compute для записи в файл в отдельном изоляте
    await compute(_saveToFileIsolate, {
      'userId': userId,
      'cards': cards.map((c) => c.toJson()).toList(),
    });
  }

  static Future<void> _saveToFileIsolate(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'] as int;
      final cardsJson = data['cards'] as List;

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_${userId}_cards_cache.json');

      final jsonData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'cards': cardsJson,
      };

      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('❌ Ошибка сохранения в файл в изоляте: $e');
    }
  }

  // Получить кэшированные карты пользователя
  Future<List<CardModel>> getUserCards(int userId,
      {bool forceRefresh = false}) async {
    // 1. Проверяем in-memory кэш (самый быстрый)
    if (!forceRefresh &&
        _memoryCache != null &&
        _lastMemoryCacheTime != null &&
        DateTime.now().difference(_lastMemoryCacheTime!).inMinutes < 5) {
      print('🎯 Используем in-memory кэш (${_memoryCache!.length} карт)');
      return List.from(_memoryCache!);
    }

    // 2. Проверяем время последней синхронизации
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey);

    if (!forceRefresh &&
        lastSync != null &&
        DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(lastSync))
                .inHours <
            _cacheDurationHours) {
      // 3. Пробуем загрузить из файла
      try {
        final fileCache = await _loadFromFile(userId);
        if (fileCache.isNotEmpty) {
          print('📁 Используем файловый кэш (${fileCache.length} карт)');
          _updateMemoryCache(fileCache);
          return fileCache;
        }
      } catch (e) {
        print('⚠️ Ошибка загрузки из файла: $e');
      }
    }

    // 4. Если кэша нет или он устарел, возвращаем пустой список
    // (фактическую загрузку выполнит вызывающий код)
    print('🔄 Кэш отсутствует или устарел');
    return [];
  }

  // Сохранить карты в кэш
  Future<void> saveUserCards(int userId, List<CardModel> cards) async {
    print('💾 Сохраняем ${cards.length} карт в кэш');

    // 1. Обновляем in-memory кэш (синхронно)
    _updateMemoryCache(cards);

    // 2. Сохраняем в SharedPreferences (синхронно)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

    // 3. Сохраняем в файл асинхронно в фоне
    Future.microtask(() async {
      try {
        await _saveToFileAsync(userId, cards);
        print('✅ Кэш сохранен в файл');
      } catch (e) {
        print('⚠️ Фоновое сохранение кэша завершилось с ошибкой: $e');
      }
    });
  }

  // Очистить кэш
  Future<void> clearCache(int userId) async {
    print('🧹 Очищаем кэш');

    // Очищаем in-memory кэш
    _memoryCache = null;
    _lastMemoryCacheTime = null;

    // Удаляем файл кэша
    await _deleteFile(userId);

    // Удаляем метку времени
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
  }

  // Проверить, есть ли актуальный кэш
  Future<bool> hasValidCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey);

    if (lastSync == null) return false;

    final duration = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastSync))
        .inHours;

    return duration < _cacheDurationHours;
  }

  // Получить только ID карт для быстрой проверки
  Future<List<int>> getCachedCardIds(int userId) async {
    try {
      final cards = await getUserCards(userId);
      return cards.map((card) => card.id).toList();
    } catch (e) {
      return [];
    }
  }

  // Приватные методы
  void _updateMemoryCache(List<CardModel> cards) {
    _memoryCache = List.from(cards);
    _lastMemoryCacheTime = DateTime.now();
  }

  Future<void> _saveToFile(int userId, List<CardModel> cards) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_${userId}_cards_cache.json');

      final data = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'cards': cards.map((card) => card.toJson()).toList(),
      };

      await file.writeAsString(jsonEncode(data));
      print('✅ Кэш сохранен в файл: ${file.path}');
    } catch (e) {
      print('❌ Ошибка сохранения в файл: $e');
    }
  }

  Future<List<CardModel>> _loadFromFile(int userId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_${userId}_cards_cache.json');

      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Проверяем, не устарел ли файловый кэш
      final timestamp = data['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime).inHours > _cacheDurationHours) {
        await file.delete(); // Удаляем устаревший файл
        return [];
      }

      final cardsJson = data['cards'] as List;
      final cards = cardsJson.map((json) => CardModel.fromJson(json)).toList();

      return cards;
    } catch (e) {
      print('❌ Ошибка загрузки из файла: $e');
      return [];
    }
  }

  Future<void> _deleteFile(int userId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_${userId}_cards_cache.json');

      if (await file.exists()) {
        await file.delete();
        print('🗑️ Файл кэша удален');
      }
    } catch (e) {
      print('❌ Ошибка удаления файла: $e');
    }
  }
}
