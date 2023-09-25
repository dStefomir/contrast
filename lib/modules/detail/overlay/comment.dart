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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  final Widget Function(BuildContext context, T item, List<String> submittedComments, SharedPreferences sharedPrefs, int index) itemBuilder;

  const CommentDialog({required this.widgetKey, required this.parentItemId, required this.serviceProvider, required this.itemBuilder}) : super(key: widgetKey);

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


    // Fetch the comments of a photo when the dialog is opened.
    useEffect(() {
      if(ref.read(overlayVisibilityProvider(widgetKey)) == true) {
        ref.read(serviceProvider.notifier).loadComments(
            parentItemId,
            apiData is List<ImageCommentsData>
                ? ref.read(commentsServiceProvider).getPhotographComments
                : ref.read(commentsServiceProvider).getVideoComments
        );
      }
      SharedPreferences.getInstance().then((value) => userNameController.text = value.getString('deviceName') ?? '');

      return null;
    }, [ref.watch(overlayVisibilityProvider(widgetKey)) == true]);

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
            child: FutureBuilder<SharedPreferences>(
                key: const Key('CommentDialogSharedPrefsFutureBuilder'),
                future: SharedPreferences.getInstance(),
                builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
                  if(!snapshot.hasData) {
                    return const Padding(
                      key: Key('SharedPrefsNoDataPadding'),
                      padding: EdgeInsets.all(15),
                      child: Center(
                          key: Key('SharedPrefsNoDataCenter'),
                          child: LoadingIndicator(
                              key: Key('SharedPrefsNoDataLoading'),
                              color: Colors.white
                          )
                      ),
                    );
                  }
                  /// Represents list of all comments that this user has posted so far
                  final List<String> submittedComments = snapshot.data!.getStringList('submittedComments') ?? [];

                  return Column(
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
                                    onClick: () => ref.read(overlayVisibilityProvider(widgetKey).notifier).setOverlayVisibility(false),
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
                      focusNode: deviceNameFocusNode,
                      labelText: FlutterI18n.translate(context, 'From who'),
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
                          itemBuilder: (context, index) => itemBuilder(context, apiData[index], submittedComments, snapshot.data!, index)),
                    ),
                    SimpleInput(
                      widgetKey: const Key('CommentInput'),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      controller: commentController,
                      focusNode: commentFocusNode,
                      onChange: (e) => e,
                      labelText: FlutterI18n.translate(context, 'Comment'),
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
                              final String deviceName = userNameController.text.isNotEmpty ? userNameController.text : 'Anonymous';
                              final String comment = commentController.text;
                              final double rating = ratingController.value;
                              deviceNameFocusNode.unfocus();
                              commentFocusNode.unfocus();
                              if (form!.validate() && comment.isNotEmpty) {
                                loading.value = true;
                                if(apiData is List<ImageCommentsData>) {
                                  ref.read(commentsServiceProvider).postPhotographComment(deviceName, parentItemId, comment, rating).then((value) {
                                    ref.read(serviceProvider.notifier).addItem(value);
                                    snapshot.data!.setStringList('submittedComments', submittedComments..add('${value.id}'));
                                    if (deviceName != 'Anonymous') {
                                      snapshot.data!.setString('deviceName', deviceName);
                                    }
                                    commentController.text = '';
                                    ratingController.value = 0;
                                    loading.value = false;
                                    showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Comment posted'));
                                  });
                                } else {
                                  ref.read(commentsServiceProvider).postVideoComment(deviceName, parentItemId, comment, rating).then((value) {
                                    ref.read(serviceProvider.notifier).addItem(value);
                                    snapshot.data!.setStringList('submittedComments', submittedComments..add('${value.id}'));
                                    if (deviceName != 'Anonymous') {
                                      snapshot.data!.setString('deviceName', deviceName);
                                    }
                                    commentController.text = '';
                                    ratingController.value = 0;
                                    loading.value = false;
                                    showSuccessTextOnSnackBar(context, FlutterI18n.translate(context, 'Comment posted'));
                                  });
                                }
                              }},
                            tooltip: FlutterI18n.translate(context, 'Submit'),
                            color: Colors.white.withOpacity(0.3),
                            borderColor: Colors.white,
                            icon: 'navigate_next.svg'
                        ) : const LoadingIndicator(color: Colors.white),
                      ),
                    )
                  ],
                );
              }
            )
          )
      ),
    );
  }
}