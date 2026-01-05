import 'package:flutter/widgets.dart';
import 'package:card_game/models/card.dart';
import 'package:card_game/models/pack_purchase.dart';

class GameState with ChangeNotifier {
  User? _currentUser;
  String _playerName = 'Игрок';
  int _gold = 1000;
  int _gems = 50;
  int _level = 1;
  int _exp = 0;
  int _totalExp = 0;
  List<CardModel> _userCards = [];
  List<PackPurchase> _purchaseHistory = [];

  String get playerName => _playerName;
  User? get currentUser => _currentUser;
  int get gold => _gold;
  int get gems => _gems;
  int get level => _level;
  int get exp => _exp;
  int get totalExp => _totalExp;
  String get userId => _currentUser?.id ?? 'anonymous';
  List<CardModel> get userCards => _userCards;
  List<PackPurchase> get purchaseHistory => _purchaseHistory;

  // Расчет необходимого опыта для следующего уровня
  int get expToNextLevel {
    return _calculateExpForLevel(_level + 1) - _totalExp;
  }

  // Процент прогресса до следующего уровня (0.0 - 1.0)
  double get levelProgress {
    if (_level == 1) {
      return _totalExp / _calculateExpForLevel(2);
    }
    final currentLevelExp = _calculateExpForLevel(_level);
    final nextLevelExp = _calculateExpForLevel(_level + 1);
    return (_totalExp - currentLevelExp) / (nextLevelExp - currentLevelExp);
  }

  // Формула опыта для уровня: 1000 * 2^(level-1)
  int _calculateExpForLevel(int level) {
    if (level <= 1) return 0;
    return 1000 * (1 << (level - 2)); // 2^(level-2) * 1000
  }

  // Добавить опыт
  void addExp(int amount) {
    _exp += amount;
    _totalExp += amount;

    // Проверяем повышение уровня
    while (_totalExp >= _calculateExpForLevel(_level + 1)) {
      _level++;
      print('🎉 Уровень повышен до $_level!');

      // Награда за уровень
      _gold += _level * 100;
      _gems += _level * 5;
    }

    notifyListeners();
  }

  void setTotalExp(int totalExp, int level) {
    _totalExp = totalExp;
    _level = level;
    _exp = _totalExp - _calculateExpForLevel(level);
    notifyListeners();
  }

  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateFromUserData(Map<String, dynamic> userData) {
    if (userData['username'] != null) {
      _playerName = userData['username'];
    }
    _gold = userData['gold'] ?? 0;
    _gems = userData['gems'] ?? 0;
    _level = userData['level'] ?? 1;
    _totalExp = userData['total_exp'] ?? 0;
    _exp = _totalExp - _calculateExpForLevel(_level);
    notifyListeners();
  }
  // Остальные методы остаются без изменений...
  // void setUserId(int id) {
  //   _userId = id;
  //   notifyListeners();
  // }

  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  void spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      notifyListeners();
    }
  }

  void addGems(int amount) {
    _gems += amount;
    notifyListeners();
  }

  void spendGems(int amount) {
    if (_gems >= amount) {
      _gems -= amount;
      notifyListeners();
    }
  }

  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }

  void addCard(CardModel card) {
    _userCards.add(card);
    notifyListeners();
  }

  void addCards(List<CardModel> cards) {
    _userCards.addAll(cards);
    notifyListeners();
  }

  void setUserCards(List<CardModel> cards) {
    _userCards = cards;
    notifyListeners();
  }

  void addPurchase(PackPurchase purchase) {
    _purchaseHistory.insert(0, purchase);
    addCards(purchase.cards);
    notifyListeners();
  }

  void setPurchaseHistory(List<PackPurchase> purchases) {
    _purchaseHistory = purchases;
    notifyListeners();
  }
}
