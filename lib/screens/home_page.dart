import 'package:flutter/material.dart';
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
  late Future<DatabaseServices> _dbServicesFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbServicesFuture = _initializeDbServices();
  }

  Future<DatabaseServices> _initializeDbServices() async {
    final dbServices = await DatabaseServices.constructor(widget.uuid);
    return dbServices;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DatabaseServices>(
      future: _dbServicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator.adaptive()),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final dbServices = snapshot.data;
          if (dbServices == null) {
            return const Text('Error in loading page');
          }
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
                          builder: (context) => SellItem(
                            dbServices: dbServices,
                          ),
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
                ],
              ),
            ),
          );
        } else {
          return const Text('No data');
        }
      },
    );
  }
}
