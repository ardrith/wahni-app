import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/local_db.dart';
import '../data/models/product.dart';
import '../data/remote/product_repository.dart';

final localDbProvider = Provider<LocalDb>((ref) => LocalDb());

final productRepositoryProvider =
    Provider<ProductRepository>((ref) => ProductRepository());

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final db = ref.read(localDbProvider);
  final repo = ref.read(productRepositoryProvider);

  final cached = db.getCachedProducts();
  if (cached.isNotEmpty) return cached;

  final remote = await repo.fetchProducts();
  await db.cacheProducts(remote);
  return remote;
});
