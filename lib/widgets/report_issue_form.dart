import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportIssueForm extends StatefulWidget {
  @override
  _ReportIssueFormState createState() => _ReportIssueFormState();
}

class _ReportIssueFormState extends State<ReportIssueForm> {
  final _formKey = GlobalKey<FormState>();

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Report an Issue"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(decoration: InputDecoration(labelText: 'Name')),
              TextFormField(decoration: InputDecoration(labelText: 'Age')),
              TextFormField(decoration: InputDecoration(labelText: 'Phone Number')),
              TextFormField(decoration: InputDecoration(labelText: 'Address')),
              TextFormField(decoration: InputDecoration(labelText: 'Describe Issue', alignLabelWithHint: true), maxLines: 4),
              SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.add_a_photo),
                label: Text("Add Image/Video"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
        ElevatedButton(onPressed: () { /* Submit logic */ Navigator.of(context).pop(); }, child: Text("Submit")),
      ],
    );
  }
}