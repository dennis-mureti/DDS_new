import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class ReturnStockTileViewmodel extends BaseViewModel {
  Product product;
  final int maxQuantity;
  final Item item;
  final Function onChange;
  int _quantity = 0;
  int get quantity => _quantity;

  ReturnStockTileViewmodel(Product product, Function onChange)
      : product = product,
        maxQuantity = product.quantity.toInt(),
        onChange = onChange,
        item = Item(
            id: product.itemCode,
            itemCode: product.itemCode,
            itemPrice: product.itemPrice,
            itemName: product.itemName);

  int get getBalance => (maxQuantity - quantity) ?? 0;

  remove({num val = 1}) {
    if (quantity > 0) {
      _quantity = quantity - val;
      product.updateQuantity(quantity);
    }
    notifyListeners();
  }

  updateProduct(String val) {
    if (val != null) {
      var newVal = int.parse(val.trim());
      //Set the value of the product
      if (newVal >= 0 && newVal <= maxQuantity) {
        product.updateQuantity(newVal);
        _quantity = newVal;
        notifyListeners();
      }
    }

    notifyListeners();
  }

  bool get canAdd => quantity < maxQuantity;
  bool get canRemove => quantity > 0;

  add({num val = 1}) {
    if (quantity <= maxQuantity) {
      _quantity = quantity + val;
      product.updateQuantity(quantity);
    }
    notifyListeners();
  }

  bool get isValid => quantity < maxQuantity;
}
