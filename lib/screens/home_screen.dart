// lib/screens/home_screen.dart
// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// --- Data Models ---

/// Represents a quiz category.
class QuizCategory {
  final String name;
  final IconData icon;
  final Color color;

  const QuizCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Represents the logged-in user's game statistics.
class UserData {
  final String displayName;
  final int rank;
  final int score;
  final int coins;

  UserData({
    required this.displayName,
    required this.rank,
    required this.score,
    required this.coins,
  });
}

// --- Main Home Screen with Bottom Navigation ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  // The pages corresponding to the bottom navigation bar items
  static const List<Widget> _pages = <Widget>[
    _CategoryPage(),
    _ScoresPage(), // Placeholder for Scores Screen
    _LeaderboardPage(), // Placeholder for Leaderboard Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // AuthWrapper will navigate to the login screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: IndexedStack(
        // Use IndexedStack to preserve state of each tab
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'My Scores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Page to Display Quiz Categories and User Stats ---
class _CategoryPage extends StatefulWidget {
  const _CategoryPage({Key? key}) : super(key: key);

  @override
  State<_CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<_CategoryPage> {
  late Future<UserData> _userDataFuture;

  // Mock data for quiz categories. In a real app, you would fetch this from Firebase.
  static final List<QuizCategory> _categories = [
    QuizCategory(name: 'Science', icon: Icons.science, color: Colors.blue),
    QuizCategory(
        name: 'History', icon: Icons.history_edu, color: Colors.orange),
    QuizCategory(
        name: 'Sports', icon: Icons.sports_soccer, color: Colors.green),
    QuizCategory(name: 'Movies', icon: Icons.movie, color: Colors.red),
    QuizCategory(name: 'Music', icon: Icons.music_note, color: Colors.purple),
    QuizCategory(name: 'Geography', icon: Icons.public, color: Colors.teal),
  ];

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  /// Simulates fetching user data from a backend service like Firebase.
  Future<UserData> _fetchUserData() async {
    // In a real app, you would use your DatabaseService to fetch this from Firestore.
    // We are using a delay to simulate a network request.
    await Future.delayed(const Duration(milliseconds: 800));
    final currentUser = FirebaseAuth.instance.currentUser;

    // TODO: Replace with actual data from your database.
    return UserData(
      displayName: currentUser?.displayName ?? 'Quizzer',
      rank: 12, // Placeholder data
      score: 5800, // Placeholder data
      coins: 350, // Placeholder data
    );
  }

  void _startQuiz(BuildContext context, QuizCategory category) {
    // TODO: Implement navigation to the quiz screen for the selected category.
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(category: category)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting a ${category.name} quiz...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserData>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final userData = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userData.displayName}!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _UserStatsCard(userData: userData),
                const SizedBox(height: 24),
                Text(
                  'Choose a category to begin',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(context, category);
                  },
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No user data found.'));
        }
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, QuizCategory category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _startQuiz(context, category),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 40, color: category.color),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A card that displays user's rank, score, and coins, as per the proposal.
class _UserStatsCard extends StatelessWidget {
  final UserData userData;

  const _UserStatsCard({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(
                context, Icons.leaderboard, '${userData.rank}', 'Rank'),
            _buildStatColumn(context, Icons.star, '${userData.score}', 'Score'),
            _buildStatColumn(
                context, Icons.monetization_on, '${userData.coins}', 'Coins'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// --- Placeholder Widget for Scores Screen ---
class _ScoresPage extends StatelessWidget {
  const _ScoresPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'My Scores Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// --- Placeholder Widget for Leaderboard Screen ---
class _LeaderboardPage extends StatelessWidget {
  const _LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Leaderboard Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
