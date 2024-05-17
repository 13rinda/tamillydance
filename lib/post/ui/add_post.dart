import 'dart:io';
import 'package:dropdown_button2/src/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/common/size_config.dart';
import 'package:streaming_post_demo/common/widgets.dart';
import 'package:streaming_post_demo/constants/app_colors.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:streaming_post_demo/post/controller/post_controller.dart';
import 'package:streaming_post_demo/terms/view.dart';

import '../../constants/app_images.dart';

class AddPostScreen extends StatelessWidget {
  var controller = Get.put(PostController());

  AddPostScreen() {
    controller.fetchUserPost();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Center(
                    child: headingText(addPost.tr,
                        SizeConfig.blockSizeHorizontal * 8, colorBlack),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: headingText(
                              country.tr,
                              SizeConfig.blockSizeHorizontal * 4.5,
                              colorBlack)),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => DropdownButton2<int>(
                              hint: Text(chooseCountry.tr,
                                  style: const TextStyle(color: Colors.black)),
                              customButton: Container(
                                  height: SizeConfig.blockSizeVertical * 6,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0)),
                                    border: Border.all(
                                        color: colorGrey, width: 0.7),
                                  ),
                                  child: Text(
                                    controller.selectedCountry == 0
                                        ? chooseCountry.tr
                                        : controller.selectedCountry == 1
                                            ? inArabRegion.tr
                                            : controller.selectedCountry == 2
                                                ? inEurop.tr
                                                : controller.selectedCountry ==
                                                        3
                                                    ? inAmerica.tr
                                                    : controller.selectedCountry ==
                                                            4
                                                        ? inArabianGulfRegion.tr
                                                        : controller.selectedCountry ==
                                                                5
                                                            ? inChina.tr
                                                            : controller.selectedCountry ==
                                                                    6
                                                                ? inTurkey.tr
                                                                : inAnotherPlace
                                                                    .tr,
                                    textAlign: TextAlign.center,
                                  )),
                              style: const TextStyle(color: Colors.black),
                              isDense: true,
                              items: [0, 1, 2, 3, 4, 5, 6, 7]
                                  .map((item) => DropdownMenuItem<int>(
                                        value: item,
                                        child: Text(
                                          item == 0
                                              ? chooseCountry.tr
                                              : item == 1
                                                  ? inArabRegion.tr
                                                  : item == 2
                                                      ? inEurop.tr
                                                      : item == 3
                                                          ? inAmerica.tr
                                                          : item == 4
                                                              ? inArabianGulfRegion
                                                                  .tr
                                                              : item == 5
                                                                  ? inChina.tr
                                                                  : item == 6
                                                                      ? inTurkey
                                                                          .tr
                                                                      : inAnotherPlace
                                                                          .tr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              value: controller.selectedCountry.value == 0
                                  ? null
                                  : controller.selectedCountry.value,
                              onChanged: (value) {
                                controller.selectedCountry.value = value!;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 25,
                          child: headingText(
                              category.tr,
                              SizeConfig.blockSizeHorizontal * 4.5,
                              colorBlack)),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => DropdownButton2<int>(
                              hint: Text(chooseCategory.tr,
                                  style: const TextStyle(color: Colors.black)),
                              customButton: Container(
                                  height: SizeConfig.blockSizeVertical * 6,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0)),
                                    border: Border.all(
                                        color: colorGrey, width: 0.7),
                                  ),
                                  child: Text(
                                    controller.selectedCategory == 0
                                        ? chooseCategory.tr
                                        : controller.selectedCategory == 1
                                            ? fashion.tr
                                            : controller.selectedCategory == 2
                                                ? electronics.tr
                                                : controller.selectedCategory ==
                                                        3
                                                    ? toys.tr
                                                    : controller.selectedCategory ==
                                                            4
                                                        ? furniture.tr
                                                        : controller.selectedCategory ==
                                                                5
                                                            ? beauty.tr
                                                            : other.tr,
                                    textAlign: TextAlign.center,
                                  )),
                              style: const TextStyle(color: Colors.black),
                              isDense: true,
                              items: [0, 1, 2, 3, 4, 5, 6]
                                  .map((item) => DropdownMenuItem<int>(
                                        value: item,
                                        child: Text(
                                          item == 0
                                              ? chooseCategory.tr
                                              : item == 1
                                                  ? fashion.tr
                                                  : item == 2
                                                      ? electronics.tr
                                                      : item == 3
                                                          ? toys.tr
                                                          : item == 4
                                                              ? furniture.tr
                                                              : item == 5
                                                                  ? beauty.tr
                                                                  : other.tr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              value: controller.selectedCategory.value == 0
                                  ? null
                                  : controller.selectedCategory.value,
                              onChanged: (value) {
                                controller.selectedCategory.value = value!;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
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
                            child: headingText(
                                addText.tr,
                                SizeConfig.blockSizeHorizontal * 4.5,
                                colorBlack),
                          )),
                      Expanded(
                        child: SizedBox(
                          // height: SizeConfig.blockSizeVertical * 6,
                          child: Obx(
                            () => TextFormField(
                              controller: controller.textController.value,
                              cursorColor: colorRed,
                              maxLines: 10,
                              maxLength: 500,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: colorBlack),
                              decoration: InputDecoration(
                                hintText: addText.tr,
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
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          width: SizeConfig.blockSizeHorizontal * 21,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: headingText(
                                photo.tr,
                                SizeConfig.blockSizeHorizontal * 4.5,
                                colorBlack),
                          )),
                      InkWell(
                        onTap: () {
                          controller.getFromGallery();
                        },
                        child: SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 20,
                          height: SizeConfig.blockSizeVertical * 10,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                plus,
                                width: SizeConfig.blockSizeHorizontal * 8.5,
                                height: SizeConfig.blockSizeVertical * 4.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: SizeConfig.blockSizeVertical * 15,
                          child: Obx(
                            () => controller.imageUrlList.value.isNotEmpty
                                ? ListView.builder(
                                    itemCount:
                                        controller.imageUrlList.value.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: FadeInImage.assetNetwork(
                                              placeholder: placeholder,
                                              image: controller
                                                  .imageUrlList.value[index],
                                              width: SizeConfig
                                                      .blockSizeHorizontal *
                                                  20,
                                              height:
                                                  SizeConfig.blockSizeVertical *
                                                      15,
                                              fit: BoxFit.fill,
                                            )),
                                      );
                                    },
                                  )
                                : controller.imageFileList.value.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: controller
                                            .imageFileList.value.length,
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return SizedBox(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Image.file(
                                                File(controller.imageFileList
                                                    .value[index].path),
                                                width: SizeConfig
                                                        .blockSizeHorizontal *
                                                    20,
                                                height: SizeConfig
                                                        .blockSizeVertical *
                                                    15,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.addPostButtonClick();
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
                              child: Obx(() => headingText(
                                  controller.postData.value.country != "" &&
                                          controller.postData.value.country !=
                                              null
                                      ? update.tr
                                      : add.tr,
                                  SizeConfig.blockSizeHorizontal * 4,
                                  colorWhite)))),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Obx(
                    () => controller.postData.value.country != "" &&
                            controller.postData.value.country != null
                        ? Center(
                            child: ElevatedButton(
                                onPressed: () {
                                  controller.deletePostButtonClick();
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
                                            delete.tr,
                                            SizeConfig.blockSizeHorizontal * 4,
                                            colorWhite)))),
                          )
                        : Container(),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 3,
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsScreen(),
                        )),
                    child: Center(
                      child: headingText(termsConditions.tr,
                          SizeConfig.blockSizeHorizontal * 4, colorBlack),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 3,
                  ),
                ],
              ),
            ),
            Obx(
              () => controller.isLoading.value == true
                  ? SizedBox(
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
