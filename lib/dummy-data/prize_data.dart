import 'package:pbp/models/prize_details.dart';

final List<ItemPrize> dummyItemPrizes = [
  ItemPrize(
    name: 'Gold Coin',
    imageUrl: 'assets/items/gold_coin.png',
    description: '24K Gold Coin',
  ),
  ItemPrize(
    name: 'Silver Coin',
    imageUrl: 'assets/items/silver_coin.png',
    description: '99.9% Pure Silver',
  ),
  ItemPrize(
    name: 'Gift Voucher',
    imageUrl: 'assets/items/gift_voucher.png',
    description: '₹1000 Shopping Voucher',
  ),
  ItemPrize(
    name: 'Electronics',
    imageUrl: 'assets/items/electronics.png',
    description: 'Latest Gadget',
  ),
];

final MoneyPrizes defaultMoneyPrizes = MoneyPrizes(
  firstJaldiFive: 100.0,
  secondJaldiFive: 50.0,
  thirdJaldiFive: 25.0,
  firstTopLine: 200.0,
  secondTopLine: 100.0,
  firstMiddleLine: 200.0,
  secondMiddleLine: 100.0,
  firstLastLine: 200.0,
  secondLastLine: 100.0,
  firstHousy: 1000.0,
  secondHousy: 500.0,
  thirdHousy: 250.0,
  fourthHousy: 100.0,
);
