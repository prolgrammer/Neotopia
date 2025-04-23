class MerchItem {
  final String id;
  final String name;
  final int price;
  final String imageUrl;

  MerchItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory MerchItem.fromMap(Map<String, dynamic> map) {
    return MerchItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as int,
      imageUrl: map['imageUrl'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MerchItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}