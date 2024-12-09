import 'package:distributor/app/locator.dart';
import 'package:distributor/services/api_service.dart';
import 'package:distributor/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:tripletriocore/tripletriocore.dart';

/// Responsible for interactions with other services in respect to products
@lazySingleton
class ProductService {
  ApiService _apiService = locator<ApiService>();
  UserService _userService = locator<UserService>();
  Api get _api => _apiService.api;
  User get _user => _userService.user;

  fetchProductsByPriceList(Customer customer) async {
    var result = await _api.fetchProductsByPriceList(
        _user.token, customer?.defaultPriceList ?? "walk in");
    return result;
  }

  fetchProductsByDefaultPriceList({@required String defaultStock}) async {
    var result = await _api.fetchProductsByPriceList(_user.token, defaultStock);
    return result;
  }

  listAllItems() async {
    var result = await _api.fetchAllProducts(_user.token);
    return result;
  }
}
