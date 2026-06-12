import 'package:flutter/material.dart';

enum PaymentType { mtn, airtel, card, stripe, cash }

class PaymentMethodModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final PaymentType type;
  final String? lastFour;

  PaymentMethodModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    this.lastFour,
  });
}
