class StockData {
  final String itemName;
  final int availableStock;
  final num salePrice;
  final num purchasePrice;
  int soldStock;

  StockData({
    required this.itemName,
    required this.availableStock,
    required this.salePrice,
    required this.purchasePrice,
    this.soldStock = 0,
  });

  Map<String, Object> toJson() => {
        'availableStock': availableStock, 
        'soldStock': soldStock,
        'purchasePrice': purchasePrice,
        'sellingPrice': salePrice,
      };

  String getName() => itemName;
}
