class StockData {
  final String itemName;
  final num itemCount;
  final num itemPrice;

  StockData({
    required this.itemName,
    required this.itemCount,
    required this.itemPrice,
  });

  Map<String, Object> toJson() => {
        'initQuantity': itemCount,
        'remQuantity': itemCount,
        'costPrice': itemPrice,
        'sellingPrice': itemPrice,
      };

  String getName() => itemName;
}
