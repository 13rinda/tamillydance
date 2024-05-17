import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:streaming_post_demo/live_screen/controller/streaming_requests_controller.dart';

import '../../common/size_config.dart';
import '../../common/widgets.dart';
import '../../constants/app_colors.dart';
import '../../constants/string_constants.dart';
import '../../profile/model/profile_model.dart';

class StreamingRequestsScreen extends StatelessWidget{
  var controller = Get.put(StreamingRequestsController());

  StreamingRequestsScreen(String userId, List<Followers> followersRequestList, String streamingToken, String channel, String chatToken) {
    controller.userID.value = userId;
    controller.followersList.value = followersRequestList;
    controller.streamingToken.value = streamingToken;
    controller.channelName.value = channel;
    controller.chatToken.value = chatToken;
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
    return InkWell(
      onTap: (){
          controller.sendLiveStreamingRequest(follower, controller.streamingToken.value, controller.channelName.value, controller.chatToken.value);
      },
      child: Padding(
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
      ),
    );
  }
}