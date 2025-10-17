import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/shopping_cubit/cart_cubit.dart';

void main() {
  late CartCubit cart;

  setUp(() {
    cart = CartCubit();
  });
  tearDown(() {
    cart.close();
  });
  group('CartCubit', () {
    test('should add a new item to the cart', () {
      cart.addItem('1', 'Laptop', 1000);

      final state = cart.state;
      expect(state.items.length, 1);
      expect(state.items.first.name, 'Laptop');
      expect(state.items.first.quantity, 1);
    });

    test('should increase quantity when adding duplicate item', () {
      cart.addItem('1', 'Laptop', 1000);
      cart.addItem('1', 'Laptop', 1000);

      final state = cart.state;
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 2);
    });
    test('should remove an item from the cart', () {
      cart.addItem('1', 'Laptop', 1000);
      cart.removeItem('1');

      expect(cart.state.items, isEmpty);
    });
    test('should update item quantity correctly', () {
      cart.addItem('1', 'Phone', 500);
      cart.updateQuantity('1', 3);

      final state = cart.state;
      expect(state.items.first.quantity, 3);
    });

    test('should remove item if quantity updated to 0', () {
      cart.addItem('1', 'Phone', 500);
      cart.updateQuantity('1', 0);

      expect(cart.state.items, isEmpty);
    });

    test('should calculate subtotal, discount, and totalAmount correctly', () {
      cart.addItem('1', 'Laptop', 1000, discount: 0.1); // 10%
      cart.addItem('2', 'Phone', 500, discount: 0.2); // 20%

      final state = cart.state;

      expect(state.subtotal, 1500);
      expect(
        state.totalDiscount,
        (1000 * 0.1) + (500 * 0.2),
      ); // = 100 + 100 = 200
      expect(state.totalAmount, 1500 - 200); // = 1300
    });
    test('should handle empty cart calculations correctly', () {
      final state = cart.state;

      expect(state.subtotal, 0);
      expect(state.totalDiscount, 0);
      expect(state.totalAmount, 0);
    });

    test('should handle 100% discount correctly', () {
      cart.addItem('1', 'Tablet', 1000, discount: 1.0);

      final state = cart.state;

      expect(state.totalAmount, 0);
    });

    test('should limit negative total to 0 if discount > 100% ', () {

      cart.addItem('1', 'Gadget', 100, discount: 2.0);

      final state = cart.state;

      expect(state.totalAmount >= 0, isTrue);
    });

    test('Cart removes item if quantity updated to 0', () {
      final cubit = CartCubit();
      cubit.addItem('1', 'iPhone', 999.99);
      cubit.updateQuantity('1', 0);

      final state = cubit.state;
      expect(state.items, isEmpty);
    });

  });
}
