import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';
import 'order_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const _databaseName = 'users.db'; // Pastikan nama database benar
  static const _databaseVersion = 1;

  // User Table
  static const table = 'users';
  static const columnId = 'id';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnRole = 'role';
  static const columnFoto = 'foto';

  // Order Table
  static const _orderTable = 'orders';
  static const _orderColumnId = 'id';
  static const _orderColumnCustomerName = 'customerName';
  static const _orderColumnTotalPrice = 'totalPrice';
  static const _orderColumnOrderDate = 'orderDate';
  static const _orderColumnStatus = 'status';
  static const _orderColumnFotoProdukURL = 'fotoProdukURL';
  static const _orderColumnFotoProgressURL = 'fotoProgressURL';
  static const _orderColumnProductName = 'productName';
  static const _orderColumnQuantity = 'quantity';
  static const _orderColumnPrice = 'price';
  static const _orderColumnVideoProgressURL = 'videoProgressURL';

  // Order Item Table
  static const _orderItemTable = 'orderItems';
  static const _orderItemColumnId = 'id';
  static const _orderItemColumnOrderId =
      'orderId'; // Foreign key ke tabel orders
  static const _orderItemColumnProductName = 'productName';
  static const _orderItemColumnQuantity = 'quantity';
  static const _orderItemColumnPrice = 'price';
  static const _orderItemColumnFotoProduk = 'fotoProduk';
  static const _orderItemColumnFotoProgress = 'fotoProgress';

  Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnEmail TEXT NOT NULL,
        $columnPassword TEXT NOT NULL,
        $columnRole TEXT NOT NULL,
        $columnFoto TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $_orderTable (
        $_orderColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_orderColumnCustomerName TEXT NOT NULL,
        $_orderColumnTotalPrice REAL NOT NULL,
        $_orderColumnOrderDate TEXT NOT NULL,
        $_orderColumnStatus TEXT NOT NULL,
        $_orderColumnFotoProdukURL TEXT,
        $_orderColumnFotoProgressURL TEXT,
        $_orderColumnProductName TEXT NOT NULL,
        $_orderColumnQuantity INTEGER NOT NULL,
        $_orderColumnPrice REAL NOT NULL,
        $_orderColumnVideoProgressURL TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $_orderItemTable (
        $_orderItemColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_orderItemColumnOrderId INTEGER NOT NULL,
        $_orderItemColumnProductName TEXT NOT NULL,
        $_orderItemColumnQuantity INTEGER NOT NULL,
        $_orderItemColumnPrice REAL NOT NULL,
        $_orderItemColumnFotoProduk TEXT,
        $_orderItemColumnFotoProgress TEXT,
        FOREIGN KEY ($_orderItemColumnOrderId) REFERENCES $_orderTable ($_orderColumnId)
      )
    ''');
    await db.execute('''
    CREATE TABLE order_progress_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER NOT NULL,
      oldFotoProgressURL TEXT,
      newFotoProgressURL TEXT,
      status TEXT,
      updateDate TEXT NOT NULL,
      FOREIGN KEY (orderId) REFERENCES $_orderTable ($_orderColumnId)
    )
  ''');
    await db.insert(table, {
      columnEmail: 'admin@melintu.com',
      columnPassword: 'password', // Ganti dengan password yang sesuai
      columnRole: 'admin',
      columnFoto: 'default.png'
    });
  }

  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(table, user.toMap());
  }

  Future<Map<String, dynamic>?> isAdmin(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result =
        await db.query(table, where: '$columnEmail = ?', whereArgs: [email]);

    if (result.isNotEmpty && result.first['role'] == 'admin') {
      debugPrint('isAdmin: true');
      return {
        'id': result.first['id'],
        'email': result.first['email'],
        'role': result.first['role'],
        // Tambahkan atribut lain jika diperlukan
      };
    }
    debugPrint('isAdmin: false');
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps =
        await db.query(table, where: '$columnEmail = ?', whereArgs: [email]);
    debugPrint('getUserByEmail query result: $maps');
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps =
        await db.query(table, where: '$columnId = ?', whereArgs: [id]);
    debugPrint('getUserById query result: $maps');
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<User?> getUserProfile(int userId) async {
    final db = await database;
    final maps = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllCustomers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnRole != ?',
      whereArgs: ['admin'],
    );
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Order Methods

  Future<int> insertOrder(Order order) async {
    Database db = await instance.database;
    String orderDateIso = order.orderDate.toIso8601String();
    int orderIds = await db.insert(_orderTable, {
      _orderColumnCustomerName: order.customerName,
      _orderColumnTotalPrice: order.totalPrice,
      _orderColumnOrderDate: orderDateIso,
      _orderColumnStatus: order.status,
      _orderColumnProductName: order.productName,
      _orderColumnQuantity: order.quantity,
      _orderColumnPrice: order.price,
      _orderColumnFotoProdukURL: order.fotoProdukURL,
      _orderColumnFotoProgressURL: order.fotoProgressURL,
      _orderColumnVideoProgressURL: order.videoProgressURL,
    });
    for (var item in order.items) {
      await insertOrderItem(item, orderIds);
    }
    return orderIds;
  }

  Future<List<Order>> getAllOrders() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(_orderTable);
    return List.generate(maps.length, (i) {
      DateTime orderDate = DateTime.parse(maps[i][_orderColumnOrderDate]);
      return Order(
        id: maps[i][_orderColumnId],
        customerName: maps[i][_orderColumnCustomerName],
        totalPrice: maps[i][_orderColumnTotalPrice],
        orderDate: orderDate,
        status: maps[i][_orderColumnStatus],
        fotoProdukURL: maps[i][_orderColumnFotoProdukURL],
        fotoProgressURL: maps[i][_orderColumnFotoProgressURL],
        videoProgressURL: maps[i][_orderColumnVideoProgressURL],
        price: maps[i][_orderColumnPrice],
        productName: maps[i][_orderColumnProductName],
        quantity: maps[i][_orderColumnQuantity],
        items: [], // Ambil item order secara terpisah jika menggunakan tabel _orderItemTable
      );
    });
  }

  Future<Order?> getOrderById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _orderTable,
      where: '$_orderColumnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      DateTime orderDate = DateTime.parse(maps[0][_orderColumnOrderDate]);
      return Order(
        id: maps[0][_orderColumnId],
        customerName: maps[0][_orderColumnCustomerName],
        totalPrice: maps[0][_orderColumnTotalPrice],
        orderDate: orderDate,
        status: maps[0][_orderColumnStatus],
        fotoProdukURL: maps[0][_orderColumnFotoProdukURL],
        fotoProgressURL: maps[0][_orderColumnFotoProgressURL],
        items: [], // Ambil item order secara terpisah jika menggunakan tabel _orderItemTable
      );
    }
    return null;
  }

  Future<int> updateOrder(Order order) async {
    Database db = await instance.database;
    String orderDateIso = order.orderDate.toIso8601String();
    return await db.update(
      _orderTable,
      {
        _orderColumnCustomerName: order.customerName,
        _orderColumnTotalPrice: order.totalPrice,
        _orderColumnOrderDate: orderDateIso,
        _orderColumnStatus: order.status,
        _orderColumnFotoProdukURL: order.fotoProdukURL,
        _orderColumnFotoProgressURL: order.fotoProgressURL,
        _orderColumnVideoProgressURL: order.videoProgressURL,
        _orderColumnProductName: order.productName,
        _orderColumnQuantity: order.quantity,
        _orderColumnPrice: order.price,
      },
      where: '$_orderColumnId = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int id) async {
    Database db = await instance.database;
    return await db.delete(
      _orderTable,
      where: '$_orderColumnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertOrderItem(OrderItem item, int orderId) async {
    Database db = await instance.database;
    return await db.insert(_orderItemTable, {
      _orderItemColumnOrderId: orderId,
      _orderItemColumnProductName: item.productName,
      _orderItemColumnQuantity: item.quantity,
      _orderItemColumnPrice: item.price,
      _orderItemColumnFotoProduk: item.fotoProduk,
      _orderItemColumnFotoProgress: item.fotoProgress,
    });
  }

  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _orderItemTable,
      where: '$_orderItemColumnOrderId = ?',
      whereArgs: [orderId],
    );
    return List.generate(maps.length, (i) {
      return OrderItem(
        productName: maps[i][_orderItemColumnProductName],
        quantity: maps[i][_orderItemColumnQuantity],
        price: maps[i][_orderItemColumnPrice],
        fotoProduk: maps[i][_orderItemColumnFotoProduk],
        fotoProgress: maps[i][_orderItemColumnFotoProgress],
      );
    });
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _orderTable,
      where: '$_orderColumnStatus = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) {
      DateTime orderDate = DateTime.parse(maps[i][_orderColumnOrderDate]);
      return Order(
        id: maps[i][_orderColumnId],
        customerName: maps[i][_orderColumnCustomerName],
        totalPrice: maps[i][_orderColumnTotalPrice],
        orderDate: orderDate,
        status: maps[i][_orderColumnStatus],
        fotoProdukURL: maps[i][_orderColumnFotoProdukURL],
        fotoProgressURL: maps[i][_orderColumnFotoProgressURL],
        items: [], // Ambil item order secara terpisah jika menggunakan tabel _orderItemTable
      );
    });
  }

  Future<List<Order>> getOrdersByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _orderTable,
      where:
          '$_orderColumnCustomerName = ?', // Ganti dengan kolom yang sesuai jika perlu
      whereArgs: [email],
    );

    return List.generate(maps.length, (i) {
      DateTime orderDate = DateTime.parse(maps[i][_orderColumnOrderDate]);
      return Order(
        id: maps[i][_orderColumnId],
        customerName: maps[i][_orderColumnCustomerName],
        totalPrice: maps[i][_orderColumnTotalPrice],
        orderDate: orderDate,
        status: maps[i][_orderColumnStatus],
        fotoProdukURL: maps[i][_orderColumnFotoProdukURL],
        fotoProgressURL: maps[i][_orderColumnFotoProgressURL],
        items: [], // Ambil item order secara terpisah jika menggunakan tabel _orderItemTable
      );
    });
  }

  Future<int> updateFotoProgress(
      int orderId, String newFotoProgressURL, String status) async {
    Database db = await instance.database;

    // Ambil data order sebelumnya
    Order? order = await getOrderById(orderId);
    if (order == null) {
      return 0; // Order tidak ditemukan
    }

    String oldFotoProgressURL = order.fotoProgressURL ?? '';

    // Perbarui foto progress di tabel orders
    int result = await db.update(
      _orderTable,
      {
        _orderColumnFotoProgressURL: newFotoProgressURL,
        _orderColumnStatus: status
      },
      where: '$_orderColumnId = ?',
      whereArgs: [orderId],
    );

    // Simpan riwayat pembaruan ke tabel order_progress_history
    await db.insert('order_progress_history', {
      'orderId': orderId,
      'oldFotoProgressURL': oldFotoProgressURL,
      'status': status,
      'newFotoProgressURL': newFotoProgressURL,
      'updateDate': DateTime.now().toIso8601String(),
    });

    return result;
  }

  Future<List<Map<String, dynamic>>> getFotoProgressHistory(int orderId) async {
    debugPrint('ini tereksekusi atau tidak');
    Database db = await instance.database;
    return await db.query(
      'order_progress_history',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }
}
