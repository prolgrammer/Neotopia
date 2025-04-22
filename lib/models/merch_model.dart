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
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imageUrl: map['imageUrl'],
    );
  }
}