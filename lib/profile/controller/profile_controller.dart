import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streaming_post_demo/constants/storage_constants.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:video_player/video_player.dart';

import '../../common/widgets.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController().obs;
  final ageController = TextEditingController().obs;
  final stateController = TextEditingController().obs;
  final nationalityController = TextEditingController().obs;
  final webController = TextEditingController().obs;
  final emailController = TextEditingController().obs;
  final storeController = TextEditingController().obs;
  var videoFile = XFile("").obs;
  var imageFile = XFile("").obs;
  var userData =
      ProfileModel("", "", "", "", "", "", "", "", "", "", "", "", []).obs;
  var store = GetStorage();
  var isLoading = false.obs;
  var imageUrl = "".obs;
  var videoUrlList = <Videos>[].obs;
  var isUploadingComplete = false.obs;
  var enableTextField = true.obs;

  @override
  void onInit() {
    super.onInit();
    userData.refresh();
  }

  getVideoFromGallery() async {
    try {
      var pickedfiles = await ImagePicker().pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 60));
      if (pickedfiles != null) {
        videoFile.value = pickedfiles;
        videoFile.refresh();
      } else {
        showDebugPrint("No video is selected.");
      }
    } catch (e) {
      showDebugPrint("error while picking file.");
    }
  }

  getImageFromGallery() async {
    try {
      var pickedfiles =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedfiles != null) {
        imageFile.value = pickedfiles;
        imageFile.refresh();
      } else {
        showDebugPrint("No video is selected.");
      }
    } catch (e) {
      showDebugPrint("error while picking file.");
    }
  }

  void setData() {
    userData.refresh();
    nameController.value.text = userData.value.username.toString();
    ageController.value.text = userData.value.age.toString();
    stateController.value.text = userData.value.state.toString();
    nationalityController.value.text = userData.value.nationality.toString();
    webController.value.text = userData.value.web.toString();
    emailController.value.text = userData.value.email.toString();
    storeController.value.text = userData.value.store.toString();
    imageUrl.value = userData.value.profileImage.toString();
    videoUrlList.clear();
    for (int i = 0; i < userData.value.videos!.length; i++) {
      videoUrlList.value.add(Videos(userData.value.videos![i].videoFile));
    }
    videoUrlList.refresh();
  }

  bool isValidEmail(String? value) {
    if (value != null) {
      return RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(value);
    } else {
      return false;
    }
  }

  Future<void> updateProfileData() async {
    if (nameController.value.text.toString().isEmpty) {
      showMessage(enterYourName.tr);
    } else if (ageController.value.text.toString().isEmpty) {
      showMessage(enterYourAge.tr);
    } else if (stateController.value.text.toString().isEmpty) {
      showMessage(enterYourState.tr);
    } else if (nationalityController.value.text.toString().isEmpty) {
      showMessage(enterYourNationality.tr);
    } else if (webController.value.text.toString().isEmpty) {
      showMessage(enterYourWeb.tr);
    } else if (emailController.value.text.isEmpty ||
        !isValidEmail(emailController.value.text)) {
      showMessage(enterYourValidEmail.tr);
    } else if (storeController.value.text.toString().isEmpty) {
      showMessage(enterYourStore.tr);
    } else {
      isLoading.value = true;
      if (videoFile.value.path != null && videoFile.value.path != "") {
        try {
          isUploadingComplete.value = true;
          var filename =
              'profile/videos/${DateTime.now().toUtc().millisecondsSinceEpoch}.mp4';
          Reference storageReference =
              FirebaseStorage.instance.ref().child(filename);
          bool validDuration =
              await isVideoValid(videoFile.value.path, Duration(seconds: 20));
          if (validDuration) {
            TaskSnapshot taskSnapshot =
                await storageReference.putFile(File(videoFile.value.path));

            String videoUrl = await FirebaseStorage.instance
                .ref()
                .child(filename)
                .getDownloadURL();

            videoUrlList.value.add(Videos(videoUrl));
            videoUrlList.refresh();
            showDebugPrint('video length >>>> ${validDuration}');
          } else {
            showMessage(videoLengthError.tr);
            isLoading.value = false;

            return;
          }
        } catch (e) {
          showDebugPrint("video upload exception ----------->  $e");
        }
      }
      if (imageFile.value.path != "") {
        try {
          isUploadingComplete.value = true;
          var filename =
              'profile/images/${DateTime.now().toUtc().millisecondsSinceEpoch}.png';
          Reference storageReference =
              FirebaseStorage.instance.ref().child(filename);

          TaskSnapshot uploadTask =
              await storageReference.putFile(File(imageFile.value.path));

          String url = await FirebaseStorage.instance
              .ref()
              .child(filename)
              .getDownloadURL();
          isUploadingComplete.value = false;
          imageUrl.value = url;
        } catch (e) {
          showDebugPrint("Image upload exception ----------->  $e");
        }
      }
      // if (videoFile.value.path == "" && imageFile.value.path == "") {
      //   isUploadingComplete.value == false;
      // }
      updateData();
      // uploadingConditionCheck();
    }
  }

  Future<Duration> getVideoDuration(String videoPath) async {
    final videoController = VideoPlayerController.file(File(videoPath));
    await videoController.initialize();
    final videoDuration = videoController.value.duration;
    videoController.dispose();
    return videoDuration;
  }

  Future<bool> isVideoValid(String videoPath, Duration maxDuration) async {
    final videoDuration = await getVideoDuration(videoPath);
    showDebugPrint(videoDuration.inSeconds.toString());
    if (videoDuration <= maxDuration) {
      return true;
    } else {
      return false;
    }
  }

  // void uploadingConditionCheck() {
  //   Future.delayed(const Duration(seconds: 10), () {
  //     if (isUploadingComplete.value == false) {
  //       updateData();
  //     } else {
  //       uploadingConditionCheck();
  //     }
  //   });
  // }

  Future<void> updateData() async {
    showDebugPrint('videoUrls >>>');
    showDebugPrint(videoUrlList.value.toSet().toString());
    showDebugPrint('videoUrls >>>${videoUrlList.value.length} ');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(store.read(userId))
        .set({
      "profileImage": imageUrl.value.toString(),
      "age": ageController.value.text.toString(),
      "state": stateController.value.text.toString(),
      "nationality": nationalityController.value.text.toString(),
      "web": webController.value.text.toString(),
      "email": emailController.value.text.toString(),
      "store": storeController.value.text.toString(),
      "videos": videoUrlList.value.map((e) => e.toMap()).toList(),
    }, SetOptions(merge: true)).then((res) {
      isLoading.value = false;
      GetStorage().write(
        userCountry,
        nationalityController.value.text.toString(),
      );
      GetStorage().write(userImage, imageUrl.value.toString());
      showMessage(dataUpdatedSuccessfully.tr);
    });
  }
}
