import 'package:flutter/material.dart';
import 'package:social_connect_hub/data/models/user.dart';
import 'package:social_connect_hub/domain/entities/user/user_entity.dart';
import 'package:social_connect_hub/domain/repositories/user/user_repository.dart';
import 'package:social_connect_hub/domain/usecases/user/search_users_usecase.dart';

class SearchService extends ChangeNotifier {
  UserRepository userRepository;
  SearchUsersUsecase searchUsersUsecase;
  List<UserEntity> searchedUsers = [];
  bool _isLoading = false;
  String? _errorMessage;


  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
  }

  SearchService(
      {required this.userRepository, required this.searchUsersUsecase});

  searchUsers(String searchKeyword) async {
    _isLoading = true;
    notifyListeners();
    var result = await searchUsersUsecase.call(searchKeyword);
    if (result.isSuccess) {
      result.fold(onSuccess: (success) => searchedUsers = success,
          onFailure: (failure) =>_errorMessage=failure.message);
      _isLoading = false;
      notifyListeners();
    }
    else{
      _isLoading = false;
      notifyListeners();
    }
  }

  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
  }
}