import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Renders a TabText
class ContrastTab extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Text as a string
  final String text;
  /// What happens when the user clicks the tab
  final Function(String) onClick;
  /// Is the tab selected or not
  final bool isSelected;
  /// Is the tab disabled or not
  final bool disabled;

  const ContrastTab({
    required this.widgetKey,
    required this.text,
    required this.onClick,
    required this.isSelected,
    this.disabled = false
  }) : super(key: widgetKey);
      

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHovering = ref.watch(hoverProvider(widgetKey));

    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () => !disabled ? onClick(text) : null,
          hoverColor: isHovering ? Colors.black : Colors.white,
          onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
          child: StyledText(
              text: text,
              color: !isHovering ? Colors.black : Colors.white,
              weight: isSelected ? FontWeight.bold : FontWeight.normal,
              useShadow: isSelected ? true : false,
              shadow: isSelected
                  ? <Shadow>[
                      Shadow(
                        offset: const Offset(0, 0),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ]
                  : null
          )
      ),
    );
  }
}
