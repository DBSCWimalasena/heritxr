import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'visitor_queue_page.dart';

class QrScreen extends StatelessWidget {
  final String name;
  final int duration;
  final String token;

  const QrScreen({
    super.key,
    required this.name,
    required this.duration,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    // 🔴 LOCALHOST LINK (FOR LAPTOP BROWSER TESTING)
    final String qrUrl =
        "http://localhost:3000/visit.html?token=$token";

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Visitor QR'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "Welcome $name",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Session: $duration minutes",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            QrImageView(
              data: qrUrl,
              size: 220,
            ),

            const SizedBox(height: 40),

            // DONE BUTTON → BACK TO VISITOR QUEUE
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VisitorQueuePage(
                        name: '',
                        email: '',
                      ),
                    ),
                        (route) => false,
                  );
                },
                child: const Text(
                  "DONE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
