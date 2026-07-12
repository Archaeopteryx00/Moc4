import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search cafés, study spots, hidden food...',
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.capsule),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          onChanged: (val) {
            widget.onChanged(val);
            // Trigger rebuild for clearing button appearance
            setState(() {});
          },
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurface,
              ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppTheme.secondary,
              size: 20,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                      setState(() {});
                    },
                  )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.capsule),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.capsule),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.capsule),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ),
    );
  }
}
