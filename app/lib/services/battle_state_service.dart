class BattleStateService {
  static final BattleStateService _instance = BattleStateService._internal();

  factory BattleStateService() => _instance;

  BattleStateService._internal();

  bool _isBattleActive = false;

  bool get isBattleActive => _isBattleActive;

  void startBattle() {
    _isBattleActive = true;
  }

  void endBattle() {
    _isBattleActive = false;
  }
}
