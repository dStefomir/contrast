import 'package:contrast/common/extentions/zoom.dart';
import 'package:contrast/common/widgets/hover_provider.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/common/widgets/tooltip.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';

class RedirectButton extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Constraints of the page
  final BoxConstraints constraints;
  /// What happens when the user clicks the button
  final Function onRedirect;
  /// Height of the button
  final double? height;

  const RedirectButton({
    required this.widgetKey,
    required this.constraints,
    required this.onRedirect,
    this.height
  }) : super(key: widgetKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool doesHover = ref.watch(hoverProvider(widgetKey));

    return StyledTooltip(
      text: 'New tab',
      pointingPosition: AxisDirection.down,
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
              onTap: () => onRedirect(),
              child: Container(
                color: doesHover ? Colors.white : Colors.black,
                child: IconRenderer(
                    asset: 'arrow_outward.svg',
                    color: doesHover ? Colors.black : Colors.white,
                    height: height ?? constraints.maxHeight / 10),
              ).translateOnPhotoHover
          )
      ),
    );
  }
}

/// Renders a styled button
class StyledButton extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// What happens when you click the button
  final Function onClick;
  /// Icon path
  final String iconAsset;
  /// Height of the icon
  final double iconHeight;
  /// Should the button have shadow
  final bool shadow;
  /// Should the button contain only icon
  final bool onlyIcon;
  /// Color of the icon
  final Color? iconColor;
  /// Color of the background
  final Color backgroundColor;

  const StyledButton({
    required this.widgetKey,
    required this.onClick,
    required this.iconAsset,
    this.iconHeight = 50,
    this.shadow = true,
    this.onlyIcon = false,
    this.iconColor,
    this.backgroundColor = Colors.white
  }) : super(key: widgetKey);

  /// Renders the button
  Widget _renderButton(WidgetRef ref) {
    final bool isHovering = ref.watch(hoverProvider(widgetKey));

    return !onlyIcon
        ? IconRenderer(
      asset: iconAsset,
      color: !isHovering ? Colors.black : Colors.white,
      height: iconHeight,
    ).translateOnPhotoHover
        : ColoredBox(
      color: backgroundColor,
      child: IconRenderer(
        asset: iconAsset,
        color: iconColor != null
            ? iconColor!
            : !isHovering
            ? Colors.black
            : Colors.white,
        height: iconHeight,
        fit: BoxFit.fill,
      ).translateOnPhotoHover,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onClick(),
          onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
          child: shadow
              ? ShadowWidget(child: _renderButton(ref))
              : _renderButton(ref),
        ),
      );
}

/// Renders a normal button
class NormalButton extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// What happens when you click the button
  final Function onClick;
  /// Button text
  final String text;

  const NormalButton({required this.widgetKey, required this.onClick, required this.text}) : super(key: widgetKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHovering = ref.watch(hoverProvider(widgetKey));

    return TextButton(
      onHover: (hover) =>
          ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll<Color>(
              isHovering ? Colors.black45 : Colors.black
          )
      ),
      onPressed: () => onClick(),
      child: StyledText(
        text: text,
        color: Colors.white,
        useShadow: false,
        fontSize: 10,
      ),
    );
  }
}

/// Renders a menu icon button
class MenuButton extends HookConsumerWidget {
  /// Widget key
  final Key widgetKey;
  /// Asset icon
  final String iconPath;
  /// Is the widget disabled or not
  final bool disabled;
  /// Is the widget selected
  final bool selected;
  /// Icon size
  final double size;
  /// Tooltip text
  final String tooltip;
  /// What happens when the widget is clicked
  final void Function() onClick;

  const MenuButton({
    required this.widgetKey,
    required this.iconPath,
    required this.disabled,
    required this.selected,
    required this.size,
    required this.tooltip,
    required this.onClick,
  }) : super(key: widgetKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool shouldAnimate = false;
    useValueChanged(ref.watch(boardHeaderTabProvider), (_, __) async {
      if (ref.read(boardHeaderTabProvider) == iconPath.substring(0, iconPath.indexOf('.')) ||
          (ref.read(boardHeaderTabProvider) == 'other' && iconPath.substring(0, iconPath.indexOf('.')) == 'dog')) {
        shouldAnimate = true;
      }
    });

    return StyledTooltip(
      text: tooltip,
      pointingPosition: AxisDirection.left,
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
          ),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => onClick(),
                  onHover: (hover) => ref.read(hoverProvider(widgetKey).notifier).onHover(hover),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: IconRenderer(
                      asset: iconPath,
                      color: selected ? Colors.white : Colors.black,
                      shouldShimmer: selected,
                    ).rotate(12, from: 0).animate(trigger: shouldAnimate, playIf: () => shouldAnimate, duration: const Duration(milliseconds: 500)).resetAll()
                  )
              )
          )
      ),
    );
  }
}

/// Renders a rounded button widget
class DefaultButton extends StatelessWidget {
  /// What happens when the widget is clicked
  final Function() onClick;
  /// Color of the button
  final Color color;
  /// Color of the button border
  final Color borderColor;
  /// Icon asset
  final String icon;
  /// Shape of the button
  final BoxShape shape;
  /// Width of the border
  final double borderWidth;
  /// Icon height
  final double height;
  /// Padding of the button
  final double padding;
  /// Tooltip text
  final String? tooltip;
  /// Svg color
  final Color? svgColor;
  /// Fit for the svg icon
  final BoxFit iconFit;

  const DefaultButton({
    required this.onClick,
    required this.borderColor,
    required this.icon,
    this.color = Colors.white,
    this.tooltip,
    this.shape = BoxShape.circle,
    this.borderWidth = 1,
    this.height = 35,
    this.padding = 10,
    this.svgColor,
    this.iconFit = BoxFit.scaleDown,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final button = Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
            color: color,
            shape: shape,
            border: borderWidth == 0 ? null : Border.all(color: borderColor, width: borderWidth)
        ),
        child: InkWell(
          onTap: onClick,
          child: IconRenderer(
              asset: icon,
              fit: iconFit,
              color: svgColor,
              height: height,
          ),
        ),
      ),
    ).translateOnVideoHover;

    return tooltip != null ? StyledTooltip(text: tooltip!, child: button) : button;
  }
}
