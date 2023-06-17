import 'package:provider/provider.dart';
import 'package:wealth_wise/login.dart';
import 'package:wealth_wise/models/users.dart';
import 'package:wealth_wise/screens/category_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'models/database_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Wealth Wise',
              style: TextStyle(
                color: Color.fromRGBO(54, 137, 131, 50),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Register an account',
              style: TextStyle(color: Color.fromRGBO(54, 137, 131, 50), fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 44.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'User Email',
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Color.fromRGBO(54, 137, 131, 50),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'User Password',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Color.fromRGBO(54, 137, 131, 50),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 18.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 28.0,
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Color.fromRGBO(54, 137, 131, 50)),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: RawMaterialButton(
                fillColor: const Color.fromRGBO(54, 137, 131, 50),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // create an expense
                    final file = Users(
                      username: _email.text,
                      password: _password.text,
                    );
                    // add it to database.
                    provider.register(file);
                    // close the bottomsheet
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
