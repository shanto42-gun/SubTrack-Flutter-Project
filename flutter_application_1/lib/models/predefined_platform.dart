import 'package:flutter/material.dart';

class PredefinedPlatform {
  final String name;
  final String category;
  final IconData icon;
  final Color color;
  final double defaultAmount;
  final String defaultBillingCycle;

  const PredefinedPlatform({
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    this.defaultAmount = 9.99,
    this.defaultBillingCycle = 'monthly',
  });

  static const List<PredefinedPlatform> popularPlatforms = [
    PredefinedPlatform(
      name: 'Netflix',
      category: 'Streaming',
      icon: Icons.movie_outlined,
      color: Color(0xFFE50914),
      defaultAmount: 15.49,
    ),
    PredefinedPlatform(
      name: 'Spotify',
      category: 'Music',
      icon: Icons.music_note_outlined,
      color: Color(0xFF1DB954),
      defaultAmount: 10.99,
    ),
    PredefinedPlatform(
      name: 'YouTube Premium',
      category: 'Entertainment',
      icon: Icons.play_arrow_rounded,
      color: Color(0xFFFF0000),
      defaultAmount: 13.99,
    ),
    PredefinedPlatform(
      name: 'Amazon Prime',
      category: 'Entertainment',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFF00A8E1),
      defaultAmount: 14.99,
    ),
    PredefinedPlatform(
      name: 'Disney+',
      category: 'Streaming',
      icon: Icons.star_outline_rounded,
      color: Color(0xFF113CCF),
      defaultAmount: 13.99,
    ),
    PredefinedPlatform(
      name: 'Apple Music / One',
      category: 'Entertainment',
      icon: Icons.apple,
      color: Color(0xFF333333),
      defaultAmount: 10.99,
    ),
    PredefinedPlatform(
      name: 'Google One',
      category: 'Cloud',
      icon: Icons.cloud_outlined,
      color: Color(0xFF4285F4),
      defaultAmount: 2.99,
    ),
    PredefinedPlatform(
      name: 'iCloud+',
      category: 'Cloud',
      icon: Icons.cloud_queue_rounded,
      color: Color(0xFF29B6F6),
      defaultAmount: 2.99,
    ),
    PredefinedPlatform(
      name: 'ChatGPT Plus',
      category: 'Productivity',
      icon: Icons.smart_toy_outlined,
      color: Color(0xFF10A37F),
      defaultAmount: 20.00,
    ),
    PredefinedPlatform(
      name: 'GitHub Copilot / Pro',
      category: 'Software',
      icon: Icons.code_rounded,
      color: Color(0xFF24292E),
      defaultAmount: 10.00,
    ),
    PredefinedPlatform(
      name: 'Gym / Fitness',
      category: 'Fitness',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFFFF5722),
      defaultAmount: 29.99,
    ),
    PredefinedPlatform(
      name: 'PlayStation Plus / Xbox',
      category: 'Entertainment',
      icon: Icons.sports_esports_outlined,
      color: Color(0xFF5C6BC0),
      defaultAmount: 14.99,
    ),
  ];
}
