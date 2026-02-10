import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class VisitorAnalyticsPage extends StatefulWidget {
  const VisitorAnalyticsPage({super.key});

  @override
  State<VisitorAnalyticsPage> createState() => _VisitorAnalyticsPageState();
}

class _VisitorAnalyticsPageState extends State<VisitorAnalyticsPage> {
  bool loading = true;
  bool animateCharts = false;

  int totalRatings = 0;
  List<double> ratingValues = [0, 0, 0, 0, 0];
  Map<String, double> interactionData = {};

  final String baseUrl = "http://10.0.2.2:3000/api/analytics";

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      final ratingsRes = await http.get(Uri.parse("$baseUrl/ratings"));
      final interactionsRes =
      await http.get(Uri.parse("$baseUrl/interactions"));

      final ratingsJson = jsonDecode(ratingsRes.body);
      final interactionsJson = jsonDecode(interactionsRes.body);

      totalRatings = ratingsJson["totalRatings"];

      final r = ratingsJson["ratings"];

      ratingValues = [
        (r["5"] ?? 0).toDouble(),
        (r["4"] ?? 0).toDouble(),
        (r["3"] ?? 0).toDouble(),
        (r["2"] ?? 0).toDouble(),
        (r["1"] ?? 0).toDouble(),
      ];

      interactionData = {};
      interactionsJson["interactions"].forEach((k, v) {
        interactionData[k] = v.toDouble();
      });

      setState(() => loading = false);

      Future.delayed(const Duration(milliseconds: 400), () {
        setState(() => animateCharts = true);
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Visitor Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            analyticsCard(
              title: 'Total Ratings',
              value: totalRatings.toString(),
              color: Colors.blue,
            ),

            const SizedBox(height: 30),

            analyticsContainer(
              title: 'Visitor Ratings',
              chart: PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  centerSpaceRadius: 65,
                  sectionsSpace: 6,
                  sections:
                  animateCharts ? ratingSections() : emptySections(5),
                ),
                swapAnimationDuration:
                const Duration(milliseconds: 1200),
              ),
              legend: const [
                StarLegend(color: Color(0xFF4CAF50), stars: 5),
                StarLegend(color: Color(0xFF8BC34A), stars: 4),
                StarLegend(color: Color(0xFFFF9800), stars: 3),
                StarLegend(color: Color(0xFFFF5722), stars: 2),
                StarLegend(color: Color(0xFFF44336), stars: 1),
              ],
            ),

            const SizedBox(height: 30),

            analyticsContainer(
              title: 'Visitor Interactions',
              chart: PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  centerSpaceRadius: 65,
                  sectionsSpace: 6,
                  sections: animateCharts
                      ? interactionSections()
                      : emptySections(interactionData.length),
                ),
                swapAnimationDuration:
                const Duration(milliseconds: 1200),
              ),
              legend: interactionData.entries
                  .map((e) => InteractionLegend(
                label: e.key,
                color: Colors.primaries[
                interactionData.keys.toList().indexOf(e.key) %
                    Colors.primaries.length],
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PIE
  // =========================
  List<PieChartSectionData> ratingSections() {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF8BC34A),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFFF44336),
    ];

    final double total = ratingValues.reduce((a, b) => a + b);

    return List.generate(
      ratingValues.length,
          (i) => pie(ratingValues[i], colors[i], total),
    );
  }

  List<PieChartSectionData> interactionSections() {
    final values = interactionData.values.toList();
    final double total =
    values.isEmpty ? 1 : values.reduce((a, b) => a + b);

    int i = 0;
    return values.map((v) {
      final color = Colors.primaries[i % Colors.primaries.length];
      i++;
      return pie(v, color, total);
    }).toList();
  }

  PieChartSectionData pie(double value, Color color, double total) {
    final percent = total == 0 ? 0 : (value / total * 100).round();

    return PieChartSectionData(
      value: value,
      color: color,
      radius: 60,
      showTitle: true,
      title: "$percent%",
      titleStyle: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  List<PieChartSectionData> emptySections(int count) {
    return List.generate(
      count,
          (_) => PieChartSectionData(
        value: 1,
        color: Colors.grey,
        showTitle: false,
      ),
    );
  }

  // =========================
  // UI
  // =========================
  Widget analyticsCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget analyticsContainer({
    required String title,
    required Widget chart,
    required List<Widget> legend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(height: 240, child: chart),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 12,
            children: legend,
          ),
        ],
      ),
    );
  }
}

// =========================
// LEGENDS
// =========================
class StarLegend extends StatelessWidget {
  final int stars;
  final Color color;

  const StarLegend({
    super.key,
    required this.stars,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
              (index) => Icon(
            Icons.star,
            size: 18,
            color: index < stars ? color : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class InteractionLegend extends StatelessWidget {
  final String label;
  final Color color;

  const InteractionLegend({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
