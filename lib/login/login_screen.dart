import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';
import 'package:streaming_post_demo/register/register_screen.dart';

import '../common/size_config.dart';
import '../common/widgets.dart';
import '../constants/app_colors.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  var controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: colorWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 4,
                  ),
                  Center(
                    child: headingText(
                        login.tr, SizeConfig.blockSizeHorizontal * 7, appColor,
                        weight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 5,
                  ),
                  headingText(
                      name.tr, SizeConfig.blockSizeHorizontal * 3.5, colorBlack,
                      weight: FontWeight.w600),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 6,
                    child: TextFormField(
                      controller: controller.nameController.value,
                      cursorColor: colorRed,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.bottom,
                      style: const TextStyle(color: colorBlack),
                      decoration: InputDecoration(
                        hintText: name.tr,
                        hintStyle: const TextStyle(color: colorGrey),
                        filled: true,
                        fillColor: colorWhite,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: colorGrey, width: 0.7),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: colorGrey),
                        ),
                        errorBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(color: colorRed),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 4,
                  ),
                   headingText(
                      phoneNumber.tr, SizeConfig.blockSizeHorizontal * 3.5, colorBlack,
                      weight: FontWeight.w600),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  InkWell(
                    onTap: (){

                    },
                    child: SizedBox(
                      height: SizeConfig.blockSizeVertical * 6,
                      child: TextFormField(
                        controller: controller.phoneController.value,
                        cursorColor: colorRed,
                        maxLines: 1,
                        textAlignVertical: TextAlignVertical.bottom,
                        style: const TextStyle(color: colorBlack),
                        decoration: InputDecoration(
                          hintText: phoneNumberHint.tr,
                          hintStyle: const TextStyle(color: colorGrey),
                          filled: true,
                          fillColor: colorWhite,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: colorGrey, width: 0.7),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: colorGrey),
                          ),
                          errorBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: colorRed),
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 4,
                  ),
                  headingText(
                      password.tr, SizeConfig.blockSizeHorizontal * 3.5, colorBlack,
                      weight: FontWeight.w600),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 6,
                    child: TextFormField(
                      controller: controller.passwordController.value,
                      obscureText: true,
                      cursorColor: colorRed,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.bottom,
                      style: const TextStyle(color: colorBlack),
                      decoration: InputDecoration(
                        hintText: password.tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: colorWhite,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: colorGrey, width: 0.7),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: colorGrey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 3,
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                           controller.loginToFirebase();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 15.0,
                        ),
                        child: SizedBox(
                            width: SizeConfig.screenWidth / 1.5,
                            height: SizeConfig.blockSizeVertical * 6,
                            child: Center(
                                child: headingText(
                                    login.tr,
                                    SizeConfig.blockSizeHorizontal * 4,
                                    colorWhite)))),
                  ),
                  Obx(() =>  controller.isOtpSent.value ==true ?
                  Column(
                      children:[
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 5,
                        ),
                        headingText(
                            otpCode.tr, SizeConfig.blockSizeHorizontal * 3.5, colorBlack,
                            weight: FontWeight.w600),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 2,
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 6,
                          child: TextFormField(
                            controller: controller.otpController.value,
                            cursorColor: colorRed,
                            maxLines: 1,
                            textAlignVertical: TextAlignVertical.bottom,
                            style: const TextStyle(color: colorBlack),
                            decoration: InputDecoration(
                              hintText: otpCode.tr,
                              hintStyle: const TextStyle(color: colorGrey),
                              filled: true,
                              fillColor: colorWhite,
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: colorGrey, width: 0.7),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(color: colorGrey),
                              ),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(color: colorRed),
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 3,
                        ),
                        Center(
                          child: ElevatedButton(
                              onPressed: () {
                                controller.otpVerfication();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 15.0,
                              ),
                              child: SizedBox(
                                  width: SizeConfig.screenWidth / 1.5,
                                  height: SizeConfig.blockSizeVertical * 6,
                                  child: Center(
                                      child: headingText(
                                          verifyOtp.tr,
                                          SizeConfig.blockSizeHorizontal * 4,
                                          colorWhite)))),
                        ),]) :Container(),),
                  SizedBox(
                    height: SizeConfig.blockSizeVertical * 7,
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => RegisterScreen());
                    },
                    child: headingText(registerHere.tr,
                        SizeConfig.blockSizeHorizontal * 3.5, colorBlack,
                        weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => controller.isLoading.value == true ? commonLoader(): Container(),),
        ],
      ),
    ));
  }
}
