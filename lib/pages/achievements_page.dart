import 'package:flutter/material.dart';
import '../models/achievement_model.dart'; // Import the updated model

class AchievementsPage extends StatelessWidget {
  // Add a parameter to accept the user's name
  final String userName;
  const AchievementsPage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Separate achievements into two lists for the tabs
    final inProgress = achievementsList.where((a) => !a.isCompleted).toList();
    final completed = achievementsList.where((a) => a.isCompleted).toList();

    // The main content is a single scrollable list
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildHeader(context),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildStreakCard(context, 4), // Dummy streak of 4 days
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildLeaderboard(context),
        ),
        const SizedBox(height: 16),
        // Use a DefaultTabController for the achievements section
        DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                indicatorColor: Colors.green,
                labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'In Progress (${inProgress.length})'),
                  Tab(text: 'Completed (${completed.length})'),
                ],
              ),
              // The TabBarView needs a specific height to work inside a ListView
              SizedBox(
                height: 400, // Adjust this height based on your needs
                child: TabBarView(
                  children: [
                    _buildAchievementsList(inProgress),
                    _buildAchievementsList(completed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- BUILDER WIDGETS ---

  Widget _buildHeader(BuildContext context) {
    // Dummy data for level and points
    int totalPoints = 950;
    int level = (totalPoints / 100).floor();
    double progress = (totalPoints % 100) / 100.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Eco-Warrior Level $level', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$totalPoints Total Points', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 4),
            Text('${(progress * 100).toInt()}% to next level', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int streakDays) {
    return Card(
      color: Colors.orange[400],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$streakDays Day Streak!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Log in tomorrow to keep your streak alive!', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    // Create a local, editable copy of the leaderboard data
    final localLeaderboard = List<LeaderboardUser>.from(leaderboardData);

    // Find the user's default entry (which is named 'You')
    final youIndex = localLeaderboard.indexWhere((user) => user.name == 'You');

    // If the default entry is found, update its name with the actual user's name
    if (youIndex != -1) {
      final youData = localLeaderboard[youIndex];
      localLeaderboard[youIndex] = LeaderboardUser(
        rank: youData.rank,
        name: userName, // Use the passed-in user name
        points: youData.points,
        avatar: youData.avatar,
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏆 Community Leaderboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            // Use the modified local list to build the rows
            ...localLeaderboard.map((user) => _buildLeaderboardRow(context, user)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(BuildContext context, LeaderboardUser user) {
    // Check against the dynamic name to know which row to highlight
    final isYou = user.name == userName;
    IconData rankIcon;
    Color rankColor;

    switch (user.rank) {
      case 1:
        rankIcon = Icons.emoji_events;
        rankColor = Colors.amber;
        break;
      case 2:
        rankIcon = Icons.emoji_events;
        rankColor = Colors.grey[400]!;
        break;
      case 3:
        rankIcon = Icons.emoji_events;
        rankColor = Colors.brown[400]!;
        break;
      default:
        rankIcon = Icons.circle;
        rankColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isYou ? Colors.green.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: user.rank <= 3
                ? Icon(rankIcon, color: rankColor)
                : Text('${user.rank}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(width: 12),
          Text(user.avatar, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(user.name, style: TextStyle(fontWeight: isYou ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text('${user.points} XP', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No achievements here yet!"),
      ));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AchievementCard(achievement: achievements[index]);
      },
    );
  }
}

// --- Individual Achievement Card Widget ---

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({Key? key, required this.achievement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = achievement.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.grey.withOpacity(0.2) : achievement.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(achievement.icon, color: isCompleted ? Colors.grey : achievement.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(achievement.description, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isCompleted)
                    Chip(
                      label: Text('+${achievement.points} XP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      backgroundColor: achievement.color.withOpacity(0.2),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: achievement.progressPercentage,
                          backgroundColor: achievement.color.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${achievement.progress}/${achievement.goal}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: achievement.color),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}