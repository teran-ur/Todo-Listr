import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../groups/data/repositories/task_group_repository_impl.dart';
import '../../../groups/domain/entities/task_group.dart';
import '../../../groups/domain/usecases/create_group.dart';
import '../../../groups/domain/usecases/delete_group.dart';
import '../../../groups/domain/usecases/reorder_groups.dart';
import '../../../groups/domain/usecases/update_group.dart';
import '../../../groups/domain/usecases/watch_groups.dart';
import '../../../groups/presentation/bloc/groups_bloc.dart';
import '../../../groups/presentation/bloc/groups_event.dart';
import '../../../groups/presentation/bloc/groups_state.dart';
import '../../../groups/presentation/widgets/group_chip_bar.dart';
import '../../../groups/presentation/widgets/group_customization_dialog.dart';
import '../../../groups/presentation/widgets/group_form_dialog.dart';
import '../../../groups/presentation/widgets/group_management_dialog.dart';
import '../../../groups/presentation/widgets/group_progress_header.dart';
import '../../../settings/presentation/widgets/global_settings_dialog.dart';
import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/widgets/sync_status_badge.dart';
import '../../../tasks/data/repositories/task_repository_impl.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/usecases/create_task.dart';
import '../../../tasks/domain/usecases/delete_task.dart';
import '../../../tasks/domain/usecases/toggle_task_completion.dart';
import '../../../tasks/domain/usecases/update_task.dart';
import '../../../tasks/domain/usecases/watch_tasks.dart';
import '../../../tasks/presentation/bloc/tasks_bloc.dart';
import '../../../tasks/presentation/bloc/tasks_event.dart';
import '../../../tasks/presentation/bloc/tasks_state.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/widgets/task_filter_bar.dart';
import '../../../tasks/presentation/widgets/task_form_dialog.dart';
import '../../../tasks/presentation/widgets/task_search_bar.dart';
import '../../../tasks/presentation/widgets/task_sort_menu.dart';
import '../widgets/adaptive_navigation_shell.dart';
import '../widgets/dashboard_group_summaries.dart';
import '../widgets/dashboard_metrics_overview.dart';
import '../widgets/empty_state_widget.dart';
import '../../../../services/local_storage/local_group_service.dart';
import '../../../../services/local_storage/local_settings_service.dart';
import '../../../../services/local_storage/local_task_service.dart';
import '../../../../services/local_storage/sync_queue_service.dart';
import '../../../../services/network/connectivity_service.dart';
import '../../../../services/remote_storage/firestore_group_service.dart';
import '../../../../services/remote_storage/firestore_settings_service.dart';
import '../../../../services/remote_storage/firestore_task_service.dart';
import '../../../../services/sync/sync_service_impl.dart';

class HomeScreen extends StatelessWidget {
  final UserEntity user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final syncQueueService = SyncQueueService();
    final connectivityService = ConnectivityService();

    final localTaskService = LocalTaskService(syncQueueService: syncQueueService);
    final remoteTaskService = FirestoreTaskService();
    final taskRepository = TaskRepositoryImpl(
      localTaskService: localTaskService,
      remoteTaskService: remoteTaskService,
    );

    final localGroupService = LocalGroupService(syncQueueService: syncQueueService);
    final remoteGroupService = FirestoreGroupService();
    final groupRepository = TaskGroupRepositoryImpl(
      localGroupService: localGroupService,
      remoteGroupService: remoteGroupService,
      localTaskService: localTaskService,
      remoteTaskService: remoteTaskService,
    );

    final localSettingsService = LocalSettingsService(syncQueueService: syncQueueService);
    final remoteSettingsService = FirestoreSettingsService();

