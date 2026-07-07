import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class LocalDb {
  static const _productsBox = 'products';
  static const _cartBox = 'cart';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CartItemAdapter());
    await Hive.openBox<Product>(_productsBox);
    await Hive.openBox<CartItem>(_cartBox);
  }

  Box<Product> get productsBox => Hive.box<Product>(_productsBox);
  Box<CartItem> get cartBox => Hive.box<CartItem>(_cartBox);

  Future<void> cacheProducts(List<Product> products) async {
    final box = productsBox;
    await box.clear();
    for (final p in products) {
      await box.put(p.id, p);
    }
  }

  List<Product> getCachedProducts() => productsBox.values.toList();

  Map<int, CartItem> getCart() {
    return {for (final item in cartBox.values) item.productId: item};
  }

  Future<void> upsertCartItem(CartItem item) async {
    await cartBox.put(item.productId, item);
  }

  Future<void> removeCartItem(int productId) async {
    await cartBox.delete(productId);
  }

  Future<void> clearCart() async => cartBox.clear();
}
