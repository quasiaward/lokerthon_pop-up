import 'package:flutter/material.dart';

class ProductPreview {
  const ProductPreview({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.accent,
    required this.motif,
  });

  final String id;
  final String name;
  final String subtitle;
  final String description;
  final List<String> tags;
  final Color accent;
  final String motif;
}
