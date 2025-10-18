import 'package:flutter/material.dart'; // <<< THIS LINE WAS CORRECTED
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerForm extends StatefulWidget {
  const VolunteerForm({Key? key}) : super(key: key);

  @override
  _VolunteerFormState createState() => _VolunteerFormState();
}

class _VolunteerFormState extends State<VolunteerForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedCountry = 'Taiwan';
  final List<String> _countries = ['Taiwan', 'Japan', 'South Korea', 'United States', 'Singapore'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('userName') ?? '';
    final email = prefs.getString('userEmail') ?? '';
    if (fullName.isNotEmpty) {
      final nameParts = fullName.split(' ');
      _firstNameController.text = nameParts.first;
      if (nameParts.length > 1) {
        _lastNameController.text = nameParts.sublist(1).join(' ');
      }
    }
    _emailController.text = email;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for volunteering!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [Icon(Icons.volunteer_activism_outlined, color: Colors.purple), SizedBox(width: 10), Text("Become a Volunteer")]),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(controller: _firstNameController, decoration: InputDecoration(labelText: 'First Name'), validator: (v) => (v?.isEmpty??true) ? 'Required' : null),
              TextFormField(controller: _lastNameController, decoration: InputDecoration(labelText: 'Last Name'), validator: (v) => (v?.isEmpty??true) ? 'Required' : null),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => (v?.isEmpty??true) ? 'Required' : null),
              TextFormField(decoration: InputDecoration(labelText: 'Mobile Number'), keyboardType: TextInputType.phone),
              TextFormField(decoration: InputDecoration(labelText: 'Address')),
              TextFormField(decoration: InputDecoration(labelText: 'City')),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                items: _countries.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCountry = v),
              ),
              SizedBox(height: 20),
              TextFormField(decoration: InputDecoration(labelText: 'Which locations would you like to help in?', alignLabelWithHint: true), maxLines: 3),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop()),
        ElevatedButton(child: Text("Submit"), onPressed: _submitForm, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple)),
      ],
    );
  }
}