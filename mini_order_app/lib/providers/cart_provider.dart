import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/local_db.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';
import 'product_provider.dart';

class CartNotifier extends Notifier<Map<int, CartItem>> {
  LocalDb get _db => ref.read(localDbProvider);

  @override
  Map<int, CartItem> build() => ref.read(localDbProvider).getCart();

  void addItem(Product product) {
    final existing = state[product.id];
    if (existing != null) {
      setQuantity(product.id, existing.quantity + 1);
    } else {
      final item = CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        image: product.image,
        quantity: 1,
      );
      _db.upsertCartItem(item);
      state = {...state, product.id: item};
    }
  }

  void setQuantity(int productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final existing = state[productId];
    if (existing == null) return;
    existing.quantity = qty;
    _db.upsertCartItem(existing);
    state = {...state, productId: existing};
  }

  void removeItem(int productId) {
    _db.removeCartItem(productId);
    final updated = Map<int, CartItem>.from(state);
    updated.remove(productId);
    state = updated;
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, Map<int, CartItem>>(CartNotifier.new);

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).length;
});

final cartTotalUnitsProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .values
      .fold(0, (sum, item) => sum + item.quantity);
});

final cartGrandTotalProvider = Provider<double>((ref) {
  return ref
      .watch(cartProvider)
      .values
      .fold(0.0, (sum, item) => sum + item.price * item.quantity);
});
