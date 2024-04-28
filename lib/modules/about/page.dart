import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:contrast/common/widgets/animation.dart';
import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/icon.dart';
import 'package:contrast/common/widgets/page.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the About page
class AboutPage extends StatefulHookConsumerWidget {

  /// Firebase plugins
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  const AboutPage({
    required this.analytics,
    required this.observer,
    super.key
  });

  @override
  ConsumerState createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {

  @override
  void initState() {
    super.initState();
    // Send analytics when the widget is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.analytics.logEvent(name: 'about'));
  }

  /// Renders the back button
  Widget _renderBackButton(BuildContext context) =>
      Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: DefaultButton(
            onClick: () => Modular.to.navigate('/'),
            color: Colors.white,
            tooltip: translate('Close'),
            borderColor: Colors.black,
            icon: 'close.svg'
        ),
      );

  /// Renders the mail button
  Widget _renderMailButton(BuildContext context) =>
      SlideTransitionAnimation(
        duration: const Duration(milliseconds: 1000),
        getStart: () => const Offset(0, -10),
        getEnd: () => const Offset(0, 0),
        whenTo: (controller) {},
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: DefaultButton(
              onClick: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'dStefomir@gmail.com',
                  queryParameters: {'subject': 'Contrastus'},
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                } else {
                  showErrorTextOnSnackBar(context, translate('Error Mail'));
                }
              },
              color: Colors.white,
              tooltip: translate('Mail'),
              borderColor: Colors.black,
              icon: 'mail.svg'
          ),
        ),
      );

  /// Renders the instagram button
  Widget _renderInstagramButton(BuildContext context) =>
      SlideTransitionAnimation(
        duration: const Duration(milliseconds: 1000),
        getStart: () => const Offset(0, -10),
        getEnd: () => const Offset(0, 0),
        whenTo: (controller) {},
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: DefaultButton(
              onClick: () async {
                final Uri url = Uri.parse('https://www.instagram.com/dstefomir/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  showErrorTextOnSnackBar(context, translate('Error Instagram'));
                }
              },
              color: Colors.white,
              tooltip: translate('Instagram'),
              borderColor: Colors.black,
              icon: 'instagram.svg'
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BackgroundPage(
        color: Colors.black,
        child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) => Stack(
              alignment: Alignment.center,
              children: [
                const IconRenderer(
                    asset: 'me.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                ).opacity(0.6, from: 1)
                    .animate(
                    duration: const Duration(milliseconds: 1800),
                    trigger: true,
                    startImmediately: true
                ),
                BlurryContainer(
                  height: double.infinity,
                  width: double.infinity,
                  blur: 3,
                  elevation: 0,
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  borderRadius: const BorderRadius.all(Radius.circular(0)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              _renderBackButton(context),
                              _renderMailButton(context),
                              _renderInstagramButton(context)
                            ],
                          )
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: orientation == Orientation.portrait ?
                          MediaQuery.of(context).size.height / 15 :
                          MediaQuery.of(context).size.height / 6),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                StyledText(
                                  text: translate("About description"),
                                  color: Colors.white,
                                  align: TextAlign.start,
                                  clip: false,
                                  fontSize: 15,
                                  useShadow: true,
                                  typewriter: true,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
        )
    );
  }
}