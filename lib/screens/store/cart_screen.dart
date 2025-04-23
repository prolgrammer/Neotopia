import 'package:flutter/material.dart';
import '../../models/merch_model.dart';
import '../constants.dart';
import './image_preview_screen.dart';
import './main_card.dart';
import './top_notification.dart';

class CartScreen extends StatelessWidget {
  final Map<MerchItem, int> cart;
  final Function(Map<MerchItem, int>) onUpdateCart;
  final Function(BuildContext) onPurchase;

  CartScreen({
    required this.cart,
    required this.onUpdateCart,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
      });
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Корзина'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16).copyWith(bottom: 120),
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final entry = cart.entries.elementAt(index);
                  final item = entry.key;
                  final quantity = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: MainCard(
                      title: item.name,
                      icon: '🛍️',
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagePreviewScreen(
                                    imageUrl: item.imageUrl,
                                    tag: 'cart_${item.id}_${index}',
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'cart_${item.id}_${index}',
                              child: Image.asset(
                                item.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Цена: ${item.price} 🪙 x $quantity = ${item.price * quantity} 🪙',
                                  style: TextStyle(fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(quantity > 1 ? Icons.remove : Icons.delete, color: Colors.red),
                                onPressed: () {
                                  final updatedCart = Map<MerchItem, int>.from(cart);
                                  if (quantity > 1) {
                                    updatedCart[item] = quantity - 1;
                                  } else {
                                    updatedCart.remove(item);
                                  }
                                  onUpdateCart(updatedCart);

                                  if (updatedCart.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              Text(
                                '$quantity',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  final updatedCart = Map<MerchItem, int>.from(cart);
                                  updatedCart[item] = quantity + 1;
                                  onUpdateCart(updatedCart);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  if (cart.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Корзина пуста!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    onPurchase(context);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(
                  'Купить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}