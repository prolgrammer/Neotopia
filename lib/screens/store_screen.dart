import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neotopia/screens/store/catalog_tab.dart';
import 'package:neotopia/screens/store/purchase_history_tab.dart';
import 'package:neotopia/screens/store/cart_tab.dart';
import 'package:neotopia/screens/store/top_notification.dart';
import '../cubits/auth_cubit.dart';
import '../models/merch_model.dart';
import '../models/user_model.dart';
import 'constants.dart';
import 'dart:io';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  Map<MerchItem, int> cart = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kAppGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header section
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return CircleAvatar(
                              radius: 24,
                              backgroundImage: state.user?.avatarUrl != null
                                  ? FileImage(File(state.user!.avatarUrl!))
                                  : AssetImage('assets/images/avatar.jpg') as ImageProvider,
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            return Text(
                              state.user?.username ?? 'Пользователь',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/neotopia.png',
                      height: 40,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/neocoins.png',
                          height: 24,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${context.watch<AuthCubit>().state.user?.coins ?? 0}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white,
                thickness: 2,
                height: 1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  'Магазин',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Каталог'),
                    Tab(text: 'Корзина'),
                    Tab(text: 'История покупок'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CatalogTab(cart: cart, onAddToCart: _addToCart),
                    CartTab(cart: cart, onUpdateCart: _updateCart, onPurchase: _purchaseItems),
                    PurchaseHistoryTab(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF4A1A7A), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/home.png',
                        height: 32,
                        width: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.home,
                            color: Color(0xFF2E0352),
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(MerchItem item) {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;

    final currentQuantity = cart[item] ?? 0;
    final totalAfterAdd = cart.entries.fold(0, (sum, entry) =>
    sum + entry.key.price * entry.value) + item.price;

    if (user.coins >= totalAfterAdd && currentQuantity < 99) {
      setState(() {
        cart[item] = currentQuantity + 1;
      });
    }
  }

  void _updateCart(Map<MerchItem, int> updatedCart) {
    setState(() {
      cart = updatedCart;
    });
  }

  void _purchaseItems(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    if (user == null) {
      TopNotification.show(
        context,
        message: 'Ошибка: Пользователь не найден',
        isError: true,
      );
      return;
    }

    if (cart.isEmpty) {
      TopNotification.show(
        context,
        message: 'Корзина пуста',
        isError: true,
      );
      return;
    }

    final totalPrice = cart.entries.fold(0, (sum, entry) => sum + entry.key.price * entry.value);
    if (user.coins < totalPrice) {
      TopNotification.show(
        context,
        message: 'Недостаточно монет для покупки',
        isError: true,
      );
      return;
    }

    try {
      final purchaseId = Random().nextInt(999999).toString();
      final purchaseItems = cart.entries.expand((entry) => List.filled(entry.value, entry.key)).toList();
      final purchase = Purchase(
        id: purchaseId,
        items: purchaseItems,
        totalPrice: totalPrice,
        timestamp: DateTime.now().toIso8601String(),
        status: 'pending',
      );

      await authCubit.addPurchase(user.uid, purchase);
      await authCubit.updateCoins(user.uid, user.coins - totalPrice);

      setState(() {
        cart.clear();
      });

      TopNotification.show(
        context,
        message: 'Покупка успешна! Приходите к нам в офис в будние дни, и мы выдадим вам ваш приз.',
      );
    } catch (e) {
      TopNotification.show(
        context,
        message: 'Ошибка при покупке',
        isError: true,
      );
    }
  }
}