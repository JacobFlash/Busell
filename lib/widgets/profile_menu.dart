import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    authService.currentUser?.displayName
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authService.currentUser?.displayName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authService.currentUser?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
            title: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              // TODO: Navigate to edit profile screen
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading:
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              // TODO: Navigate to settings screen
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications,
                color: Theme.of(context).primaryColor),
            title: const Text(
              'Notifications',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              // TODO: Navigate to notifications screen
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Theme.of(context).primaryColor),
            title: const Text(
              'Help & Support',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              // TODO: Navigate to help screen
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).primaryColor),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                // TODO: Navigate to login screen
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
