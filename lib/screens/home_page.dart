import 'package:flutter/material.dart';
import 'package:inventory_management/db/data_models.dart';
import 'package:inventory_management/db/database_services.dart';
import 'package:inventory_management/screens/sell_item.dart';
import 'package:inventory_management/screens/stock_entry.dart';

class MyHomePage extends StatefulWidget {
  final String uuid;
  const MyHomePage(this.uuid, {super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseServices dbServices;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbServices = DatabaseServices(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Inventory Management',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellItem(),
                  ),
                )
              },
              child: const Text(
                'Sell Item',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockEntry(dbServices),
                  ),
                )
              },
              child: const Text(
                'Add to Stock',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                StockData data = StockData(
                  itemName: 'rubber',
                  itemCount: 15,
                  itemPrice: 20,
                );

                dbServices.create(data);
              },
              child: const Text('Create'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                DatabaseServices dbServices = DatabaseServices('amal');
                final data = await dbServices.read('rubber');
                print(data);
              },
              child: const Text('Read'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                DatabaseServices dbServices = DatabaseServices('amal');
                final data =
                    await dbServices.update('rubber', {'initQuantity': 100});
                print(data);
              },
              child: const Text('Update'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                DatabaseServices dbServices = DatabaseServices('amal');
                final data = await dbServices.delete('rubber');
                print(data);
              },
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }
}