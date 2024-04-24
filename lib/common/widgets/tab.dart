import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';

/// Renders a TabText
class ContrastTab extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Key of the tab which is used to trigger the a filter
  final String tabKey;
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
    required this.tabKey,
    required this.text,
    required this.onClick,
    required this.isSelected,
    this.disabled = false
  }) : super(key: widgetKey);
      

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHovering = ref.watch(hoverProvider(widgetKey));
    bool shouldAnimate = false;
    useValueChanged(ref.watch(boardHeaderTabProvider), (_, __) async {
      if (ref.read(boardHeaderTabProvider) == tabKey) {
        shouldAnimate = true;
      }
    });
    useValueChanged(ref.watch(boardFooterTabProvider), (_, __) async {
      if (ref.read(boardFooterTabProvider) == tabKey) {
        shouldAnimate = true;
      }
    });

    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () => !disabled ? onClick(tabKey) : null,
          hoverColor: isHovering ? Colors.black : Colors.white,
          onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
          child: Container(
            color: isSelected ? Colors.black : Colors.transparent,
            child: StyledText(
                text: text,
                color: isSelected ? Colors.white : !isHovering ? Colors.black : Colors.white,
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
                .shake(frequency: 2)
                .animate(trigger: shouldAnimate, playIf: () => shouldAnimate)
                .resetAll(),
          )
      ),
    );
  }
}
