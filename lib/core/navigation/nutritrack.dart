import 'package:flutter/material.dart';
import 'package:nutritrack/features/assessment/presentation/pages/assessment.dart';

class NutritrackApp extends StatefulWidget {
  const NutritrackApp({super.key});

  @override
  State<NutritrackApp> createState() => _NutritrackAppState();
}

class _NutritrackAppState extends State<NutritrackApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Placeholder(), 
    const AssessmentPage(),    
    const Placeholder(), 
  ];


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Assessment'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Nutritrack'),
    );
  }
}


