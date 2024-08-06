import 'package:flutter/material.dart';
import 'package:inventory_management/api/pdf_invoice_api.dart';
import 'package:inventory_management/db/data_models.dart';
import 'package:inventory_management/exports/exports.dart';

class CartScreen extends StatefulWidget {
  final List<StockData> items;
  const CartScreen({super.key, required this.items});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<StockData> userChecked = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          userChecked.isEmpty
              ? const SizedBox(
                  height: 0,
                  width: 0,
                )
              : TextButton(
                  onPressed: () => _fillSupplierDetails(context),
                  child: const Text(
                    'Print',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
      body: widget.items.isEmpty
          ? const Center(
              child: Text(
                'No items in the cart',
                style: TextStyle(fontSize: 24),
              ),
            )
          : ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return ListTile(
                  title: Text(item.itemName),
                  subtitle: Text(
                    'Available: ${item.availableStock}, Sold: ${item.soldStock}',
                  ),
                  trailing: Checkbox(
                    value: userChecked.contains(item),
                    onChanged: (val) {
                      _onSelected(val!, item);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _onSelected(bool selected, StockData dataName) {
    if (selected == true) {
      setState(() {
        userChecked.add(dataName);
      });
    } else {
      setState(() {
        userChecked.remove(dataName);
      });
    }
  }

  Future<void> _fillSupplierDetails(BuildContext context) async {
    final companyController = TextEditingController();
    final companyAddressController = TextEditingController();
    final paymentInfoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        bool isLoading = false;
        bool isCompleted = false;

        return StatefulBuilder(
          builder: (BuildContext ctx1, StateSetter setState) {
            return AlertDialog(
              title: const Text('Fill up details'),
              scrollable: true,
              content: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: companyController,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        companyController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: companyController.selection,
                        );
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a valid name'
                          : null,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Supplier Name',
                        icon: Icon(Icons.assignment_ind),
                      ),
                    ),
                    TextFormField(
                      controller: companyAddressController,
                      maxLines: null,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a valid address'
                          : null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Supplier Address',
                        icon: Icon(Icons.mail),
                      ),
                    ),
                    TextFormField(
                      controller: paymentInfoController,
                      maxLines: 1,
                      onChanged: (value) {
                        paymentInfoController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: paymentInfoController.selection,
                        );
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a valid payment method'
                          : null,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Payment method',
                        icon: Icon(Icons.payment),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (!isLoading && !isCompleted)
                  TextButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        final items = userChecked
                            .map(
                              (item) => InvoiceItem(
                                description: item.itemName,
                                date: DateTime.now(),
                                quantity: item.availableStock,
                                vat: 0,
                                unitPrice: item.purchasePrice,
                              ),
                            )
                            .toList();

                        final invoice = Invoice(
                          info: InvoiceInfo(
                            description: '10',
                            number: 10,
                            date: DateTime.now(),
                            dueDate: DateTime.now(),
                          ),
                          supplier: Supplier(
                            name: companyController.text,
                            address: companyAddressController.text,
                            paymentInfo:
                                paymentInfoController.text.toUpperCase(),
                          ),
                          customer: Customer(
                            address: OUR_ADDRESS,
                            name: OUR_NAME,
                          ),
                          items: items,
                        );

                        await PdfInvoiceApi.generate(invoice);

                        setState(() {
                          isLoading = false;
                          isCompleted = true;
                        });

                        await Future.delayed(const Duration(milliseconds: 500));

                        if (ctx1.mounted) Navigator.of(ctx1).pop();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                if (isLoading) const CircularProgressIndicator(),
                if (isCompleted) const Icon(Icons.check, color: Colors.green),
              ],
            );
          },
        );
      },
    );
  }
}
