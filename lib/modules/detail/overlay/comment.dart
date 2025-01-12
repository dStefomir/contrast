import 'dart:io';

import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/model/image_comments.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/overlay/provider.dart';
import 'package:contrast/modules/detail/overlay/service.dart';
import 'package:contrast/security/session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dialog height
const double dialogHeight = 550;
/// Renders a delete item dialog
class CommentDialog<T> extends HookConsumerWidget {
  /// Form key
  static GlobalKey<FormState> formKey = GlobalKey<FormState>();
  /// Widget key
  final Key widgetKey;
  /// Id of the selected item
  final int parentItemId;
  /// Service provider for the comments dialog
  final StateNotifierProvider <CommentsNotifier, List<T>> serviceProvider;
  /// Renders each row of the list view
  final Widget Function(BuildContext context, T item, String? deviceId, int index) itemBuilder;

  const CommentDialog({required this.widgetKey, required this.parentItemId, required this.serviceProvider, required this.itemBuilder}) : super(key: widgetKey);

  /// Renders the child widget with the device unique Id
  Widget _deviceInfoWidget(Widget Function(String?) child) {
    const Widget loading = Padding(
      padding: EdgeInsets.all(15),
      child: Center(
          child: LoadingIndicator(
              color: Colors.white
          )
      ),
    );
    if(kIsWeb) {
      return child('web_admin');
    } else if (Platform.isIOS) {
      return FutureBuilder<IosDeviceInfo>(
          future: DeviceInfoPlugin().iosInfo,
          builder: (BuildContext context, AsyncSnapshot<IosDeviceInfo> snapshot) {
            if(!snapshot.hasData) {
              return loading;
            }

            return child(snapshot.data!.identifierForVendor);
          }
      );
    } else if (Platform.isAndroid) {
      return FutureBuilder<AndroidDeviceInfo>(
          future: DeviceInfoPlugin().androidInfo,
          builder: (BuildContext context, AsyncSnapshot<AndroidDeviceInfo> snapshot) {
            if(!snapshot.hasData) {
              return loading;
            }

            return child(snapshot.data!.id);
          }
      );
    } else {
      return child('desktop');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// List of comments
    final apiData = ref.watch(serviceProvider);
    /// Text controllers
    final userNameController = useTextEditingController();
    final commentController = useTextEditingController();
    /// Rating controller
    final ratingController = useState(0.0);
    /// Text input focus nodes
    final deviceNameFocusNode = useFocusNode();
    final commentFocusNode = useFocusNode();
    /// Loading controller
    final loading = useState(false);
    /// Is the admin logged in or not
    final bool isAdmin = Session().isLoggedIn();

    // Fetch the comments of a photo when the dialog is opened.
    useEffect(() {
      if(ref.read(overlayVisibilityProvider(widgetKey)) == true) {
        ref.read(serviceProvider.notifier).loadComments(
            parentItemId,
            isAdmin,
            apiData is List<ImageCommentsData>
                ? ref.read(commentsServiceProvider).getPhotographComments
                : ref.read(commentsServiceProvider).getVideoComments
        );
      }
      SharedPreferences.getInstance().then((value) {
        if(isAdmin) {
          userNameController.text = 'dStefomir';
        } else {
          userNameController.text = value.getString('deviceName') ?? '';
        }
      });
      return null;
    }, [ref.watch(overlayVisibilityProvider(widgetKey)) == true]);

    return Form(
      key: formKey,
      child: ShadowWidget(
          offset: const Offset(0, 0),
          blurRadius: 4,
          child: Container(
            color: Colors.white,
            height: dialogHeight,
            child: _deviceInfoWidget((deviceId) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyledText(
                            text: translate('Comments'),
                            weight: FontWeight.bold,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 10),
                            child: StyledText(
                                text: translate(isAdmin ? 'Approve pending comments' : 'You can post only one comment per day'),
                                color: Colors.grey,
                                fontSize: 10,
                                padding: 0,
                                letterSpacing: 3,
                                clip: false,
                                align: TextAlign.start,
                                weight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: DefaultButton(
                            onClick: () {
                              ref.read(overlayVisibilityProvider(widgetKey).notifier).setOverlayVisibility(false);
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            tooltip: translate('Close'),
                            color: Colors.white,
                            borderColor: Colors.black,
                            icon: 'close.svg'
                        ),
                      ),
                    ],
                  ),
                ),
                SimpleInput(
                  widgetKey: const Key('CommentInputDeviceName'),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  controller: userNameController,
                  focusNode: deviceNameFocusNode,
                  enabled: !isAdmin,
                  labelText: translate('From who'),
                  onChange: (e) => e,
                  suffixWidget: Center(
                    widthFactor: 1.2,
                    child: RatingBar.builder(
                      initialRating: ratingController.value,
                      minRating: 0,
                      wrapAlignment: WrapAlignment.center,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: 25,
                      glow: true,
                      itemCount: 5,
                      itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber,),
                      onRatingUpdate: (rating) => ratingController.value = rating,
                    ),
                  ),
                  validator: (e) {
                    if(e != null && !Session().isLoggedIn() && (
                        e.toLowerCase().contains('dstefomir') ||
                            e.toLowerCase().contains('stefomir') ||
                            e.toLowerCase().contains('stefomird') ||
                            e.toLowerCase().contains('dstefko') ||
                            e.toLowerCase().contains('stefkod'
                            )
                    )) {
                      return translate('This name cannot be used');
                    }

                    return null;
                  },
                ),
                Expanded(
                  child: apiData.isEmpty ? Center(
                    child: StyledText(text: translate('Nothing here so far')),
                  ) : ListView.builder(
                      key: const Key('CommentDialogList'),
                      itemCount: apiData.length,
                      itemBuilder: (context, index) => itemBuilder(context, apiData[index], deviceId, index)),
                ),
                SimpleInput(
                  widgetKey: const Key('CommentInput'),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  controller: commentController,
                  focusNode: commentFocusNode,
                  onChange: (e) => e,
                  labelText: translate('Comment'),
                  validator: (e) {
                    if (e != null && e.isEmpty) {
                      return translate('This field is mandatory');
                    }
                    if(e != null && e.length > 1000) {
                      return translate('The comment is more than 1000 characters');
                    }

                    return null;
                  },
                  suffixWidget: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: !loading.value ? DefaultButton(
                        onClick: () async {
                          final form = formKey.currentState;
                          final String deviceName = userNameController.text.isNotEmpty ? userNameController.text : 'Anonymous';
                          final String comment = commentController.text;
                          final double rating = ratingController.value;
                          deviceNameFocusNode.unfocus();
                          commentFocusNode.unfocus();
                          if (form!.validate() && comment.isNotEmpty) {
                            loading.value = true;
                            final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
                            if (deviceName != 'Anonymous') {
                              sharedPrefs.setString('deviceName', deviceName);
                            }
                            if(apiData is List<ImageCommentsData>) {
                              ref.read(commentsServiceProvider).postPhotographComment(deviceId ?? 'noId', deviceName, parentItemId, comment, rating, isAdmin).then((value) {
                                if(value.approved! == true) {
                                  ref.read(serviceProvider.notifier).addItem(value);
                                }
                                commentController.text = '';
                                ratingController.value = 0;
                                loading.value = false;
                                showSuccessTextOnSnackBar(
                                    context.mounted
                                        ? context
                                        : null,
                                    translate(
                                        value.approved!
                                            ? 'Comment posted'
                                            : 'Comment review is pending'
                                    )
                                );
                              }).onError((error, stackTrace) {
                                loading.value = false;
                                showErrorTextOnSnackBar(
                                    context.mounted
                                        ? context
                                        : null,
                                    translate('Only one comment per day is allowed')
                                );
                              });
                            } else {
                              ref.read(commentsServiceProvider).postVideoComment(deviceId ?? 'noId', deviceName, parentItemId, comment, rating, isAdmin).then((value) {
                                if(value.approved! == true) {
                                  ref.read(serviceProvider.notifier).addItem(value);
                                }
                                commentController.text = '';
                                ratingController.value = 0;
                                loading.value = false;
                                showSuccessTextOnSnackBar(
                                    context.mounted
                                        ? context
                                        : null,
                                    translate(
                                        value.approved!
                                            ? 'Comment posted'
                                            : 'Comment review is pending'
                                    )
                                );
                              }).onError((error, stackTrace) {
                                loading.value = false;
                                showErrorTextOnSnackBar(
                                    context.mounted
                                        ? context
                                        : null,
                                    translate('Only one comment per day is allowed')
                                );
                              });
                            }
                          }},
                        tooltip: translate('Submit'),
                        color: Colors.white.withValues(alpha: 0.3),
                        borderColor: Colors.black,
                        icon: 'navigate_next.svg'
                    ) : const LoadingIndicator(color: Colors.black),
                  ),
                )
              ],
            ))
          )
      ),
    );
  }
}