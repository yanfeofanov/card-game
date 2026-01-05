import 'package:card_game/models/card.dart';
import 'package:card_game/models/game_state.dart';
import 'package:card_game/services/battle_state_service.dart';
import 'package:card_game/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class BattleScreen extends StatefulWidget {
  final List<CardModel> playerCards;
  static bool isBattleActive = false;

  const BattleScreen({
    super.key,
    required this.playerCards,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late List<CardModel> _playerCards;
  late List<CardModel> _enemyCards;
  int _currentTurn = 0;
  int _currentAttackerIndex = 0;
  int _currentDefenderIndex = 0;
  final List<String> _battleMessages = [];
  bool _isBattleInProgress = false;
  bool _isBattleFinished = false;
  String? _winner;
  final Random _random = Random();

  bool _isProcessingTurn = false;
  bool _shouldContinueBattle = true;

  @override
  void initState() {
    super.initState();
    BattleStateService().startBattle();

    _playerCards = List.from(widget.playerCards);
    _generateEnemyCards();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isBattleFinished) {
        _startBattle();
      }
    });
  }

  @override
  void dispose() {
    BattleStateService().endBattle();
    _shouldContinueBattle = false;
    super.dispose();
  }

  void _generateEnemyCards() {
    _enemyCards = [];

    for (int i = 0; i < 5; i++) {
      _enemyCards.add(CardModel(
        id: 1000 + i,
        name: 'Враг ${i + 1}',
        description: 'Противник',
        rarity: Rarity.common,
        type: CardType.warrior,
        level: 1,
        attack: 10 + _random.nextInt(10),
        health: 20 + _random.nextInt(20),
        manaCost: 2,
        imagePath: 'assets/cards/enemy.png',
      ));
    }
  }

  void _startBattle() {
    if (!mounted || _isBattleFinished) return;

    setState(() {
      _isBattleInProgress = true;
      _battleMessages.add('🎮 Бой начинается!');
    });

    _safeProcessNextTurn();
  }

  Future<void> _safeProcessNextTurn() async {
    if (!mounted ||
        _isBattleFinished ||
        _isProcessingTurn ||
        !_shouldContinueBattle) {
      return;
    }

    _isProcessingTurn = true;

    try {
      await _processSingleTurn();
    } catch (e, stack) {
      print('❌ Ошибка в ходе боя: $e\n$stack');
    } finally {
      _isProcessingTurn = false;

      if (_playerCards.isEmpty || _enemyCards.isEmpty) {
        _endBattle();
        return;
      }

      if (mounted && !_isBattleFinished && _shouldContinueBattle) {
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted && !_isBattleFinished && _shouldContinueBattle) {
          _safeProcessNextTurn();
        }
      }
    }
  }

  Future<void> _processSingleTurn() async {
    _playerCards.removeWhere((card) => card.health <= 0);
    _enemyCards.removeWhere((card) => card.health <= 0);

    if (_playerCards.isEmpty || _enemyCards.isEmpty) {
      return;
    }

    _currentAttackerIndex %=
        _currentTurn == 0 ? _playerCards.length : _enemyCards.length;
    _currentDefenderIndex %=
        _currentTurn == 0 ? _enemyCards.length : _playerCards.length;

    final bool isPlayerTurn = _currentTurn == 0;
    final List<CardModel> attackers = isPlayerTurn ? _playerCards : _enemyCards;
    final List<CardModel> defenders = isPlayerTurn ? _enemyCards : _playerCards;

    if (_currentAttackerIndex >= attackers.length) _currentAttackerIndex = 0;
    if (_currentDefenderIndex >= defenders.length) _currentDefenderIndex = 0;

    final attacker = attackers[_currentAttackerIndex];
    final defender = defenders[_currentDefenderIndex];

    if (attacker.health <= 0 || defender.health <= 0) {
      _currentTurn = (_currentTurn + 1) % 2;
      return;
    }

    if (mounted) {
      setState(() {
        _battleMessages
            .add('--- ${isPlayerTurn ? 'ХОД ИГРОКА' : 'ХОД ВРАГА'} ---');
        if (_battleMessages.length > 8) _battleMessages.removeAt(0);
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final baseDamage = attacker.attack;
    final variation = max(1, (baseDamage * 0.2).round());
    final damage =
        max(1, baseDamage + _random.nextInt(variation * 2) - variation);
    final newHealth = defender.health - damage;

    if (mounted) {
      setState(() {
        if (isPlayerTurn) {
          if (_currentDefenderIndex < _enemyCards.length) {
            _enemyCards[_currentDefenderIndex] = defender.copyWith(
              health: max(0, newHealth),
            );
          }
        } else {
          if (_currentDefenderIndex < _playerCards.length) {
            _playerCards[_currentDefenderIndex] = defender.copyWith(
              health: max(0, newHealth),
            );
          }
        }

        final attackerName =
            isPlayerTurn ? attacker.name : 'Враг: ${attacker.name}';
        final defenderName =
            isPlayerTurn ? 'Враг: ${defender.name}' : defender.name;
        final message = '⚔️ $attackerName → $damage → $defenderName';

        _battleMessages.add(message);
        if (_battleMessages.length > 8) _battleMessages.removeAt(0);

        if (newHealth <= 0) {
          _battleMessages.add('💀 $defenderName повержен!');
          if (_battleMessages.length > 8) _battleMessages.removeAt(0);
        }
      });
    }

    if (isPlayerTurn) {
      if (_playerCards.isNotEmpty) {
        _currentAttackerIndex =
            (_currentAttackerIndex + 1) % _playerCards.length;
      }
      if (_enemyCards.isNotEmpty) {
        _currentDefenderIndex =
            (_currentDefenderIndex + 1) % _enemyCards.length;
      }
    } else {
      if (_enemyCards.isNotEmpty) {
        _currentAttackerIndex =
            (_currentAttackerIndex + 1) % _enemyCards.length;
      }
      if (_playerCards.isNotEmpty) {
        _currentDefenderIndex = _random.nextInt(_playerCards.length);
      }
    }

    _currentTurn = (_currentTurn + 1) % 2;
  }

  void _endBattle() {
    if (_isBattleFinished) return;

    final bool playerWon = _enemyCards.isEmpty && _playerCards.isNotEmpty;

    if (mounted) {
      setState(() {
        _isBattleFinished = true;
        _isBattleInProgress = false;
        _winner = playerWon ? 'Игрок' : 'Враг';

        if (playerWon) {
          _battleMessages.add('🎉 ПОБЕДА! Вы победили врага!');
          _giveReward();
        } else {
          _battleMessages.add('💀 ПОРАЖЕНИЕ! Враг оказался сильнее.');
          _giveDefeatReward(); // Добавим метод для малой награды при поражении
        }

        if (_battleMessages.length > 12) _battleMessages.removeAt(0);
      });
    }
  }

  // Небольшая награда за поражение
  void _giveDefeatReward() {
    final gameState = context.read<GameState>();
    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);

    // Минимальная награда за поражение
    final goldReward = 10;
    final expReward = 10;

    gameState.addGold(goldReward);
    gameState.addExp(expReward);

    // Сохраняем в базу
    Future.microtask(() async {
      try {
        final playerCardIds = _playerCards.map((card) => card.id).toList();
        final enemyCardIds = _enemyCards.map((card) => card.id).toList();

        await supabaseService.saveBattleResult(
          userId: gameState.userId,
          won: false,
          expGained: expReward,
          goldGained: goldReward,
          playerCards: playerCardIds,
          enemyCards: enemyCardIds,
        );
      } catch (e) {
        print('⚠️ Не удалось сохранить результат поражения: $e');
      }
    });

    if (mounted) {
      setState(() {
        _battleMessages.add('💔 Утешительная награда: +$goldReward золота');
        _battleMessages.add('📉 Опыт: +$expReward');
        if (_battleMessages.length > 12) _battleMessages.removeAt(0);
      });
    }
  }

  void _giveReward() {
    final gameState = context.read<GameState>();
    final supabaseService =
        Provider.of<SupabaseService>(context, listen: false);

    // Расчет награды
    final baseGold = 50;
    final baseExp = 50;

    // Бонусы за уровень
    final levelBonus = gameState.level * 10;

    // Случайный бонус (0-50)
    final randomBonus = _random.nextInt(51);

    // Итоговая награда
    final goldReward = baseGold + levelBonus + randomBonus;
    final expReward = baseExp + (levelBonus ~/ 2) + (randomBonus ~/ 2);

    // Максимум 100 опыта за бой
    final finalExpReward = min(expReward, 100);

    // Обновляем локальное состояние
    gameState.addGold(goldReward);
    gameState.addExp(finalExpReward);

    // Сохраняем в базу данных в фоне
    Future.microtask(() async {
      try {
        // Получаем ID карт для сохранения
        final playerCardIds = _playerCards.map((card) => card.id).toList();
        final enemyCardIds = _enemyCards.map((card) => card.id).toList();

        await supabaseService.saveBattleResult(
          userId: gameState.userId,
          won: true,
          expGained: finalExpReward,
          goldGained: goldReward,
          playerCards: playerCardIds,
          enemyCards: enemyCardIds,
        );

        print(
            '✅ Награда сохранена в БД: $goldReward золота, $finalExpReward опыта');
      } catch (e) {
        print('⚠️ Не удалось сохранить награду в БД: $e');
      }
    });

    if (mounted) {
      setState(() {
        _battleMessages.add('🏆 Награда: +$goldReward золота');
        _battleMessages.add('📈 Опыт: +$finalExpReward');
        _battleMessages.add(
            '🎯 Уровень: ${gameState.level} (${(gameState.levelProgress * 100).toStringAsFixed(1)}%)');
        if (_battleMessages.length > 12) _battleMessages.removeAt(0);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎉 Победа!'),
              SizedBox(height: 4),
              Text('+$goldReward золота, +$finalExpReward опыта'),
              if (gameState.expToNextLevel > 0)
                Text(
                  'До следующего уровня: ${gameState.expToNextLevel} опыта',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildCardStack(List<CardModel> cards, bool isPlayer) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          final isDead = card.health <= 0;

          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 65,
                  decoration: BoxDecoration(
                    color: isPlayer ? Colors.blue : Colors.red,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDead ? Colors.grey : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.name.substring(0, min(3, card.name.length)),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '❤️${card.health}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDead ? Colors.red : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                if (isDead) const Text('💀', style: TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бой'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isBattleInProgress ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Враг - фиксированная высота 20%
            Container(
              height: screenHeight * 0.2,
              color: Colors.red.shade900.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ПРОТИВНИК',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Карт: ${_enemyCards.length}'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildCardStack(_enemyCards, false),
                  ),
                ],
              ),
            ),

            // Центр боя - фиксированная высота 15%
            Container(
              height: screenHeight * 0.15,
              color: Colors.grey.shade900,
              child: Center(
                child: _isBattleInProgress && !_isBattleFinished
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _currentTurn == 0 ? Icons.person : Icons.computer,
                            color: _currentTurn == 0 ? Colors.blue : Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentTurn == 0 ? 'Ваш ход' : 'Ход врага',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : _isBattleFinished
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _winner == 'Игрок'
                                    ? Icons.emoji_events
                                    : Icons.close,
                                color: _winner == 'Игрок'
                                    ? Colors.yellow
                                    : Colors.red,
                                size: 40,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _winner == 'Игрок' ? 'ПОБЕДА' : 'ПОРАЖЕНИЕ',
                                style: TextStyle(
                                  color: _winner == 'Игрок'
                                      ? Colors.yellow
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Загрузка...'),
                            ],
                          ),
              ),
            ),

            // Игрок - фиксированная высота 20%
            Container(
              height: screenHeight * 0.2,
              color: Colors.blue.shade900.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ВАШИ КАРТЫ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Карт: ${_playerCards.length}'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildCardStack(_playerCards, true),
                  ),
                ],
              ),
            ),

            // Лог боя - занимает оставшееся пространство
            Expanded(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Лог боя:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          reverse: true,
                          itemCount: _battleMessages.length,
                          itemBuilder: (context, index) {
                            final message =
                                _battleMessages.reversed.toList()[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопка завершения
            if (_isBattleFinished)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _winner == 'Игрок' ? Colors.green : Colors.red,
                    ),
                    child: const Text(
                      'ВЕРНУТЬСЯ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
