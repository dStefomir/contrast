import 'package:contrast/common/widgets/button.dart';
import 'package:contrast/common/widgets/input.dart';
import 'package:contrast/common/widgets/load.dart';
import 'package:contrast/common/widgets/shadow.dart';
import 'package:contrast/common/widgets/snack.dart';
import 'package:contrast/common/widgets/text.dart';
import 'package:contrast/modules/board/provider.dart';
import 'package:contrast/modules/detail/overlay/provider.dart';
import 'package:contrast/modules/detail/overlay/service.dart';
import 'package:contrast/security/session.dart';
import 'package:contrast/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dialog height
const double dialogHeight = 550;
/// Renders a delete item dialog
class CommentDialog extends HookConsumerWidget {
  /// Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  /// Id of the selected photograph
  final int photographId;

  CommentDialog({Key? key, required this.photographId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// List of comments
    final apiData = ref.watch(commentsDataViewProvider);
    /// Text controllers
    final userNameController = useTextEditingController();
    final commentController = useTextEditingController();
    /// Rating controller
    final ratingController = useState(0.0);
    /// Loading controller
    final loading = useState(false);

    // Fetch the comments of a photo when the dialog is opened.
    useEffect(() {
      if(ref.read(overlayVisibilityProvider(const Key('comment_photograph'))) == true) {
        ref.read(commentsDataViewProvider.notifier).loadComments(
            photographId, ref
            .read(photographCommentsServiceProvider)
            .getComments);
      }
      SharedPreferences.getInstance().then((value) => userNameController.text = value.getString('deviceName') ?? '');

      return null;
    }, [ref.watch(overlayVisibilityProvider(const Key('comment_photograph')))]);

    return Form(
      key: formKey,
      child: ShadowWidget(
          key: const Key('CommentDialogShadow'),
          offset: const Offset(0, 0),
          blurRadius: 4,
          child: Container(
            key: const Key('CommentDialogTopContainer'),
            color: Colors.white.withOpacity(0.3),
            height: dialogHeight,
            child: Column(
              key: const Key('CommentDialogTopColumn'),
              children: [
                Column(
                  key: const Key('CommentDialogInnerColumn'),
                  children: [
                    Padding(
                      key: const Key('CommentDialogColumnPadding'),
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          key: const Key('CommentDialogColumnRow'),
                          children: [
                            StyledText(
                                key: const Key('CommentDialogColumnRowText'),
                                text: FlutterI18n.translate(context, 'Comments'),
                                weight: FontWeight.bold
                            ),
                            const Spacer(key: Key('CommentDialogColumnRowSpacer'),),
                            DefaultButton(
                                key: const Key('CommentDialogColumnRowButton'),
                                onClick: () => ref.read(overlayVisibilityProvider(const Key('comment_photograph')).notifier).setOverlayVisibility(false),
                                tooltip: FlutterI18n.translate(context, 'Close'),
                                color: Colors.white.withOpacity(0.3),
                                borderColor: Colors.white,
                                icon: 'close.svg'
                            ),
                          ]
                      ),
                    ),
                  ],
                ),
                SimpleInput(
                    widgetKey: const Key('CommentInputDeviceName'),
                    backgroundColor: Colors.white.withOpacity(0.3),
                    controller: userNameController,
                    labelText: FlutterI18n.translate(context, 'From who'),
                    hint: FlutterI18n.translate(context, 'Your name'),
                    onChange: (e) => e,
                    suffixWidget: Center(
                      widthFactor: 1.5,
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
                      if(e != null && e.isEmpty) {
                        return FlutterI18n.translate(context, 'This field is mandatory');
                      }
                      if(e != null && !Session().isLoggedIn() && (
                          e.toLowerCase().contains('dstefomir') ||
                              e.toLowerCase().contains('stefomir') ||
                              e.toLowerCase().contains('stefomird') ||
                              e.toLowerCase().contains('dstefko') ||
                              e.toLowerCase().contains('stefkod'
                              )
                      )) {
                        return FlutterI18n.translate(context, 'This name cannot be used');
                      }

                      return null;
                    },
                ),
                apiData.isEmpty ? Expanded(
                  key: const Key('CommentNoDataExpanded'),
                  child: Center(
                    key: const Key('CommentNoDataCentered'),
                    child: StyledText(
                        key: const Key('CommentNoDataText'),
                        text: FlutterI18n.translate(context, 'Nothing here so far')
                    ),
                  ),
                ) : Expanded(
                  key: const Key('CommentDialogListExpanded'),
                  child: ListView.builder(
                      key: const Key('CommentDialogList'),
                      itemCount: apiData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          key: const Key('CommentDialogListPadding'),
                          padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
                          child: Column(
                            key: const Key('CommentDialogListColumn'),
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StyledText(
                                    text: '${apiData[index].deviceName}',
                                    fontSize: 15,
                                    weight: FontWeight.bold,
                                    clip: false,
                                    align: TextAlign.start,
                                    padding: 0,
                                  ),
                                  const Spacer(),
                                  if (!Session().isLoggedIn()) StyledText(
                                    text: formatTimeDifference(apiData[index].date),
                                    fontSize: 10,
                                    color: Colors.black38,
                                    weight: FontWeight.bold,
                                    align: TextAlign.start,
                                    letterSpacing: 3,
                                    padding: 0,
                                  ) else DefaultButton(
                                      key: const Key('CommentDeleteButton'),
                                      onClick: () => ref.read(photographCommentsServiceProvider).deleteComment(apiData[index].id!).then((value) {
                                        ref.read(commentsDataViewProvider.notifier).removeItem(value);
                                        showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Comment was deleted successfully'));
                                      }),
                                      tooltip: FlutterI18n.translate(context, 'Delete comment'),
                                      color: Colors.white.withOpacity(0.3),
                                      borderColor: Colors.white,
                                      icon: 'close.svg'
                                  ),
                              ],),
                              if(apiData[index].rating! > 0) Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Center(
                                  widthFactor: 1,
                                  child: RatingBar.builder(
                                    initialRating: apiData[index].rating!,
                                    minRating: 0,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    ignoreGestures: true,
                                    itemSize: 25,
                                    glow: true,
                                    itemCount: 5,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {},
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: StyledText(
                                  text: apiData[index].comment!,
                                  fontSize: 13,
                                  clip: false,
                                  align: TextAlign.start,
                                  color: Colors.black87,
                                  padding: 0,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                SimpleInput(
                  widgetKey: const Key('CommentInput'),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  controller: commentController,
                  onChange: (e) => e,
                  labelText: FlutterI18n.translate(context, 'Comment'),
                  hint: FlutterI18n.translate(context, 'Type what do you think'),
                  validator: (e) {
                    if (e != null && e.isEmpty) {
                      return FlutterI18n.translate(context, 'This field is mandatory');
                    }
                    if(e != null && e.length > 1000) {
                      return FlutterI18n.translate(context, 'The comment is more than 1000 characters');
                    }

                    return null;
                  },
                  suffixWidget: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: !loading.value ? DefaultButton(
                        key: const Key('CommentInputSubmitButton'),
                        onClick: () async {
                          final form = formKey.currentState;
                          final String deviceName = userNameController.text;
                          final String comment = commentController.text;
                          final double rating = ratingController.value;
                          if (form!.validate() && comment.isNotEmpty) {
                            loading.value = true;
                            ref.read(photographCommentsServiceProvider).postComment(deviceName, photographId, comment, rating).then((value) {
                              ref.read(commentsDataViewProvider.notifier).addItem(value);
                              SharedPreferences.getInstance().then((value) {
                                value.setString('deviceName', deviceName);
                                commentController.text = '';
                                ratingController.value = 0;
                                loading.value = false;
                                showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Comment posted'));
                              });
                            });
                          }},
                        tooltip: FlutterI18n.translate(context, 'Submit'),
                        color: Colors.white.withOpacity(0.3),
                        borderColor: Colors.white,
                        icon: 'navigate_next.svg'
                    ) : const LoadingIndicator(color: Colors.white),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}