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

  postSale(Map<String, dynamic> data, {String modeOfPayment}) async {
    data['warehouseId'] = _user.salesChannel;
    return await _api.makePayment(
        modeOfPayment: modeOfPayment, data: data, token: _user.token);
  }

  fulfillDeliveryNotePayment(Map<String, dynamic> data) async {
    // data['warehouseId'] = _user.salesChannel;
    return await _api.makeDeliveryNotePayment(data: data, token: _user.token);
  }

  fetchQuotationList() async {
    return await _api.fetchQuotations(_user.token);
  }

  fetchProductsByDefaultPriceList({@required String defaultStock}) async {
    var result = await _api.fetchProductsByPriceList(_user.token, defaultStock);
    return result;
  }

  listAllItems() async {
    var result = await _api.fetchAllProducts(_user.token);
    return result;
  }

  void createNewQuotation(Map<String, dynamic> data) async {
    data['warehouse'] = _user.salesChannel;
    var result = await _api.generateQuotation(_user.token, data);
    return result;
  }

  getQuotationDetail(String quotationId) async {
    return await _api.getQuotationById(_user.token, quotationId);
  }

  generateInvoiceFromQuotation(Map<String, dynamic> data) async {
    data['warehouse'] = _user.branch;
    return await _api.createNewDeliveryNoteFromQuotation(_user.token, data);
  }
}
