import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Ładowanie użytkowników z bazy danych
  void _loadUsers() async {
    users = await dbHelper.getAllUsers();
    setState(() {});
  }

  // Aktualizacja statusu blokady użytkownika
  void _toggleUserBlock(User user) async {
    user.isBlocked = !user.isBlocked;
    await dbHelper.updateUser(user);
    setState(() {});
  }

  // Aktualizacja statusu administratora
  void _toggleAdminStatus(User user) async {
    user.isAdmin = !user.isAdmin;
    await dbHelper.updateUser(user);
    setState(() {});
  }

  // Usunięcie użytkownika
  void _deleteUser(User user) async {
    await dbHelper.deleteUser(user.userID!);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text(user.isAdmin ? 'Admin' : 'User'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Przycisk blokady/odblokowania użytkownika
                IconButton(
                  icon: Icon(
                    user.isBlocked ? Icons.lock : Icons.lock_open,
                    color: user.isBlocked ? Colors.red : Colors.green,
                  ),
                  onPressed: () => _toggleUserBlock(user),
                ),
                // Przycisk nadania/odebrania statusu administratora
                IconButton(
                  icon: Icon(
                    user.isAdmin ? Icons.remove_circle : Icons.admin_panel_settings,
                    color: user.isAdmin ? Colors.orange : Colors.blue,
                  ),
                  onPressed: () => _toggleAdminStatus(user),
                ),
                // Przycisk usunięcia użytkownika
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(user),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
