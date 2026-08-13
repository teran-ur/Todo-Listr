import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/home/presentation/widgets/dashboard_metrics_overview.dart';

void main() {
  testWidgets('DashboardMetricsOverview displays metric cards with counts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 800,
              child: DashboardMetricsOverview(
                todayCount: 3,
                overdueCount: 1,
                totalCount: 10,
                completedCount: 4,
                onSelectCategory: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('metric_today')), findsOneWidget);
    expect(find.text('Due Today'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    expect(find.byKey(const Key('metric_overdue')), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    expect(find.byKey(const Key('metric_remaining')), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);

    expect(find.byKey(const Key('metric_completed')), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });
}
