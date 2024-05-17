class StreamingRequestsModel{
  String? senderUserId;
  String? receiverUserId;
  String? senderUsername;
  String? senderUserCountry;
  String? senderUserImage;
  String? streamingToken;
  String? streamingChannel;
  String? chatToken;
  String? remoteID;
  String? hostID;

  StreamingRequestsModel(this.senderUserId, this.receiverUserId, this.senderUsername,
      this.senderUserCountry, this.senderUserImage, this.streamingToken,
      this.streamingChannel,
      this.chatToken, this.remoteID, this.hostID);

  StreamingRequestsModel.fromJson(Map<String, dynamic> json) {
    senderUserId = json['senderUserId'].toString();
    receiverUserId = json['receiverUserId'].toString();
    senderUsername = json['senderUsername'].toString();
    senderUserCountry = json['senderUserCountry'].toString();
    senderUserImage = json['senderUserImage'].toString();
    streamingToken = json['streamingToken'].toString();
    streamingChannel = json['streamingChannel'].toString();
    chatToken = json['chatToken'].toString();
    remoteID = json['remoteID'].toString();
    hostID = json['hostID'].toString();

  }

  Map<String, dynamic> toMap() {
    return {
      'senderUserId': senderUserId,
      'receiverUserId': receiverUserId,
      'senderUsername': senderUsername,
      'senderUserCountry': senderUserCountry,
      'senderUserImage': senderUserImage,
      'streamingToken': streamingToken,
      'streamingChannel': streamingChannel,
      'chatToken': chatToken,
      'remoteID': remoteID,
      'hostID': hostID,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderUserId'] = senderUserId;
    data['receiverUserId'] = receiverUserId;
    data['senderUsername'] = senderUsername;
    data['senderUserCountry'] = senderUserCountry;
    data['senderUserImage'] = senderUserImage;
    data['streamingToken'] = streamingToken;
    data['streamingChannel'] = streamingChannel;
    data['chatToken'] = chatToken;
    data['remoteID'] = remoteID;
    data['hostID'] = hostID;

    return data;
  }
}

