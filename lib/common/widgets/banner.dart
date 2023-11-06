import 'dart:async';

import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gif/flutter_gif.dart';

/// The time for switching to the next banner
const _nextBanner = Duration(milliseconds: 6000);
/// The time for general animation of the banner switching
const _bannerAnimationDuration = Duration(milliseconds: 600);
/// This widget renders a banner photo or video
class BannerWidget extends StatefulHookConsumerWidget {
  /// Banners
  final List<String> banners;
  /// Banner quotes
  final List<String> quotes;

  const BannerWidget({
    super.key,
    required this.banners,
    this.quotes = const []
  });

  @override
  ConsumerState createState() => BannerWidgetState();
}

class BannerWidgetState extends ConsumerState<BannerWidget> with TickerProviderStateMixin {
  /// Page controller for handling the page view
  late PageController _pageController;
  /// Controller for the giff header of the data view
  FlutterGifController? _videoBoardGiffController;
  /// Timer for switching to the next banner
  Timer? _nextBannerTimer;

  @override
  void initState() {
    _pageController = PageController(initialPage: 1);
    _videoBoardGiffController = widget.banners.firstWhere(
            (element) => element.contains('.gif'), orElse: () => '').isNotEmpty
        ? FlutterGifController(vsync: this)
        : null;

    if (widget.banners.length > 1) {
      _pageController.addListener(_onBannerChange);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.banners.length > 1) {
      _pageController.removeListener(_onBannerChange);
    }
    _pageController.dispose();
    super.dispose();
  }

  /// Sets a periodic timer for changing the banners
  Timer _startBannerChangingTimer() => Timer(_nextBanner, () {
    if(_pageController.hasClients) {
      if (_getCurrentPage() == widget.banners.length - 1) {
        _pageController.nextPage(duration: _bannerAnimationDuration, curve: Curves.fastEaseInToSlowEaseOut);
      } else {
        _pageController.animateToPage(_getCurrentPage() + 1, duration: _bannerAnimationDuration, curve: Curves.fastEaseInToSlowEaseOut);
      }
    }
  });

  /// Returns the current displayed page from the page view
  int _getCurrentPage() {
    int currentPage;
    if(_pageController.hasClients) {
      currentPage = _pageController.page?.toInt() ?? 1;
    } else {
      currentPage = 1;
    }

    return currentPage;
  }

  /// What happens when banner is changed
  _onBannerChange() {
    setState(() {
      if (_nextBannerTimer != null) {
        _nextBannerTimer!.cancel();
      }
      _nextBannerTimer = _startBannerChangingTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_videoBoardGiffController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _videoBoardGiffController!.repeat(
          min: 0,
          max: 299,
          period: const Duration(seconds: 10)
      ));
    }

    if (widget.banners.length > 1) {
      _nextBannerTimer ??= _startBannerChangingTimer();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.banners.length > 1 ? widget.banners.length + 2 : widget.banners.length,
          itemBuilder: (context, index) {
            String banner;
            String text;
            if (index == 0) {
              banner = widget.banners.last;
              text = widget.quotes.last;
            } else if (index == widget.banners.length + 1) {
              banner = widget.banners.first;
              text = widget.quotes.first;
            } else {
              banner = widget.banners[index - 1];
              text = widget.quotes[index - 1];
            }

            return Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                banner.contains('.gif') ?
                GifImage(
                  controller: _videoBoardGiffController!,
                  fit: BoxFit.cover,
                  image: AssetImage("assets/$banner",),
                ) :
                IconRenderer(asset: banner, fit: BoxFit.cover),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: StyledText(
                    maxLines: 1,
                    text: text,
                    color: Colors.white,
                    useShadow: true,
                    align: TextAlign.start,
                    letterSpacing: 5,
                    fontSize: !kIsWeb ? 20 : 25,
                    italic: true,
                    clip: true,
                  ),
                )
              ],
            );
          },
          onPageChanged: (index) {
            if (widget.banners.length > 1) {
              if (index == 0) {
                _pageController.jumpToPage(widget.banners.length);
              } else if (index == widget.banners.length + 1) {
                _pageController.jumpToPage(1);
              }
            }
          },
        ),
        if (widget.banners.length > 1) Align(
          alignment: Alignment.topCenter,
          child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _BannerDotIndicator(
                  pageController: _pageController,
                  banners: widget.banners.length,
                  duration: _nextBanner
              )
          ),
        )
      ],
    );
  }
}

/// A banner indicator widget
class _BannerDotIndicator extends StatefulHookConsumerWidget {
  /// Parent page controller for moving to other pages
  final PageController pageController;
  /// Number of banners
  final int banners;
  /// Duration for switching to the next banner
  final Duration duration;

  const _BannerDotIndicator({required this.pageController, required this.banners, required this.duration});

  @override
  ConsumerState createState() => _BannerDotIndicatorState();
}

class _BannerDotIndicatorState extends ConsumerState<_BannerDotIndicator> {

  /// Starting width of the indicator
  late ValueNotifier<double> _selectedIndicatorWidth;
  /// Timer for rendering the indicator
  Timer? _animationRender;

  @override
  void initState() {
    widget.pageController.addListener(_onDotChanged);
    super.initState();
  }

  @override
  void dispose() {
    _animationRender!.cancel();
    widget.pageController.removeListener(_onDotChanged);
    super.dispose();
  }

  /// Sets a periodic timer for rendering the remaining time for banner change in the indicator
  Timer startIndicatorRenderingTimer() => Timer.periodic(const Duration(milliseconds: 16), (timer) {
    if(_selectedIndicatorWidth.value < 25) {
      _selectedIndicatorWidth.value = _selectedIndicatorWidth.value + (25 / (widget.duration.inSeconds));
    }
  });

  /// What happens when the banner is changed
  _onDotChanged() => _selectedIndicatorWidth.value = 0.0;

  /// Renders the banner indicators
  List<Widget> _renderIndicators() {
    final List<Widget> children = [];
    for(int i = 0; i < widget.banners; i++) {
      final isBannerCurrent = i == (widget.pageController.page?.round() ?? 0) - 1;
      children.add(
          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: isBannerCurrent ? ShadowWidget(
              blurRadius: 0.5,
              offset: const Offset(0, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 10,
                      width: 25,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(0)
                        //more than 50% of width makes circle
                      ),
                    ),
                    AnimatedContainer(
                      duration: widget.duration,
                      height: 10,
                      width: _selectedIndicatorWidth.value,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0)
                      ),
                    ),
                  ],
                ),
              ),
            ) : ShadowWidget(
              blurRadius: 0.5,
              offset: const Offset(0, 0),
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(0)
                ),
              ),
            ),
          )
      );
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndicatorWidth = useState(0.0);
    _animationRender ??= startIndicatorRenderingTimer();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _renderIndicators(),
    );
  }
}