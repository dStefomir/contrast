import 'dart:async';

import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:parallax_animation/parallax_animation.dart';

/// The time for switching to the next banner
const _nextBanner = Duration(milliseconds: 3000);
/// The time for general animation of the banner switching
const _bannerAnimationDuration = Duration(milliseconds: 1000);
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
  /// Current banner index
  late int _currentBannerIndex;
  /// Previous banner index
  late int _previousBannerIndex;
  /// Controller for the giff header of the data view
  FlutterGifController? _videoBoardGiffController;
  /// Timer for switching to the next banner
  Timer? _nextBannerTimer;

  @override
  void initState() {
    _currentBannerIndex = 99999992;
    _previousBannerIndex = _currentBannerIndex;
    _pageController = PageController(initialPage: _currentBannerIndex, keepPage: false, viewportFraction: 1.0);
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
    if (_videoBoardGiffController != null) {
      _videoBoardGiffController!.dispose();
    }
    super.dispose();
  }

  /// Sets a periodic timer for changing the banners
  Timer _startBannerChangingTimer() => Timer(_nextBanner, () {
    if (mounted) {
      _pageController.nextPage(duration: _bannerAnimationDuration, curve: Curves.fastEaseInToSlowEaseOut);
    }
  });

  /// What happens when banner is changed
  _onBannerChange() {
    if (_nextBannerTimer != null) {
      _nextBannerTimer!.cancel();
    }
    setState(() => _nextBannerTimer = _startBannerChangingTimer());
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.banners.length > 1) {
        _nextBannerTimer ??= _startBannerChangingTimer();
      }
      if (_videoBoardGiffController != null) {
        _videoBoardGiffController!.repeat(
            min: 0,
            max: 299,
            period: const Duration(seconds: 10)
        );
      }
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        ParallaxArea(
          child: PageView.builder(
            controller: _pageController,
            physics: widget.banners.length < 2 ? const NeverScrollableScrollPhysics() : null,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (widget.banners.isEmpty) {
                return const SizedBox.shrink();
              }

              final calculatedIndex = (index % widget.banners.length).round();
              final String banner = widget.banners[calculatedIndex];
              final String text = widget.quotes[calculatedIndex];

              return ParallaxWidget(
                  alignment: Alignment.centerLeft,
                  fixedVertical: true,
                  inverted: true,
                  overflowWidthFactor: 1.1,
                  overflowHeightFactor: 1,
                  background: Stack(
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
                        alignment: Alignment.center,
                        child: StyledText(
                          maxLines: 1,
                          text: text,
                          color: Colors.white,
                          useShadow: true,
                          align: TextAlign.start,
                          letterSpacing: 5,
                          fontSize: 30,
                          italic: true,
                          clip: true,
                        ),
                      )
                    ],
                  ),
                  child: const SizedBox(width: double.infinity, height: double.infinity)
              );
            },
            onPageChanged: (index) {
              _previousBannerIndex = _currentBannerIndex;
              _currentBannerIndex = (index % widget.banners.length).round();
            },
          ),
        ),
        if (widget.banners.length > 1) Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _BannerDotIndicator(
                  pageController: _pageController,
                  banners: widget.banners.length,
                  duration: _nextBanner,
                  currentBannerIndex: _currentBannerIndex,
                  previousBannerIndex: _previousBannerIndex
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
  /// Current index of the banner
  final int currentBannerIndex;
  /// Previous index of the banner
  final int previousBannerIndex;
  /// Number of banners
  final int banners;
  /// Duration for switching to the next banner
  final Duration duration;

  const _BannerDotIndicator({
    required this.pageController,
    required this.currentBannerIndex,
    required this.previousBannerIndex,
    required this.banners,
    required this.duration
  });

  @override
  ConsumerState createState() => _BannerDotIndicatorState();
}

class _BannerDotIndicatorState extends ConsumerState<_BannerDotIndicator> with TickerProviderStateMixin {
  /// Animation controller
  late AnimationController _controller;
  /// Animation
  late Animation _animation;

  @override
  void initState() {
    widget.pageController.addListener(_onDotChanged);
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(_reload);
    _animation = Tween<double>(begin: 10, end: 25).animate(_controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onDotChanged);
    _controller.removeListener(_reload);
    _controller.dispose();
    super.dispose();
  }

  /// What happens when the banner is changed
  _onDotChanged() => Future.delayed(const Duration(milliseconds: 100), () {
    if (mounted) {
      _controller.removeListener(_reload);
      _controller.stop();
      _controller.duration = widget.duration;
      _controller.reset();
      _controller.addListener(_reload);
      _controller.forward();
    }
  });

  /// Reloads the widget state
  _reload() => setState(() {});

  /// Renders the banner indicators
  List<Widget> _renderIndicators() {
    final List<Widget> children = [];
    for(int i = 0; i < widget.banners; i++) {
      final isBannerCurrent = i == (widget.currentBannerIndex % widget.banners).round();
      final isBannerPrevious = i == (widget.previousBannerIndex % widget.banners).round();

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
                    Container(
                      height: 10,
                      width: _animation.value,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(0)
                      ),
                    )
                  ],
                ),
              ),
            ) :
            isBannerPrevious ?
            const ShadowWidget(
              blurRadius: 0.5,
              offset: Offset(0, 0),
              child: _DotIndicatorMask(
                  startWidth: 25,
                  endWidth: 10,
                  duration: Duration(milliseconds: 100)
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
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const NeverScrollableScrollPhysics(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: _renderIndicators(),
    ),
  );
}

/// Renders an animated mask for the banner dot indicator
class _DotIndicatorMask extends StatefulHookConsumerWidget {
  /// Starting width of the animation
  final double startWidth;
  /// Ending width of the animation
  final double endWidth;
  /// Duration for the animation
  final Duration duration;

  const _DotIndicatorMask({Key? key, required this.startWidth, required this.endWidth, required this.duration}) : super(key: key);

  @override
  ConsumerState createState() => _DotIndicatorMaskState();
}

class _DotIndicatorMaskState extends ConsumerState<_DotIndicatorMask> with TickerProviderStateMixin {
  /// Dot mask filler animation controller
  late AnimationController _dotFillerController;
  /// Dot mask filler Animation
  late Animation _dotFillerAnimation;

  @override
  void initState() {
    _dotFillerController = AnimationController(vsync: this, duration: widget.duration);
    _dotFillerController.addListener(_reload);
    _dotFillerAnimation = Tween<double>(begin: widget.startWidth, end: widget.endWidth).animate(_dotFillerController);
    super.initState();
  }

  @override
  void dispose() {
    _dotFillerController.removeListener(_reload);
    _dotFillerController.dispose();
    super.dispose();
  }

  /// Reloads the widget state
  _reload() => setState(() {});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_dotFillerController.isAnimating) {
        _dotFillerController.forward();
      }
    });

    return Container(
      height: 10,
      width: _dotFillerAnimation.value,
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(0)
        //more than 50% of width makes circle
      ),
    );
  }
}