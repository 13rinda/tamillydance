import 'dart:async';
import 'dart:convert';

import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:streaming_post_demo/common/widgets.dart';
import 'package:streaming_post_demo/constants/api_endpoints.dart';
import 'package:streaming_post_demo/live_screen/model/live_audience_model.dart';
import 'package:streaming_post_demo/live_screen/model/streaming_request_model.dart';

import '../../common/size_config.dart';
import '../../constants/app_colors.dart';
import '../../constants/storage_constants.dart';
import '../../constants/string_constants.dart';
import '../../login/login_screen.dart';
import '../../profile/model/profile_model.dart';
import '../model/chat_model.dart';
import '../ui/live_partner_screen.dart';

class LiveController extends GetxController {
  final messageController = TextEditingController().obs;
  var store = GetStorage();
  var userData =
      ProfileModel("", "", "", "", "", "", "", "", "", "", "", "", []).obs;
  var isLoading = false.obs;
  var token = "".obs;
  var rtmToken = "".obs;
  var userID = "".obs;
  var isLoadingVideoView = false.obs;
  RtcEngine? agoraEngine;
  var uid = 0.obs; // uid of the local user
  var streamingJoiningId = "0".obs;
  var hostId = "0".obs;
  var remoteUid = 1.obs; // uid of the remote user
  var isJoined =
      false.obs; // Indicates if the local user has joined the channel
  var isHost = false.obs;
  var isBroadcaster = false.obs;

  var groupStreaming = false.obs;
  var isPartnerJoin = false.obs;
  var streamingUserId = "".obs;
  var agoraChatId = 0.obs;
  var enableTextField = true.obs;
  // var followText = "".obs;
  var followRequests = <Followers>[].obs;
  // var myClientsList = <Followers>[].obs;
  // var streamingRequestsList = <StreamingRequestsModel>[].obs;
  var scrollController = ScrollController().obs;
  var channelName = "".obs;
  // var joinRequestSent = false.obs;
  var showingListMode = 0.obs;
  // var showingList = [].obs;

  // var streamingToken =
  //     "007eJxTYGAyXq18gefCsYCvfZna+3/+esK0QVHz1VTp5wlcLxg7QtIVGNIsLMzTDM1TU00SLUxMjFMtU8wMUg1S0swsjEySk9PMlV/LpTQEMjJk1H9nYmRgZGABYhCfCUwyg0kWMMnLEFxSlJqYm5mXHpBfXMLAAADi6iXI"
  //         .obs;
  var chatToken =
      "007eJxTYLBou26XnrE/K18mKHHO8suRJ7W+PX5m9dUnf2Wj86u5pzYoMKRZWJinGZqnppokWpiYGKdappgZpBqkpJlZGJkkJ6eZ+7yWS2kIZGTQrjBiZmRgZWAEQhBfhcHEIDEpzTjFQDcpLS1N19AwNUU3McnMTNc4KckwJSnNMs0iyRAALzsp4w=="
          .obs;
  var chatList = <ChatModel>[].obs;
  var streamingAudienceList = <LiveAudienceModel>[].obs;

  var users = <StreamUser>[].obs;
  var tokenUrl = 'https://ourworld-yx0i.onrender.com'.obs;
  final _infoStrings = <String>[];
  var muted = false.obs;
  AgoraRtmClient? _client;
  AgoraRtmChannel? channel;

  late int _remoteUid;
  late RtcEngine _engine;

  Future<void> initForAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = await RtcEngine.createWithConfig(
        RtcEngineConfig(ApiEndPoints.agoraAppId));

    await _engine.enableVideo();

    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");

          _remoteUid = uid;
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");

