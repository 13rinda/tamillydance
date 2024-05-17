import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:streaming_post_demo/constants/api_endpoints.dart';

import '../../common/widgets.dart';
import '../../constants/storage_constants.dart';
import '../model/agora_register_model.dart';

class LiveRepo extends GetConnect{
  var store = GetStorage();


 Future<AgoraRegisterModel> agoraRegisterUser(
      String appToken, String userId) async {
    var map = {
      "username": userId,
      "password": "123456",
      "nickname": store.read(userName)
    };

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response = await post(
            "https://${ApiEndPoints.agoraHostRestApi}/${ApiEndPoints.agoraOrgName}/${ApiEndPoints.agoraAppName}/users",
            headers: {'Content-Type': "application/json",
              'Authorization': "Bearer $appToken"},
              map);

        showDebugPrint(
            "  api url --->  https://${ApiEndPoints.agoraHostRestApi}/${ApiEndPoints.agoraOrgName}/${ApiEndPoints.agoraAppName}/users \n params: $map");

        if (response.statusCode == 200) {
          showDebugPrint(
              "get register user api response----->  ${response.bodyString}");

          return AgoraRegisterModel.fromJson(response.body);
        } else {
          return AgoraRegisterModel();
        }
      } else {
        return AgoraRegisterModel();
      }
    } catch (e) {
      return AgoraRegisterModel();
    }
  }

}