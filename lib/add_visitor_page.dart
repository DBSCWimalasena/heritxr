import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';
import 'qr_screen.dart';

class AddVisitorPage extends StatefulWidget {
  const AddVisitorPage({super.key});

  @override
  State<AddVisitorPage> createState() => _AddVisitorPageState();
}

class _AddVisitorPageState extends State<AddVisitorPage> {
  String selectedDuration = '5';

  final List<String> durations =
  List.generate(16, (index) => '${index + 5}'); // 5 to 20

  final TextEditingController nameController = TextEditingController();
  bool loading = false;

  // 🔹 CALL TEMP API → NAVIGATE TO QR SCREEN
  Future<void> submitAndGenerateQr() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visitor name is required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/visitor/temp-create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "duration": int.parse(selectedDuration),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrScreen(
              name: nameController.text.trim(),
              duration: int.parse(selectedDuration),
              token: data['token'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate QR")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server connection failed")),
      );
    }

    setState(() => loading = false);
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
          'Add Visitor',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Visitor Name", style: TextStyle(fontSize: 14)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            const Text("Session Duration", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButton<String>(
                value: selectedDuration,
                underline: const SizedBox(),
                items: durations.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value minutes'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedDuration = value!);
                },
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: loading ? null : submitAndGenerateQr,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "SUBMIT",
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
