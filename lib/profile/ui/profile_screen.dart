import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:streaming_post_demo/profile/controller/profile_controller.dart';
import 'package:streaming_post_demo/profile/model/profile_model.dart';
import 'package:streaming_post_demo/profile/ui/video_player_screen.dart';

import '../../common/size_config.dart';
import '../../common/widgets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';

class ProfileScreen extends StatelessWidget {
  var controller = Get.put(ProfileController());

  ProfileScreen(
    ProfileModel model,
    bool enableTextField1,
  ) {
    controller.userData.value = model;

    controller.enableTextField.value = enableTextField1;
    controller.userData.refresh();
    controller.setData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Center(
                    child: headingText(profile.tr,
                        SizeConfig.blockSizeHorizontal * 8, colorBlack),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          child: headingText(photoForLiveIcon.tr,
                              SizeConfig.blockSizeHorizontal * 4, colorBlack)),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal * 10,
                      ),
                      InkWell(
                        onTap: () {
                          if (controller.enableTextField.value == true) {
                            controller.getImageFromGallery();
                          } else {}
                        },
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal * 22,
                          height: SizeConfig.blockSizeVertical * 12,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorBlack,
                              style: BorderStyle.solid,
                              width: 1.0,
                            ),
                          ),
                          child: Obx(
                            () => controller.imageFile.value.path != null &&
                                    controller.imageFile.value.path != "" &&
                                    controller.imageFile.value.path != "null"
                                ? Image.file(
                                    File(controller.imageFile.value.path),
                                    width: SizeConfig.blockSizeHorizontal * 20,
                                    height: SizeConfig.blockSizeVertical * 15,
                                    fit: BoxFit.fill,
                                  )
                                : controller.userData.value.profileImage !=
                                            null &&
                                        controller
                                                .userData.value.profileImage !=
                                            "" &&
                                        controller
                                                .userData.value.profileImage !=
                                            "null"
                                    ? FadeInImage.assetNetwork(
                                        placeholder: placeholder,
                                        image: controller
                                            .userData.value.profileImage
                                            .toString(),
                                        width:
                                            SizeConfig.blockSizeHorizontal * 20,
                                        height:
                                            SizeConfig.blockSizeVertical * 15,
                                        fit: BoxFit.fill,
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Image.asset(
                                          plus,
                                          width: 15,
                                          height: 15,
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: headingText(name.tr,
                                SizeConfig.blockSizeHorizontal * 4, colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller: controller.nameController.value,
                              cursorColor: colorRed,
                              enabled: controller.enableTextField.value,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: name.tr,
                                hintStyle: const TextStyle(color: colorGrey),
                                filled: true,
                                fillColor: colorWhite,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: colorGrey, width: 0.7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: colorGrey),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: colorRed),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: headingText(myAge.tr,
                                SizeConfig.blockSizeHorizontal * 4, colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller: controller.ageController.value,
                              cursorColor: colorRed,
                              enabled: controller.enableTextField.value,
                              textAlignVertical: TextAlignVertical.bottom,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: myAge.tr,
                                hintStyle: const TextStyle(color: colorGrey),
                                filled: true,
                                fillColor: colorWhite,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: colorGrey, width: 0.7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: colorGrey),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: colorRed),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: headingText(myState.tr,
                                SizeConfig.blockSizeHorizontal * 4, colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller: controller.stateController.value,
                              cursorColor: colorRed,
                              enabled: controller.enableTextField.value,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: myState.tr,
                                hintStyle: const TextStyle(color: colorGrey),
                                filled: true,
                                fillColor: colorWhite,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: colorGrey, width: 0.7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: colorGrey),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: colorRed),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          // height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: headingText(myNationality.tr,
                                SizeConfig.blockSizeHorizontal * 4, colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller:
                                  controller.nationalityController.value,
                              cursorColor: colorRed,
                              enabled: controller.enableTextField.value,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: myNationality.tr,
                                hintStyle: const TextStyle(color: colorGrey),
                                filled: true,
                                fillColor: colorWhite,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: colorGrey, width: 0.7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: colorGrey),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: colorRed),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: headingText(myWeb.tr,
                                SizeConfig.blockSizeHorizontal * 4, colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller: controller.webController.value,
                              cursorColor: colorRed,
                              enabled: controller.enableTextField.value,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: myWeb.tr,
                                hintStyle: const TextStyle(color: colorGrey),
                                filled: true,
                                fillColor: colorWhite,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: colorGrey, width: 0.7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: colorGrey),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: colorRed),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: headingText(myEmail.tr,
                                SizeConfig.blockSizeHorizontal * 4, colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller: controller.emailController.value,
                              cursorColor: colorRed,
                              enabled: controller.enableTextField.value,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: myEmail.tr,
                                hintStyle: const TextStyle(color: colorGrey),
                                filled: true,
                                fillColor: colorWhite,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: colorGrey, width: 0.7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: colorGrey),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: colorRed),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                    child: headingText(storeMustStartsWith.tr,
                        SizeConfig.blockSizeHorizontal * 3.2, colorBlack,
                        weight: FontWeight.w400),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 13.0),
                            child: headingText(myStore.tr,
                                SizeConfig.blockSizeHorizontal * 4, colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller: controller.storeController.value,
                              cursorColor: colorRed,
                              enabled: controller.enableTextField.value,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: myStore.tr,
                                hintStyle: const TextStyle(color: colorGrey),
                                filled: true,
                                fillColor: colorWhite,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: colorGrey, width: 0.7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: colorGrey),
                                ),
                                errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: colorRed),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Obx(() => controller.enableTextField.value == true
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: headingText(addVideosNotMoreThan20Minutes.tr,
                              SizeConfig.blockSizeHorizontal * 4, colorBlack),
                        )
                      : Container()),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Obx(() => controller.enableTextField.value == true
                      ? InkWell(
                          onTap: () {
                            controller.getVideoFromGallery();
                          },
                          child: SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 20,
                            height: SizeConfig.blockSizeVertical * 10,
                            child: Center(
                              child: Obx(() => controller
                                          .videoFile.value.path !=
                                      ""
                                  ? FadeInImage.assetNetwork(
                                      placeholder: placeholder,
                                      image:
                                          "https://www.dignited.com/wp-content/uploads/2019/03/images-1.png",
                                      width:
                                          SizeConfig.blockSizeHorizontal * 20,
                                      height: SizeConfig.blockSizeVertical * 15,
                                      fit: BoxFit.fill,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                        plus,
                                        width: SizeConfig.blockSizeHorizontal *
                                            8.5,
                                        height:
                                            SizeConfig.blockSizeVertical * 4.8,
                                      ),
                                    )),
                            ),
                          ),
                        )
                      : Container()),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Obx(
                    () => controller.userData.value.videos!.length > 0
                        ? SizedBox(
                            height: SizeConfig.blockSizeVertical * 15,
                            child: ListView.builder(
                              itemCount:
                                  controller.userData.value.videos!.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              reverse: true,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Get.to(() => VideoPlayerScreen(controller
                                        .userData.value.videos![index].videoFile
                                        .toString()));
                                  },
                                  child: SizedBox(
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: FadeInImage.assetNetwork(
                                          placeholder: placeholder,
                                          image:
                                              "https://cdn-icons-png.flaticon.com/512/4503/4503915.png",
                                          width:
                                              SizeConfig.blockSizeHorizontal *
                                                  25,
                                          height:
                                              SizeConfig.blockSizeVertical * 15,
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                );
                              },
                            ))
                        : Container(),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Obx(
                    () => controller.enableTextField.value == true
                        ? Center(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.updateProfileData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 15.0,
                              ),
                              child: SizedBox(
                                  width: SizeConfig.screenWidth / 1.5,
                                  height: SizeConfig.blockSizeVertical * 6,
                                  child: Center(
                                      child: headingText(
                                          update.tr,
                                          SizeConfig.blockSizeHorizontal * 4,
                                          colorWhite))),
                            ),
                          )
                        : Container(),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                ],
              ),
            ),
            Obx(
              () => controller.isLoading.value == true
                  ? Container(
                      width: SizeConfig.screenWidth,
                      height: SizeConfig.screenHeight,
                      child: Center(child: commonLoader()))
                  : Container(),
            ),
          ],
        ),
      ),
    ));
  }
}
