import 'dart:async';

import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gif/flutter_gif.dart';

/// The time for switching to the next banner
const _nextBanner = Duration(milliseconds: 3000);
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
  /// Current banner index
  late int _currentBannerIndex;
  /// Controller for the giff header of the data view
  FlutterGifController? _videoBoardGiffController;
  /// Timer for switching to the next banner
  Timer? _nextBannerTimer;

  @override
  void initState() {
    _currentBannerIndex = 0;
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
    if (_videoBoardGiffController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _videoBoardGiffController!.repeat(
          min: 0,
          max: 299,
          period: const Duration(seconds: 10)
      ));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.banners.length > 1) {
        _nextBannerTimer ??= _startBannerChangingTimer();
      }
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            if (widget.banners.isEmpty) {
              return const SizedBox.shrink();
            }

            final calculatedIndex = (index % widget.banners.length).round();
            final String banner = widget.banners[calculatedIndex];
            final String text = widget.quotes[calculatedIndex];

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
                  alignment: Alignment.center,
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
          onPageChanged: (index) => _currentBannerIndex = (index % widget.banners.length).round(),
        ),
        if (widget.banners.length > 1) Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _BannerDotIndicator(
                  pageController: _pageController,
                  banners: widget.banners.length,
                  duration: _nextBanner,
                  currentBannerIndex: _currentBannerIndex
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
  /// Number of banners
  final int banners;
  /// Duration for switching to the next banner
  final Duration duration;

  const _BannerDotIndicator({required this.pageController, required this.currentBannerIndex, required this.banners, required this.duration});

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
      children: _renderIndicators(),
    ),
  );
}