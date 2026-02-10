import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'visitor_analytics_page.dart';

class VisitorQueuePage extends StatelessWidget {
  final String name;
  final String email;

  const VisitorQueuePage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // ======================
          // COVER
          // ======================
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/cover2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(20),
            child: const Text(
              "Visitor Queue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ======================
          // VISITOR LIST
          // ======================
          actionButton(
            text: "Visitor List",
            onTap: () {
              Navigator.pushNamed(context, '/visitor-list');
            },
          ),

          const SizedBox(height: 20),

          // ======================
          // ADD VISITOR
          // ======================
          actionButton(
            text: "Add Visitor",
            onTap: () {
              Navigator.pushNamed(context, '/add-visitor');
            },
          ),

          const SizedBox(height: 20),

          // ======================
          // VISITOR ANALYTICS (NEW)
          // ======================
          actionButton(
            text: "Visitor Analytics",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VisitorAnalyticsPage(),
                ),
              );
            },
          ),
        ],
      ),

      // ======================
      // BOTTOM NAV BAR
      // ======================
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(
                  name: name,
                  email: email,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Visitor",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // ======================
  // REUSABLE BUTTON
  // ======================
  Widget actionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.double_arrow, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
