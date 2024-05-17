import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/common/size_config.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: -(SizeConfig.screenWidth * 0.5),
              left: -SizeConfig.screenWidth * 0.125,
              child: Container(
                height: SizeConfig.screenWidth * 1.2,
                width: SizeConfig.screenWidth * 1.25,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(255, 122, 196, 251),
                      Color.fromARGB(255, 109, 127, 251),
                    ], stops: [
                      0.5,
                      1
                    ]),
                    shape: BoxShape.circle),
              )),
          Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                        child: Text(termsConditions.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold))),
                  ),
                  Container(width: 50, height: 50)
                ],
              )),
          Positioned(
              top: SizeConfig.screenWidth * 0.4,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset('assets/images/saveearth.png',
                    height: SizeConfig.screenWidth * 0.5,
                    width: SizeConfig.screenWidth * 0.5),
              )),
          Positioned(
              top: SizeConfig.screenWidth * 0.9,
              left: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: SizeConfig.screenWidth,
                child: SingleChildScrollView(
                  child: Column(children: [
                    SelectableText(
                      termsText.tr,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    )
                  ]),
                ),
              ))
        ],
      ),
    );
  }
}
