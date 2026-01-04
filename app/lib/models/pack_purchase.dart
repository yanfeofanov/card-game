import 'package:card_game/models/card.dart';

class PackPurchase {
  final int id; // Добавляем ID покупки
  final String packName;
  final List<CardModel> cards;
  final int costGold;
  final int costGems;
  final DateTime purchaseDate;

  PackPurchase({
    required this.id,
    required this.packName,
    required this.cards,
    required this.costGold,
    required this.costGems,
    required this.purchaseDate,
  });

  factory PackPurchase.fromJson(Map<String, dynamic> json) {
    // Если cards уже пришли как модели карт
    if (json['cards'] is List<CardModel>) {
      return PackPurchase(
        id: json['id'] as int,
        packName: json['pack_name'],
        cards: json['cards'] as List<CardModel>,
        costGold: json['cost_gold'] ?? 0,
        costGems: json['cost_gems'] ?? 0,
        purchaseDate: DateTime.parse(json['purchase_date']),
      );
    }

    // Если cards - это массив ID карт (старый вариант)
    return PackPurchase(
      id: json['id'] as int,
      packName: json['pack_name'],
      cards: [], // Пустой массив, карты нужно будет загрузить отдельно
      costGold: json['cost_gold'] ?? 0,
      costGems: json['cost_gems'] ?? 0,
      purchaseDate: DateTime.parse(json['purchase_date']),
    );
  }
}
