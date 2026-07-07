import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final items = cart.values.toList();
    final uniqueCount = ref.watch(cartItemCountProvider);
    final totalUnits = ref.watch(cartTotalUnitsProvider);
    final grandTotal = ref.watch(cartGrandTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final subtotal = item.price * item.quantity;
                      return ListTile(
                        leading: Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                        trailing: _CartQtyControl(
                          productId: item.productId,
                          quantity: item.quantity,
                        ),
                      );
                    },
                  ),
                ),
                _SummaryPanel(
                  uniqueCount: uniqueCount,
                  totalUnits: totalUnits,
                  grandTotal: grandTotal,
                ),
              ],
            ),
    );
  }
}

class _CartQtyControl extends ConsumerStatefulWidget {
  final int productId;
  final int quantity;
  const _CartQtyControl({required this.productId, required this.quantity});

  @override
  ConsumerState<_CartQtyControl> createState() => _CartQtyControlState();
}

class _CartQtyControlState extends ConsumerState<_CartQtyControl> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.quantity.toString());
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      final val = int.tryParse(_ctrl.text) ?? 0;
      ref.read(cartProvider.notifier).setQuantity(widget.productId, val);
    }
  }

  @override
  void didUpdateWidget(covariant _CartQtyControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && _ctrl.text != widget.quantity.toString()) {
      _ctrl.text = widget.quantity.toString();
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            final next = widget.quantity - 1;
            if (next <= 0) {
              ref.read(cartProvider.notifier).removeItem(widget.productId);
            } else {
              _ctrl.text = next.toString();
              ref.read(cartProvider.notifier).setQuantity(widget.productId, next);
            }
          },
        ),
        SizedBox(
          width: 44,
          child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (val) {
              final qty = int.tryParse(val) ?? 0;
              ref.read(cartProvider.notifier).setQuantity(widget.productId, qty);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            final next = widget.quantity + 1;
            _ctrl.text = next.toString();
            ref.read(cartProvider.notifier).setQuantity(widget.productId, next);
          },
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final int uniqueCount;
  final int totalUnits;
  final double grandTotal;

  const _SummaryPanel({
    required this.uniqueCount,
    required this.totalUnits,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Row('Unique Items', '$uniqueCount items in cart'),
          _Row('Total Units', 'Total Units: $totalUnits'),
          const Divider(),
          _Row(
            'Grand Total',
            '\$${grandTotal.toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
