import 'package:flutter/material.dart';
import 'package:flutter_testing_lab/shopping_cubit/cart_cubit.dart';
import 'package:flutter_testing_lab/shopping_cubit/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit(),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final cartCubit = context.read<CartCubit>();
          return Column(
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      cartCubit.addItem(
                        '1',
                        'Apple iPhone',
                        999.99,
                        discount: 0.1,
                      );
                    },
                    child: const Text('Add iPhone'),
                  ),
                  ElevatedButton(
                    onPressed: () => cartCubit.addItem(
                      '2',
                      'Samsung Galaxy',
                      899.99,
                      discount: 0.15,
                    ),
                    child: const Text('Add Galaxy'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        cartCubit.addItem('3', 'iPad Pro', 1099.99),
                    child: const Text('Add iPad'),
                  ),
                  ElevatedButton(
                    onPressed: () => cartCubit.addItem(
                      '1',
                      'Apple iPhone',
                      999.99,
                      discount: 0.1,
                    ),
                    child: const Text('Add iPhone Again'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Items: ${state.totalItems}'),
                        ElevatedButton(
                          onPressed: cartCubit.clearCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Clear Cart'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Subtotal: \$${state.subtotal.toStringAsFixed(2)}'),
                    Text(
                      'Total Discount: \$${state.totalDiscount.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    Text(
                      'Total Amount: \$${state.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              state.items.isEmpty
                  ? const Center(child: Text('Cart is empty'))
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        final itemTotal = item.price * item.quantity;

                        return Card(
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: \$${item.price.toStringAsFixed(2)} each',
                                ),
                                if (item.discount > 0)
                                  Text(
                                    'Discount: ${(item.discount * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                Text(
                                  'Item Total: \$${itemTotal.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => cartCubit.updateQuantity(
                                    item.id,
                                    item.quantity - 1,
                                  ),
                                  icon: const Icon(Icons.remove),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${item.quantity}'),
                                ),
                                IconButton(
                                  onPressed: () => cartCubit.updateQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                                  icon: const Icon(Icons.add),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      cartCubit.removeItem(item.id),
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          );
        },
      ),
    );
  }
}
