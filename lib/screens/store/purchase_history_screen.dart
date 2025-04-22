import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/auth_cubit.dart';
import '../store_screen.dart';
import '../../models/merch_model.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.purple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Image.asset(
              'assets/images/mascot.jpg',
              height: 100,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.purple.shade800,
                  child: Row(
                    children: [
                      Text(
                        'История покупок',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildPurchaseList(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref()
          .child('purchases')
          .child(context.read<AuthCubit>().state.user!.uid)
          .onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return Center(child: Text('Нет покупок'));
        }

        final purchases = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>);

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final purchaseId = purchases.keys.elementAt(index);
            final purchase = Map<String, dynamic>.from(purchases[purchaseId]);
            final items = (purchase['items'] as List<dynamic>)
                .map((item) => MerchItem.fromMap(Map<String, dynamic>.from(item)))
                .toList();

            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: MainCard(
                title: 'Покупка #$purchaseId',
                icon: '📦',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Дата: ${purchase['timestamp'].toString().substring(0, 10)}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    ...items.map((item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Image.asset(
                            item.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.name} - ${item.price} 🪙',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(height: 8),
                    Text(
                      'Итого: ${purchase['totalPrice']} 🪙',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Статус: ${purchase['status'] == 'pending' ? 'Ожидает выдачи' : 'Выдано'}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}