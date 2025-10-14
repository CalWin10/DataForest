// lib/models/species_model.dart

import 'package:flutter/material.dart';

// Data model for Species
class Species {
  final String name;
  final String status;
  final String info;
  final IconData icon;

  const Species({
    required this.name,
    required this.status,
    required this.info,
    required this.icon,
  });
}