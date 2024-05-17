class AgoraRegisterModel {
  String? path;
  String? uri;
  int? timestamp;
  String? organization;
  String? application;
  List<Entities>? entities;
  String? action;
  int? duration;
  String? applicationName;

  AgoraRegisterModel(
      {path,
        uri,
        timestamp,
        organization,
        application,
        entities,
        action,
        duration,
        applicationName});

  AgoraRegisterModel.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    uri = json['uri'];
    timestamp = json['timestamp'];
    organization = json['organization'];
    application = json['application'];
    if (json['entities'] != null) {
      entities = <Entities>[];
      json['entities'].forEach((v) {
        entities!.add(Entities.fromJson(v));
      });
    }
    action = json['action'];
    duration = json['duration'];
    applicationName = json['applicationName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['uri'] = uri;
    data['timestamp'] = timestamp;
    data['organization'] = organization;
    data['application'] = application;
    if (entities != null) {
      data['entities'] = entities!.map((v) => v.toJson()).toList();
    }
    data['action'] = action;
    data['duration'] = duration;
    data['applicationName'] = applicationName;
    return data;
  }
}

class Entities {
  String? uuid;
  String? type;
  int? created;
  int? modified;
  String? username;
  bool? activated;
  String? nickname;

  Entities(
      {uuid,
        type,
        created,
        modified,
        username,
        activated,
        nickname});

  Entities.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    type = json['type'];
    created = json['created'];
    modified = json['modified'];
    username = json['username'];
    activated = json['activated'];
    nickname = json['nickname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['type'] = type;
    data['created'] = created;
    data['modified'] = modified;
    data['username'] = username;
    data['activated'] = activated;
    data['nickname'] = nickname;
    return data;
  }
}