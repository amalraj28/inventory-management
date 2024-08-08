import 'package:flutter/material.dart';
import 'package:inventory_management/api/pdf_invoice_api.dart';
import 'package:inventory_management/db/data_models.dart';
import 'package:inventory_management/db/database_services.dart';
import 'package:inventory_management/exports/constants.dart';

class SaleListScreen extends StatefulWidget {
  final List<Map<String, Object>> items;
  const SaleListScreen({super.key, required this.items});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  final List<Map<String, Object>> userChecked = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items sold today'),
        actions: [
          userChecked.isEmpty
              ? const SizedBox(
                  height: 0,
                  width: 0,
                )
              : TextButton(
                  child: const Text(
                    'Print',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    await _fillSupplierDetails(context);
                  },
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
                  title: Text(item['itemName'].toString()),
                  subtitle: Text(
                    'Sold: ${item['soldStock']}',
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

  void _onSelected(bool selected, Map<String, Object> dataName) {
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
    final buyerNameController = TextEditingController();
    final buyerAddressController = TextEditingController();
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
                      controller: buyerNameController,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        buyerNameController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection: buyerNameController.selection,
                        );
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Buyer Name (Optional)',
                        icon: Icon(Icons.assignment_ind),
                      ),
                    ),
                    TextFormField(
                      controller: buyerAddressController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Buyer Address (Optional)',
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

                        final dbMap = DatabaseServices.getEntries();

                        final items = userChecked
                            .map(
                              (item) => InvoiceItem(
                                description: item['itemName'].toString(),
                                date: DateTime.now(),
                                quantity: item['soldStock'] as int,
                                vat: 0,
                                unitPrice: dbMap[item['itemName'].toString()]![
                                    'salePrice'] as num,
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
                            name: OUR_NAME,
                            address: OUR_ADDRESS,
                            paymentInfo:
                                paymentInfoController.text.toUpperCase(),
                          ),
                          customer: Customer(
                            address: buyerAddressController.text,
                            name: buyerNameController.text,
                          ),
                          items: items,
                        );

                        await PdfInvoiceApi.generate(
                          invoice,
                          dueDateNeeded: false,
                        );

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
                if (isCompleted)
                  const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
