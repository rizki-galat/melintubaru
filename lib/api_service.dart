import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/user_model.dart';

import 'order_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5500'; // Sesuaikan dengan URL backend Anda

  // Menambahkan User
  Future<void> addUser(User user) async {
      String jsonString  = user.toJson();
      print('inijson: $jsonString');
      final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonString, // Pastikan body dikirim dalam format JSON
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add user');
    }
  }

  // Mengambil Semua User
  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromMap(Map<String, dynamic>.from(json))).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Menghapus User berdasarkan ID
  Future<Map<String, dynamic>> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to delete user');
    }
  }

  // Mengambil User berdasarkan ID
  Future<Map<String, dynamic>> getUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/id/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(response.body);
      return userData;
    } else {
      throw Exception('Failed to load user with ID: $id');
    }
  }

  // Login User
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['success'];
    } else {
      throw Exception('Gagal login');
    }
  }

  static Future<int?> getUserIdByEmail(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$email'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> user = json.decode(response.body);
      if (user.isNotEmpty) {
        return user['id'];
      } else {
        return null;
      }
    } else {
      throw Exception('Gagal mendapatkan User ID');
    }
  }

  // Order
  // Menambahkan Order
  Future<Map<String, dynamic>> addOrder(Map<String, dynamic> order) async {
    final url = Uri.parse('$baseUrl/orders');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );
    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to add order');
    }
  }

  // Mengambil Semua Order
  Future<List<dynamic>> getOrders({String? email}) async {
    final url = Uri.parse('$baseUrl/orders');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Mengambil Order berdasarkan ID
  Future<Map<String, dynamic>> getOrderById(int id) async {
    final url = Uri.parse('$baseUrl/orders/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to load order');
    }
  }

  // Mengupdate Order
  Future<Map<String, dynamic>> updateOrder(int id, Map<String, dynamic> order) async {
    final url = Uri.parse('$baseUrl/orders/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to update order');
    }
  }

  // Menghapus Order
  Future<void> deleteOrder(int id) async {
    debugPrint('$id');
    final url = Uri.parse('$baseUrl/orders/$id');
    final response = await http.delete(url);
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete order');
    }
  }

  // Mengambil Orders berdasarkan Email
  Future<List<Map<String, dynamic>>> getOrdersByEmail(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/email/$email'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> responseBody = List<Map<String, dynamic>>.from(json.decode(response.body));
      return responseBody;
    } else {
      throw Exception('Failed to load orders for email: $email');
    }
  }

  // Mengambil Semua Customers
  Future<List<User>> getAllCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromMap(Map<String, dynamic>.from(json))).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  // Mengupdate Foto Progress
  Future<void> updateFotoProgress(int orderId, String newFotoProgressURL, String status) async {
    debugPrint('$orderId');
    debugPrint(newFotoProgressURL);
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/progress'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'fotoProgressURL': newFotoProgressURL,
        'status': status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update foto progress');
    }
  }
  Future<void> updateFoto(int orderId, String newFotoProduct) async {
    debugPrint('$orderId');
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/fotoproduct'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'fotoProdukURL': newFotoProduct,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update foto dan video');
    }
  }
  Future<void> updateVideo(int orderId, String newVideoProduct) async {
    debugPrint('$orderId');
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/videoproduct'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        
        'videoProgressURL': newVideoProduct, 
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update foto dan video');
    }
  }
 Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/$orderId/items'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => OrderItem.fromMap(Map<String, dynamic>.from(json))).toList();
    } else {
      throw Exception('Failed to load order items');
    }
  }

  // Mendapatkan riwayat foto progress berdasarkan ID order
  Future<List<Map<String, dynamic>>> getFotoProgressHistory(int orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/$orderId/progress'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> responseBody = List<Map<String, dynamic>>.from(json.decode(response.body));
      return responseBody;
    } else {
      throw Exception('Failed to load foto progress history');
    }
  }

  Future<String> getFotoProduk(int orderId) async {
  final response = await http.get(Uri.parse('$baseUrl/orders/$orderId/fotoproduct'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['fotoProdukURL'];
  } else {
    throw Exception('Failed to load foto produk URL');
  }
}

  Future<String> getVideoUrl(int orderId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/$orderId/video'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      debugPrint('$data');
      return data['videoUrl'];
    } else {
      throw Exception('Failed to load video URL');
    }
  }

  // Mengupload File (Image atau Video)
Future<String?> uploadFile(File file) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data['url'];
    } else {
      final responseData = await response.stream.bytesToString();
      if (responseData.contains('No file uploaded')) {
        throw Exception('No file selected');  // Custom exception
      } else {
        throw Exception('Error uploading file: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error uploading file: $e');
    rethrow;
  }
}

}

