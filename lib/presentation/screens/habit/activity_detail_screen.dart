import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/providers/activity_provider.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final Activity activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  ConsumerState<ActivityDetailScreen> createState() =>
      _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  late TextEditingController _typeController;
  late TextEditingController _valueController;
  late TextEditingController _unitController;
  late TextEditingController _noteController;

  bool _isCompleted = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.activity.activityType);
    _valueController = TextEditingController(text: widget.activity.value ?? '');
    _unitController = TextEditingController(text: widget.activity.unit ?? '');
    _noteController = TextEditingController(text: widget.activity.note ?? '');
    _isCompleted = widget.activity.isCompleted;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(activitiesNotifierProvider.notifier).updateActivity(
            habitId: widget.activity.habitId,
            activityId: widget.activity.id,
            activityType: _typeController.text.trim(),
            value: _valueController.text.trim(),
            unit: _unitController.text.trim(),
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Activity saved'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Save failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(activitiesNotifierProvider.notifier)
          .deleteActivity(widget.activity.habitId, widget.activity.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Activity deleted'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Delete failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleComplete() async {
    setState(() => _loading = true);
    try {
      if (_isCompleted) {
        await ref
            .read(activitiesNotifierProvider.notifier)
            .unmarkActivityComplete(
                widget.activity.habitId, widget.activity.id);
      } else {
        await ref
            .read(activitiesNotifierProvider.notifier)
            .markActivityComplete(widget.activity.habitId, widget.activity.id);
      }
      setState(() => _isCompleted = !_isCompleted);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Operation failed: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Type',
                style: AppTypography.bodySmall(
                    isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            TextField(
                controller: _typeController,
                decoration:
                    const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Text('Value',
                style: AppTypography.bodySmall(
                    isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Text('Unit',
                style: AppTypography.bodySmall(
                    isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            TextField(
                controller: _unitController,
                decoration:
                    const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Text('Settlement Date',
                style: AppTypography.bodySmall(
                    isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder)),
              child: Text(
                  '${widget.activity.settlementPeriodDate.day}/${widget.activity.settlementPeriodDate.month}/${widget.activity.settlementPeriodDate.year}'),
            ),
            const SizedBox(height: 12),
            Text('Note',
                style: AppTypography.bodySmall(
                    isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            TextField(
                controller: _noteController,
                maxLines: 3,
                decoration:
                    const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _loading ? null : _delete,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                    value: _isCompleted, onChanged: (_) => _toggleComplete()),
                const SizedBox(width: 8),
                Text(_isCompleted ? 'Completed' : 'Mark as complete'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
