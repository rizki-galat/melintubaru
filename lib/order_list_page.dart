import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'order_detail_page.dart';
import 'order_add_page.dart';
import 'order_model.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  OrderListPageState createState() => OrderListPageState();
}

class OrderListPageState extends State<OrderListPage> {
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isAdmin = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initialize();
    _searchController.addListener(_onSearchChanged);
  }
  Future<void> _initialize() async {
    await _checkAdminStatus();
    _loadOrders();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAdminStatus();
    // Reload orders when returning to this page
    // _loadOrders();
  }
  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final userResponse = await _apiService.getUserById(userId);
      final user = Map<String, dynamic>.from(userResponse);
      debugPrint(user['role']);
      setState(() {
        _isAdmin = user['role'] == 'Admin' ? true : false;
      });
    } else {
      setState(() {
        _isAdmin = false;
      });
    }
  }
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<Order> orders;
      debugPrint('$_isAdmin');
      if (_isAdmin) {
        final response = await _apiService.getOrders();
        orders = List<Order>.from(response.map((data) => Order.fromMap(data)));
      } else {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');
        final userResponse = await _apiService.getUserById(userId!);
        final user = Map<String, dynamic>.from(userResponse);
        final orderResponse = await _apiService.getOrdersByEmail(user['email']);
        print('Order response by email: $orderResponse'); // Cek format JSON
        orders = List<Order>.from(orderResponse.map((data) => Order.fromMap(data)));
      }

      setState(() {
        _orders = orders;
        _filteredOrders = orders;
      });
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  void _onSearchChanged() {
    _searchOrders(_searchController.text);
  }

  void _searchOrders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = _orders;
      } else {
        _filteredOrders = _orders.where((order) {
          return order.customerName
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              order.status!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showAddOrderPage() async {
    final newOrder = await Navigator.push<Order?>(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderAddPage(),
      ),
    );

    if (newOrder != null) {
      await _apiService.addOrder(newOrder.toMap());
      _loadOrders(); // Reload orders after adding a new order
    }
  }

  void _showEditOrderPage(Order order) async {
    final editedOrder = await Navigator.push<Order?>(
      context,
      MaterialPageRoute(
        builder: (context) => OrderAddPage(order: order),
      ),
    );

    if (editedOrder != null) {
      await _apiService.updateOrder(order.id, editedOrder.toMap());
      _loadOrders(); // Reload orders after editing an existing order
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Order'),
        actions: [
          const Text('Refresh',style: TextStyle(color: Colors.blue)),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _loadOrders,
             
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari Order',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? const Center(child: Text('order tidak ditemukan'))
                      : ListView.builder(
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text('Total  : ${order.totalPrice}'),
                                          Text(
                                              'Status: ${order.status ?? 'N/A'}'),
                                          Text('Nama Produk :${order.productName} '),
                                        ],
                                      ),
                                    ),
                                    if (_isAdmin)
                                      Row(
                                        children: [
                                           ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetailPage(order: order),
                                            ),
                                          );
                                        },
                                        child: const Text('Detail'),
                                        
                                      ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _showEditOrderPage(order);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              bool confirmDelete =
                                                  await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Konfirmasi Hapus'),
                                                    content: const Text(
                                                        'Apakah Anda yakin ingin menghapus order ini?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child:
                                                            const Text('Batal'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false),
                                                      ),
                                                      TextButton(
                                                        child:
                                                            const Text('Hapus'),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (confirmDelete == true) {
                                                await _apiService.deleteOrder(order.id);
                                                _loadOrders(); // Reload orders after deleting
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Order berhasil dihapus')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetailPage(order: order),
                                            ),
                                          );
                                        },
                                        child: const Text('Detail Order'),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddOrderPage,
              child: const Icon(Icons.add), 
            )
          : null,
    
    
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
