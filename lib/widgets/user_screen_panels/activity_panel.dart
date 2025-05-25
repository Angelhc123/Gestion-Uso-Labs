import 'package:flutter/material.dart';

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.list_alt, size: 60, color: Colors.blue),
          SizedBox(height: 16),
          Text('No recent activity.', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
