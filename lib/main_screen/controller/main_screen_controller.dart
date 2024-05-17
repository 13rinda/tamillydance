import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:streaming_post_demo/main_screen/ui/main_screen.dart';
import '../../common/size_config.dart';
import '../../common/widgets.dart';
import '../../constants/app_colors.dart';
import '../../constants/storage_constants.dart';
import '../../live_screen/ui/live_screen.dart';
import '../../login/login_screen.dart';
import '../../main.dart';
import '../../post/model/post_model.dart';

class MainScreenController extends GetxController {
  var postList = <PostModel>[].obs;
  var duplicatePostList = <PostModel>[].obs;
  final searchController = TextEditingController().obs;
  var store = GetStorage();
  var username = "".obs;
  var selectedCountry = 0.obs;
  var selectedCategory = 0.obs;
  late final FirebaseMessaging _messaging;
  Timer? _timerForInter;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  BannerAd? bannerAd;
  var blockedUsers = <String>[].obs;
  var hiddenPosts = <String>[].obs;
  SharedPreferences? sharedPreferences;
  @override
  void dispose() {
    // TODO: implement dispose
    _timerForInter?.cancel();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  onInit() {
    super.onInit();

    loadAd();
    // loadBannerAd();
    _timerForInter = Timer.periodic(const Duration(minutes: 20), (result) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
      }
    });
    _requestPermissions().then((value) {
      _configureDidReceiveLocalNotificationSubject();
      _configureSelectNotificationSubject();
      FirebaseMessaging.onMessage.listen(showFlutterNotification);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print(message.toMap());
        if (message.toMap()['category'] == 'FLUTTER_NOTIFICATION_CLICK') {}
      });
    });

    setupToken();
  }

  final bannerAdId = Platform.isAndroid
      ? 'ca-app-pub-7968575513161002/7749256565'
      : 'ca-app-pub-3940256099942544/4411468910';

  final intrinsialAd = Platform.isAndroid
      ? 'ca-app-pub-7968575513161002/6704285123'
      : 'ca-app-pub-7968575513161002/8074643906';

  Future hidePost(String postId) async {
    if (!hiddenPosts.contains(postId)) {
      hiddenPosts.value.add(postId);
      hiddenPosts.refresh();

      print('~~~~~~~~${hiddenPosts.toSet()}');

      await sharedPreferences!.setStringList('hiddenPosts', hiddenPosts);
    }
  }

  Future showPost(String postId) async {
    hiddenPosts.value.remove(postId);
    hiddenPosts.refresh();
    print('~~~~~~~~${hiddenPosts.toSet()}');
    await sharedPreferences!.setStringList('hiddenPosts', hiddenPosts);
  }

  getHiddenPosts() async {
    sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences!.getStringList('hiddenPosts') != null) {
      hiddenPosts.value = sharedPreferences!.getStringList('hiddenPosts')!;
      hiddenPosts.refresh();
    }
    print('~~!!!!~~~~~~${hiddenPosts.toSet()}');
  }

  loadBannerAd() {
    BannerAd(
      adUnitId: bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();
  }

  Future reportPost(String postId, String report) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .add({'postId': postId, 'report': report});
    hidePost(postId);
  }

  Future blockUser(String postId, String report) async {
    // await FirebaseFirestore.instance
    //     .collection('reports')
    //     .add({'postId': postId, 'report': report});
    hidePost(postId);
  }

  /// Loads an interstitial ad.
  void loadAd() {
    InterstitialAd.load(
        adUnitId: intrinsialAd,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            print('$ad------------- loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            print('-------------InterstitialAd failed to load: $error');
          },
        ));
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example

    if (FirebaseAuth.instance.currentUser != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'token': token,
      });
    }
  }

  showSubscriptionDialog(BuildContext context) async {
    await showDialog(
      context: Get.context!,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Subscription'),
        content: Text(yourTrialFinished.tr),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              Get.to(() => LiveScreen(true, "", "", "0", false, "0", ''));
              // Get.to(() => PlanScreen(
              //       showFree: false,
              //     ));
            },
            child: const Text('Ok'),
          )
        ],
      ),
    );
  }

  Future<void> getUserData(BuildContext context) async {
    Future.delayed(const Duration(seconds: 1), () {
      String? uid = store.read(userId) ?? "";

      if (uid != "") {
        checkMembershipDate(context);
      } else {
        showLoginDialog();
      }
    });
  }

  void showLoginDialog() {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        content: SizedBox(
            width: SizeConfig.screenWidth / 1.5,
            height: SizeConfig.blockSizeVertical * 14,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  headingText(pleaseLoginFirstToJoinALive.tr,
                      SizeConfig.blockSizeHorizontal * 4.2, colorBlack,
                      weight: FontWeight.w500),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 3,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.off(() => LoginScreen());
                          },
                          child: Container(
                            height: SizeConfig.blockSizeVertical * 5,
                            width: SizeConfig.blockSizeHorizontal * 18,
                            decoration: BoxDecoration(
                                color: colorWhite,
                                border: Border.all(color: colorRed),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: headingText(
                                  ok.tr,
                                  SizeConfig.blockSizeHorizontal * 3.5,
                                  colorBlack,
                                  weight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
      ),
    );
  }

  checkMembershipDate(BuildContext context) async {
    Get.to(() => LiveScreen(true, "", "", "0", false, "0", ''));
    // print('aaaaaa');
    // showDebugPrint('aazzz');
    // int? subscibedDateInt = store.read(membershipDate);
    // showDebugPrint(subscibedDateInt.toString());
    // if (subscibedDateInt != null) {
    //   DateTime subscribedDate =
    //       DateTime.fromMillisecondsSinceEpoch(subscibedDateInt);

    //   DateTime now = DateTime.now();
    //   showDebugPrint(now.difference(subscribedDate).inMinutes.toString());
    //   print(subscribedDate);
    //   if (now.difference(subscribedDate).inMinutes > 0) {
    //     showSubscriptionDialog(context);
    //   } else {
    //     Get.to(() => LiveScreen(true, "", "", "0", false, "0", ''));
    //   }
    // } else {
    //   Get.to(() => PlanScreen(showFree: true));
    // }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      showDebugPrint(receivedNotification.body);
      showDebugPrint(
          '>>>>>>>>>>>>>>>>>>notification ${receivedNotification.body}');

      if (receivedNotification.body.split(startedNewLive.tr).first.trim() !=
          store.read(userName)) {
        await showDialog(
          context: Get.context!,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: receivedNotification.title != null
                ? Text(receivedNotification.title)
                : null,
            content: receivedNotification.body != null
                ? Text(receivedNotification.body)
                : null,
            // actions: <Widget>[
            //   CupertinoDialogAction(
            //     isDefaultAction: true,
            //     onPressed: () async {
            //       Navigator.of(context, rootNavigator: true).pop();
            //       await Navigator.push(
            //         context,
            //         MaterialPageRoute<void>(
            //           builder: (BuildContext context) => HomeScreen(),
            //         ),
            //       );
            //     },
            //     child: const Text('Ok'),
            //   )
            // ],
          ),
        );
      }
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String payload) async {
      // await Navigator.pushNamed(Get.context!, '/secondPage');
    });
  }

  Future<void> setupToken() async {
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    if (token != null && token.isNotEmpty) await saveTokenToDatabase(token);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> _requestPermissions() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await FirebaseMessaging.instance.subscribeToTopic('live');
  }

  filterButtonTap() async {
    postList.clear();
    duplicatePostList.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .where('country', isEqualTo: selectedCountry.value)
        .where('category', isEqualTo: selectedCategory.value)
        .get()
        .then((value) async {
      for (var i in value.docs) {
        var imageList = <Images>[];
        if (i.data()['images'] != null && i.data()['images'] != []) {
          for (int j = 0; j < i.data()['images'].length; j++) {
            imageList.add(Images(i.data()['images'][j]));
          }
        }
        var commentList = <Comments>[];
        if (i.data()['comments'] != null && i.data()['comments'] != []) {
          for (int k = 0; k < i.data()['comments'].length; k++) {
            commentList.add(Comments(
                i.data()['comments'][k]['comment'],
                i.data()['comments'][k]['username'] ?? "",
                i.data()['comments'][k]['userId'] ?? "",
                i.data()['comments'][k]['timestamp'].toString() ?? "",
                i.data()['comments'][k]['image'].toString() ?? ""));
          }
        }

        postList.add(PostModel(
            i.id,
            i.data()['userId'] ?? "",
            i.data()['username'] ?? "",
            i.data()['text'] ?? "",
            i.data()['timestamp'].toString() ?? "",
            i.data()['country'] ?? 0,
            i.data()['category'] ?? 0,
            imageList ?? [],
            commentList ?? []));
      }
      await Future.delayed(Duration.zero);
      username.value = store.read(userName) ?? "";
      postList.refresh();
      duplicatePostList.addAll(postList);
    });
  }

  fetchPosts() async {
    getHiddenPosts();

    Future.delayed(const Duration(milliseconds: 500), () async {
      postList.clear();
      duplicatePostList.clear();
      await FirebaseFirestore.instance
          .collection("posts")
          .get()
          .then((value) async {
        for (var i in value.docs) {
          var imageList = <Images>[];
          if (i.data()['images'] != null && i.data()['images'] != []) {
            for (int j = 0; j < i.data()['images'].length; j++) {
              imageList.add(Images(i.data()['images'][j]));
            }
          }
          var commentList = <Comments>[];
          if (i.data()['comments'] != null && i.data()['comments'] != []) {
            for (int k = 0; k < i.data()['comments'].length; k++) {
              commentList.add(Comments(
                  i.data()['comments'][k]['comment'],
                  i.data()['comments'][k]['username'] ?? "",
                  i.data()['comments'][k]['userId'] ?? "",
                  i.data()['comments'][k]['timestamp'].toString() ?? "",
                  i.data()['comments'][k]['image'].toString() ?? ""));
            }
          }

          postList.add(PostModel(
              i.id,
              i.data()['userId'] ?? "",
              i.data()['username'] ?? "",
              i.data()['text'] ?? "",
              i.data()['timestamp'].toString() ?? "",
              int.parse(i.data()['country'].toString()) ?? 0,
              i.data()['category'] ?? 0,
              imageList ?? [],
              commentList ?? []));
        }
        await Future.delayed(Duration.zero);
        username.value = store.read(userName) ?? "";
        postList.refresh();
        duplicatePostList.addAll(postList);
      });
    });
  }

  void filterSearchResults(String query) {
    List<PostModel> dummySearchList = [];
    dummySearchList.addAll(duplicatePostList);
    if (query.isNotEmpty) {
      List<PostModel> dummyListData = [];
      for (var item in dummySearchList) {
        if (item.country
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      postList.clear();
      postList.addAll(dummyListData);
      postList.refresh();
      return;
    } else {
      postList.clear();
      postList.addAll(duplicatePostList);
      postList.refresh();
    }
  }

  Future<void> shareLink(String url, String username, String contentt) async {
    await FlutterShare.share(
        title: url,
        text:
            '${postShareText.tr}\n\n$username ${addedAPostHaving.tr}\n\n${content.tr} : $contentt\n\n${check.tr} : \n\n$url'
        // title: "hi",
        // text: list.text == "" || list.text == null
        //     ? '\n\n Watch the below post \n\n${list.username} from ${list.country} added a post having  \n\n Check 1st Image: ${list.images![0].image}'
        //     : list.images!.isEmpty
        //         ? '\n\n Watch the below post \n\n${list.username} from ${list.country} added a post having  \n\n Content: ${list.text}'
        //         : 'Hi!!\n\n Watch the below post \n\n${list.username} from ${list.country} added a post having  \n\n Content: ${list.text} \n\n Check 1st Image: ${list.images![0].image}',
        // chooserTitle: 'Example Chooser Title'
        );
  }

/*void showCountriesDialog() {
    showDebugPrint("-------button click--------");
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        content: SizedBox(
            width: SizeConfig.screenWidth / 1.5,
            height: SizeConfig.blockSizeVertical * 14,
            child: ListView.builder(
              itemCount: controller.postList.value.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              reverse: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return postRowItem(controller.postList.value[index]);
              },
            )),
      ),
    );
  }*/

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        content: SizedBox(
            width: SizeConfig.screenWidth / 1.5,
            height: SizeConfig.blockSizeVertical * 14,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  headingText(areYouSureToLogoutFromApp.tr,
                      SizeConfig.blockSizeHorizontal * 4.2, colorBlack,
                      weight: FontWeight.w500),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 3,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            height: SizeConfig.blockSizeVertical * 5,
                            width: SizeConfig.blockSizeHorizontal * 18,
                            decoration: BoxDecoration(
                                color: colorWhite,
                                border: Border.all(color: colorRed),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: headingText(
                                  cancel.tr,
                                  SizeConfig.blockSizeHorizontal * 3.5,
                                  colorBlack,
                                  weight: FontWeight.w500),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            store.erase();
                            username.value = "";
                            Get.offAll(() => MainScreen());
                            Get.back();
                          },
                          child: Container(
                            height: SizeConfig.blockSizeVertical * 5,
                            width: SizeConfig.blockSizeHorizontal * 18,
                            decoration: BoxDecoration(
                                color: colorRed,
                                border: Border.all(color: colorRed),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: headingText(
                                  ok.tr,
                                  SizeConfig.blockSizeHorizontal * 3.5,
                                  colorWhite,
                                  weight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
      ),
    );
  }
}
