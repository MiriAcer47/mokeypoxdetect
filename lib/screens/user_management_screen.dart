import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';
import 'alertDialog.dart';
import 'patient_list.dart';

///Klasa reprezentująca ekran zarządzania użytkownikami.
///
/// Pozwala administratorowi na przeglądanie, blokowanie, odblokowanie, nadawanie uprawnień administratora oraz usuwanie użytkowników.
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  ///Lista użytkowników pobrana z bazy danych.
  List<User> users = [];

  ///Instancja klasy 'DatabaseHelper' do interakcji z bazą danych.
  final dbHelper = DatabaseHelper.instance;

  ///Metoda wywoływana podczas inicjalizacji stanu.
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  ///Ładuje listę użytkowników z bazy danych.
  void _loadUsers() async {
    users = await dbHelper.getAllUsers();
    setState(() {});
  }

  /// Aktualizuje status blokady użytkownika.
  ///
  /// Zmienia wartość 'isBlocked' i aktualizuje rekord w bazie danych.
  void _toggleUserBlock(User user) async {
    user.isBlocked = !user.isBlocked;
    await dbHelper.updateUser(user);
    setState(() {});
  }

  ///Aktualizuje status administratora użytkownika
  ///
  /// Zmienia wartość 'isAdmin' i aktualizuje rekord w bazie.
  void _toggleAdminStatus(User user) async {
    user.isAdmin = !user.isAdmin;
    await dbHelper.updateUser(user);
    setState(() {});
  }

  ///Usuwa użytkownika z bazy danych.
  void _deleteUser(User user) async {
    await dbHelper.deleteUser(user.userID!);
    _loadUsers();
  }

  ///Wyświetla okno dialogowe potwierdzające usunięcie użytkowników.
  void _confirmDeleteUser(User user){
    CCupertinoAlertDialog.show(
      context: context,
      title: "Delete user",
      content: 'Do you really want to delete this user?',
      onConfirm: (){
        _deleteUser(user);
      },
    );
  }

  ///Metoda budująca interfejs ekranu zarządzania użytkownikami.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Users',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
          separatorBuilder: (context, index) => Divider(
            color: colorScheme.outline.withOpacity(0.2),
            thickness: 1,
          ),
          itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary,
              child: Text(
                user.username.isNotEmpty
                    ? user.username[0].toUpperCase()
                    : 'U',
                style: TextStyle(color: colorScheme.onSecondary),
              ),
            ),
               title: Text(user.username, style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface, fontWeight: FontWeight.bold,
              ),
          ),
               subtitle: Text(user.isAdmin ? 'Admin' : 'User', style: textTheme.bodyMedium?.copyWith(
              color: user.isAdmin ? Colors.blueAccent : colorScheme.onSurface.withOpacity(0.6),
            ),
            ),
            trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Przycisk blokady/odblokowania użytkownika
            IconButton(
            icon: Icon(
            user.isBlocked ? Icons.lock : Icons.lock_open,
            color: user.isBlocked ? colorScheme.error : Colors.green.shade400,
            ),
            onPressed: () => _toggleUserBlock(user),
            ),
            // Przycisk nadania/odebrania statusu administratora
            IconButton(
            icon: Icon(
            user.isAdmin ? Icons.remove_circle : Icons.admin_panel_settings,
            color: user.isAdmin ? Colors.orange.shade400 : Colors.blueAccent,
            ),
            onPressed: () => _toggleAdminStatus(user),
            ),
            // Przycisk usunięcia użytkownika
            IconButton(
            icon: Icon(Icons.delete, color: colorScheme.error),
            onPressed: () => _confirmDeleteUser(user),
            ),
            ],

            ),
          );

        }

      ),

    );
  }
}
