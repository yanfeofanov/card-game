import 'package:flutter/widgets.dart';

class GameState with ChangeNotifier {
  String _playerName = 'Игрок';
  int _gold = 1000;
  int _gems = 50;
  int _level = 1;
  int _exp = 0;

  String get playerName => _playerName;
  int get gold => _gold;
  int get gems => _gems;
  int get level => _level;
  int get exp => _exp;

  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  void sendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      notifyListeners();
    }
  }

  void addExp(int amount) {
    _exp += amount;
    if (_exp >= _level * 100) {
      _level++;
      _exp = 0;
      // Можно показать уведомление о повышении опыта
    }
    notifyListeners();
  }

  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }
}
