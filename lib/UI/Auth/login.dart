import 'package:buty/Base/AllTranslation.dart';
import 'package:buty/Bolcs/loginBloc.dart';
import 'package:buty/UI/Auth/forget_password.dart';
import 'package:buty/UI/Auth/sign_up.dart';
import 'package:buty/UI/CustomWidgets/CustomButton.dart';
import 'package:buty/UI/CustomWidgets/CustomTextFormField.dart';
import 'package:buty/UI/CustomWidgets/ErrorDialog.dart';
import 'package:buty/UI/CustomWidgets/LoadingDialog.dart';
import 'package:buty/helpers/appEvent.dart';
import 'package:buty/helpers/appState.dart';
import 'package:buty/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Image.asset(
              "assets/images/header.png",
              fit: BoxFit.contain,
              width: 150,
              height: 30,
            )),
        body: BlocListener(
            bloc: logInBloc,
            listener: (context, state) {
              var data = state.model as UserResponse;
              if (state is Loading) showLoadingDialog(context);
              if (state is ErrorLoading) {
                Navigator.of(context).pop();
                errorDialog(text: data.msg,
                );
              }
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              children: [
                rowItem(Icons.mail, allTranslations.text("email")),
                CustomTextField(
                  hint: "example@gmail.com",
                  value: (String val) {
                    setState(() {
                      email = val;
                    });
                    print(email);
                  },
                ),
                rowItem(Icons.lock, allTranslations.text("password")),
                CustomTextField(
                  value: (String val) {
                    setState(() {
                      password = val;
                    });
                    print(password);
                  },
                  hint: "************",
                ),
                CustomButton(
                  onBtnPress: () {
                    logInBloc.updateEmail(email);
                    logInBloc.updatePassword(password);
                    logInBloc.add(Click());
                  },
                  text: allTranslations.text("login"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgetPassword()));
                    },
                    child: Center(
                        child: Text(allTranslations.text("forget_password"))),
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                    child: Center(child: Text(allTranslations.text("no_acc")))),
              ],
            )));
  }

  Widget rowItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          )
        ],
      ),
    );
  }
}
