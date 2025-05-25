import 'package:flutter/material.dart';

class ProfilePanel extends StatelessWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          SizedBox(height: 16),
          Text('User Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('user.email@example.com'),
        ],
      ),
    );
  }
}
