import 'package:provider/provider.dart';
import 'package:wealth_wise/main.dart';
import 'package:wealth_wise/models/database_provider.dart';
import 'package:wealth_wise/models/users.dart';
import 'package:wealth_wise/register.dart';
import 'package:wealth_wise/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  static const name = '/login';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  // track successful login
  bool success = false;

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
              'Login to your app',
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
                      } else if (!success) {
                        return 'Incorrect email or password';
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
                      if (!success) {
                        return 'Incorrect email or password';
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
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 28.0,
                  child: Text(
                    "Don't have an account? Register",
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
                onPressed: () async {
                  // create a user
                  final user = Users(
                    username: _email.text,
                    password: _password.text,
                  );
                  // login
                  bool loginSuccess = await provider.login(user);
                  if (loginSuccess) {
                    setState(() {
                      success = true;
                    });
                  } else {
                    setState(() {
                      success = false;
                    });
                  }
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    // close the bottomsheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'LOGIN',
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
