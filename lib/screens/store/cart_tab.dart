import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth_cubit.dart';
import '../../models/merch_model.dart';
import '../constants.dart';
import './image_preview_screen.dart';
import './main_card.dart';

class CartTab extends StatelessWidget {
  final Map<MerchItem, int> cart;
  final Function(Map<MerchItem, int>) onUpdateCart;
  final Function(BuildContext) onPurchase;

  CartTab({required this.cart, required this.onUpdateCart, required this.onPurchase});

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return Center(
        child: Text(
          'Корзина пуста',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final totalPrice = cart.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Цена: ${item.price}',
                                  style: TextStyle(fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'x $quantity = ${item.price * quantity}',
                                      style: TextStyle(fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(width: 4),
                                    Image.asset(
                                      'assets/images/neocoins.png',
                                      height: 15,
                                    ),
                                  ],
                                ),
                              ],
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
                            },
                          ),
                          Text('$quantity', style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.add, color: quantity < 99 ? Colors.green : Colors.grey),
                            onPressed: quantity < 99
                                ? () {
                              final userCoins = context.read<AuthCubit>().state.user?.coins ?? 0;
                              final totalAfterAdd = cart.entries.fold(
                                  0, (sum, entry) => sum + entry.key.price * entry.value) +
                                  item.price;

                              if (userCoins >= totalAfterAdd) {
                                final updatedCart = Map<MerchItem, int>.from(cart);
                                updatedCart[item] = quantity + 1;
                                onUpdateCart(updatedCart);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.white),
                                        SizedBox(width: 8),
                                        Expanded(
                                            child: Text('Недостаточно монет',
                                                style: TextStyle(color: Colors.white))),
                                      ],
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                                : null,
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Итого: $totalPrice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    'assets/images/neocoins.png',
                    height: 18,
                  ),
                ],
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => onPurchase(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text(
                  'Купить',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}