import 'package:wealth_wise/models/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:wealth_wise/widgets/update_form.dart';
import '../../models/ex_category.dart';
import '../../models/expense.dart';

class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final int index;
  final String prevTitle;
  const CategoryCard(this.category, this.index, this.prevTitle, {super.key});

  @override
  Widget build(BuildContext context) {
    // UPDATE NEW
    final _title = TextEditingController();
    final _amount = TextEditingController();
    DateTime? _date;
    String _initialValue = 'Other';

    var db = Provider.of<DatabaseProvider>(context);

    return Slidable(
      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              db.deleteCategory(category.title);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      startActionPane: ActionPane(motion: ScrollMotion(), children: [
        SlidableAction(
          onPressed: (context) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              // builder: (_) => const UpdateForm(),
              builder: (BuildContext context) {
                // UPDATE FORM
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
                        const SizedBox(height: 20.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            print("*****************************************");
                            // print(prevTitle);
                            // print(index);
                            db.viewDatabaseContents();
                            print("*****************************************");

                            if (_title.text != '' && _amount.text != '') {
                              // create an expense
                              final file = Expense(
                                id: 0,
                                title: _title.text,
                                amount: double.parse(_amount.text),
                                date: _date ?? DateTime.now(),
                                category: _initialValue,
                              );

                              db.updateExpense(prevTitle, _title.text, double.parse(_amount.text));

                              // db.updateExpense(index, category.title, _title.text, double.parse(_amount.text));
                              // add it to database.
                              // provider.addExpense(file);
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
                          label: const Text('Update Expense'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            // db.updateCategory(category, nEntries., nTotalAmount)
          },
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          icon: Icons.update,
          label: 'Update',
        )
      ]),

      child: ListTile(
        onTap: () {
          // Navigator.of(context).pushNamed(
          //   ExpenseScreen.name,
          //   arguments: category.title, // for expensescreen.
          // );
        },
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(category.icon),
        ),
        title: Text(category.title),
        subtitle: Text('entries: ${category.entries}'),
        trailing: Text(
          NumberFormat.currency(locale: 'en_NP', symbol: 'Rs ').format(category.totalAmount),
        ),
      ),
    );
  }
}
