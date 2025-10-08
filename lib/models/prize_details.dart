class PrizeDetails {
  final String gameType;
  final int playerCount;
  final MoneyPrizes moneyPrizes;
  final List<ItemPrize> itemPrizes;

  PrizeDetails({
    required this.gameType,
    required this.playerCount,
    required this.moneyPrizes,
    required this.itemPrizes,
  });
}

class MoneyPrizes {
  double? firstJaldiFive;
  double? secondJaldiFive;
  double? thirdJaldiFive;
  double? firstTopLine;
  double? secondTopLine;
  double? firstMiddleLine;
  double? secondMiddleLine;
  double? firstLastLine;
  double? secondLastLine;
  double? firstHousy;
  double? secondHousy;
  double? thirdHousy;
  double? fourthHousy;

  MoneyPrizes({
    this.firstJaldiFive,
    this.secondJaldiFive,
    this.thirdJaldiFive,
    this.firstTopLine,
    this.secondTopLine,
    this.firstMiddleLine,
    this.secondMiddleLine,
    this.firstLastLine,
    this.secondLastLine,
    this.firstHousy,
    this.secondHousy,
    this.thirdHousy,
    this.fourthHousy,
  });
}

class ItemPrize {
  final String name;
  final String imageUrl;
  final String description;

  ItemPrize({
    required this.name,
    required this.imageUrl,
    required this.description,
  });
}
