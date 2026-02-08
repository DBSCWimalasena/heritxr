import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/api_config.dart';

class VisitorListPage extends StatefulWidget {
  const VisitorListPage({super.key});

  @override
  State<VisitorListPage> createState() => _VisitorListPageState();
}

class _VisitorListPageState extends State<VisitorListPage> {
  bool loading = true;
  List visitors = [];

  @override
  void initState() {
    super.initState();
    fetchVisitors();
  }

  // =========================
  // FETCH VISITOR LIST
  // =========================
  Future<void> fetchVisitors() async {
    setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/visitor/list'),
      );

      if (response.statusCode == 200) {
        setState(() {
          visitors = jsonDecode(response.body);
          loading = false;
        });
      } else {
        throw Exception('Failed to load visitors');
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch visitor list')),
      );
    }
  }

  // =========================
  // CANCEL VISITOR
  // =========================
  Future<void> cancelVisitor(int visitorId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/visitor/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'visitor_id': visitorId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitor cancelled')),
        );
        fetchVisitors(); // 🔄 refresh list
      } else {
        throw Exception('Cancel failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel visitor')),
      );
    }
  }

  // =========================
  // STATUS COLOR
  // =========================
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.deepPurple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // =========================
  // STATUS TEXT
  // =========================
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return 'WAITING';
      case 'active':
        return 'IN SESSION';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Visitor list",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : visitors.isEmpty
            ? const Center(child: Text("No visitors found"))
            : ListView.builder(
          itemCount: visitors.length,
          itemBuilder: (context, index) {
            final visitor = visitors[index];

            final int visitorId = visitor['visitor_id'];
            final int queueNumber =
                visitor['queue_number'] ?? (index + 1);
            final String name =
                visitor['name'] ?? 'Unknown Visitor';
            final String rawStatus =
                visitor['status'] ?? 'waiting';

            return GestureDetector(
              onTap: () {
                if (rawStatus.toLowerCase() == 'waiting') {
                  showCancelDialog(visitorId, name);
                }
              },
              child: visitorItem(
                index: queueNumber,
                name: name,
                status: getStatusText(rawStatus),
                statusColor: getStatusColor(rawStatus),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // =========================
  // CANCEL CONFIRM DIALOG
  // =========================
  void showCancelDialog(int visitorId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Visitor'),
        content: Text('Cancel visit for "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              cancelVisitor(visitorId);
            },
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  // =========================
  // VISITOR ITEM UI
  // =========================
  Widget visitorItem({
    required int index,
    required String name,
    required String status,
    required Color statusColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              "$index. $name",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
