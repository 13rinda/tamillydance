class LiveAudienceModel {
  String? userId;

  LiveAudienceModel(this.userId);

  LiveAudienceModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'].toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    return data;
  }
}