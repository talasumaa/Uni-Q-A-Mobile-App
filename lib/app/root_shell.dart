import 'package:flutter/material.dart';
import 'app_state.dart';
import '../screens/feed_screen.dart';
import '../screens/ask_question_screen.dart';
import '../screens/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _goToAsk() => setState(() => _index = 1);

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    final pages = [
      FeedScreen(onTapAsk: _goToAsk),
      const AskQuestionScreen(),
      ProfileScreen(
        onResetDemo: () => state.resetDemo(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: state.loaded
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: pages[_index],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.question_answer_outlined),
            label: "Feed",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: "Ask",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
