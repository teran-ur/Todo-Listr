import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/home/presentation/widgets/adaptive_navigation_shell.dart';

void main() {
  testWidgets('AdaptiveNavigationShell renders NavigationRail on Desktop (>= 600px)',
      (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationShell(
          currentDestination: DashboardDestination.allTasks,
          onDestinationSelected: (_) {},
          child: const Text('Content'),
        ),
      ),
    );

    expect(find.byKey(const Key('desktop_navigation_rail')), findsOneWidget);
    expect(find.byKey(const Key('mobile_navigation_bar')), findsNothing);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('AdaptiveNavigationShell renders NavigationBar on Mobile (< 600px)',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationShell(
          currentDestination: DashboardDestination.allTasks,
          onDestinationSelected: (_) {},
          child: const Text('Content'),
        ),
      ),
    );

    expect(find.byKey(const Key('mobile_navigation_bar')), findsOneWidget);
    expect(find.byKey(const Key('desktop_navigation_rail')), findsNothing);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
