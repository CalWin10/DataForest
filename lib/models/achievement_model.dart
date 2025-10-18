import 'package:flutter/material.dart';

// --- Data Model for a single Achievement ---
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final int points; // Points awarded on completion
  final int progress;
  final int goal;
  final Color color;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.progress,
    required this.goal,
    required this.color,
  });

  // Calculated properties to easily check status
  bool get isCompleted => progress >= goal;
  double get progressPercentage => (progress / goal).clamp(0.0, 1.0);
}

// --- Data Model for a Leaderboard Entry ---
class LeaderboardUser {
  final int rank;
  final String name;
  final int points;
  final String avatar; // Using a character for avatar for simplicity

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
  });
}


// --- DUMMY DATA ---

// Your dynamic list of dummy data for achievements
final List<Achievement> achievementsList = [
  Achievement(
    title: 'Report Watcher',
    description: 'Submit your first environmental issue report.',
    icon: Icons.flag_rounded,
    points: 50,
    progress: 1,
    goal: 1,
    color: Colors.green,
  ),
  Achievement(
    title: 'Community Guardian',
    description: 'Submit 5 issue reports in your local area.',
    icon: Icons.group_add_rounded,
    points: 150,
    progress: 3,
    goal: 5,
    color: Colors.blue,
  ),
  Achievement(
    title: 'Biodiversity Expert',
    description: 'View 10 different species in the database.',
    icon: Icons.search_sharp,
    points: 100,
    progress: 10,
    goal: 10,
    color: Colors.orange,
  ),
  Achievement(
    title: 'AR Explorer',
    description: 'Use the AR experience to identify 3 species.',
    icon: Icons.camera_alt_rounded,
    points: 120,
    progress: 0,
    goal: 3,
    color: Colors.purple,
  ),
  Achievement(
    title: 'Map Navigator',
    description: 'Explore the environmental map for 15 minutes.',
    icon: Icons.map_rounded,
    points: 75,
    progress: 7,
    goal: 15,
    color: Colors.red,
  ),
  Achievement(
    title: 'Perfect Week',
    description: 'Log in every day for 7 consecutive days.',
    icon: Icons.calendar_view_week_rounded,
    points: 200,
    progress: 4,
    goal: 7,
    color: Colors.teal,
  ),
];

// Dummy data for the leaderboard, including a 'You' entry to be replaced
final List<LeaderboardUser> leaderboardData = [
  LeaderboardUser(rank: 1, name: 'ADITHYA', points: 8520, avatar: '🌳'),
  LeaderboardUser(rank: 2, name: 'CALWIN', points: 7950, avatar: '🐻'),
  LeaderboardUser(rank: 3, name: 'ARAVIND', points: 7100, avatar: '🌊'),
  LeaderboardUser(rank: 48, name: 'You', points: 950, avatar: '😊'),
  LeaderboardUser(rank: 49, name: 'ANAND', points: 920, avatar: '🌲'),
  LeaderboardUser(rank: 70, name: 'GURU', points: 998, avatar: '😎'),
];