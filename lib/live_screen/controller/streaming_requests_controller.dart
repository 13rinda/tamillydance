import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:streaming_post_demo/constants/storage_constants.dart';

import '../../common/widgets.dart';
import '../../constants/string_constants.dart';
import '../../profile/model/profile_model.dart';
import '../model/streaming_request_model.dart';

class StreamingRequestsController extends GetxController{
  var userID = "".obs;
  var streamingToken = "".obs;
  var channelName = "".obs;
  var chatToken = "".obs;
  var isLoading = false.obs;
  var requestList = <StreamingRequestsModel>[].obs;
  var followersList = <Followers>[].obs;



  sendLiveStreamingRequest(Followers userDetails, String streamingToken1, String channel1, String chatToken1) {
    showDebugPrint("userid ------------->  ${userID.value}");
    isLoading.value = true;
    var senderUserId = "";
    var receiverUserId = "";
    var senderUsername = "";
    var senderUserCountry = "";
    var senderUserImage = "";
    var streamingToken = "";
    var streamingChannel = "";
    var chatToken = "";
   /* FirebaseFirestore.instance
        .collection("live_streaming_requests")
        .doc(userDetails.userId)
        .get()
        .then((value) {
      senderUserId = value.data() != null ? value.data()!['senderUserId'] : "";
      receiverUserId = value.data() != null ? value.data()!['receiverUserId'] : "";
      senderUsername = value.data() != null ? value.data()!['senderUsername'] : "";
      senderUserImage =
      value.data() != null ? value.data()!['senderUserImage'] : "";
      senderUserCountry =
      value.data() != null ? value.data()!['senderUserCountry'] : "";
      streamingToken =
      value.data() != null ? value.data()!['streamingToken'] : "";
      streamingChannel =
      value.data() != null ? value.data()!['streamingChannel'] : "";
      chatToken =
      value.data() != null ? value.data()!['chatToken'] : "";

      requestList.add(StreamingRequestsModel(senderUserId, receiverUserId,
          senderUsername, senderUserImage,senderUserCountry,streamingToken,streamingChannel,chatToken));*/

    requestList.add(StreamingRequestsModel(userID.value, userDetails.userId, GetStorage().read(userName), GetStorage().read(userCountry), GetStorage().read(userImage), streamingToken1, channel1, chatToken1, "",""));

      FirebaseFirestore.instance
          .collection('live_streaming_requests')
          .doc(userDetails.userId)
          .set({
        "requests": requestList.value.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true)).then((res) {
        isLoading.value = false;
        showMessage("Request sent to ${userDetails.username}");
      });
    //});
  }

}