import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../providers/cart_provider.dart';

class QuantityController extends ConsumerStatefulWidget {
  final Product product;
  const QuantityController({super.key, required this.product});

  @override
  ConsumerState<QuantityController> createState() => _QuantityControllerState();
}

class _QuantityControllerState extends ConsumerState<QuantityController> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    final qty =
        ref.read(cartProvider)[widget.product.id]?.quantity ?? 1;
    _ctrl = TextEditingController(text: qty.toString());
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      final val = int.tryParse(_ctrl.text) ?? 0;
      if (val <= 0) {
        ref.read(cartProvider.notifier).removeItem(widget.product.id);
      } else {
        ref.read(cartProvider.notifier).setQuantity(widget.product.id, val);
      }
    }
  }

  @override
  void didUpdateWidget(covariant QuantityController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus) {
      final qty = ref.read(cartProvider)[widget.product.id]?.quantity ?? 0;
      final newText = qty.toString();
      if (_ctrl.text != newText) {
        _ctrl.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _increment() {
    final current = int.tryParse(_ctrl.text) ?? 0;
    final next = current + 1;
    _ctrl.text = next.toString();
    ref.read(cartProvider.notifier).setQuantity(widget.product.id, next);
  }

  void _decrement() {
    final current = int.tryParse(_ctrl.text) ?? 0;
    final next = current - 1;
    if (next <= 0) {
      ref.read(cartProvider.notifier).removeItem(widget.product.id);
    } else {
      _ctrl.text = next.toString();
      ref.read(cartProvider.notifier).setQuantity(widget.product.id, next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleBtn(icon: Icons.remove, onTap: _decrement),
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
              if (qty <= 0) {
                ref.read(cartProvider.notifier).removeItem(widget.product.id);
              } else {
                ref.read(cartProvider.notifier).setQuantity(widget.product.id, qty);
              }
            },
          ),
        ),
        _CircleBtn(icon: Icons.add, onTap: _increment),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
