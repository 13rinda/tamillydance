import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/live_screen/model/streaming_request_model.dart';
import 'package:streaming_post_demo/profile/model/profile_model.dart';

import '../../common/widgets.dart';
import '../../constants/string_constants.dart';
import '../../live_screen/ui/live_screen.dart';

class FollowRequestsController extends GetxController {
  var userID = "".obs;

  //var requestsList = <Followers>[].obs;
  var requestsList = <StreamingRequestsModel>[].obs;

  fetchFollowingRequests(String userID) async {
    await FirebaseFirestore.instance
        .collection("live_streaming_requests")
        .doc(userID)
        .get()
        .then((value) {
      if (value.data() != null && value.data()!['requests'] != null) {
        if (value.data()!['requests'] != null &&
            value.data()!['requests'] != []) {
          for (int j = 0; j < value.data()!['requests'].length; j++) {
            requestsList.add(StreamingRequestsModel(
              value.data()!['requests'][j]['senderUserId'],
              value.data()!['requests'][j]['receiverUserId'],
              value.data()!['requests'][j]['senderUsername'],
              value.data()!['requests'][j]['senderUserCountry'],
              value.data()!['requests'][j]['senderUserImage'],
              value.data()!['requests'][j]['streamingToken'],
              value.data()!['requests'][j]['streamingChannel'],
              value.data()!['requests'][j]['chatToken'],
              value.data()!['requests'][j]['remoteID'],
              value.data()!['requests'][j]['hostID'],
            ));
          }
        }
      }
      requestsList.refresh();
    });
  }

  void deleteStreamingRequest(int index) {
    requestsList.removeAt(index);
    requestsList.refresh();

    FirebaseFirestore.instance
        .collection('live_streaming_requests')
        .doc(userID.value)
        .set({
      "requests": requestsList.value.map((e) => e.toMap()).toList(),
    }, SetOptions(merge: true)).then((res) {
      showMessage(dataUpdatedSuccessfully.tr);
    });
  }

  void acceptFollowRequest(
      int index, String remoteId, String hostId, String senderId) {
    // deleteStreamingRequest(index);
    showDebugPrint(
        "remote id on request screen---------------------   $remoteId");
    setRequestAccept(senderId);
    //Get.to(() => LiveScreen(true, "", "", remoteId, true, hostId) );
  }

  setRequestAccept(String senderId) async {
    FirebaseFirestore.instance
        .collection('accepted_live_request')
        .doc(senderId)
        .set({
      "senderId": senderId,
      "accept": "true",
    }, SetOptions(merge: true)).then((res) {
      Get.back();
    });
  }
}
