import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth_cubit.dart';
import '../../models/merch_model.dart';
import '../constants.dart';
import './image_preview_screen.dart';
import './main_card.dart';
import './top_notification.dart';

class CatalogTab extends StatelessWidget {
  final Map<MerchItem, int> cart;
  final Function(MerchItem) onAddToCart;

  CatalogTab({required this.cart, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final merchItems = [
      MerchItem(id: '1', name: 'Аккумулятор', price: 1250, imageUrl: 'assets/images/merch/accumulator.png'),
      MerchItem(id: '2', name: 'Закладки', price: 150, imageUrl: 'assets/images/merch/bookmarks.png'),
      MerchItem(id: '3', name: 'Бутылка', price: 500, imageUrl: 'assets/images/merch/bottle.png'),
      MerchItem(id: '4', name: 'Бутылка оранжевая', price: 600, imageUrl: 'assets/images/merch/bottle1.png'),
      MerchItem(id: '5', name: 'Колонка', price: 900, imageUrl: 'assets/images/merch/music_speaker.png'),
      MerchItem(id: '6', name: 'Колонка беспроводная', price: 1000, imageUrl: 'assets/images/merch/music_speaker1.png'),
      MerchItem(id: '7', name: 'Блокнот', price: 300, imageUrl: 'assets/images/merch/notepad.png'),
      MerchItem(id: '8', name: 'Ручка', price: 100, imageUrl: 'assets/images/merch/pencil.png'),
      MerchItem(id: '9', name: 'Косметичка', price: 400, imageUrl: 'assets/images/merch/pouch.png'),
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16).copyWith(bottom: 200),
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: merchItems.length,
      itemBuilder: (context, index) {
        final item = merchItems[index];
        final userCoins = context.watch<AuthCubit>().state.user?.coins ?? 0;
        final currentQuantity = cart[item] ?? 0;
        final itemTotalPrice = currentQuantity * item.price + item.price;
        final canAfford = userCoins >= itemTotalPrice;
        final canAddMore = currentQuantity < 99;

        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: MainCard(
            title: item.name,
            icon: '🛍️',
            onTap: canAfford && canAddMore
                ? () {
              onAddToCart(item);
              TopNotification.show(
                context,
                message: '${item.name} добавлен в корзину',
              );
            }
                : () {
              TopNotification.show(
                context,
                message: canAfford
                    ? 'Достигнут лимит количества для ${item.name}'
                    : 'Недостаточно монет для добавления ${item.name}',
                isError: true,
              );
            },
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagePreviewScreen(
                          imageUrl: item.imageUrl,
                          tag: 'merch_${item.id}',
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'merch_${item.id}',
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
                        'Цена: ${item.price} 🪙',
                        style: TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentQuantity > 0) Text(
                        'В корзине: $currentQuantity',
                        style: TextStyle(fontSize: 14, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: canAfford && canAddMore
                      ? () {
                    onAddToCart(item);
                    TopNotification.show(
                      context,
                      message: '${item.name} добавлен в корзину',
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford && canAddMore ? Colors.purple : Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'В корзину',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}