import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streaming_post_demo/common/widgets.dart';
import 'package:streaming_post_demo/constants/storage_constants.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:streaming_post_demo/login/login_screen.dart';

import '../../common/size_config.dart';
import '../../constants/app_colors.dart';
import '../../main_screen/ui/main_screen.dart';
import '../model/post_model.dart';

class PostController extends GetxController {
  final textController = TextEditingController().obs;
  var store = GetStorage();
  var imageFileList = <XFile>[].obs;
  var postData = PostModel("", "", "", "", "", 0, 0, null, null).obs;
  var imageUrlList = <String>[].obs;
  var isLoading = false.obs;
  var commentList = <Comments>[].obs;
  var selectedCountry = 0.obs;
  var selectedCategory = 0.obs;

  getFromGallery() async {
    try {
      var pickedfiles = await ImagePicker().pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      if (pickedfiles != null) {
        if (pickedfiles.length > 5 - imageFileList.length) {
          showMessage(youCanOnlySelectUpto5Photos.tr);
        } else {
          // imageFileList.clear();
          imageFileList.value.addAll(pickedfiles);
          imageFileList.refresh();
          imageUrlList.clear();
          imageUrlList.refresh();
        }
      } else {
        showDebugPrint("No image is selected.");
      }
    } catch (e) {
      showDebugPrint("error while picking file.");
    }
  }

  Future<void> sendNotifications() async {
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

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('~~~~~~~~~~~~~~~~~~User granted permission');
      print('~~~~~~~~~~~~~~~~~~User granted permission');

      print('~~~~~~~~~~~~~~~~~~User granted permission');
      print('~~~~~~~~~~~~~~~~~~User granted permission');

      // TODO: handle the received notifications
    } else {
      print('~~~~~~~~~~~~~~User declined or has not accepted permission');
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
          'to': '/topics/live',
          'notification': {
            'title': newPost.tr,
            'body': '${store.read(userName)} ${createdNewPost.tr}',
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

  Future<void> addPostButtonClick() async {
    if (selectedCountry.value == 0) {
      showMessage(chooseCountry.tr);
    } else if (selectedCategory.value == 0) {
      showMessage(chooseCategory.tr);
    } else if (textController.value.text.isEmpty &&
        imageFileList.value.isEmpty) {
      showMessage(cantShareEmptyPost.tr);
    } else {
      if (store.read(userName) == "" || store.read(userName) == null) {
        //  showMessage(pleaseLoginFirstToShareAPost.tr);
        showLoginDialog();
      } else {
        isLoading.value = true;

        if (imageUrlList.value.isNotEmpty) {
          uploadPost();
        } else {
          // uploading images on firebase store
          for (int i = 0; i < imageFileList.length; i++) {
            try {
              var filename =
                  'sightings/${DateTime.now().toUtc().millisecondsSinceEpoch}.png';
              Reference storageReference =
                  FirebaseStorage.instance.ref().child(filename);

              storageReference
                  .putFile(File(imageFileList.value[i].path))
                  .then((p0) async => {
                        await FirebaseStorage.instance
                            .ref()
                            .child(filename)
                            .getDownloadURL()
                            .then((value) => {
                                  print("image url --->  $value"),
                                  imageUrlList.add(value.toString())
                                })
                      });
            } catch (e) {
              showDebugPrint("Image upload excaption ----------->  $e");
            }
          }
          uploadingConditionCheck();
        }
      }
    }
  }

  Future<void> uploadPost() async {
    var map = {
      'userId': store.read(userId),
      'username': store.read(userName),
      'country': selectedCountry.value,
      'category': selectedCategory.value,
      'text': textController.value.text.trim(),
      'timestamp': (DateTime.now().toUtc().millisecondsSinceEpoch).toString(),
      'images': imageUrlList,
      'comments': commentList
    };
    showDebugPrint("userid ------------->  ${store.read(userId)}");

    await FirebaseFirestore.instance
        .collection("posts")
        .doc(store.read(userId))
        .set({
      'userId': store.read(userId),
      'username': store.read(userName),
      'country': selectedCountry.value,
      'category': selectedCategory.value,
      'text': textController.value.text.trim(),
      'timestamp': (DateTime.now().toUtc().millisecondsSinceEpoch).toString(),
      'images': imageUrlList.value,
      'comments': commentList.value
    }).then((value) => {
              sendNotifications(),
              showMessage(postShareSuccessfully.tr),
              isLoading.value = false,
              Get.to(() => MainScreen()),
              selectedCountry.value = 0,
              selectedCategory.value = 0,
              textController.value.text = "",
              imageFileList.clear(),
              imageUrlList.clear(),
              commentList.clear(),
            });
  }

  void uploadingConditionCheck() {
    Future.delayed(const Duration(seconds: 5), () {
      if (imageUrlList.value.length == imageFileList.value.length) {
        uploadPost();
      } else {
        uploadingConditionCheck();
      }
    });
  }

  fetchUserPost() async {
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(store.read(userId))
        .get()
        .then((value) {
      isLoading.value = true;
      var imageList = <Images>[];
      if (value.data() != null && value.data()!['images'] != null) {
        if (value.data()!['images'] != null && value.data()!['images'] != []) {
          for (int j = 0; j < value.data()!['images'].length; j++) {
            imageList.add(Images(value.data()!['images'][j]));
            imageUrlList.add(value.data()!['images'][j]);
          }
        }
      }

      /*    if (value.data() != null && value.data()!['comments'] != null && value.data()!['comments'] != []) {
        for (int k = 0; k < value.data()!['comments'].length; k++) {
          commentList.add(Comments(
              value.data()!['comments'][k]['comment'] ?? "",
              value.data()!['comments'][k]['username'] ?? "",
              value.data()!['comments'][k]['userId'] ?? "",
              value.data()!['comments'][k]['timestamp'].toString() ?? "",
              value.data()!['comments'][k]['image'].toString() ?? "")
          );
        }
      }*/
      isLoading.value = false;
      postData.value.id = value.id;
      postData.value.userId =
          value.data() != null ? value.data()!['userId'] : "";
      postData.value.username =
          value.data() != null ? value.data()!['username'] : "";
      postData.value.text = value.data() != null ? value.data()!['text'] : "";
      postData.value.timestamp =
          value.data() != null ? value.data()!['timestamp'] : "";
      postData.value.country =
          value.data() != null ? value.data()!['country'] : 0;
      postData.value.category =
          value.data() != null ? value.data()!['category'] : 0;
      postData.value.images = imageList;
      postData.value.comments = commentList;
      selectedCountry.value = int.parse(postData.value.country.toString());
      selectedCategory.value = postData.value.category!;

      textController.value.text = postData.value.text.toString();
      imageUrlList.refresh();
      postData.refresh();
    });
  }

  void deletePostButtonClick() {
    FirebaseFirestore.instance
        .collection("posts")
        .doc(store.read(userId))
        .delete()
        .then((value) {
      showMessage(postDeletedSuccessfully.tr);
      isLoading.value = false;
      Get.to(() => MainScreen());
      selectedCountry.value = 0;
      selectedCategory.value = 0;
      textController.value.text = "";
      imageFileList.clear();
      imageUrlList.clear();
      commentList.clear();
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
                  headingText(pleaseLoginFirstToShareAPost.tr,
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
