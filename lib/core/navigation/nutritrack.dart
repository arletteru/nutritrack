import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NutritrackApp extends HookConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NutritrackApp({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

      useEffect(() {
        debugPrint(
          'Current tab: ${navigationShell.currentIndex}',
        );
        return null;
      }, [navigationShell.currentIndex]);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Nutritrack'),
        ),

        body: navigationShell,

        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,

          currentIndex: navigationShell.currentIndex,

          onTap: (index) {
            navigationShell.goBranch(index);
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), 
              label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Assessment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    }

    PreferredSizeWidget buildAppBar() {
      return AppBar(title: const Text('Nutritrack'));
    }
}
