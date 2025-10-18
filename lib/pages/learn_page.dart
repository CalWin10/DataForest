import 'package:flutter/material.dart';

class LearnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Learn About Biodiversity")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("What is Biodiversity?", style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 8),
          Text("Biodiversity is all the different kinds of life you'll find in one area..."),
          // Add more sections and rich text/images here
        ],
      ),
    );
  }
}