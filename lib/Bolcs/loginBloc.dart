import 'package:bloc/bloc.dart';
import 'package:buty/helpers/appEvent.dart';
import 'package:buty/helpers/appState.dart';
import 'package:buty/helpers/shared_preference_manger.dart';
import 'package:buty/repo/user_repo.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class LogInBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => Start(null);

  final email = BehaviorSubject<String>();
  final password = BehaviorSubject<String>();
  Function(String) get updateEmail => email.sink.add;
  Function(String) get updatePassword => password.sink.add;

  String msg;

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is Click) {
      yield (Start(null));
      yield Loading(null);
      var userResponee = await UserDataRepo.LOGIN(email.value, password.value);
      print("LogIn ResPonse" + userResponee.msg);
      if (userResponee.status == true) {
        SharedPreferenceManager preferenceManager = SharedPreferenceManager();
        preferenceManager.writeData(CachingKey.IS_LOGGED_IN, true);
        preferenceManager.writeData(CachingKey.AUTH_TOKEN, "Bearer ${userResponee.user.accessToken}");
        preferenceManager.writeData(CachingKey.USER_NAME, userResponee.user.name);
        preferenceManager.writeData(CachingKey.EMAIL, userResponee.user.email);
        preferenceManager.writeData(CachingKey.MOBILE_NUMBER, userResponee.user.mobile);
        yield Done(userResponee);
      } else if (userResponee.status == false) {
        print("Message   ");
        yield ErrorLoading(userResponee);
      }
    }
  }

  dispose() {
    email.close();
    password.close();
  }
}

final logInBloc = LogInBloc();