          // _remoteUid = "";
        },
      ),
    );

    await _engine.joinChannel(
        ApiEndPoints.agoraAppCertificates, "firstchannel", null, 0);
  }

  @override
  onInit() {
    initForAgora();
    getUserData();
    //  checkLiveRequestAcceptance();
    //if(streamingToken.value == null || streamingToken.value == ""){
    //tokenGeneration();
    //  }
    showDebugPrint("----------controller staretd-------------  ");
    // followText.value = follow.tr;
    super.onInit();
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
            'title': liveVideo.tr,
            'body': '${store.read(userName)} ${startedNewLive.tr}',
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

  /*--------------------VIDEO STREAMING START--------------------------------*/

  void _createClient() async {
    _client = await AgoraRtmClient.createInstance(ApiEndPoints.agoraAppId);
    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      showDebugPrint("Peer msg: $peerId, msg: ${message.text}");
    };
    _client?.onConnectionStateChanged = (int state, int reason) {
      showDebugPrint('Connection state changed: $state, reason: $reason');
      if (state == 5) {
        _client?.logout();
        showDebugPrint('Logout.');
      }
    };
    _client?.onLocalInvitationReceivedByPeer =
        (AgoraRtmLocalInvitation invite) {
      showDebugPrint(
          'Local invitation received by peer: ${invite.calleeId}, content: ${invite.content}');
    };
    _client?.onRemoteInvitationReceivedByPeer =
        (AgoraRtmRemoteInvitation invite) {
      showDebugPrint(
          'Remote invitation received by peer: ${invite.callerId}, content: ${invite.content}');
    };
  }

  showFollowers() {
    showingListMode.value = 1;
    showingListMode.refresh();
    // showingList.value = myClientsList;
    // showingList.refresh();
  }

  showRequests() {
    showDebugPrint('message');
    showingListMode.value = 2;
    // showingList.value = streamingRequestsList;
    showingListMode.refresh();
    // showingList.refresh();
  }

  hideList() {
    showingListMode.value = 0;
    showingListMode.refresh();
    // showingList.value = [];
    // showingList.refresh();
  }

  Future<AgoraRtmChannel?> _createChannel(String name) async {
    AgoraRtmChannel? channel = await _client?.createChannel(name);
    if (channel != null) {
      showDebugPrint('channel not equal null');
      channel.onMemberJoined = (AgoraRtmMember member) {
        showDebugPrint(
            'Member joined: ${member.userId}, channel: ${member.channelId}');
      };
      channel.onMemberLeft = (AgoraRtmMember member) {
        showDebugPrint(
            'Member left: ${member.userId}, channel: ${member.channelId}');
      };
      channel.onMessageReceived =
          (AgoraRtmMessage message, AgoraRtmMember member) {
        showDebugPrint("Channel msg: ${member.userId}, msg: ${message.text}");
      };
    } else {
      showDebugPrint('channel  equal null ~~~~');
    }
    return channel;
  }

  onToggleMute() {
    muted.value = !muted.value;
    agoraEngine!.muteLocalAudioStream(muted.value);
  }

  onSwitchCamera() {
    agoraEngine!.switchCamera();
  }

  muteUser(int uid) {
    agoraEngine!.muteRemoteAudioStream(uid, true);
    int index = users.indexWhere((element) => element.uid == uid);
    users[index].muted = true;
    users.refresh();
  }

  unMuteUser(int uid) {
    agoraEngine!.muteRemoteAudioStream(uid, false);
    int index = users.indexWhere((element) => element.uid == uid);
    users[index].muted = false;
    users.refresh();
  }

  removeRequest(String uid, List<StreamingRequestsModel> streamingList) async {
    streamingList.removeWhere((element) => element.senderUserId == uid);
    FirebaseFirestore.instance
        .collection('live_streaming_requests')
        .doc(streamingUserId.value)
        .set({
      "requests": streamingList.map((e) => e.toMap()).toList(),
    }, SetOptions(merge: true)).then((res) {
      isLoading.value = false;
      showMessage('Request Removed');
      // fetchStreamingRequests(
      //     isHost.value == false ? streamingUserId.value : userID.value);
    });
  }

  rejoinAsBroadcaster() async {
    if (agoraEngine != null) {
      agoraEngine!.setClientRole(ClientRole.Broadcaster);
    }

    isBroadcaster.value = true;
    if (agoraEngine != null) {
      agoraEngine!.leaveChannel().then((value) {
        setupVideoSDKEngine();
      });

      showDebugPrint('left channel >>>>>>');
    }
    await agoraEngine!.leaveChannel();
    await agoraEngine!.destroy();
    await _client!.destroy();
    await channel!.leave();
    Navigator.pushReplacement(
        Get.context!,
        MaterialPageRoute(
          builder: (context) => LivePartenerScreen(
              false,
              streamingUserId.value,
              "",
              remoteUid.value.toString(),
              true,
              hostId.value.toString(),
              channelName.value),
        ));

    // controller.fetchAudienceData(controller.streamingUserId.value);
    if (agoraEngine != null) {
      await agoraEngine!.leaveChannel();
      await agoraEngine!.destroy();
    }
    agoraEngine = await RtcEngine.createWithContext(
        RtcEngineContext(ApiEndPoints.agoraAppId));
    print('~~~~~~~~~~~~~~');
    print('~~~~~~~~~~~~~~');
    print('~~~~~~~~~~~~~~');
    print('~~~~~~~~~~~~~~');
    if (agoraEngine != null) {
      agoraEngine!.setClientRole(ClientRole.Broadcaster);
    }

    // Get.to(() => LivePartnerScreen(true, "", "", remoteUid.value.toString(),
    //     true, hostId.value.toString()));
  }

  rejoinAsAudience() async {
    if (agoraEngine != null) {
      agoraEngine!.setClientRole(ClientRole.Audience);
    }
  }

  acceptRequest(String uid, List<StreamingRequestsModel> streamingList,
      StreamingRequestsModel model) async {
    streamingList.removeWhere((element) => element.senderUserId == uid);
    await FirebaseFirestore.instance
        .collection('live_streaming_requests')
        .doc(streamingUserId.value)
        .set({
      "requests": streamingList.map((e) => e.toMap()).toList(),
    }, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection('accepted_live_request')
        .doc(streamingUserId.value)
        .set({
      "requests": FieldValue.arrayUnion([
        {'senderId': uid, 'accepted': true, 'uid': int.parse(model.remoteID!)}
      ]),
    }, SetOptions(merge: true)).then((res) {
      isLoading.value = false;
      showMessage('Request Accepted');
      // fetchStreamingRequests(
      //     isHost.value == false ? streamingUserId.value : userID.value);
    });
  }

  Future removeRequests() async {
    try {
      FirebaseFirestore.instance
          .collection('live_streaming_requests')
          .doc(streamingUserId.value)
          .delete();
    } catch (e) {}
  }

  Future<void> setupVideoSDKEngine() async {
    await [Permission.microphone, Permission.camera].request();
    users.clear();
    //create an instance of the Agora engine

    agoraEngine = await RtcEngine.createWithContext(
        RtcEngineContext(ApiEndPoints.agoraAppId));

    Future.delayed(const Duration(seconds: 2), () async {
      agoraEngine!.enableVideo();
      agoraEngine!.setChannelProfile(ChannelProfile.LiveBroadcasting);

      // Register the event handler
      // if (isHost.value == true) {
      //   streamingUserId.value = userID.value;
      //   updateLiveStreamingData();
      // }

      agoraEngine!.setEventHandler(
        RtcEngineEventHandler(
          joinChannelSuccess: (channel, uidd, elapsed) {
            showMessage("Local user uid:$uidd joined the channel");
            showDebugPrint(
                "connection.localUid id is -remoteUid1---------------  $uidd");

            uid.value = uidd;
            isJoined.value = true;

            // if (isHost.value == true) {
            streamingUserId.value = userID.value;
            updateLiveStreamingData();
            //}
          },
          userJoined: (uidd, elapsed) {
            print("Remote user uid:$uidd joined the channel");
            showMessage("Remote user uid:$uidd joined the channel");
            // if (groupStreaming.value == true) {

            users.add(StreamUser(uid: uidd, muted: false));
            //   }

            remoteUid.value = uidd;
            //    addStreamingAudience();
            showDebugPrint("Remote id is -remoteUid1---------------  $uidd");
            users.refresh();
          },
          userOffline: (uidd, elapsed) {
            users.removeWhere((element) => element.uid == uidd);
            users.refresh();
            // showMessage("Remote user uid:$remoteUid left the channel");
            remoteUid.value = 1;
          },
          clientRoleChanged: (oldRole, newRole) {
            var attribute = List<AgoraRtmChannelAttribute>.generate(1, (index) {
              return AgoraRtmChannelAttribute(
                  ApiEndPoints.agoraAppKey, agoraChatId.value.toString());
            });
            //Updating the channel attributes

            if (channel != null && _client != null) {
              _client?.addOrUpdateChannelAttributes(
                  channelName.value, attribute, true);
              isBroadcaster.value = true;
            }
          },
          leaveChannel: (stats) {
            users.clear();
            users.refresh();
            // showMessage("left channel");
          },

          // clientRoleChanged: (oldRole, newRole) {
          //   showDebugPrint('------------------------');
          //   showDebugPrint('------------------------');
          //   showDebugPrint('------------------------');
          //   showDebugPrint(
          //       '${oldRole.name}   ${oldRole.index}   ${newRole.name}    ${newRole.index}');
          //   showDebugPrint('------------------------');
          //   showDebugPrint('------------------------');
          //   if (newRole.name == 'Broadcaster' && !isHost.value) {
          //     users.add(uid.value);
          //     users.refresh();
          //   }
          // },
          streamMessage: (_, __, message) {
            final String info = "here is the message $message";
            showMessage(info);
          },
          streamMessageError: (_, __, error, ___, ____) {
            final String info = "here is the error $error";
            showMessage(info);
          },
        ),
      );

      join();
    });
  }

  void join() async {
    // Set channel options
    try {
      // Set channel profile and client role
      if (isHost.value == true || isBroadcaster.value == true) {
        agoraEngine!.setClientRole(ClientRole.Broadcaster);
        agoraEngine!.startPreview();
      } else {
        agoraEngine!.setClientRole(ClientRole.Audience);
      }
      isLoadingVideoView.value = true;
      int time = DateTime.now().millisecondsSinceEpoch;

      agoraChatId.value =
          int.parse(time.toString().substring(3, time.toString().length));

      // store.write(agoraUid, agoraChatId.value);
      await fetchRtcToken(
        agoraChatId.value,
        channelName.value,
      );

      await fetchRtmToken(
        agoraChatId.value,
        channelName.value,
      );
      showDebugPrint(
          '~~~1111~${agoraChatId.value.toString()}   ${rtmToken.value}');
      await _client?.login(rtmToken.value, agoraChatId.value.toString());

      channel = await _createChannel(channelName.value);

      await channel!.join();
      agoraEngine!.joinChannel(token.value, channelName.value, null,
          agoraChatId.value, ChannelMediaOptions());
      showDebugPrint("-------------check is token is expired--------------");
      initAgoraChatSDK();
    } catch (e) {
      showDebugPrint('~~~~~~~~~~$e');
    }
  }

  Future<void> fetchRtcToken(
    int uid,
    String channelName,
  ) async {
    // Prepare the Url

    String tokenRole = 'publisher';

    String url = '$tokenUrl/rtc/$channelName/publisher/uid/$uid/?expiry=3600';

    showDebugPrint('~~~~url >>>$url');
    // Send the request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response.body);
      String newToken = json['rtcToken'];
      debugPrint('Token Received: $newToken');
      // Use the token to join a channel or renew an expiring token
      token.value = newToken;
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }

  Future<void> fetchRtmToken(
    int uid,
    String channelName,
  ) async {
    // Prepare the Url

    String rtmUrl = '$tokenUrl/rtm/${agoraChatId.value}/?expiry=3600';
    showDebugPrint('!#####$rtmUrl');

    final response2 = await http.get(Uri.parse(rtmUrl));
    showDebugPrint('!!~~~~~~~~~#####${response2.body}');

    if (response2.statusCode == 200) {
      // If the server returns an OK response, then parse the JSON.
      Map<String, dynamic> json = jsonDecode(response2.body);
      String newToken = json['rtmToken'];
      debugPrint('Token Received: $newToken');
      // Use the token to join a channel or renew an expiring token
      rtmToken.value = newToken;
    } else {
      // If the server did not return an OK response,
      // then throw an exception.
      throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid');
    }
  }

  void leave() {
    isJoined.value = false;
    remoteUid.value = 1;
    users.clear();
    goOffline();
  }

  /*--------------------VIDEO STREAMING END--------------------------------*/
  /*--------------------AGORA CHAT START--------------------------------*/

  void initAgoraChatSDK() async {
    // ChatOptions options = ChatOptions(
    //   appKey: ApiEndPoints.agoraAppKey,
    //   autoLogin: true,
    // );
    // await ChatClient.getInstance.init(options);

    if (store.read(userName) != null) {
      signInToAgora(store.read(userName));
      // addChatListener();
    }
  }

  void signInToAgora(String userId) async {
    try {
      // await fetchRtmToken(
      //   agoraChatId.value,
      //   channelName.value,
      // );
      // showDebugPrint(
      //     '~~~1111~${agoraChatId.value.toString()}   ${rtmToken.value}');
      // await _client?.login(rtmToken.value, agoraChatId.value.toString());
      // showDebugPrint('Login success: $userId');

      // await ChatClient.getInstance
      //     .login(agoraChatId.value.toString(), rtmToken.value, false);
      // _addLogToConsole("login succeed, userId: $userId");
      // joinChatRoom("210795849908225");
    } on ChatError catch (e) {
      _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
      //  getAgoraRegisterApi(agoraAppChatToken.value, userId.value);
    }
    //  joinChatRoom("1234567890");
  }

  void addChatListener() {
    ChatClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      ChatEventHandler(onMessagesReceived: onMessagesReceived),
    );
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            _addLogToConsole(
              "receive text message: ${body.content}, from: ${msg.from}",
            );
            chatList
                .add(ChatModel(msg.from.toString(), body.content, colorYellow));
            chatList.refresh();
            /*    Timer(
                const Duration(milliseconds: 500),
                    () => scrollController.value
                    .jumpTo(scrollController.value.position.maxScrollExtent));*/
          }
          break;
        case MessageType.IMAGE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VIDEO:
          {
            _addLogToConsole(
              "receive video message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.LOCATION:
          {
            _addLogToConsole(
              "receive location message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.VOICE:
          {
            _addLogToConsole(
              "receive voice message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.FILE:
          {
            _addLogToConsole(
              "receive image message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CUSTOM:
          {
            _addLogToConsole(
              "receive custom message, from: ${msg.from}",
            );
          }
          break;
        case MessageType.CMD:
          {
            // Receiving command messages does not trigger the `onMessagesReceived` event, but triggers the `onCmdMessagesReceived` event instead.
          }
          break;
      }
    }
  }

  void sendMessage() async {
    await FirebaseFirestore.instance
        .collection('stream_chat')
        .doc(streamingUserId.value)
        .collection('messages')
        .add({
      'message': messageController.value.text,
      'userId': store.read(userId),
      'userName': store.read(userName),
      'date': Timestamp.fromDate(DateTime.now())
    });
    messageController.value.clear();
  }

  Future clearMessages() async {
    print('~~~~~~~~~~~');
    print('cleaning ${userID.value}');
    print('~~~~~~~~~~~');

    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    var collection = instance
        .collection('stream_chat')
        .doc(userID.value)
        .collection('messages');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future clearAccepted() async {
    if (userID.value.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('accepted_live_request')
          .doc(userID.value)
          .delete();
    }
  }

  // void sendMessage() async {
  //   var firstAttempt = true;
  //   if (messageController.value.text == "") {
  //     _addLogToConsole("single chat id or message content is null");
  //     showMessage(enterAChatMessage.tr);
  //     return;
  //   } else {
  //     var msg = ChatMessage.createTxtSendMessage(
  //         targetId: "101",
  //         content: messageController.value.text,
  //         chatType: ChatType.Chat);

  //     ChatClient.getInstance.chatManager.addMessageEvent(
  //         "UNIQUE_HANDLER_ID",
  //         ChatMessageEvent(
  //           onSuccess: (msgId, msg) {
  //             _addLogToConsole("send message: ${messageController.value.text}");
  //             ChatTextMessageBody body = msg.body as ChatTextMessageBody;
  //             chatList
  //                 .add(ChatModel(store.read(userName), body.content, colorRed));
  //             chatList.refresh();
  //             Timer(
  //                 const Duration(milliseconds: 500),
  //                 () => scrollController.value
  //                     .jumpTo(scrollController.value.position.maxScrollExtent));
  //             messageController.value.clear();
  //           },
  //           onProgress: (msgId, progress) {
  //             _addLogToConsole("send message succeed");
  //           },
  //           onError: (msgId, msg, error) {
  //             _addLogToConsole(
  //               "send message failed, code: ${error.code}, desc: ${error.description}",
  //             );
  //             if (error.code == 500 && firstAttempt) {
  //               sendMessage();
  //               firstAttempt = false;
  //             }
  //           },
  //         ));

  //     ChatClient.getInstance.chatManager.sendMessage(msg);
  //   }
  // }

  void _addLogToConsole(String log) {
    showDebugPrint("message agora -----------------------   $log");
  }

  Future<void> joinChatRoom(String roomId) async {
    try {
      await ChatClient.getInstance.chatRoomManager.joinChatRoom(roomId);
    } on ChatError catch (e) {
      showDebugPrint("room join failure ---- $e");
    }
  }

  Future<void> leaveChatRoom(String roomId) async {
    try {
      await ChatClient.getInstance.chatRoomManager.leaveChatRoom(roomId);
    } on ChatError catch (e) {
      showDebugPrint("room leave failure ---- $e");
    }
  }

  /*--------------------AGORA CHAT END--------------------------------*/
  /*--------------------FIREBASE DATA FETCHING START--------------------------------*/
  void goOffline() async {
    if (isBroadcaster.value) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('accepted_live_request')
              .doc(streamingUserId.value)
              .get();

      if (documentSnapshot.exists &&
          documentSnapshot.data() != null &&
          documentSnapshot.data()!['requests'] != null) {
        List list = documentSnapshot.data()!['requests'];
        list.removeWhere((element) => element['senderId'] == userID.value);
        await FirebaseFirestore.instance
            .collection('accepted_live_request')
            .doc(streamingUserId.value)
            .update({'requests': list});
      }
    }
    await removeRequests();
    await clearAccepted();
    await clearMessages();
    if (userID.value.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("live_streaming")
          .doc(userID.value)
          .delete()
          .then((value) {
        showMessage(postDeletedSuccessfully.tr);
        isLoading.value = false;
      });
    } else {
      showMessage(postDeletedSuccessfully.tr);
      isLoading.value = false;
    }
    await agoraEngine!.destroy();
  }

  Future<void> updateLiveStreamingData() async {
    showDebugPrint("inside the update live streaming data-------------------");
    await FirebaseFirestore.instance
        .collection('live_streaming')
        .doc(userID.value)
        .set({
      "user_id": userID.value,
      "agora_user_id": uid.value,
      "streaming_token": token.value,
      "streaming_channel": channelName.value,
      "chat_token": chatToken.value,
      "user_image": userData.value.profileImage,
      "user_name": userData.value.username,
    }, SetOptions(merge: true)).then((res) {
      isLoading.value = false;
      // showMessage(dataUpdatedSuccessfully.tr);
    });
  }

  Future<void> addStreamingAudience() async {
    streamingAudienceList.add(LiveAudienceModel(remoteUid.value.toString()));
    await FirebaseFirestore.instance
        .collection('live_audience')
        .doc(userID.value)
        .set({
      "requests": streamingAudienceList.value.map((e) => e.toMap()).toList(),
    }, SetOptions(merge: true)).then((res) {
      isLoading.value = false;
      streamingAudienceList.refresh();
      showMessage(dataUpdatedSuccessfully.tr);
    });
  }

  // fetchAudienceData(String userID) async {
  //   print("fetch user id audience ------------>  $userID");
  //   fetchFollowingRequests(userID);
  //   // fetchFollowers(userID);
  //   await FirebaseFirestore.instance
  //       .collection("live_audience")
  //       .doc(userID)
  //       .get()
  //       .then((value) {
  //     streamingAudienceList.clear();
  //     if (value.data() != null && value.data()!['requests'] != null) {
  //       if (value.data()!['requests'] != null &&
  //           value.data()!['requests'] != []) {
  //         for (int j = 0; j < value.data()!['requests'].length; j++) {
  //           streamingAudienceList
  //               .add(LiveAudienceModel(value.data()!['requests'][j]['userId']));
  //         }
  //       }
  //     }
  //     streamingAudienceList.refresh();
  //     Future.delayed(Duration(seconds: 2), () {
  //       if (groupStreaming.value == true) {
  //         print(
  //             "firebase remote user id ------->  ${streamingAudienceList.value[0].userId.toString()}");
  //         users.value
  //             .add(int.parse(streamingAudienceList.value[0].userId.toString()));
  //         users.refresh();
  //       }
  //     });
  //   });
  // }

  fetchUserData(String userID) async {
    isLoading.value = true;
    fetchFollowingRequests(userID);
    // fetchFollowers(userID);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .get()
        .then((value) {
      var videoList = <Videos>[];
      if (value.data() != null && value.data()!['videos'] != null) {
        if (value.data()!['videos'] != null && value.data()!['videos'] != []) {
          for (int j = 0; j < value.data()!['videos'].length; j++) {
            videoList.add(Videos(value.data()!['videos'][j]['video']));
          }
        }
      }
      userData.value.id = value.data() != null ? value.data()!['userId'] : "";
      userData.value.userId =
          value.data() != null ? value.data()!['userId'] : "";
      userData.value.username =
          value.data() != null ? value.data()!['username'] : "";
      userData.value.password =
          value.data() != null ? value.data()!['password'] : "";
      userData.value.phoneNumber =
          value.data() != null ? value.data()!['phoneNumber'] : "";
      userData.value.profileImage =
          value.data() != null ? value.data()!['profileImage'] : "";
      userData.value.age = value.data() != null ? value.data()!['age'] : "";
      userData.value.state = value.data() != null ? value.data()!['state'] : "";
      userData.value.nationality =
          value.data() != null ? value.data()!['nationality'] : "";
      userData.value.web = value.data() != null ? value.data()!['web'] : "";
      userData.value.email = value.data() != null ? value.data()!['email'] : "";
      userData.value.store = value.data() != null ? value.data()!['store'] : "";
      userData.value.videos = videoList;
      userData.refresh();
      isLoading.value = false;
    });
  }

  fetchFollowingRequests(String userID) async {
    await FirebaseFirestore.instance
        .collection("follow_request")
        .doc(userID)
        .get()
        .then((value) {
      if (value.data() != null && value.data()!['requests'] != null) {
        if (value.data()!['requests'] != null &&
            value.data()!['requests'] != []) {
          for (int j = 0; j < value.data()!['requests'].length; j++) {
            followRequests.add(Followers(
                value.data()!['requests'][j]['userId'],
                value.data()!['requests'][j]['username'],
                value.data()!['requests'][j]['userImage'],
                value.data()!['requests'][j]['userCountry']));
          }
        }
      }
      followRequests.refresh();
    });
  }

  fetchStreamingRequests(String userID) async {
    // streamingRequestsStream = FirebaseFirestore.instance
    //     .collection('live_streaming_requests')
    //     .doc(userID)
    //     .snapshots();
    // streamingRequestsList.clear();
    // await FirebaseFirestore.instance
    //     .collection("live_streaming_requests")
    //     .doc(userID)
    //     .get()
    //     .then((value) {
    //   if (value.data() != null && value.data()!['requests'] != null) {
    //     if (value.data()!['requests'] != null &&
    //         value.data()!['requests'] != []) {
    //       for (int j = 0; j < value.data()!['requests'].length; j++) {
    //         streamingRequestsList.add(StreamingRequestsModel(
    //           value.data()!['requests'][j]['senderUserId'],
    //           value.data()!['requests'][j]['receiverUserId'],
    //           value.data()!['requests'][j]['senderUsername'],
    //           value.data()!['requests'][j]['senderUserCountry'],
    //           value.data()!['requests'][j]['senderUserImage'],
    //           value.data()!['requests'][j]['streamingToken'],
    //           value.data()!['requests'][j]['streamingChannel'],
    //           value.data()!['requests'][j]['chatToken'],
    //           value.data()!['requests'][j]['remoteID'],
    //           value.data()!['requests'][j]['hostID'],
    //         ));
    //       }
    //     }
    //   }
    //   streamingRequestsList.refresh();
    //   checkIfUserExistsInRequests();
    // });

    // Future.delayed(const Duration(seconds: 10), () {
    //   fetchStreamingRequests(userID);
    // });
  }

  // fetchFollowers(String userID) async {
  //   showDebugPrint("User id is ---->  $userID");
  //   await FirebaseFirestore.instance
  //       .collection("followers")
  //       .doc(userID)
  //       .get()
  //       .then((value) {
  //     if (value.data() != null && value.data()!['requests'] != null) {
  //       if (value.data()!['requests'] != null &&
  //           value.data()!['requests'] != []) {
  //         for (int j = 0; j < value.data()!['requests'].length; j++) {
  //           myClientsList.value.add(Followers(
  //               value.data()!['requests'][j]['userId'],
  //               value.data()!['requests'][j]['username'],
  //               value.data()!['requests'][j]['userImage'],
  //               value.data()!['requests'][j]['userCountry']));
  //         }
  //       }
  //     }
  //     myClientsList.refresh();
  //     checkIfUserExistsInFollowers();
  //   });
  // }

  Future<void> getUserData() async {
    Future.delayed(const Duration(seconds: 1), () {
      userID.value = store.read(userId) ?? "";
      showDebugPrint("user id---------->  $userID");
      showDebugPrint("streamingUserId id---------->  $streamingUserId");
      enableTextField.value = isHost.value;

      if (userID.value != "") {
        if (isHost.value) {
          sendNotifications();
        }
        fetchUserData(
            isHost.value == false ? streamingUserId.value : userID.value);

        if (streamingUserId.value.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('accepted_live_request')
              .doc(streamingUserId.value)
              .snapshots()
              .listen((querySnapshot) {
            if (querySnapshot.exists &&
                querySnapshot.data() != null &&
                querySnapshot.data()!['requests'] != null) {
              List list = querySnapshot.data()!['requests'];

              int index = list.indexWhere((element) =>
                  element['senderId'] != null &&
                  element['senderId'] == userID.value &&
                  element['accepted'] != null &&
                  element['accepted'] == true);

              int index2 = list.indexWhere((element) =>
                  element['senderId'] != null &&
                  element['senderId'] == userID.value &&
                  element['accepted'] != null &&
                  element['accepted'] == false);
              if (index != -1 && agoraEngine != null) {
                rejoinAsBroadcaster();
              } else if (index2 != -1) {
                rejoinAsAudience();
              }
            }
          });
        }
        if (agoraEngine == null) {
          setupVideoSDKEngine();
          _createClient();
        }

        // fetchStreamingRequests(
        //     isHost.value == false ? streamingUserId.value : userID.value);
      } else {
        showLoginDialog();
      }
    });
  }

  /*--------------------FIREBASE DATA FETCHING END--------------------------------*/

  Future<void> backPressButton() async {
    try {
      if (agoraEngine != null) {
        await agoraEngine!.leaveChannel();
      }
    } catch (e) {}

    // await ChatClient.getInstance.logout();

    leave();
    Get.back();
  }

  removeUserFromLive(int uid) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('accepted_live_request')
            .doc(streamingUserId.value)
            .get();

    List list = documentSnapshot.data()!['requests'];
    int index = list.indexWhere((element) => element['uid'] == uid);
    if (index != -1) {
      list[index]['accepted'] = false;

      await FirebaseFirestore.instance
          .collection('accepted_live_request')
          .doc(streamingUserId.value)
          .update({'requests': list});
    }
    showDebugPrint('~~~~~~~~~~');
    showDebugPrint(list.toSet().toString());
    showDebugPrint(uid.toString());

    showDebugPrint('~~~~~~~~~~');

    // FirebaseFirestore.instance
    //     .collection('accepted_live_request')
    //     .doc(streamingUserId.value)
    //     .set({
    //   "requests": list,
    // }, SetOptions(merge: true)).then((res) {
    //   isLoading.value = false;
    //   showMessage('User Removed');
    //   // fetchStreamingRequests(
    //   //     isHost.value == false ? streamingUserId.value : userID.value);
    // });
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
                  headingText(pleaseLoginFirstToJoinALive.tr,
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
                            Get.off(() => LoginScreen());
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

  Future<void> storeButtonClick(String url) async {
    if (url == "") {
      url = "https://www.google.com/";
    }

    if (!await launchUrl(Uri.parse(url))) {
      showDebugPrint('Could not launch =======');
    }
  }

  followButtonClick(
    ProfileModel userDetails,
  ) {
    var followerUserid = "";
    var followerUsername = "";
    var followerUserCountry = "";
    var followerUserImage = "";

    List<Followers> followers = [];

    FirebaseFirestore.instance
        .collection("users")
        .doc(userID.value)
        .get()
        .then((value) async {
      followerUserid = value.data() != null ? value.data()!['userId'] : "";
      followerUsername = value.data() != null ? value.data()!['username'] : "";
      followerUserImage =
          value.data() != null && value.data()!['profileImage'] != null
              ? value.data()!['profileImage']
              : "";
      followerUserCountry =
          value.data() != null && value.data()!['nationality'] != null
              ? value.data()!['nationality']
              : "";

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('followers')
              .doc(streamingUserId.value)
              .get();

      if (documentSnapshot.exists &&
          documentSnapshot.data() != null &&
          documentSnapshot.data()!['requests'] != null) {
        List<dynamic> list = documentSnapshot.data()!['requests'];
        followers = list.map((e) => Followers.fromJson(e)).toList();
      } else {
        followers = [];
      }

      followers.add(Followers(followerUserid, followerUsername,
          followerUserImage, followerUserCountry));

      FirebaseFirestore.instance
          .collection('followers')
          .doc(streamingUserId.value)
          .set({
        "requests": followers.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true)).then((res) {
        showMessage(dataUpdatedSuccessfully.tr);
      });
      // FirebaseFirestore.instance
      //     .collection('follow_request')
      //     .doc(streamingUserId.value)
      //     .set({
      //   "requests": followRequests.value.map((e) => e.toMap()).toList(),
      // }, SetOptions(merge: true)).then((res) {
      //   isLoading.value = false;
      //   // followText.value = following.tr;
      //   FirebaseFirestore.instance
      //       .collection('followers')
      //       .doc(streamingUserId.value)
      //       .set({
      //     "requests": followRequests.value.map((e) => e.toMap()).toList(),
      //   }, SetOptions(merge: true)).then((res) {
      //     showMessage(dataUpdatedSuccessfully.tr);
      //   });
      // });
    });
  }

  unfollowButtonClick(
    ProfileModel userDetails,
  ) {
    var followerUserid = "";
    var followerUsername = "";
    var followerUserCountry = "";
    var followerUserImage = "";

    List<Followers> followers = [];

    FirebaseFirestore.instance
        .collection("users")
        .doc(userID.value)
        .get()
        .then((value) async {
      followerUserid = value.data() != null ? value.data()!['userId'] : "";
      followerUsername = value.data() != null ? value.data()!['username'] : "";
      followerUserImage =
          value.data() != null && value.data()!['profileImage'] != null
              ? value.data()!['profileImage']
              : "";
      followerUserCountry =
          value.data() != null && value.data()!['nationality'] != null
              ? value.data()!['nationality']
              : "";

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('followers')
              .doc(streamingUserId.value)
              .get();

      if (documentSnapshot.exists &&
          documentSnapshot.data() != null &&
          documentSnapshot.data()!['requests'] != null) {
        List<dynamic> list = documentSnapshot.data()!['requests'];
        followers = list.map((e) => Followers.fromJson(e)).toList();
      } else {
        followers = [];
      }

      followers.removeWhere((element) => element.userId == followerUserid);

      FirebaseFirestore.instance
          .collection('followers')
          .doc(streamingUserId.value)
          .set({
        "requests": followers.map((e) => e.toMap()).toList(),
      }, SetOptions(merge: true)).then((res) {
        showMessage(dataUpdatedSuccessfully.tr);
      });
    });
  }

  // checkIfUserExistsInRequests() {
  //   int index = streamingRequestsList
  //       .indexWhere((element) => element.senderUserId == userID.value);
  //   joinRequestSent.value = index != -1;
  // }

  // checkIfUserExistsInFollowers() {
  //   int index =
  //       myClientsList.indexWhere((element) => element.userId == userID.value);
  //   followText.value = index != -1 ? following.tr : follow.tr;
  // }

  sendLiveStreamingRequest(List<StreamingRequestsModel> streamingRequestsList) {
    showDebugPrint("userid ------------->  ${userID.value}");

    isLoading.value = true;
    streamingRequestsList.add(StreamingRequestsModel(
        userID.value,
        streamingUserId.value,
        GetStorage().read(userName),
        GetStorage().read(userCountry),
        GetStorage().read(userImage),
        token.value,
        channelName.value,
        chatToken.value,
        agoraChatId.value.toString(),
        remoteUid.value.toString()));

    FirebaseFirestore.instance
        .collection('live_streaming_requests')
        .doc(streamingUserId.value)
        .set({
      "requests": streamingRequestsList.map((e) => e.toMap()).toList(),
    }, SetOptions(merge: true)).then((res) {
      isLoading.value = false;
      showMessage(requestSent.tr);
      fetchStreamingRequests(
          isHost.value == false ? streamingUserId.value : userID.value);
    });
    //});
  }

  // Future<void> checkLiveRequestAcceptance() async {
  //   Future.delayed(Duration(seconds: 15), () async {
  //     await FirebaseFirestore.instance
  //         .collection("accepted_live_request")
  //         .doc(userID.value)
  //         .get()
  //         .then((value) {
  //       showDebugPrint(
  //           "-----------------sender id user ------- ${userID.value}");
  //       if (value.data() != null &&
  //           value.data()!['senderId'] != null &&
  //           value.data()!['senderId'] == userID.value) {
  //         showDebugPrint(
  //             "-----------------sender id ------- ${value.data()!['senderId']}");
  //         isPartnerJoin.value = true;

  //         Get.to(() => LivePartnerScreen(true, "", "",
  //             remoteUid.value.toString(), true, hostId.value.toString()));
  //       } else {
  //         checkLiveRequestAcceptance();
  //       }
  //     });
  //   });
  // }

/*void tokenGeneration(){
    streamingToken.value = RtcTokenBuilder.build(
      appId: ApiEndPoints.agoraAppId,
      appCertificate: ApiEndPoints.agoraAppCertificates,
      channelName: channelName,
      uid: "101",
      role: RtcRole.publisher,
      expireTimestamp: 1710397585,
    );

    showDebugPrint("Generated token is -> ------------   ${streamingToken.value}");
  }*/

/* void getAgoraRegisterApi(String appToken, String userId) {
    GoLiveRepo().agoraRegisterUser(appToken, userId).then((value) async {
      if (value.applicationName != "") {
        try {
          await ChatClient.getInstance.loginWithAgoraToken(
           userId,
            chatToken.value,
          );
          _addLogToConsole("login succeed, userId: $userId");
        } on ChatError catch (e) {
          _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
        }
      } else {
        return;
      }
    });
  }*/
}

class StreamUser {
  int uid;
  bool muted;
  StreamUser({
    required this.uid,
    required this.muted,
  });
}
