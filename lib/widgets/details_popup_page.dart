import 'package:flutter/material.dart';
import 'dart:ui';

class DetailsPopupPage extends StatelessWidget {
  final String name;
  final String imagePath;
  final IconData? icon;
  final String status;
  final String cause;
  final String history;

  const DetailsPopupPage({
    Key? key,
    required this.name,
    this.imagePath = "",
    this.icon,
    required this.status,
    required this.cause,
    required this.history,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        imagePath.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(imagePath, height: 150, width: double.infinity, fit: BoxFit.cover),
                        )
                            : Icon(icon, size: 80, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Chip(label: Text(status), backgroundColor: Colors.red.withOpacity(0.1)),
                        const Divider(height: 30),
                        _buildDetailRow("Cause of Extinction/Threat", cause, context),
                        _buildDetailRow("History/Info", history, context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String content, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 4),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
      ],
    );
  }
}