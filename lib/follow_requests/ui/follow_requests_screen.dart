import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/constants/app_images.dart';
import 'package:streaming_post_demo/follow_requests/controller/follow_requests_controller.dart';
import 'package:streaming_post_demo/live_screen/model/streaming_request_model.dart';
import 'package:streaming_post_demo/profile/model/profile_model.dart';

import '../../common/size_config.dart';
import '../../common/widgets.dart';
import '../../constants/app_colors.dart';
import '../../constants/string_constants.dart';

class FollowRequestsScreen extends StatelessWidget {
  var controller = Get.put(FollowRequestsController());

  FollowRequestsScreen(String userId, List<Followers> followersRequestList, int streamingJoiningId, List<StreamingRequestsModel> requestList) {
    controller.userID.value = userId;
    controller.fetchFollowingRequests(controller.userID.value);
    controller.requestsList.value = requestList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () => controller.requestsList.isNotEmpty
              ? ListView.builder(
                  itemCount: controller.requestsList.value.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  reverse: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return requestRowItem(controller.requestsList.value[index], index);
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

  Widget requestRowItem(StreamingRequestsModel model, int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(model.senderUserImage.toString()),
                radius: 35,
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 4,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  headingText(model.senderUsername.toString(),
                      SizeConfig.blockSizeHorizontal * 4, colorBlack,
                      weight: FontWeight.w700),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal * 2,
                  ),
                  headingText(model.senderUserCountry.toString(),
                      SizeConfig.blockSizeHorizontal * 4, colorBlack,
                      weight: FontWeight.w700),
                ],
              ),
              Spacer(),
              InkWell(
                  onTap: (){
                    controller.acceptFollowRequest(index, model.remoteID.toString(), model.hostID.toString(), model.senderUserId.toString());
                  },
                  child: Image.asset(checked, width: 40,height: 40,)),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 2,
              ),
              InkWell(
                  onTap: (){
                    controller.deleteStreamingRequest(index);
                  },
                  child: Image.asset(cancelImage, width: 40,height: 40,)),
            ],
          ),
        ),
      ),
    );
  }
}
