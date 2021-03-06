import 'package:example_navigator_20/common/app_session.dart';
import 'package:example_navigator_20/constraints/preference_key.dart';
import 'package:example_navigator_20/data/cubit/navigator/navigator_cubit.dart';
import 'package:example_navigator_20/data/model/sign_in/login_params.dart';
import 'package:example_navigator_20/data/model/sign_in/login_response.dart';
import 'package:example_navigator_20/data/repository/app_repository.dart';
import 'package:example_navigator_20/screens/authorized/main_app.dart';
import 'package:example_navigator_20/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  AppRepository _appRepository = AppRepository();

  SignInCubit() : super(InitState());

  void saveUser(String user) {
    emit(SaveTextState(state.dataSignIn.copyWith(userName: user)));
  }

  void savePass(String pass) {
    emit(SaveTextState(state.dataSignIn.copyWith(passWord: pass)));
  }

  Future<void> doLogin(BuildContext context) async {
    if (!validateUserName(state.dataSignIn.userName)) {
      emit(ValidateState(state.dataSignIn.copyWith(errorText: 'User error')));
      return;
    }
    if (!validatePassword(state.dataSignIn.passWord)) {
      emit(ValidateState(state.dataSignIn.copyWith(errorText: 'Pass error')));
      return;
    }
    emit(LoadingState(state.dataSignIn.copyWith(isLoading: true,messageError: '',errorText: '')));
    final resultLogin = await _appRepository.signIn(
        LoginParams(
            username: state.dataSignIn.userName,
            password:  state.dataSignIn.passWord
        ).toJson()
    );
    emit(LoadingState(state.dataSignIn.copyWith(isLoading: false)));
    if (resultLogin.code == 200) {
      LoginResponse response = LoginResponse.fromJson(resultLogin.data);
      AppSession().box.put(PreferenceKey.TOKEN, response.access);
      AppSession().token = response.access;
      NaCubit.of(context).replace(MainApp());
    } else {
      emit(ErrorState(state.dataSignIn.copyWith(messageError: resultLogin.message)));
    }
  }

}

