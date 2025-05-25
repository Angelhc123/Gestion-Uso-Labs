import 'package:flutter/material.dart';
import 'package:controlusolab/widgets/user_screen_panels/profile_panel.dart';
import 'package:controlusolab/widgets/user_screen_panels/settings_panel.dart';
import 'package:controlusolab/widgets/user_screen_panels/activity_panel.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProfilePanel(),
          SettingsPanel(),
          ActivityPanel(),
        ],
      ),
    );
  }
}