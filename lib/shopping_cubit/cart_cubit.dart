import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart_item.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addItem(String id, String name, double price, {double discount = 0.0}) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == id);

    if (index != -1) {
      items[index].quantity += 1;
    } else {
      items.add(CartItem(id: id, name: name, price: price, discount: discount));
    }

    emit(CartState(items: items));
  }

  void removeItem(String id) {
    final items = state.items.where((item) => item.id != id).toList();
    emit(CartState(items: items));
  }

  void updateQuantity(String id, int newQuantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == id);

    if (index != -1) {
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = newQuantity;
      }
      emit(CartState(items: items));
    }
  }

  void clearCart() => emit(const CartState());
}
