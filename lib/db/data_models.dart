import 'dart:convert';

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
        'salePrice': salePrice,
      };

  factory StockData.fromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;

    return StockData(
      itemName: data['itemName'] ?? '',
      availableStock: data['availableStock'] ?? 0,
      salePrice: data['salePrice'] ?? 0,
      purchasePrice: data['purchasePrice'] ?? 0,
    );
  }

  String getName() => itemName;
}

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final int number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

class InvoiceItem {
  final String description;
  final DateTime date;
  final int quantity;
  final num vat;
  final num unitPrice;

  const InvoiceItem({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}

class Supplier {
  final String name;
  final String address;
  final String paymentInfo;

  const Supplier({
    required this.name,
    required this.address,
    required this.paymentInfo,
  });
}

class Customer {
  final String name;
  final String address;

  const Customer({
    required this.name,
    required this.address,
  });
}
