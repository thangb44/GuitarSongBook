import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    ),
  );
}
