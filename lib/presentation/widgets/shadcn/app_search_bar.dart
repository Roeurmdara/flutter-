import 'package:flutter/material.dart';
import 'app_input.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search...',
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppInput(
      controller: widget.controller,
      placeholder: widget.hintText,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      prefix: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(
          Icons.search_rounded,
          size: 18,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
      suffix: widget.controller.text.isNotEmpty
          ? GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onClear?.call();
                widget.onChanged?.call('');
              },
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            )
          : null,
    );
  }
}
