import '../models/cart_item.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);

  double get totalDiscount =>
      items.fold(0, (sum, item) => sum + item.discount * item.price * item.quantity);

  double get totalAmount => (subtotal - totalDiscount).clamp(0, double.infinity);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
