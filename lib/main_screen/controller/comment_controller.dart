import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streaming_post_demo/common/widgets.dart';
import 'package:streaming_post_demo/constants/storage_constants.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:streaming_post_demo/post/model/post_model.dart';
import 'package:http/http.dart' as http;

import '../../common/size_config.dart';
import '../../constants/app_colors.dart';
import '../../login/login_screen.dart';

class CommentController extends GetxController {
  final commentController = TextEditingController().obs;
  var commentList = <Comments>[].obs;
  var commentId = "".obs;
  var store = GetStorage();
  XFile? commentImage = null;
  var commentImagePath = "".obs;
  var isLoading = false.obs;

  fetchComments() async {
    commentList.value.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(commentId.value)
        .get()
        .then((value) {
      for (int i = 0; i < value.data()!['comments'].length; i++) {
        commentList.value.add(Comments.fromJson(value.data()!['comments'][i]));
      }
      commentList.refresh();
    });
  }

  Future<void> sendCommentNotifications() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("posts")
        .doc(commentId.value)
        .get();

    if (documentSnapshot != null &&
        documentSnapshot.exists &&
        documentSnapshot.data() != null) {
      var data = documentSnapshot.data() as Map;
      if (data['userId'] != null) {
        String userId = data['userId'];
        FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get()
            .then((value) async {
          if (value != null && value.exists && value.data() != null) {
            var data = value.data() as Map;

            if (data['notificationsToken'] != null) {
              String notificationsToken = data['notificationsToken'];
              NotificationSettings settings =
                  await FirebaseMessaging.instance.requestPermission(
                alert: true,
                announcement: false,
                badge: true,
                carPlay: false,
                criticalAlert: false,
                provisional: false,
                sound: true,
              );

              if (settings.authorizationStatus ==
                  AuthorizationStatus.authorized) {
                print('~~~~~~~~~~~~~~~~~~User granted permission');
                print('~~~~~~~~~~~~~~~~~~User granted permission');

                print('~~~~~~~~~~~~~~~~~~User granted permission');
                print('~~~~~~~~~~~~~~~~~~User granted permission');

                // TODO: handle the received notifications
              } else {
                print(
                    '~~~~~~~~~~~~~~User declined or has not accepted permission');
              }
              try {
                final response = await http.post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Authorization':
                        'key=AAAAtLMfoU8:APA91bGNKD-YjlljGwYO6IQCc1jm5YHDbm_PbQk72HWaDtJ-YCw0r0JSOFPzXlQ93z_9dJnDfq0-NC1eh_vFYYnZKU5LWH7hQ2OJxJG9UwvTS5rRwNvBE0MYYClO6HNbAU9I3VIW_7wQ'
                  },
                  body: jsonEncode({
                    'to': '/token/${notificationsToken}',
                    'notification': {
                      'title': newComment.tr,
                      'body': '${store.read(userName)} ' +
                          addedCommentOnYourPost.tr,
                    },
                  }),
                );
                showDebugPrint('FCM request for device sent!');
                showDebugPrint(response.body);
                showDebugPrint(response.statusCode.toString());
                showDebugPrint(response.headers.entries.toSet().toString());
                showDebugPrint(response.reasonPhrase.toString());
              } catch (e) {
                print(e);
                showDebugPrint('~~~~ ${e.toString()}');
              }
            }
          }
        });
      }
    }
  }

  void sendMessage() {
    if (commentController.value.text.isEmpty && commentImage == null) {
      showMessage(enterComment.tr);
    } else {
      if (store.read(userName) == "" || store.read(userName) == null) {
        //  showMessage(pleaseLoginFirstToCommentAPost.tr);
        showLoginDialog();
      } else {
        isLoading.value = true;
        var imageUrl = "";
        if (commentImage != null) {
          try {
            var filename =
                'sightings/comments/${DateTime.now().toUtc().millisecondsSinceEpoch}.png';
            Reference storageReference =
                FirebaseStorage.instance.ref().child(filename);

            storageReference
                .putFile(File(commentImage!.path))
                .then((p0) async => {
                      await FirebaseStorage.instance
                          .ref()
                          .child(filename)
                          .getDownloadURL()
                          .then((value) => {
                                print("image url --->  $value"),
                                imageUrl = value.toString(),
                                uploadComment(imageUrl),
                              })
                    });
          } catch (e) {
            showDebugPrint("Image upload excaption ----------->  $e");
          }
        } else {
          uploadComment(imageUrl);
        }
      }
    }
  }

  Future<void> openGallery() async {
    try {
      var pickedfile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      //you can use ImageCourse.camera for Camera capture
      if (pickedfile != null) {
        commentImage = pickedfile;
        commentImagePath.value = commentImage!.path.toString();
      }
    } catch (e) {
      showDebugPrint("error while picking file.");
    }
  }

  void uploadComment(String imageUrl) {
    sendCommentNotifications();
    commentList.value.add(Comments(
        commentController.value.text,
        store.read(userName),
        store.read(userId),
        (DateTime.now().toUtc().millisecondsSinceEpoch).toString(),
        imageUrl));

    FirebaseFirestore.instance.collection('posts').doc(commentId.value).set({
      'comments': commentList.value.map((e) => e.toMap()).toList(),
    }, SetOptions(merge: true)).then((value) => {
          commentList.refresh(),
          commentController.value.text = "",
          commentImage = null,
          commentImagePath.value = "",
          isLoading.value = false,
          showMessage("Message sent successfully")
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
                  headingText(pleaseLoginFirstToCommentAPost.tr,
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
                            Get.to(() => LoginScreen());
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
}
