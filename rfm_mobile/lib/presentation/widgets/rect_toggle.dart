import 'package:flutter/material.dart';

class RectToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RectToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 30 : 2,
              top: 2,
              bottom: 2,
              child: Container(
                width: 26,
                decoration: BoxDecoration(
                  color: value 
                      ? Theme.of(context).colorScheme.primaryContainer 
                      : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  boxShadow: value ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      blurRadius: 8,
                    )
                  ] : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
