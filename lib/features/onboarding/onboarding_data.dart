import 'package:flutter/material.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final IconData? icon;
  final String? assetPath;

  const OnboardingPageData({
    required this.title,
    required this.description,
    this.icon,
    this.assetPath,
  });
}

const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    title: 'Learn Lithuanian, clearly',
    description: 'Short lessons + real dialogues to get you speaking fast.',
    assetPath: 'assets/branding/logo_mark_1024.png',
  ),
  OnboardingPageData(
    title: 'Practice & remember',
    description: 'Spaced repetition tailored to your progress.',
    icon: Icons.psychology_outlined,
  ),
  OnboardingPageData(
    title: 'Prepare for A1–B2',
    description: 'Track your level and practice with exam-style questions.',
    icon: Icons.school_outlined,
  ),
];
