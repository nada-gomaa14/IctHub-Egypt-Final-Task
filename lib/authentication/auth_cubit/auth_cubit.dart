import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:final_task/authentication/auth_cubit/auth_cubit_states.dart';
import 'package:final_task/authentication/models/user_model.dart';
import 'package:final_task/functions/notify.dart';


class AuthCubit extends Cubit<AuthStates> {
  AuthCubit(): super(AuthInitialState());
  bool isObscure = true;
  Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://rzbxwxguxqwtsnsbymbq.supabase.co/auth/v1/',
      headers: {
        'apikey' : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50d2Z2YWRyaGR0c2J6eWl3bWJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczNzQ1OTYsImV4cCI6MjA5Mjk1MDU5Nn0.WFunSD0R5nfSnpF_KOh5wAeSqWEgg3QCQC6PcjEisAU'
      }
    )
  );

  void changePasswordVisibility() {
    isObscure = !isObscure;
    emit(PasswordVisibilityState());
  }

  void resetPasswordVisibility() {
    isObscure = true;
    emit(PasswordVisibilityState());
  }

  UserModel? userModel;

  Future<void> register({required Map<String, dynamic> user}) async {
    emit(RegisterLoadingState());
    try {
      Response response = await dio.post(
        'signup',
        data: user
      );
      emit(RegisterSuccessState());
      userModel = UserModel.fromJson(json: response.data);
    }
    catch(e){
      emit(RegisterErrorState(error: e.toString()));
    }
  }

  Future<void> login({required Map<String, dynamic> user}) async {
    emit(LoginLoadingState());
    try {
      Response response = await dio.post(
        'token?grant_type=password',
        data: user
      );
      emit(LoginSuccessState());
      userModel = UserModel.fromJson(json: response.data);
    }
    catch(e) {
      emit(LoginErrorState(error: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(LogoutLoadingState());
    try {
      Response response = await dio.post(
        'logout',
        options: Options(
          headers: {
            'Authorization' : 'Bearer ${userModel?.accessToken}'
          }
        )
      );
      if(response.statusCode == 204){
        emit(LogoutSuccessState());
      }
      else {
        throw 'Failed to logout.';
      }
    }
    catch (e) {
      emit(LogoutErrorState(error: e.toString()));
    }
  }
}
