import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

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
        throw Exception();
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
        fetchVisitors();
      } else {
        throw Exception();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel visitor')),
      );
    }
  }

  // =========================
  // CREATE FEEDBACK QR (VISITOR ID)
  // =========================
  Future<void> createFeedbackQr(int visitorId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/feedback/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'visitor_id': visitorId}),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];

        // ✅ FORCE LOCALHOST
        final server = 'http://localhost:3000';

        final url = '$server/feedback.html?token=$token';

        print("TOKEN: $token");
        print("SERVER: $server");
        print("URL: $url");
        print("OPENING QR DIALOG");

        showQrDialog(url);
      } else {
        throw Exception();
      }
    } catch (e) {
      print("ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create QR')),
      );
    }
  }

  // =========================
  // QR POPUP (FIXED CRASH)
  // =========================
  void showQrDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Scan for Feedback"),
        content: SizedBox(
          width: 220,
          height: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: url,
                size: 200,
              ),
              const SizedBox(height: 10),
              const Text("Visitor scan using mobile"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  // =========================
  // STATUS
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
                showFeedback:
                rawStatus.toLowerCase() == 'completed',
                onFeedback: () => createFeedbackQr(visitorId),
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // CANCEL DIALOG
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
  // ITEM UI
  // =========================
  Widget visitorItem({
    required int index,
    required String name,
    required String status,
    required Color statusColor,
    required bool showFeedback,
    required VoidCallback onFeedback,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            if (showFeedback) ...[
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onFeedback,
                child: const Text("Feedback"),
              ),
            ]
          ],
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
