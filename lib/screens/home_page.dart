import 'package:flutter/material.dart';
import 'package:inventory_management/db/database_services.dart';
import 'package:inventory_management/screens/sign_in.dart';
import 'package:inventory_management/screens/sell_item.dart';
import 'package:inventory_management/screens/sign_up.dart';
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
                    builder: (context) => SellItem(dbServices),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => SignIn(),
                  ),
                );
              },
              child: const Text('Login Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const SignUp(),
                  ),
                );
              },
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
