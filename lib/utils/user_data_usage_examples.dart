/// This file demonstrates how to use UserProvider and access user data
/// throughout the app using Provider and SharedPreferences

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

/// Example 1: Display user name in any widget
class ExampleUserNameDisplay extends StatelessWidget {
  const ExampleUserNameDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.user?.name ?? 'Guest';
        return Text('Hello, $userName!');
      },
    );
  }
}

/// Example 2: Check if user is logged in
class ExampleLoginCheck extends StatelessWidget {
  const ExampleLoginCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (userProvider.isLoggedIn) {
      return const Text('User is logged in');
    } else {
      return const Text('User is not logged in');
    }
  }
}

/// Example 3: Access user data without rebuilding widget
class ExampleAccessUserData extends StatelessWidget {
  const ExampleAccessUserData({Key? key}) : super(key: key);

  void _printUserInfo(BuildContext context) {
    // Use listen: false to access data without rebuilding
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      print('User ID: ${user.id}');
      print('Name: ${user.name}');
      print('Email: ${user.email}');
      print('Phone: ${user.phoneNumber}');
      print('City: ${user.city}');
      print('Gender: ${user.gender}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _printUserInfo(context),
      child: const Text('Print User Info'),
    );
  }
}

/// Example 4: Update user profile
class ExampleUpdateProfile extends StatefulWidget {
  const ExampleUpdateProfile({Key? key}) : super(key: key);

  @override
  State<ExampleUpdateProfile> createState() => _ExampleUpdateProfileState();
}

class _ExampleUpdateProfileState extends State<ExampleUpdateProfile> {
  final _nameController = TextEditingController();

  Future<void> _updateName(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    
    if (currentUser != null && _nameController.text.isNotEmpty) {
      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
      );
      
      await userProvider.updateUser(updatedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'New Name'),
        ),
        ElevatedButton(
          onPressed: () => _updateName(context),
          child: const Text('Update Name'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

/// Example 5: Display different content based on user data
class ExampleConditionalContent extends StatelessWidget {
  const ExampleConditionalContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        
        if (user == null) {
          return const Text('Please log in to continue');
        }
        
        // Show different content based on user's city
        if (user.city?.toLowerCase() == 'noida') {
          return const Text('Welcome, Noida resident!');
        } else {
          return Text('Welcome from ${user.city}!');
        }
      },
    );
  }
}

/// Example 6: Logout functionality
class ExampleLogoutButton extends StatelessWidget {
  const ExampleLogoutButton({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logoutUser();
    
    if (context.mounted) {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _logout(context),
      child: const Text('Logout'),
    );
  }
}

/// Example 7: Show user avatar with initials
class ExampleUserAvatar extends StatelessWidget {
  const ExampleUserAvatar({Key? key}) : super(key: key);

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.user?.name ?? 'User';
        
        return CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            _getInitials(userName),
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
