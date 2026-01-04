import 'package:card_game/models/card.dart';
import 'package:card_game/models/pack_purchase.dart';
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
      print('🔄 SupabaseService.initialize() вызван');

      if (_isInitialized) {
        print('✅ Supabase уже инициализирован');
        return;
      }

      print('📁 Загружаем .env файл...');
      await dotenv.load(fileName: "assets/.env");

      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      print('🔗 URL: $url');
      print('🔑 ANON KEY присутствует: ${anonKey != null}');

      if (url == null || anonKey == null) {
        print('❌ Не найдены учетные данные в .env файле');
        throw Exception('Supabase credentials not found in .env file');
      }

      print('🔧 Вызываем Supabase.initialize()...');

      // Инициализируем Supabase
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        //authCallbackUrlHostname: 'login-callback',
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      print('✅ Supabase успешно инициализирован!');
      print('📊 Client: ${_client.runtimeType}');
    } catch (e, stack) {
      print('❌ ОШИБКА при инициализации Supabase:');
      print('❌ Тип: ${e.runtimeType}');
      print('❌ Сообщение: $e');
      print('❌ Stack trace: $stack');
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
      _logger.d('🔍 Начинаю загрузку карт из Supabase...');

      // Проверяем, инициализирован ли клиент
      if (!_isInitialized) {
        throw Exception('Supabase не инициализирован!');
      }

      _logger.d('✅ Клиент инициализирован, делаем запрос...');

      // Делаем простой запрос для тестирования
      final testQuery = await _client.from('cards').select('count').single();

      _logger.d('📊 Количество карт в базе: $testQuery');

      // Теперь получаем все карты
      final response =
          await _client.from('cards').select().order('id', ascending: true);

      _logger.d('📦 Тип ответа: ${response.runtimeType}');
      _logger.d('📦 Длина ответа: ${response.length}');

      if (response.isNotEmpty) {
        _logger.d('📦 Первая карта в ответе:');
        _logger.d('  ID: ${response[0]['id']}');
        _logger.d('  Имя: ${response[0]['name']}');
        _logger.d('  Тип: ${response[0]['type']}');
        _logger.d('  Редкость: ${response[0]['rarity']}');
      } else {
        _logger.w('⚠️ Ответ пустой!');
      }

      // Преобразуем в правильный формат
      final List<Map<String, dynamic>> result = [];
      for (var item in response) {
        result.add(Map<String, dynamic>.from(item));
      }

      _logger.i('✅ Успешно загружено ${result.length} карт');
      return result;
    } catch (e, stack) {
      _logger.e('❌ Ошибка при загрузке карт');
      _logger.e('❌ Тип ошибки: ${e.runtimeType}');
      _logger.e('❌ Сообщение: $e');
      _logger.e('❌ Stack trace: $stack');

      // Проверяем, может быть проблема с авторизацией
      try {
        final authState = _client.auth.currentSession;
        _logger.d('🔐 Текущая сессия: $authState');
      } catch (authError) {
        _logger.e('🔐 Ошибка при проверке авторизации: $authError');
      }

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

  // Генерация случайных карт для набора
  Future<List<CardModel>> _generateRandomCards(String packType) async {
    try {
      // Получаем все карты из базы
      final allCards = await getAllCards();
      final List<CardModel> allCardModels =
          allCards.map((json) => CardModel.fromJson(json)).toList();

      // Фильтруем по редкости в зависимости от типа набора
      List<CardModel> filteredCards;

      switch (packType) {
        case 'Стартовый набор':
          // 3 случайные карты любой редкости
          filteredCards = allCardModels;
          break;
        case 'Набор новичка':
          // 5 карт, минимум 1 редкая
          final rareCards = allCardModels
              .where((card) => card.rarity.index >= Rarity.rare.index)
              .toList();
          final commonCards = allCardModels
              .where((card) => card.rarity == Rarity.common)
              .toList();

          // Смешиваем
          filteredCards = [...rareCards, ...commonCards];
          break;
        case 'Эпический набор':
          // 10 карт, гарантированная эпическая
          final epicCards = allCardModels
              .where((card) => card.rarity.index >= Rarity.epic.index)
              .toList();
          filteredCards = epicCards;
          break;
        case 'Легендарный набор':
          // 15 карт, шанс на легендарную
          final legendaryCards = allCardModels
              .where((card) => card.rarity == Rarity.legendary)
              .toList();
          final otherCards = allCardModels
              .where((card) => card.rarity != Rarity.legendary)
              .toList();
          filteredCards = [...legendaryCards, ...otherCards];
          break;
        default:
          filteredCards = allCardModels;
      }

      // Перемешиваем карты
      filteredCards.shuffle();

      // Выбираем нужное количество
      final int count = packType == 'Стартовый набор'
          ? 3
          : packType == 'Набор новичка'
              ? 5
              : packType == 'Эпический набор'
                  ? 10
                  : 15;

      return filteredCards.take(count).toList();
    } catch (e, stack) {
      _logger.e('❌ Error generating random cards', error: e, stackTrace: stack);
      rethrow;
    }
  }

// Покупка набора
  Future<PackPurchase> purchasePack(String packName, int userId) async {
    try {
      _logger.d('Purchasing pack: $packName for user: $userId');

      // Определяем стоимость
      int costGold = 0;
      int costGems = 0;
      switch (packName) {
        case 'Стартовый набор':
          costGold = 0;
          break;
        case 'Набор новичка':
          costGold = 100;
          break;
        case 'Эпический набор':
          costGems = 50;
          break;
        case 'Легендарный набор':
          costGems = 100;
          break;
      }

      // Генерируем случайные карты
      final cards = await _generateRandomCards(packName);

      // Создаем запись о покупке
      final purchaseData = {
        'user_id': userId,
        'pack_name': packName,
        'cost_gold': costGold,
        'cost_gems': costGems,
        'purchase_date': DateTime.now().toIso8601String(),
      };

      // Сохраняем покупку
      final response = await _client
          .from('purchases')
          .insert(purchaseData)
          .select()
          .single();

      final purchaseId = response['id'] as int;

      // Добавляем карты пользователю
      final List<int> successfullyAddedCards = [];
      for (final card in cards) {
        try {
          // Проверяем, есть ли уже такая карта - ПРАВИЛЬНЫЙ ВАРИАНТ
          Map<String, dynamic>? existingCard;
          try {
            existingCard = await _client
                .from('user_cards')
                .select()
                .eq('user_id', userId)
                .eq('card_id', card.id)
                .eq('level', 1)
                .single() as Map<String, dynamic>;
          } catch (e) {
            // Если карта не найдена, это нормально - existingCard останется null
            _logger.d(
                'Card ${card.id} not found for user $userId, will create new');
          }

          if (existingCard != null) {
            // Увеличиваем количество существующей карты
            final currentCount = existingCard['count'] as int? ?? 1;
            await _client
                .from('user_cards')
                .update({'count': currentCount + 1}).eq(
                    'id', existingCard['id'] as int);
            _logger.d(
                'Incremented count for card ${card.id} to ${currentCount + 1}');
          } else {
            // Добавляем новую карту
            await _client.from('user_cards').insert({
              'user_id': userId,
              'card_id': card.id,
              'level': 1,
              'count': 1,
              'type': card.type.toString().split('.').last,
              'rarity': card.rarity.toString().split('.').last,
              'attack': card.attack,
              'health': card.health,
            });
            _logger.d('Created new card ${card.id} for user $userId');
          }
          successfullyAddedCards.add(card.id);
        } catch (e) {
          _logger.w('Failed to add card ${card.id} to user $userId: $e');
          // Продолжаем добавлять другие карты
        }
      }

      _logger.i('✅ Pack purchased successfully: $packName');
      _logger
          .i('✅ Added ${successfullyAddedCards.length} cards to user $userId');

      // Возвращаем только успешно добавленные карты
      final successfulCards = cards
          .where((card) => successfullyAddedCards.contains(card.id))
          .toList();

      return PackPurchase(
        id: purchaseId,
        packName: packName,
        cards: successfulCards,
        costGold: costGold,
        costGems: costGems,
        purchaseDate: DateTime.now(),
      );
    } catch (e, stack) {
      _logger.e('❌ Error purchasing pack', error: e, stackTrace: stack);
      rethrow;
    }
  }

// Добавить карты пользователю
  Future<void> addCardsToUser(int userId, List<int> cardIds) async {
    try {
      for (final cardId in cardIds) {
        // Проверяем, есть ли уже такая карта
        final existingCards = await _client
            .from('user_cards')
            .select()
            .eq('user_id', userId)
            .eq('card_id', cardId);

        if (existingCards.isEmpty) {
          await _client.from('user_cards').insert({
            'user_id': userId,
            'card_id': cardId,
            'level': 1,
          });
        } else {
          // Добавляем ещё одну копию карты
          await _client.from('user_cards').insert({
            'user_id': userId,
            'card_id': cardId,
            'level': 1,
          });
        }
      }

      _logger.i('✅ Cards added to user: $cardIds');
    } catch (e, stack) {
      _logger.e('❌ Error adding cards to user', error: e, stackTrace: stack);
      rethrow;
    }
  }

// Получить историю покупок пользователя
  Future<List<PackPurchase>> getUserPurchases(int userId) async {
    try {
      final response = await _client
          .from('purchases')
          .select(
              '*, user_cards!inner(card_id, card:cards(*))') // Исправляем запрос
          .eq('user_id', userId)
          .order('purchase_date', ascending: false);

      // Преобразуем данные в модели
      final List<PackPurchase> purchases = [];

      for (var purchaseJson in response) {
        // Получаем карты из связанной таблицы
        final userCardsData = purchaseJson['user_cards'] as List? ?? [];
        final List<CardModel> cards = [];

        for (var userCard in userCardsData) {
          final cardJson = userCard['card'] as Map<String, dynamic>;
          cards.add(CardModel.fromJson(cardJson));
        }

        purchases.add(PackPurchase(
          id: purchaseJson['id'] as int,
          packName: purchaseJson['pack_name'] as String,
          cards: cards,
          costGold: purchaseJson['cost_gold'] ?? 0,
          costGems: purchaseJson['cost_gems'] ?? 0,
          purchaseDate: DateTime.parse(purchaseJson['purchase_date']),
        ));
      }

      return purchases;
    } catch (e) {
      _logger.e('Error getting user purchases: $e');
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

  // // Добавить карты пользователю
  // Future<void> addCardsToUser(int userId, List<int> cardIds) async {
  //   try {
  //     for (final cardId in cardIds) {
  //       await _client.from('user_cards').insert({
  //         'user_id': userId,
  //         'card_id': cardId,
  //       });
  //     }
  //     _logger.i('✅ Cards added to user: $cardIds');
  //   } catch (e, stack) {
  //     _logger.e('❌ Error adding cards to user', error: e, stackTrace: stack);
  //     rethrow;
  //   }
  // }

// // Получить карты пользователя
//   Future<List<CardModel>> getUserCards(int userId) async {
//     try {
//       _logger.d('Fetching cards for user: $userId');

//       final response = await _client.from('user_cards').select('''
//           card:cards(*)
//         ''').eq('user_id', userId);

//       final cards = response
//           .map((item) =>
//               CardModel.fromJson(item['card'] as Map<String, dynamic>))
//           .toList();

//       _logger.i('✅ Found ${cards.length} cards for user $userId');
//       return cards;
//     } catch (e, stack) {
//       _logger.e('❌ Error fetching user cards', error: e, stackTrace: stack);
//       rethrow;
//     }
//   }

  // Проверка возможности объединения карт
  Future<bool> canMergeCards(
      int userId, int cardId, CardType cardType, int level) async {
    try {
      _logger.d(
          '🔍 Checking merge possibility for card $cardId, type: $cardType, level: $level');

      // Получаем все записи карт этого типа и уровня
      final response = await _client
          .from('user_cards')
          .select()
          .eq('user_id', userId)
          .eq('card_id', cardId)
          .eq('type', cardType.toString().split('.').last)
          .eq('level', level);

      // Суммируем поле count из всех записей
      int totalCount = 0;
      for (var card in response) {
        final count = card['count'] as int? ?? 1;
        totalCount += count;
      }

      _logger.d(
          '📊 Found $totalCount cards of type $cardType level $level (need 3)');

      _logger.d(
          '📊 Records found: ${response.length} with counts: ${response.map((c) => c['count']).toList()}');

      return totalCount >= 3;
    } catch (e, stack) {
      _logger.e('❌ Error checking merge possibility',
          error: e, stackTrace: stack);
      return false;
    }
  }

// Объединение карт
  Future<CardModel?> mergeCards(int userId, int baseCardId,
      CardType currentType, int currentLevel) async {
    try {
      _logger.d(
          '🔄 Starting merge for card $baseCardId, type: $currentType, level: $currentLevel');

      // Получаем базовую карту из базы
      final cardData = await getCardById(baseCardId);
      final baseCard = CardModel.fromJson(cardData);

      // Определяем следующий уровень
      final nextLevel = currentLevel + 1;

      // Определяем новый тип и редкость
      final CardType nextType;
      final Rarity nextRarity;

      if (currentLevel % 3 == 0 && baseCard.rarity != Rarity.legendary) {
        // Каждый 3-й уровень - повышение типа
        nextType = baseCard.nextUpgradedType;
        nextRarity = _getRarityByType(nextType);
        _logger.d(
            '🎯 Level upgrade: New type will be $nextType, rarity: $nextRarity');
      } else {
        // Просто улучшение характеристик
        nextType = currentType;
        nextRarity = baseCard.rarity;
        _logger.d(
            '📈 Stats upgrade only: Keeping type $nextType, rarity: $nextRarity');
      }

      // Рассчитываем улучшенные характеристики
      final double multiplier = _getUpgradeMultiplier(nextRarity, nextLevel);
      final int newAttack = (baseCard.attack * multiplier).round();
      final int newHealth = (baseCard.health * multiplier).round();

      _logger.d(
          '📊 New stats: attack=$newAttack, health=$newHealth (multiplier: $multiplier)');

      // Создаем улучшенную карту
      final upgradedCard = CardModel(
        id: baseCardId,
        name: _getUpgradedName(baseCard.name, nextType),
        description: baseCard.description,
        rarity: nextRarity,
        type: nextType,
        level: nextLevel,
        attack: newAttack,
        health: newHealth,
        manaCost: baseCard.manaCost,
        imagePath: _getUpgradedImagePath(baseCard.imagePath, nextType),
      );

      _logger.d('🃏 Created upgraded card: ${upgradedCard.name}');

      // Получаем ВСЕ записи карт для удаления
      final cardsToDelete = await _client
          .from('user_cards')
          .select()
          .eq('user_id', userId)
          .eq('card_id', baseCardId)
          .eq('type', currentType.toString().split('.').last)
          .eq('level', currentLevel);

      _logger.d('🔍 Found ${cardsToDelete.length} records matching criteria');

      // УДАЛЯЕМ 3 КАРТЫ ИЗ СЧЕТЧИКА
      int remainingToRemove = 3;

      for (var card in cardsToDelete) {
        if (remainingToRemove <= 0) break;

        final cardId = card['id'] as int;
        final count = card['count'] as int? ?? 1;

        _logger.d(
            '📊 Processing record id=$cardId, count=$count, need to remove $remainingToRemove');

        if (count > remainingToRemove) {
          // В этой записи достаточно карт
          final newCount = count - remainingToRemove;
          await _client
              .from('user_cards')
              .update({'count': newCount}).eq('id', cardId);
          _logger.d('✅ Updated record $cardId: count $count -> $newCount');
          remainingToRemove = 0;
        } else {
          // Берем все карты из этой записи
          await _client.from('user_cards').delete().eq('id', cardId);
          _logger.d('✅ Deleted record $cardId (had $count cards)');
          remainingToRemove -= count;
        }
      }

      if (remainingToRemove > 0) {
        _logger.e(
            '❌ Not enough cards to merge. Found: ${3 - remainingToRemove}, needed: 3');
        throw Exception('Not enough cards to merge');
      }

      _logger.d('✅ Successfully removed 3 cards');

      // Проверяем, есть ли уже такая улучшенная карта
      final existingUpgradedCards = await _client
          .from('user_cards')
          .select()
          .eq('user_id', userId)
          .eq('card_id', baseCardId)
          .eq('type', nextType.toString().split('.').last)
          .eq('level', nextLevel);

      _logger.d(
          '🔍 Checking for existing upgraded card: type=$nextType, level=$nextLevel');

      if (existingUpgradedCards.isNotEmpty) {
        // Увеличиваем количество существующей карты
        final existingCard = existingUpgradedCards[0];
        final currentCount = existingCard['count'] as int? ?? 1;
        await _client.from('user_cards').update({'count': currentCount + 1}).eq(
            'id', existingCard['id'] as int);
        _logger.d(
            '📈 Incremented count of existing upgraded card to ${currentCount + 1}');
      } else {
        // Добавляем новую улучшенную карту
        // ВАЖНО: Проверяем, нет ли уже записи с таким же card_id, но другим типом/уровнем
        Map<String, dynamic>? existingCardWithSameId;
        try {
          existingCardWithSameId = await _client
              .from('user_cards')
              .select()
              .eq('user_id', userId)
              .eq('card_id', baseCardId)
              .eq('type', nextType.toString().split('.').last)
              .single() as Map<String, dynamic>;
        } catch (e) {
          // Если записи нет, это нормально
          existingCardWithSameId = null;
        }

        if (existingCardWithSameId != null) {
          // Обновляем существующую запись
          await _client.from('user_cards').update({
            'level': nextLevel,
            'rarity': nextRarity.toString().split('.').last,
            'attack': newAttack,
            'health': newHealth,
            'count': 1,
          }).eq('id', existingCardWithSameId['id'] as int);
          _logger.d('🔄 Updated existing card to new level/type');
        } else {
          // Добавляем новую запись
          await _client.from('user_cards').insert({
            'user_id': userId,
            'card_id': baseCardId,
            'type': nextType.toString().split('.').last,
            'level': nextLevel,
            'rarity': nextRarity.toString().split('.').last,
            'attack': newAttack,
            'health': newHealth,
            'count': 1,
          });
          _logger.d('➕ Added new upgraded card');
        }
      }

      _logger.i(
          '✅ Cards merged successfully! New type: $nextType, level: $nextLevel');
      return upgradedCard;
    } catch (e, stack) {
      _logger.e('❌ Error merging cards', error: e, stackTrace: stack);
      return null;
    }
  }

// Вспомогательные методы
  double _getUpgradeMultiplier(Rarity rarity, int level) {
    switch (rarity) {
      case Rarity.common:
        return 1.0 + (level * 0.1); // +10% за уровень
      case Rarity.rare:
        return 1.0 + (level * 0.15); // +15% за уровень
      case Rarity.epic:
        return 1.0 + (level * 0.2); // +20% за уровень
      case Rarity.legendary:
        return 1.0 + (level * 0.25); // +25% за уровень
    }
  }

  Rarity _getRarityByType(CardType type) {
    if (type.index <= CardType.support.index) return Rarity.common;
    if (type.index <= CardType.priest.index) return Rarity.rare;
    if (type.index <= CardType.druid.index) return Rarity.epic;
    return Rarity.legendary;
  }

  String _getUpgradedName(String baseName, CardType newType) {
    final typeName = newType.toString().split('.').last;
    return '$baseName ($typeName)';
  }

  String _getUpgradedImagePath(String basePath, CardType newType) {
    final typeName = newType.toString().split('.').last;
    return basePath.replaceFirst('.png', '_$typeName.png');
  }

  Future<Map<String, dynamic>> getUserCardStats(int userId) async {
    try {
      _logger.d('📊 Fetching detailed card stats for user: $userId');

      // Получаем все карты пользователя с детальной информацией
      final response = await _client.from('user_cards').select('''
          id,
          card_id,
          type,
          level,
          rarity,
          attack,
          health,
          count,
          cards!inner(
            id,
            name,
            description,
            attack,
            health,
            mana_cost,
            image_path
          )
        ''') // Убрали experience
          .eq('user_id', userId);

      // Группируем карты по card_id и type
      final Map<int, Map<String, dynamic>> groupedCards = {};
      int totalCards = 0;
      int totalAttack = 0;
      int totalHealth = 0;
      int uniqueCardTypes = 0;

      // Статистика по редкости
      final Map<Rarity, int> rarityStats = {
        Rarity.common: 0,
        Rarity.rare: 0,
        Rarity.epic: 0,
        Rarity.legendary: 0,
      };

      // Статистика по типам
      final Map<CardType, int> typeStats = {};

      // Собираем карты для возможности объединения
      final List<Map<String, dynamic>> mergeableCards = [];

      for (var item in response) {
        final cardId = item['card_id'] as int;
        final cardTypeStr = item['type'] as String;
        final level = item['level'] as int;
        final count = item['count'] as int? ?? 1;
        final rarityStr = item['rarity'] as String;
        final attack = item['attack'] as int? ?? 0;
        final health = item['health'] as int? ?? 0;

        // Получаем данные карты
        final cardData = item['cards'] as Map<String, dynamic>;
        final card = CardModel.fromJson(cardData);

        // Преобразуем строки в enum
        final CardType cardType = CardType.values.firstWhere(
          (e) => e.toString().split('.').last == cardTypeStr,
          orElse: () => CardType.warrior,
        );

        final Rarity rarity = Rarity.values.firstWhere(
          (e) => e.toString().split('.').last == rarityStr,
          orElse: () => Rarity.common,
        );

        // Обновляем статистику
        totalCards += count;
        totalAttack += attack * count;
        totalHealth += health * count;
        rarityStats[rarity] = rarityStats[rarity]! + count;
        typeStats[cardType] = (typeStats[cardType] ?? 0) + count;

        // Ключ для группировки: cardId + type + level
        final String groupKey = '$cardId-$cardTypeStr-$level';

        if (!groupedCards.containsKey(cardId)) {
          groupedCards[cardId] = {
            'card': card.copyWith(type: cardType, rarity: rarity),
            'totalCount': 0,
            'byLevel': <int, Map<String, dynamic>>{},
            'byType': <String, Map<String, dynamic>>{},
          };
        }

        // Добавляем данные по уровням
        if (!groupedCards[cardId]!['byLevel'].containsKey(level)) {
          groupedCards[cardId]!['byLevel'][level] = {
            'count': 0,
            'attack': attack,
            'health': health,
            'rarity': rarity,
            'type': cardType,
          };
        }

        final levelData = groupedCards[cardId]!['byLevel'][level];
        levelData['count'] = (levelData['count'] as int) + count;

        // Добавляем данные по типам
        final typeKey = '$cardTypeStr-$rarityStr';
        if (!groupedCards[cardId]!['byType'].containsKey(typeKey)) {
          groupedCards[cardId]!['byType'][typeKey] = {
            'count': 0,
            'level': level,
            'rarity': rarity,
            'type': cardType,
          };
        }

        final typeData = groupedCards[cardId]!['byType'][typeKey];
        typeData['count'] = (typeData['count'] as int) + count;

        // Обновляем общее количество
        groupedCards[cardId]!['totalCount'] =
            (groupedCards[cardId]!['totalCount'] as int) + count;

        // Проверяем возможность объединения
        if (count >= 3 || (levelData['count'] as int) >= 3) {
          mergeableCards.add({
            'cardId': cardId,
            'card': card,
            'type': cardType,
            'level': level,
            'rarity': rarity,
            'count': levelData['count'] as int,
            'canMerge': true,
          });
        }
      }

      // Вычисляем уникальные типы карт
      uniqueCardTypes = groupedCards.length;

      // Находим самые частые и редкие карты
      CardModel? mostCommonCard;
      int mostCommonCount = 0;

      CardModel? rarestCard;
      Rarity highestRarity = Rarity.common;

      for (var entry in groupedCards.entries) {
        final card = entry.value['card'] as CardModel;
        final totalCount = entry.value['totalCount'] as int;

        if (totalCount > mostCommonCount) {
          mostCommonCount = totalCount;
          mostCommonCard = card;
        }

        if (card.rarity.index > highestRarity.index) {
          highestRarity = card.rarity;
          rarestCard = card;
        }
      }

      // Сортируем карты по возможности объединения
      mergeableCards.sort((a, b) {
        // Сначала те, которые можно объединить
        final bool aCanMerge = a['canMerge'] as bool;
        final bool bCanMerge = b['canMerge'] as bool;
        if (aCanMerge && !bCanMerge) return -1;
        if (!aCanMerge && bCanMerge) return 1;

        // Затем по редкости
        final Rarity aRarity = a['rarity'] as Rarity;
        final Rarity bRarity = b['rarity'] as Rarity;
        return bRarity.index.compareTo(aRarity.index);
      });

      // Рассчитываем общую стоимость маны
      final totalManaCost = groupedCards.values.fold(0, (sum, cardData) {
        final card = cardData['card'] as CardModel;
        final totalCount = cardData['totalCount'] as int;
        return sum + (card.manaCost * totalCount);
      });

      // Средние значения
      final double avgAttack = totalCards > 0 ? totalAttack / totalCards : 0;
      final double avgHealth = totalCards > 0 ? totalHealth / totalCards : 0;
      final double avgManaCost =
          totalCards > 0 ? totalManaCost / totalCards : 0;

      _logger.i('✅ User card stats loaded successfully');
      _logger.d('📊 Total cards: $totalCards');
      _logger.d('📊 Unique cards: $uniqueCardTypes');
      _logger.d('📊 Mergeable cards: ${mergeableCards.length}');

      return {
        // Основная статистика
        'totalCards': totalCards,
        'uniqueCards': uniqueCardTypes,
        'totalAttack': totalAttack,
        'totalHealth': totalHealth,
        'totalManaCost': totalManaCost,

        // Средние значения
        'avgAttack': avgAttack,
        'avgHealth': avgHealth,
        'avgManaCost': avgManaCost,

        // Группированные данные
        'groupedCards': groupedCards,
        'mergeableCards': mergeableCards,

        // Статистика по редкости
        'rarityStats': {
          'common': rarityStats[Rarity.common],
          'rare': rarityStats[Rarity.rare],
          'epic': rarityStats[Rarity.epic],
          'legendary': rarityStats[Rarity.legendary],
          'total': rarityStats.values.fold(0, (sum, count) => sum + count),
        },

        // Статистика по типам
        'typeStats': typeStats.map(
            (key, value) => MapEntry(key.toString().split('.').last, value)),

        // Особые карты
        'mostCommonCard': mostCommonCard,
        'mostCommonCount': mostCommonCount,
        'rarestCard': rarestCard,
        'highestLevelCard': _getHighestLevelCard(groupedCards),
        'strongestCard': _getStrongestCard(groupedCards),

        // Мета-информация
        'lastUpdated': DateTime.now().toIso8601String(),
        'userId': userId,
      };
    } catch (e, stack) {
      _logger.e('❌ Error fetching user card stats',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

// Вспомогательные методы
  Map<String, dynamic> _getHighestLevelCard(
      Map<int, Map<String, dynamic>> groupedCards) {
    int highestLevel = 0;
    CardModel? highestLevelCard;

    for (var cardData in groupedCards.values) {
      final card = cardData['card'] as CardModel;
      final byLevel = cardData['byLevel'] as Map<int, Map<String, dynamic>>;

      for (var level in byLevel.keys) {
        if (level > highestLevel) {
          highestLevel = level;
          highestLevelCard = card.copyWith(level: level);
        }
      }
    }

    return {
      'card': highestLevelCard,
      'level': highestLevel,
    };
  }

  Map<String, dynamic> _getStrongestCard(
      Map<int, Map<String, dynamic>> groupedCards) {
    double highestPower = 0;
    CardModel? strongestCard;
    int strongestLevel = 1;

    for (var cardData in groupedCards.values) {
      final card = cardData['card'] as CardModel;
      final byLevel = cardData['byLevel'] as Map<int, Map<String, dynamic>>;

      for (var levelEntry in byLevel.entries) {
        final level = levelEntry.key;
        final levelData = levelEntry.value;
        final attack = levelData['attack'] as int? ?? card.attack;
        final health = levelData['health'] as int? ?? card.health;

        // Простая формула мощности: атака + здоровье
        final double power = attack + health * 0.5;

        if (power > highestPower) {
          highestPower = power;
          strongestCard = card.copyWith(
            level: level,
            attack: attack,
            health: health,
          );
          strongestLevel = level;
        }
      }
    }

    return {
      'card': strongestCard,
      'power': highestPower,
      'level': strongestLevel,
    };
  }

// Получить карты пользователя с учетом уровня
  Future<List<CardModel>> getUserCards(int userId) async {
    try {
      _logger.d('🃏 Fetching user cards for: $userId');

      final response = await _client.from('user_cards').select('''
          id,
          card_id,
          type,
          level,
          rarity,
          attack,
          health,
          count,
          cards!inner(
            id,
            name,
            description,
            attack,
            health,
            mana_cost,
            image_path
          )
        ''') // Убрали experience
          .eq('user_id', userId);

      final List<CardModel> allCards = [];

      for (var item in response) {
        final cardData = item['cards'] as Map<String, dynamic>;
        final baseCard = CardModel.fromJson(cardData);

        final cardTypeStr = item['type'] as String;
        final level = item['level'] as int;
        final count = item['count'] as int? ?? 1; // Важно: получаем count
        final rarityStr = item['rarity'] as String;
        final attack = item['attack'] as int? ?? baseCard.attack;
        final health = item['health'] as int? ?? baseCard.health;

        // Преобразуем строки в enum
        final CardType cardType = CardType.values.firstWhere(
          (e) => e.toString().split('.').last == cardTypeStr,
          orElse: () => CardType.warrior,
        );

        final Rarity rarity = Rarity.values.firstWhere(
          (e) => e.toString().split('.').last == rarityStr,
          orElse: () => Rarity.common,
        );

        // Создаем копию карты для каждого экземпляра
        for (int i = 0; i < count; i++) {
          allCards.add(baseCard.copyWith(
            level: level,
            rarity: rarity,
            type: cardType,
            attack: attack,
            health: health,
          ));
        }
      }

      _logger.i('✅ Found ${allCards.length} cards for user $userId');
      return allCards;
    } catch (e, stack) {
      _logger.e('❌ Error fetching user cards', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // Получить карты, которые можно объединить
  Future<List<Map<String, dynamic>>> getMergeableCards(int userId) async {
    try {
      _logger.d('🔍 Getting mergeable cards for user: $userId');

      // Получаем все карты пользователя
      final response = await _client.from('user_cards').select('''
          card_id,
          type,
          level,
          count,
          cards!inner(
            id,
            name,
            description,
            rarity,
            attack,
            health,
            mana_cost,
            image_path
          )
        ''').eq('user_id', userId);

      // Группируем по card_id, type, level
      final Map<String, Map<String, dynamic>> groupedCards = {};

      for (var card in response) {
        final cardId = card['card_id'] as int;
        final type = card['type'] as String? ?? 'warrior';
        final level = card['level'] as int;
        final count = card['count'] as int? ?? 1;
        final cardData = card['cards'] as Map<String, dynamic>;

        final key = '$cardId-$type-$level';

        if (!groupedCards.containsKey(key)) {
          groupedCards[key] = {
            'cardId': cardId,
            'type': type,
            'level': level,
            'count': 0,
            'cardData': cardData,
          };
        }

        // СУММИРУЕМ количество из всех записей
        groupedCards[key]!['count'] =
            (groupedCards[key]!['count'] as int) + count;
      }

      // Фильтруем только те, у которых >= 3 карт
      final List<Map<String, dynamic>> mergeableCards = [];

      for (var entry in groupedCards.entries) {
        final cardData = entry.value;
        final totalCount = cardData['count'] as int;

        if (totalCount >= 3) {
          final savedCard = cardData['cardData'] as Map<String, dynamic>;

          // Создаем базовую карту
          final baseCard = CardModel(
            id: cardData['cardId'] as int,
            name: savedCard['name'] as String? ?? 'Карта',
            description: savedCard['description'] as String? ?? '',
            rarity: Rarity.values.firstWhere(
              (e) =>
                  e.toString().split('.').last ==
                  (savedCard['rarity'] as String? ?? 'common'),
              orElse: () => Rarity.common,
            ),
            type: CardType.values.firstWhere(
              (e) => e.toString().split('.').last == cardData['type'],
              orElse: () => CardType.warrior,
            ),
            level: cardData['level'] as int,
            attack: savedCard['attack'] as int? ?? 10,
            health: savedCard['health'] as int? ?? 10,
            manaCost: savedCard['mana_cost'] as int? ?? 2,
            imagePath: savedCard['image_path'] as String? ??
                'assets/cards/default.png',
          );

          mergeableCards.add({
            'card': baseCard,
            'cardId': cardData['cardId'],
            'type': baseCard.type,
            'level': cardData['level'],
            'rarity': baseCard.rarity,
            'count': totalCount,
          });
        }
      }

      _logger.i('✅ Found ${mergeableCards.length} mergeable cards');
      return mergeableCards;
    } catch (e, stack) {
      _logger.e('❌ Error getting mergeable cards', error: e, stackTrace: stack);
      return [];
    }
  }
}
