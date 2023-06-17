import 'package:wealth_wise/constants/icons.dart';
import 'package:wealth_wise/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import '../widgets/category_screen/category_fetcher.dart';
import '../widgets/expense_form.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  static const name = '/category_screen'; // for routes
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                provider.resetActiveUsers();
              },
              icon: const Icon(Icons.logout))
        ],
        title: const Text('Wealth Wise'),
        backgroundColor: const Color.fromRGBO(554, 137, 131, 100),
      ),
      body: const CategoryFetcher(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(554, 137, 131, 100),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ExpenseForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