    final syncService = SyncServiceImpl(
      connectivityService: connectivityService,
      syncQueueService: syncQueueService,
      remoteTaskService: remoteTaskService,
      remoteGroupService: remoteGroupService,
      remoteSettingsService: remoteSettingsService,
      localTaskService: localTaskService,
      localGroupService: localGroupService,
      localSettingsService: localSettingsService,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<SyncBloc>(
          create: (context) => SyncBloc(syncService: syncService)
            ..add(StartAutoSyncRequested(user.uid)),
        ),
        BlocProvider<GroupsBloc>(
          create: (context) => GroupsBloc(
            watchGroups: WatchGroups(groupRepository),
            createGroup: CreateGroupUseCase(groupRepository),
            updateGroup: UpdateGroupUseCase(groupRepository),
            deleteGroup: DeleteGroupUseCase(groupRepository),
            reorderGroups: ReorderGroupsUseCase(groupRepository),
          )..add(LoadGroupsRequested(user.uid)),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(
            watchTasks: WatchTasks(taskRepository),
            createTask: CreateTaskUseCase(taskRepository),
            updateTask: UpdateTaskUseCase(taskRepository),
            deleteTask: DeleteTaskUseCase(taskRepository),
            toggleTaskCompletion: ToggleTaskCompletionUseCase(taskRepository),
          )..add(LoadTasksRequested(user.uid)),
        ),
      ],
      child: _HomeScreenContent(user: user),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final UserEntity user;

  const _HomeScreenContent({required this.user});

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  DashboardDestination _currentDestination = DashboardDestination.allTasks;

  void _onDestinationSelected(DashboardDestination destination) {
    setState(() => _currentDestination = destination);

    final tasksBloc = context.read<TasksBloc>();
    final groupsBloc = context.read<GroupsBloc>();

    switch (destination) {
      case DashboardDestination.today:
        tasksBloc.add(const FilterCategoryChanged(TaskFilterCategory.today));
        groupsBloc.add(const SelectGroupEvent(null));
        break;
      case DashboardDestination.upcoming:
        tasksBloc.add(const FilterCategoryChanged(TaskFilterCategory.upcoming));
        groupsBloc.add(const SelectGroupEvent(null));
        break;
      case DashboardDestination.completed:
        tasksBloc.add(const FilterCategoryChanged(TaskFilterCategory.completed));
        groupsBloc.add(const SelectGroupEvent(null));
        break;
      case DashboardDestination.allTasks:
      case DashboardDestination.groups:
        tasksBloc.add(const FilterCategoryChanged(TaskFilterCategory.all));
        break;
      case DashboardDestination.settings:
        _openGlobalSettings(context);
        break;
    }
  }

  void _openTaskForm(BuildContext context, [TaskEntity? task]) {
    final tasksBloc = context.read<TasksBloc>();
    final groupsState = context.read<GroupsBloc>().state;
    final availableGroups =
        groupsState is GroupsLoaded ? groupsState.allGroups : <TaskGroupEntity>[];

    showDialog(
      context: context,
      builder: (dialogContext) => TaskFormDialog(
        userId: widget.user.uid,
        initialTask: task,
        availableGroups: availableGroups,
        onSubmit: (newOrUpdatedTask) {
          if (task == null) {
            tasksBloc.add(AddTaskRequested(newOrUpdatedTask));
          } else {
            tasksBloc.add(UpdateTaskRequested(newOrUpdatedTask));
          }
        },
      ),
    );
  }

