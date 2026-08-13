import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../domain/entities/user_settings.dart';

class GlobalSettingsDialog extends StatelessWidget {
  final String userId;

  const GlobalSettingsDialog({
    super.key,
    required this.userId,
  });

  static const List<String> _accentColors = [
    '#6750A4', // Purple
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#00BCD4', // Cyan
    '#9C27B0', // Deep Purple
    '#795548', // Brown
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('global_settings_dialog'),
      title: const Text('Global Appearance Settings'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              final settings = state.settings;
              final bloc = context.read<SettingsBloc>();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Theme Mode Selector
                  Text('Theme Mode', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<AppThemeMode>(
                    key: const Key('theme_mode_segmented_button'),
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (set) {
                      bloc.add(ChangeThemeModeRequested(
                        userId: userId,
                        themeMode: set.first,
                      ));
                    },
                  ),
                  const SizedBox(height: 20),

                  // User Accent Color Palette
                  Text('Global Accent Color', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _accentColors.map((hex) {
                      final color = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
                      final isSelected = settings.accentColorHex == hex;

                      return GestureDetector(
                        onTap: () {
                          bloc.add(ChangeAccentColorRequested(
                            userId: userId,
                            accentColorHex: hex,
                          ));
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 20, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // UI Spacing & Density Preference
                  Text('UI Spacing & Density', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<UiDensity>(
                    key: const Key('ui_density_segmented_button'),
                    segments: const [
                      ButtonSegment(
                        value: UiDensity.compact,
                        label: Text('Compact'),
                      ),
                      ButtonSegment(
                        value: UiDensity.comfortable,
                        label: Text('Standard'),
                      ),
                      ButtonSegment(
                        value: UiDensity.spacious,
                        label: Text('Spacious'),
                      ),
                    ],
                    selected: {settings.uiDensity},
                    onSelectionChanged: (set) {
                      bloc.add(ChangeUiDensityRequested(
                        userId: userId,
                        uiDensity: set.first,
                      ));
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
