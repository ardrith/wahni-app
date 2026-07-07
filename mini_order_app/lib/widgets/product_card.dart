import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../providers/cart_provider.dart';
import 'quantity_controller.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(
      cartProvider.select((cart) => cart.containsKey(product.id)),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: product.image,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const SizedBox(width: 70, height: 70, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 70),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            inCart
                ? QuantityController(product: product)
                : ElevatedButton(
                    onPressed: () =>
                        ref.read(cartProvider.notifier).addItem(product),
                    child: const Text('Add'),
                  ),
          ],
        ),
      ),
    );
  }
}
