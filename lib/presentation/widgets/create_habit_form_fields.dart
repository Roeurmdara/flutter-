import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/category_providers.dart';

// ── Section label ───────────────────────────────────────────────────────────
Widget buildLabel(String text, bool isDark) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );

// ── Input decoration ────────────────────────────────────────────────────────
InputDecoration buildInputDecoration(bool isDark,
    {String hint = '', Widget? suffix}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: isDark ? Colors.white12 : Colors.black12,
      width: 1,
    ),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: isDark ? Colors.white30 : Colors.black26,
      fontSize: 14,
    ),
    filled: true,
    fillColor: isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppColors.primaryPurple.withValues(alpha: 0.6),
        width: 1,
      ),
    ),
    suffixIcon: suffix,
  );
}

// ── Category dropdown ───────────────────────────────────────────────────────
class CategoryDropdown extends ConsumerWidget {
  final bool isDark;
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.isDark,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      ),
      error: (_, __) => const Text(
        'Failed to load categories',
        style: TextStyle(color: AppColors.error, fontSize: 13),
      ),
      data: (categories) {
        if (selectedCategoryId != null) {
          try {
            categories.firstWhere((cat) => cat.id == selectedCategoryId);
          } catch (_) {
            // Category not found, keep as null
          }
        }

        Color parseColor(String hex) {
          try {
            return Color(
              int.parse(hex.replaceFirst('#', ''), radix: 16) + 0xFF000000,
            );
          } catch (_) {
            return AppColors.primaryPurple;
          }
        }

        return DropdownButtonFormField<String>(
          initialValue: selectedCategoryId,
          isExpanded: true,
          itemHeight: 64,
          icon: Icon(
            Icons.expand_more,
            size: 18,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primaryPurple.withValues(alpha: 0.6),
              ),
            ),
          ),
          dropdownColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
          hint: Text(
            'Select category',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          selectedItemBuilder: (context) => categories.map((cat) {
            final color = parseColor(cat.colorHex);
            return Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat.icon,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            );
          }).toList(),
          items: categories.map((cat) {
            final color = parseColor(cat.colorHex);
            return DropdownMenuItem<String>(
              value: cat.id,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.15),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (cat.description.isNotEmpty)
                          Text(
                            cat.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white30 : Colors.black38,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}

// ── Frequency dropdown ──────────────────────────────────────────────────────
class FrequencyDropdown extends StatelessWidget {
  final bool isDark;
  final String selectedFrequency;
  final List<String> frequencies;
  final ValueChanged<String> onChanged;

  const FrequencyDropdown({
    super.key,
    required this.isDark,
    required this.selectedFrequency,
    required this.frequencies,
    required this.onChanged,
  });

  String _getFrequencyEmoji(String freq) {
    switch (freq.toLowerCase()) {
      case 'daily':
        return '📅';
      case 'weekly':
        return '📆';
      case 'monthly':
        return '📊';
      default:
        return '⏰';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return GestureDetector(
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _getFrequencyEmoji(selectedFrequency),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedFrequency.capitalize(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
        );
      },
      menuChildren: frequencies.map((freq) {
        return MenuItemButton(
          style: MenuItemButton.styleFrom(
            minimumSize: const Size(160, 48),
          ),
          onPressed: () => onChanged(freq),
          child: Row(
            children: [
              Text(_getFrequencyEmoji(freq),
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                freq.capitalize(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Date field ──────────────────────────────────────────────────────────────
class HabitDateField extends StatelessWidget {
  final bool isDark;
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;
  final bool isOptional;

  const HabitDateField({
    super.key,
    required this.isDark,
    required this.label,
    required this.date,
    required this.onChanged,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label, isDark),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.primaryPurple.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date!.day}/${date!.month}/${date!.year}'
                        : 'Select',
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.white30 : Colors.black26),
                    ),
                  ),
                ),
                if (isOptional && date != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Icon(Icons.close,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.black38),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Extensions ───────────────────────────────────────────────────────────────
extension StringCapitalize on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}

DateTime dateOnly(DateTime date) {
  final d = date.toLocal();
  return DateTime(d.year, d.month, d.day);
}
