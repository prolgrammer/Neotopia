import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth_cubit.dart';
import './image_preview_screen.dart';
import './main_card.dart';

class PurchaseHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final purchases = context.watch<AuthCubit>().state.user?.purchases ?? [];

    if (purchases.isEmpty) {
      return Center(child: Text('Нет покупок', style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16).copyWith(bottom: 200),
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: MainCard(
            title: 'Покупка #${purchase.id}',
            icon: '📦',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Дата: ${purchase.timestamp.substring(0, 10)}',
                  style: TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                ...purchase.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagePreviewScreen(
                                  imageUrl: item.imageUrl,
                                  tag: 'purchase_${purchase.id}_${item.id}',
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'purchase_${purchase.id}_${item.id}',
                            child: Image.asset(
                              item.imageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading purchase image: ${item.imageUrl}, error: $error');
                                return Icon(Icons.error);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Text(
                              '${item.name} - ${item.price} ',
                              style: TextStyle(fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Image.asset(
                              'assets/images/neocoins.png',
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Итого: ${purchase.totalPrice} ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Image.asset(
                      'assets/images/neocoins.png',
                      height: 16,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Статус: ${purchase.status == 'pending' ? 'Ожидает выдачи' : 'Выдано'}',
                  style: TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}