import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pedagogie/models/user.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pedagogie/pages/home_page.dart';
// import 'package:flutter/src/widgets/framework.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String url = "http://192.168.2.104:8080/api";
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [Colors.green, Colors.white])),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: _page(),
          )),
    );
  }

  void login(String email, password) async {
    try {
      Response response = await post(Uri.parse("$url/login"),
          body: {'email': email, 'password': password});
      var responseData = jsonDecode(response.body);
      var userJson = responseData["data"]["user"];
      // debugPrint(responseData.toString());
      UserData user = UserData(
          nom: userJson["nom"],
          email: userJson["email"],
          role: userJson["role"],
          id: userJson["id"]);
      debugPrint(response.body);
      String token = responseData["data"]["token"]; // debugPrint(user.toString());
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    userData: user,
                    token: token,
                  )),
        );
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _icon(),
          const SizedBox(
            height: 50,
          ),
          _inputField("Email", emailController),
          const SizedBox(
            height: 20,
          ),
          _inputField("Password", passwordController, isPassword: true),
          const SizedBox(
            height: 50,
          ),
          _loginButton(),
          const SizedBox(
            height: 20,
          )
        ]),
      ),
    );
  }

  Widget _icon() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          shape: BoxShape.circle),
      child: const Icon(Icons.person, color: Colors.white, size: 120),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {isPassword = false}) {
    var border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white));
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
           suffixIcon: IconButton(
                 onPressed: controller.clear,
                 icon: const Icon(Icons.clear),
               ),
          hintStyle: const TextStyle(color: Colors.white),
          enabledBorder: border,
          focusedBorder: border),
      obscureText: isPassword,
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          login(emailController.text.toString(),
              passwordController.text.toString());
        });
      },
      style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16)),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Sign in",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
