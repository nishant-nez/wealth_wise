import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/database_provider.dart';
import '../constants/icons.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _date;
  String _initialValue = 'Other';

  //
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(27.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // title
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title of expense',
              ),
            ),
            const SizedBox(height: 20.0),
            // amount
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount of expense',
              ),
            ),
            const SizedBox(height: 20.0),
            // date picker

            const SizedBox(height: 20.0),
            // category
            // Row(
            //   children: [
            //     const Expanded(child: Text('Category')),
            //     Expanded(
            //       child: DropdownButton(
            //         items: icons.keys
            //             .map(
            //               (e) => DropdownMenuItem(
            //                 value: e,
            //                 child: Text(e),
            //               ),
            //             )
            //             .toList(),
            //         value: _initialValue,
            //         onChanged: (newValue) {
            //           setState(() {
            //             _initialValue = newValue!;
            //           });
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                if (_title.text != '' && _amount.text != '') {
                  // create an expense
                  final file = Expense(
                    id: 0,
                    title: _title.text,
                    amount: double.parse(_amount.text),
                    date: _date != null ? _date! : DateTime.now(),
                    category: _initialValue,
                  );
                  // add it to database.
                  provider.addExpense(file);
                  // close the bottomsheet
                  Navigator.of(context).pop();
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Color.fromRGBO(54, 137, 131, 50),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
