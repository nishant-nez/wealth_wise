import 'package:wealth_wise/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/database_provider.dart';
// screens
import './screens/category_screen.dart';

import './screens/all_expenses.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => DatabaseProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: HomePage.name,
      routes: {
        HomePage.name: (_) => const HomePage(),
        CategoryScreen.name: (_) => const CategoryScreen(),
        AllExpenses.name: (_) => const AllExpenses(),
      },
    );
  }
}
