import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import '../models/merch_model.dart';
import '../models/user_model.dart';
import 'dart:math';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  List<MerchItem> cart = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.purple.shade800,
                flexibleSpace: FlexibleSpaceBar(
                  title: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Каталог'),
                      Tab(text: 'История покупок'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildCatalogTab(),
                _buildPurchaseHistoryTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.purple.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Магазин',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '🪙 ${context.watch<AuthCubit>().state.user?.coins ?? 0}',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogTab() {
    final merchItems = [
      MerchItem(id: '1', name: 'Аккумулятор', price: 150, imageUrl: 'assets/images/merch/accumulator.png'),
      MerchItem(id: '2', name: 'Закладки', price: 30, imageUrl: 'assets/images/merch/bookmarks.png'),
      MerchItem(id: '3', name: 'Бутылка', price: 80, imageUrl: 'assets/images/merch/bottle.png'),
      MerchItem(id: '4', name: 'Бутылка (Дизайн 2)', price: 90, imageUrl: 'assets/images/merch/bottle1.png'),
      MerchItem(id: '5', name: 'Колонка', price: 200, imageUrl: 'assets/images/merch/music_speaker.png'),
      MerchItem(id: '6', name: 'Колонка (Дизайн 2)', price: 220, imageUrl: 'assets/images/merch/music_speaker1.png'),
      MerchItem(id: '7', name: 'Блокнот', price: 50, imageUrl: 'assets/images/merch/notepad.png'),
      MerchItem(id: '8', name: 'Блокнот (Дизайн 2)', price: 60, imageUrl: 'assets/images/merch/notepad1.png'),
      MerchItem(id: '9', name: 'Косметичка', price: 70, imageUrl: 'assets/images/merch/pouch.png'),
    ];

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.all(16),
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: merchItems.length,
          itemBuilder: (context, index) {
            final item = merchItems[index];
            final userCoins = context.watch<AuthCubit>().state.user?.coins ?? 0;
            final canAfford = userCoins >= item.price;

            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: MainCard(
                title: item.name,
                icon: '🛍️',
                onTap: canAfford ? () => _addToCart(item) : null,
                child: Row(
                  children: [
                    Image.asset(
                      item.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
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
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Цена: ${item.price} 🪙',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: canAfford ? () => _addToCart(item) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? Colors.purple : Colors.grey,
                      ),
                      child: Text('В корзину'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (cart.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCartFooter(context),
          ),
      ],
    );
  }

  Widget _buildPurchaseHistoryTab() {
    final purchases = context.watch<AuthCubit>().state.user?.purchases ?? [];

    if (purchases.isEmpty) {
      return Center(child: Text('Нет покупок'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
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
                ),
                SizedBox(height: 8),
                ...purchase.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Image.asset(
                        item.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
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
                  'Итого: ${purchase.totalPrice} 🪙',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Статус: ${purchase.status == 'pending' ? 'Ожидает выдачи' : 'Выдано'}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartFooter(BuildContext context) {
    final totalPrice = cart.fold(0, (sum, item) => sum + item.price);

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.purple.shade800,
      child: Column(
        children: [
          Text(
            'Корзина: ${cart.length} предмет(ов), Итого: $totalPrice 🪙',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _purchaseItems(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text('Купить'),
          ),
        ],
      ),
    );
  }

  void _addToCart(MerchItem item) {
    setState(() {
      cart.add(item);
    });
  }

  void _purchaseItems(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;
    if (user == null) {
      print('Error: User is null, cannot process purchase');
      return;
    }
    print('Processing purchase for UID: ${user.uid}');

    final totalPrice = cart.fold(0, (sum, item) => sum + item.price);
    if (user.coins < totalPrice) return;

    try {
      final purchaseId = Random().nextInt(999999).toString();
      final purchase = Purchase(
        id: purchaseId,
        items: cart,
        totalPrice: totalPrice,
        timestamp: DateTime.now().toIso8601String(),
        status: 'pending',
      );

      await authCubit.addPurchase(user.uid, purchase);
      await authCubit.updateCoins(user.uid, user.coins - totalPrice);

      setState(() {
        cart.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Покупка успешна! Приходите к нам в офис в будние дни, и мы выдадим вам ваш приз.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print('Purchase error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при покупке: $e')),
      );
    }
  }
}

class MainCard extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onTap;
  final Widget? child;

  MainCard({
    required this.title,
    required this.icon,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipPath(
        clipper: CardClipper(),
        child: Container(
          height: child != null ? null : 120,
          padding: child != null ? EdgeInsets.all(16) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child ??
              Row(
                children: [
                  Container(
                    width: 80,
                    color: Colors.purple.shade100,
                    child: Center(
                      child: Text(
                        icon,
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
}

class CardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 20.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}