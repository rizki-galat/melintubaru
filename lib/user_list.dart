import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart'; // Update import untuk ApiService
import 'user_model.dart';
import 'add_user_page.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late Future<List<User>> _users;
  List<User> _filteredUsers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Inisialisasi daftar pengguna
  }

  void _loadUsers() {
    _users = ApiService().getAllCustomers(); // Menggunakan ApiService
    _users.then((users) => setState(() {
      _filteredUsers = users;
    }));
  }

  void refreshUserList() {
    _loadUsers(); // Memuat ulang daftar pengguna
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        actions: [
          const Text('Refresh'),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshUserList(); // Memuat ulang daftar pengguna
            },
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
                hintText: 'Cari Pengguna ...', prefixIcon: Icon(Icons.search)),
            onChanged: (text) {
              setState(() {
                _filteredUsers = _filteredUsers
                    .where((user) =>
                        user.email.toLowerCase().contains(text.toLowerCase()))
                    .toList();
                if (kDebugMode) {
                  print(_filteredUsers);
                }
              });
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<User>>(
            future: _users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    User user = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user.foto),
                              radius: 25,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Peran: ${user.role}'),
                                  
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Logika hapus pengguna
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Konfirmasi Hapus'),
                                      content: const Text(
                                          'Apakah kamu yakin ingin menghapus pengguna ini?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Batal'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text('Hapus'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                // Jika pengguna mengkonfirmasi, hapus pengguna.
                                if (confirmDelete == true) {
                                  try {
                                    // Hapus pengguna melalui ApiService
                                    await ApiService().deleteUser(user.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Gagal menghapus pengguna')),
                                    );
                                    refreshUserList();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Pengguna berhasil dihapus')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddUserPage(onUserAdded: refreshUserList)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
