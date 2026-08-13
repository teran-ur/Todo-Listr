import 'package:flutter/material.dart';

enum DashboardDestination { today, allTasks, upcoming, groups, completed, settings }

class AdaptiveNavigationShell extends StatelessWidget {
  final DashboardDestination currentDestination;
  final ValueChanged<DashboardDestination> onDestinationSelected;
  final Widget child;

  const AdaptiveNavigationShell({
    super.key,
    required this.currentDestination,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        if (isDesktop) {
          // Desktop Layout: Sidebar Navigation Rail + Content
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  key: const Key('desktop_navigation_rail'),
                  selectedIndex: currentDestination.index,
                  onDestinationSelected: (index) {
                    onDestinationSelected(DashboardDestination.values[index]);
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Icon(Icons.task_alt, size: 36, color: Color(0xFF6750A4)),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.today_outlined),
                      selectedIcon: Icon(Icons.today),
                      label: Text('Today'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.check_circle_outline),
                      selectedIcon: Icon(Icons.check_circle),
                      label: Text('All Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.event_outlined),
                      selectedIcon: Icon(Icons.event),
                      label: Text('Upcoming'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_open_outlined),
                      selectedIcon: Icon(Icons.folder),
                      label: Text('Groups'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.task_outlined),
                      selectedIcon: Icon(Icons.task),
                      label: Text('Completed'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        // Mobile Layout: Bottom Navigation Bar + Touch Content
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            key: const Key('mobile_navigation_bar'),
            selectedIndex: currentDestination.index,
            onDestinationSelected: (index) {
              onDestinationSelected(DashboardDestination.values[index]);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle),
                label: 'All Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event),
                label: 'Upcoming',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_open_outlined),
                selectedIcon: Icon(Icons.folder),
                label: 'Groups',
              ),
              NavigationDestination(
                icon: Icon(Icons.task_outlined),
                selectedIcon: Icon(Icons.task),
                label: 'Completed',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
