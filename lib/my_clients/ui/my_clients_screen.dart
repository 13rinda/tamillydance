import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/constants/app_images.dart';
import 'package:streaming_post_demo/follow_requests/controller/follow_requests_controller.dart';
import 'package:streaming_post_demo/my_clients/controller/my_clients_controller.dart';
import 'package:streaming_post_demo/profile/model/profile_model.dart';

import '../../common/size_config.dart';
import '../../common/widgets.dart';
import '../../constants/app_colors.dart';
import '../../constants/string_constants.dart';

class MyClientsScreen extends StatelessWidget {
  var controller = Get.put(MyClientsController());

  MyClientsScreen(String userId, List<Followers> followersRequestList) {
    controller.userID.value = userId;
    controller.followersList.value = followersRequestList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(
              () => controller.followersList.isNotEmpty
              ? ListView.builder(
            itemCount: controller.followersList.value.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return requestRowItem(controller.followersList.value[index], index);
            },
          )
              : Container(
            height: 300,
            child: Center(
              child: headingText(noDataFound.tr,
                  SizeConfig.blockSizeHorizontal * 4, colorGrey,
                  weight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget requestRowItem(Followers follower, int index) {
    return  Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(follower.userImage.toString()),
                  radius: 35,
                ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 4,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    headingText(follower.username.toString(),
                        SizeConfig.blockSizeHorizontal * 4, colorBlack,
                        weight: FontWeight.w700),
                    SizedBox(
                      height: SizeConfig.blockSizeHorizontal * 2,
                    ),
                    headingText(follower.userCountry.toString(),
                        SizeConfig.blockSizeHorizontal * 4, colorBlack,
                        weight: FontWeight.w700),
                  ],
                ),

              ],
            ),
          ),
        ),
    );
  }
}
