import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';

final serverIp = dotenv.get('API_URL');
const storage = FlutterSecureStorage();

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  Future<String?> attemptLogIn(String username, String password) async {
    var res = await http.post(Uri.parse("$serverIp/login"),
        body: {"username": username, "password": password});
    if (res.statusCode == 200) return res.body;
    return null;
  }

  Future<int> attemptSignUp(String username, String password) async {
    var res = await http.post(Uri.parse("$serverIp/signup"),
        body: {"username": username, "password": password});
    return res.statusCode;
  }

  void onLogin(BuildContext context) async {
    var username = _usernameController.text;
    var password = _passwordController.text;
    var jwt = await attemptLogIn(username, password);
    if (jwt != null) {
      storage.write(key: "jwt", value: jwt);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomePage.fromBase64(jwt)));
    } else {
      displayDialog(context, "An Error Occurred",
          "No account was found matching that username and password");
    }
  }

  void onSignUp(BuildContext context) async {
    var username = _usernameController.text;
    var password = _passwordController.text;

    if (username.length < 4) {
      displayDialog(context, "Invalid Username",
          "The username should be at least 4 characters long");
    } else if (password.length < 4) {
      displayDialog(context, "Invalid Password",
          "The password should be at least 4 characters long");
    } else {
      var res = await attemptSignUp(username, password);
      if (res == 201) {
        displayDialog(context, "Success", "The user was created. Log in now.");
      } else if (res == 409) {
        displayDialog(context, "That username is already registered",
            "Please try to sign up using another username or log in if you already have an account.");
      } else {
        displayDialog(context, "Error", "An unknown error occurred.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Log In"),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(
              50.0, MediaQuery.of(context).size.height * 0.3, 50.0, 20.0),
          child: Column(
            children: [
              Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(
                    height: 35,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => onLogin(context),
                      child: const Text("Log In")),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () => onSignUp(context),
                      child: const Text("Sign Up"))
                ],
              )
            ],
          ),
        ));
  }
}
