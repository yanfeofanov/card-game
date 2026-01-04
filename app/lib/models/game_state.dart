import 'package:flutter/widgets.dart';
import 'package:card_game/models/card.dart';
import 'package:card_game/models/pack_purchase.dart';

class GameState with ChangeNotifier {
  String _playerName = 'Игрок';
  int _gold = 1000;
  int _gems = 50;
  int _level = 1;
  int _exp = 0;
  int _userId = 1;
  List<CardModel> _userCards = [];
  List<PackPurchase> _purchaseHistory = [];

  String get playerName => _playerName;
  int get gold => _gold;
  int get gems => _gems;
  int get level => _level;
  int get exp => _exp;
  List<CardModel> get userCards => _userCards;
  List<PackPurchase> get purchaseHistory => _purchaseHistory;

  // Геттер для userId
  int get userId => _userId;

  // Сеттер для userId
  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

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

  void addExp(int amount) {
    _exp += amount;
    if (_exp >= _level * 100) {
      _level++;
      _exp = 0;
    }
    notifyListeners();
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