  void _openGroupForm(BuildContext context, [TaskGroupEntity? group]) {
    final groupsBloc = context.read<GroupsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => GroupFormDialog(
        userId: widget.user.uid,
        initialGroup: group,
        onSubmit: (newOrUpdatedGroup) {
          if (group == null) {
            groupsBloc.add(AddGroupRequested(newOrUpdatedGroup));
          } else {
            groupsBloc.add(UpdateGroupRequested(newOrUpdatedGroup));
          }
        },
      ),
    );
  }

  void _openGroupCustomization(BuildContext context, TaskGroupEntity group) {
    final groupsBloc = context.read<GroupsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => GroupCustomizationDialog(
        group: group,
        onSave: (updatedGroup) {
          groupsBloc.add(UpdateGroupRequested(updatedGroup));
        },
      ),
    );
  }

  void _openGroupManagement(BuildContext context, List<TaskGroupEntity> groups) {
    final groupsBloc = context.read<GroupsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => GroupManagementDialog(
        groups: groups,
        onEditGroup: (group) => _openGroupCustomization(context, group),
        onDeleteGroup: (groupId) {
          groupsBloc.add(DeleteGroupRequested(userId: widget.user.uid, groupId: groupId));
        },
        onReorderGroups: (reorderedList) {
          groupsBloc.add(ReorderGroupsRequested(userId: widget.user.uid, groups: reorderedList));
        },
      ),
    );
  }

  void _openGlobalSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => GlobalSettingsDialog(userId: widget.user.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationShell(
      currentDestination: _currentDestination,
      onDestinationSelected: _onDestinationSelected,
      child: Scaffold(
        key: const Key('home_screen'),
        appBar: AppBar(
          title: Text(_destinationTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SyncStatusBadge(userId: widget.user.uid),
            ),
            IconButton(
              key: const Key('global_settings_button'),
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Appearance Settings',
              onPressed: () => _openGlobalSettings(context),
            ),
            BlocBuilder<TasksBloc, TasksState>(
              builder: (context, state) {
                final activeSort =
                    state is TasksLoaded ? state.activeSort : TaskSortOption.createdAt;
                return TaskSortMenu(
                  activeSort: activeSort,
                  onSortSelected: (sortOption) {
                    context.read<TasksBloc>().add(SortOptionChanged(sortOption));
                  },
                );
              },
            ),
            IconButton(
              key: const Key('home_logout_button'),
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Dynamic Group Selector Header
            BlocConsumer<GroupsBloc, GroupsState>(
              listener: (context, state) {
                if (state is GroupsLoaded) {
                  context
                      .read<TasksBloc>()
                      .add(SelectedGroupChanged(state.selectedGroupId));
                }
              },
              builder: (context, state) {
                final groups = state is GroupsLoaded ? state.allGroups : <TaskGroupEntity>[];
                final selectedGroupId = state is GroupsLoaded ? state.selectedGroupId : null;

                return Column(
                  children: [
                    GroupChipBar(
                      groups: groups,
                      selectedGroupId: selectedGroupId,
                      onGroupSelected: (groupId) {
                        context.read<GroupsBloc>().add(SelectGroupEvent(groupId));
                        context.read<TasksBloc>().add(SelectedGroupChanged(groupId));
                      },
                      onAddGroup: () => _openGroupForm(context),
                      onManageGroups: () => _openGroupManagement(context, groups),
                    ),
                    if (_currentDestination == DashboardDestination.groups)
                      DashboardGroupSummaries(
                        groups: groups,
                        selectedGroupId: selectedGroupId,
                        onSelectGroup: (groupId) {
                          context.read<GroupsBloc>().add(SelectGroupEvent(groupId));
                        },
                      ),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is TasksLoading || state is TasksInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TasksLoaded) {
                    final groupsState = context.read<GroupsBloc>().state;
                    TaskGroupEntity? activeGroup;
                    if (groupsState is GroupsLoaded && state.selectedGroupId != null) {
                      activeGroup = groupsState.allGroups.firstWhere(
                        (g) => g.id == state.selectedGroupId,
                        orElse: () => groupsState.allGroups.first,
                      );
                    }

                    return Column(
                      children: [
                        // Metrics Overview Bar
                        DashboardMetricsOverview(
                          todayCount: state.todayCount,
                          overdueCount: state.overdueCount,
                          totalCount: state.totalCount,
                          completedCount: state.completedCount,
                          onSelectCategory: (category) {
                            context
                                .read<TasksBloc>()
                                .add(FilterCategoryChanged(category));
                          },
                        ),

                        // Group Progress Header
                        if (activeGroup != null)
                          GroupProgressHeader(
                            group: activeGroup,
                            totalTasks: state.totalCount,
                            completedTasks: state.completedCount,
                          ),
                        TaskSearchBar(
                          query: state.searchQuery,
                          onChanged: (query) {
                            context.read<TasksBloc>().add(SearchQueryChanged(query));
                          },
                        ),
                        TaskFilterBar(
                          activeFilter: state.activeFilter,
                          totalCount: state.totalCount,
                          todayCount: state.todayCount,
                          upcomingCount: state.upcomingCount,
                          overdueCount: state.overdueCount,
                          completedCount: state.completedCount,
                          onFilterSelected: (category) {
                            context
                                .read<TasksBloc>()
                                .add(FilterCategoryChanged(category));
                          },
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: state.filteredTasks.isEmpty
                              ? _buildEmptyState(context, state)
                              : ListView.builder(
                                  key: const Key('tasks_list_view'),
                                  itemCount: state.filteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = state.filteredTasks[index];
                                    return TaskCard(
                                      task: task,
                                      onToggleCompletion: (val) {
                                        context.read<TasksBloc>().add(
                                              ToggleTaskCompletionRequested(
                                                userId: widget.user.uid,
                                                taskId: task.id,
                                                isCompleted: val ?? false,
                                              ),
                                            );
                                      },
                                      onEdit: () => _openTaskForm(context, task),
                                      onDelete: () {
                                        context.read<TasksBloc>().add(
                                              DeleteTaskRequested(
                                                userId: widget.user.uid,
                                                taskId: task.id,
                                              ),
                                            );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }

                  if (state is TasksError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('add_task_fab'),
          icon: const Icon(Icons.add),
          label: const Text('New Task'),
          onPressed: () => _openTaskForm(context),
        ),
      ),
    );
  }

  String get _destinationTitle {
    switch (_currentDestination) {
      case DashboardDestination.today:
        return 'Tasks Due Today';
      case DashboardDestination.upcoming:
        return 'Upcoming Tasks';
      case DashboardDestination.completed:
        return 'Completed Tasks';
      case DashboardDestination.groups:
        return 'Task Groups Dashboard';
      case DashboardDestination.settings:
        return 'Global Settings';
      case DashboardDestination.allTasks:
        return 'All Productivity Tasks';
    }
  }

  Widget _buildEmptyState(BuildContext context, TasksLoaded state) {
    if (state.totalCount == 0 && state.searchQuery.isEmpty) {
      return EmptyStateWidget(
        title: 'Welcome to Task Manager!',
        message: 'Organize your day, set priorities, and sync across all devices.',
        icon: Icons.task_alt,
        actionLabel: 'Create First Task',
        onActionPressed: () => _openTaskForm(context),
      );
    }

    String title = 'No tasks found';
    String message = 'Tap "New Task" below to create your first task.';

    if (state.selectedGroupId != null) {
      title = 'No tasks in this group';
      message = 'Create a task or move existing tasks to this group.';
    } else if (state.activeFilter == TaskFilterCategory.today) {
      title = 'No tasks due today';
      message = 'You have no pending tasks scheduled for today.';
    } else if (state.activeFilter == TaskFilterCategory.upcoming) {
      title = 'No upcoming tasks';
      message = 'No future tasks scheduled.';
    } else if (state.activeFilter == TaskFilterCategory.overdue) {
      title = 'No overdue tasks!';
      message = 'All your past tasks are completed or up to date.';
    } else if (state.activeFilter == TaskFilterCategory.completed) {
      title = 'No completed tasks yet';
      message = 'Tasks you complete will appear here.';
    } else if (state.searchQuery.isNotEmpty) {
      title = 'No matching tasks';
      message = 'No tasks matched "${state.searchQuery}".';
    }

    return EmptyStateWidget(
      title: title,
      message: message,
      icon: Icons.checklist_rtl,
    );
  }
}
