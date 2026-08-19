import 'package:flutter/material.dart';

/// Centralized model representing a supported application language.
class LanguageModel {
  final String code; // ISO 639-1 language code (e.g., 'en')
  final String name; // English display name (e.g., 'Spanish')
  final String nativeName; // Native name (e.g., 'Español')
  final String? countryCode;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.countryCode,
  });

  Locale get locale => Locale(code, countryCode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
