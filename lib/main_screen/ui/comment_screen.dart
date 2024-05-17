import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:streaming_post_demo/main_screen/controller/comment_controller.dart';
import 'package:streaming_post_demo/post/model/post_model.dart';

import '../../common/size_config.dart';
import '../../common/widgets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';

class CommentScreen extends StatelessWidget {
  var controller = Get.put(CommentController());

  CommentScreen(String id) {
    controller.commentId.value = id;
    controller.fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colorWhite,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                child: Column(
                  children: [
                    SizedBox(
                      height: SizeConfig.blockSizeVertical * 4,
                    ),
                   Obx(() => controller.commentImagePath.value != "" ? SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.file(
                                  File(controller.commentImagePath.value),
                                  width: SizeConfig.blockSizeHorizontal * 20,
                                  height: SizeConfig.blockSizeVertical * 15,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ):Container(),),

                    Container(
                      decoration: const BoxDecoration(
                          color: colorLightGreyBg,
                          borderRadius: BorderRadius.all(
                            Radius.circular(50.0),
                          )),
                      margin:
                          const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextFormField(
                          controller: controller.commentController.value,
                          cursorColor: colorRed,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.bottom,
                          style: const TextStyle(color: colorBlack),
                          decoration: InputDecoration(
                            hintText: enter.tr,
                            hintStyle: const TextStyle(color: colorGrey),
                            filled: true,
                            border: InputBorder.none,
                            prefixIcon: InkWell(
                              onTap: () {
                                controller.openGallery();
                              },
                              child: Container(
                                width: SizeConfig.blockSizeVertical * 1,
                                height: SizeConfig.blockSizeVertical * 1,
                                margin: const EdgeInsets.all(5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    attachment,
                                    width: SizeConfig.blockSizeVertical * 3,
                                    height: SizeConfig.blockSizeVertical * 3,
                                  ),
                                ),
                              ),
                            ),
                            fillColor: Colors.transparent,
                            suffixIcon: InkWell(
                              onTap: () {
                                controller.sendMessage();
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              child: Container(
                                width: SizeConfig.blockSizeVertical * 1,
                                height: SizeConfig.blockSizeVertical * 1,
                                margin: const EdgeInsets.all(5),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    sendChat,
                                    width: SizeConfig.blockSizeVertical * 3,
                                    height: SizeConfig.blockSizeVertical * 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Obx(
                        () => controller.commentList.value.length > 0
                            ? ListView.builder(
                              itemCount: controller.commentList.value.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                             reverse: true,
                              primary: false,
                              itemBuilder: (context, index) {
                                return chatRowItem(
                                    controller.commentList.value[index], index);
                              },
                            )
                            : Container(
                                height: 600,
                                child: Center(
                                  child: headingText(noDataFound.tr,
                                      SizeConfig.blockSizeHorizontal * 4, colorGrey,
                                      weight: FontWeight.w500),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx (() => controller.isLoading.value == true ? Container( width: SizeConfig.screenWidth, height : SizeConfig.screenHeight, child: Center(child: commonLoader())) : Container(),),

            ],
          ),
        ),
      ),
    );
  }

  Widget chatRowItem(Comments comments, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: SizeConfig.blockSizeHorizontal * 25,
                child: headingText(
                    comments.username.toString() != ""
                        ? "${comments.username.toString()} :"
                        : "User :",
                    SizeConfig.blockSizeHorizontal * 3.8,
                    appColor,
                    weight: FontWeight.w600),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 3,
              ),
              Expanded(
                child: Text(
                  comments.comment.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      fontSize: SizeConfig.blockSizeHorizontal * 3.8),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 5,
              ),
            ],
          ),
          comments.image != "" && comments.image != "null" ? Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 15),
            child: FadeInImage.assetNetwork(
              placeholder: placeholder,
              image: comments.image!.toString(),
              width: SizeConfig.blockSizeHorizontal *40,
              height: SizeConfig.blockSizeVertical * 20,
              fit: BoxFit.fill,
            ),
          ): Container(),
          Divider(),
        ],
      ),
    );
  }
}
