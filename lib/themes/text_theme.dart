import 'package:flutter/material.dart';

const _bold = FontWeight.w700;
const _semiBold = FontWeight.w600;
const _medium = FontWeight.w500;
const _regular = FontWeight.w400;

const TextTheme textTheme = TextTheme(
  headlineLarge: TextStyle(fontSize: 28.0, fontWeight: _bold),
  headlineMedium: TextStyle(fontSize: 24.0, fontWeight: _semiBold),
  headlineSmall: TextStyle(fontSize: 20.0, fontWeight: _medium),
  bodyLarge: TextStyle(fontSize: 20.0, fontWeight: _regular),
  bodyMedium: TextStyle(fontSize: 18.0, fontWeight: _regular),
  bodySmall: TextStyle(fontSize: 16.0, fontWeight: _regular),
  titleLarge: TextStyle(fontSize: 24.0, fontWeight: _bold),
  titleMedium: TextStyle(fontSize: 22.0, fontWeight: _semiBold),
  titleSmall: TextStyle(fontSize: 20.0, fontWeight: _medium),
  labelLarge: TextStyle(fontSize: 16.0, fontWeight: _semiBold),
  labelMedium: TextStyle(fontSize: 14.0, fontWeight: _medium),
  labelSmall: TextStyle(fontSize: 12.0, fontWeight: _regular),
);
