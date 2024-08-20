import 'dart:convert';

class Order {
  final int id;
  final String customerName;
  final List<OrderItem> items;
  final DateTime orderDate;
  final double totalPrice;
  final String? productName;
  final int? quantity;
  final double? price;// Opsional
  final String? status;
  final String? fotoProdukURL; // Opsional
  final String? fotoProgressURL; // Opsional
  final String? videoProgressURL;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.orderDate,
    required this.totalPrice,
    this.status,
    this.fotoProdukURL,
    this.fotoProgressURL,
    this.videoProgressURL,
    this.productName,
    this.quantity,
    this.price,
  });

  // Konversi Map ke objek Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      customerName: map['customerName'],
      totalPrice: (map['totalPrice'] as num).toDouble(),
      orderDate: DateTime.parse(map['orderDate']),
      status: map['status'],
      fotoProdukURL: map['fotoProdukURL'],
      fotoProgressURL: map['fotoProgressURL'],
      videoProgressURL: map['videoProgressURL'],
      items: map['items'] != null
          ? List<OrderItem>.from(
              map['items'].map((item) => OrderItem.fromMap(item as Map<String, dynamic>)))
          : [],
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
    );
  }

  // Konversi objek Order ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'fotoProdukURL': fotoProdukURL,
      'fotoProgressURL': fotoProgressURL,
      'videoProgressURL': videoProgressURL,
      'items': items.map((item) => item.toMap()).toList(),
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  // Konversi objek Order ke JSON
  Map<String, dynamic> toJson() => toMap();
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;
  final String? fotoProduk; // Opsional
  final String? fotoProgress;
  final String? videoProgress;// Opsional

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
    this.fotoProduk,
    this.fotoProgress,
    this.videoProgress,
  });

  // Konversi Map ke objek OrderItem
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
      fotoProduk: map['fotoProduk'],
      fotoProgress: map['fotoProgress'],
      videoProgress: map['videoProgress'],
    );
  }

  // Konversi objek OrderItem ke Map
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'fotoProduk': fotoProduk,
      'fotoProgress': fotoProgress,
      'videoProgress': videoProgress,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
