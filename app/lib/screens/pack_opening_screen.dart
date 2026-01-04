import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:card_game/models/card.dart';
import 'package:card_game/models/pack_purchase.dart';
import 'package:card_game/widgets/card_widget.dart';

class PackOpeningScreen extends StatefulWidget {
  final PackPurchase purchase;
  final VoidCallback onComplete;

  const PackOpeningScreen({
    super.key,
    required this.purchase,
    required this.onComplete,
  });

  @override
  _PackOpeningScreenState createState() => _PackOpeningScreenState();
}

class _PackOpeningScreenState extends State<PackOpeningScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _currentCardIndex = 0;
  bool _isOpening = false;
  bool _showCard = false;
  bool _allCardsShown = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Показываем первую карту автоматически
    _showNextCard();
  }

  void _showNextCard() {
    if (_currentCardIndex >= widget.purchase.cards.length) {
      setState(() {
        _allCardsShown = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        widget.onComplete();
      });
      return;
    }

    setState(() {
      _showCard = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _showCard = true;
      });
      _controller.reset();
      _controller.forward();
    });
  }

  void _nextCard() {
    if (_currentCardIndex < widget.purchase.cards.length - 1) {
      setState(() {
        _currentCardIndex++;
      });
      _showNextCard();
    } else {
      setState(() {
        _allCardsShown = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        widget.onComplete();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        children: [
          // Фоновые эффекты
          Positioned.fill(
            child: !_allCardsShown
                ? Lottie.asset(
                    'assets/animations/confetti.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.purple.shade900.withOpacity(0.8),
                          Colors.blue.shade900.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Прогресс
                  Text(
                    'Карта ${_currentCardIndex + 1}/${widget.purchase.cards.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Анимация открытия карты
                  if (_showCard)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 280,
                            maxHeight: 400,
                          ),
                          child: CardWidget(
                            card: widget.purchase.cards[_currentCardIndex],
                            showDetails: true,
                            compact: true,
                          ),
                        ),
                      ),
                    )
                  else
                    // Анимация "сияния" перед открытием
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Lottie.asset(
                        'assets/animations/sparkle.json',
                        fit: BoxFit.contain,
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Информация о карте
                  if (_showCard)
                    AnimatedOpacity(
                      opacity: _showCard ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            widget.purchase.cards[_currentCardIndex].name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Редкость: ${_getRarityName(widget.purchase.cards[_currentCardIndex].rarity)}',
                            style: TextStyle(
                              color: Color(widget.purchase
                                  .cards[_currentCardIndex].rarityColor),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Кнопка следующей карты
                          if (_currentCardIndex <
                              widget.purchase.cards.length - 1)
                            ElevatedButton(
                              onPressed: _nextCard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Следующая карта',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                widget.onComplete();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Завершить',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _getRarityName(Rarity rarity) {
  switch (rarity) {
    case Rarity.common:
      return 'Обычная';
    case Rarity.rare:
      return 'Редкая';
    case Rarity.epic:
      return 'Эпическая';
    case Rarity.legendary:
      return 'Легендарная';
  }
}

// И добавьте метод для получения названия типа:
String _getTypeName(CardType type) {
  switch (type) {
    case CardType.warrior:
      return 'Воин';
    case CardType.mage:
      return 'Маг';
    case CardType.archer:
      return 'Лучник';
    case CardType.assassin:
      return 'Убийца';
    case CardType.tank:
      return 'Танк';
    case CardType.support:
      return 'Поддержка';
    case CardType.knight:
      return 'Рыцарь';
    case CardType.archmage:
      return 'Архимаг';
    case CardType.sniper:
      return 'Снайпер';
    case CardType.ninja:
      return 'Ниндзя';
    case CardType.juggernaut:
      return 'Джаггернаут';
    case CardType.priest:
      return 'Жрец';
    case CardType.paladin:
      return 'Паладин';
    case CardType.sorcerer:
      return 'Чародей';
    case CardType.hawkeye:
      return 'Ястребиный глаз';
    case CardType.shadowblade:
      return 'Теневой клинок';
    case CardType.colossus:
      return 'Колосс';
    case CardType.druid:
      return 'Друид';
    case CardType.dragonknight:
      return 'Рыцарь-дракон';
    case CardType.phoenixmage:
      return 'Маг-феникс';
    case CardType.celestialarcher:
      return 'Небесный лучник';
    case CardType.voidassassin:
      return 'Ассасин пустоты';
    case CardType.titan:
      return 'Титан';
    case CardType.lifeweaver:
      return 'Ткач жизни';
  }
}
// }
