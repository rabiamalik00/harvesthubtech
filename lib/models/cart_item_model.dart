class CartItemModel {
  final String productId;
  final int quantity;

  CartItemModel({required this.productId, this.quantity = 1});

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'quantity': quantity,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        productId: map['productId'] as String,
        quantity: (map['quantity'] as num).toInt(),
      );
}
