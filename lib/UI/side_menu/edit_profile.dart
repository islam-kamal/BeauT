import 'package:buty/Base/shared_preference_manger.dart';
import 'package:buty/Bolcs/update_profile_bloc.dart';
import 'package:buty/UI/CustomWidgets/CustomButton.dart';
import 'package:buty/UI/CustomWidgets/CustomTextFormField.dart';
import 'package:buty/UI/CustomWidgets/ErrorDialog.dart';
import 'package:buty/UI/CustomWidgets/LoadingDialog.dart';
import 'package:buty/UI/CustomWidgets/on_done_dialog.dart';
import 'package:buty/UI/bottom_nav_bar/main_page.dart';
import 'package:buty/helpers/appEvent.dart';
import 'package:buty/helpers/appState.dart';
import 'package:buty/models/updateProfileResponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String type = "data";
  GlobalKey<FormState> dataKey = GlobalKey();
  GlobalKey<FormState> passKey = GlobalKey();

  String name, email, phone;
  String IsLogged;

  getFromCash() async {
    String _name, _email, _phone;
    var mSharedPreferenceManager = SharedPreferenceManager();
    _email = await mSharedPreferenceManager.readString(CachingKey.EMAIL);
    _phone =
        await mSharedPreferenceManager.readString(CachingKey.MOBILE_NUMBER);
    _name = await mSharedPreferenceManager.readString(CachingKey.USER_NAME);
    var logged =
        await mSharedPreferenceManager.readString(CachingKey.AUTH_TOKEN);
    print("USER STATUS${logged != null ? false : true}");
    setState(() {
      name = _name;
      email = _email;
      phone = _phone;
      IsLogged = logged.toString();
    });
  }

  @override
  void initState() {
    getFromCash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: translator.currentLanguage=="ar"?TextDirection.rtl :TextDirection.ltr,

      child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                Padding(padding: EdgeInsets.only(right: 10,left: 10),
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainPage(
                                  index: 0,
                                )));
                      },
                      child:  Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      )),)
              ],
              centerTitle: true,
              title: Text(
                translator.translate("edit_profile"),
                style: TextStyle(color: Colors.white, fontSize: 14),
              )),
          body: IsLogged == false
              ? Center(
                  child: Text(translator.currentLanguage == "ar"
                      ? "الرجاء تسجيل الدخول اولاً"
                      : "Please Log In First"),
                )
              : ListView(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              type = "data";
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  translator.translate("edit_profile"),
                                  style: TextStyle(
                                      fontWeight: type == "data"
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: 2,
                                  color: type == "data"
                                      ? Colors.black
                                      : Colors.grey[200],
                                )
                              ],
                            ),
                            width: MediaQuery.of(context).size.width / 2,
                            height: 40,
                            color: Colors.grey[200],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              type = "last";
                            });
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  translator.translate("password"),
                                  style: TextStyle(
                                      fontWeight: type == "last"
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height: 2,
                                  color: type == "last"
                                      ? Colors.black
                                      : Colors.grey[200],
                                )
                              ],
                            ),
                            width: MediaQuery.of(context).size.width / 2,
                            height: 40,
                            color: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                    type == "data"
                        ? editDataView(name, email, phone)
                        : passView(),
                    BlocListener(
                      bloc: updateProfileBloc,
                      listener: (context, state) {
                        var data = state.model as UpadteProfileResponse;
                      if (state is Done) {
                        Navigator.pop(context);
                          onDoneDialog(
                              context: context,
                              text: data.msg,
                              function: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainPage(
                                        index: 0,
                                      ),
                                    ),
                                    (Route<dynamic> route) => false);
                              });
                        }
                      },
                      child: CustomButton(
                        onBtnPress: () {
                          showLoadingDialog(context);
                          if (type == "data") {
                            if (!dataKey.currentState.validate()) {
                              return;
                            } else {
                              updateProfileBloc.add(Click());
                            }
                          } else {
                            if (!passKey.currentState.validate()) {
                              return;
                            } else {
                              updateProfileBloc.add(Click());
                            }
                          }
                        },
                        text: translator.translate("change"),
                      ),
                    )
                  ],
                )),
    );
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

  Widget editDataView(String name, String email, String phone) {
    return Form(
      key: dataKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: rowItem(Icons.person, translator.translate("name")),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomTextField(
              value: (String val) {
                updateProfileBloc.updateName(val);
              },
              validate: (String val) {
                if (val.isNotEmpty && val.length < 3) {
                  return "      ";
                }
              },
              hint: "${name ?? " "}",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: rowItem(Icons.phone, translator.translate("phone")),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomTextField(
              value: (String val) {
                updateProfileBloc.updateMobile(val);
              },
              validate: (String val) {
                if (val.isNotEmpty && val.length < 10) {
                  return "      ";
                }
              },
              hint: "+${phone ?? ""}",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: rowItem(Icons.mail, translator.translate("email")),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomTextField(
              value: (String val) {
                updateProfileBloc.updateEmail(val);
              },
              validate: (String val) {
                if (val.isNotEmpty && val.contains("@") == false) {
                  return "      ";
                }
              },
              hint: "${email}",
            ),
          ),
        ],
      ),
    );
  }

  Widget passView() {
    return Form(
      key: passKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child:
                rowItem(Icons.lock, translator.translate("current_password")),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomTextField(
              value: (String val) {
                updateProfileBloc.updateCurrentPassword(val);
              },
              validate: (String val) {
                if (val.isNotEmpty && val.length < 8) {
                  return "      ";
                }
              },
              secureText: true,
              hint: "*****************",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: rowItem(Icons.lock, translator.translate("new_password")),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomTextField(
              value: (String val) {
                updateProfileBloc.updateNewPassword(val);
              },
              validate: (String val) {
                if (val.isNotEmpty && val.length < 8) {
                  return "      ";
                }
              },
              secureText: true,
              hint: "*****************",
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: rowItem(
                Icons.lock, translator.translate("confirm_new_password")),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomTextField(
              value: (String val) {
                updateProfileBloc.updateConfirmPassword(val);
              },
              validate: (String val) {
                if (val.isNotEmpty && val.length < 8) {
                  return "      ";
                }
              },
              secureText: true,
              hint: "*****************",
            ),
          ),
        ],
      ),
    );
  }

// Widget phoneVerifyCodeSheet() {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       SizedBox(),
//       Text(
//          translator.translate("confirm_change_phone"),
//         style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//       ),
//       Text( translator.translate("enter_code")),
//       Container(
//           width: double.infinity,
//           height: 100,
//           child: Center(
//             child: PinCodeTextField(
//               pinBoxWidth: 60,
//               pinBoxHeight: 60,
//               pinBoxColor: Colors.white,
//               onDone: (String value) {},
//               defaultBorderColor: Theme.of(context).primaryColor,
//               pinBoxRadius: 10,
//               highlightPinBoxColor: Colors.grey[50],
//               hasTextBorderColor: Theme.of(context).primaryColor,
//               // controller: code,
//               pinTextStyle: TextStyle(
//                   color: Theme.of(context).primaryColor, fontSize: 18),
//               textDirection: TextDirection.ltr,
//               keyboardType: TextInputType.phone,
//             ),
//           )),
//       CustomButton(
//         text:  translator.translate("confirm"),
//       ),
//       Text( translator.translate("resend_code")),
//       SizedBox(),
//     ],
//   );
// }
}
