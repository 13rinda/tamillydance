import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streaming_post_demo/about_us/listview_child.dart';
import 'package:streaming_post_demo/common/size_config.dart';
import 'package:streaming_post_demo/constants/string_constants.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

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
                        child: Text(aboutUs.tr,
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
                child: ListView(children: [
                  AboutUsListViewChild(
                      icon: Icon(Icons.apartment, color: Colors.white),
                      iconBackgroundColor: Colors.lightBlue[300]!,
                      title: ownerCompany.tr,
                      content: 'SPECIALIST DEVELOPER ,LLC'),
                  AboutUsListViewChild(
                      icon: Icon(Icons.location_on, color: Colors.white),
                      iconBackgroundColor: Color.fromRGBO(123, 207, 97, 1),
                      title: companyHeadquarter.tr,
                      content: 'U.S.A'),
                  AboutUsListViewChild(
                      icon: Icon(Icons.insert_drive_file_sharp,
                          color: Colors.white),
                      iconBackgroundColor: Color.fromRGBO(225, 183, 43, 1),
                      title: taxNo.tr,
                      content: ' 38-4204944'),
                  AboutUsListViewChild(
                      icon: Icon(Icons.person, color: Colors.white),
                      iconBackgroundColor: Colors.black,
                      title: authDirector.tr,
                      content: 'Nour Aldeen Alkalab'),
                  AboutUsListViewChild(
                      icon: Icon(Icons.message, color: Colors.white),
                      iconBackgroundColor: Color.fromARGB(255, 179, 9, 150),
                      title: forComplaints.tr,
                      content: 'nouraldeenalkalab1@gmail.com'),
                  AboutUsListViewChild(
                      icon: Icon(Icons.call, color: Colors.white),
                      iconBackgroundColor: Colors.blue,
                      title: call.tr,
                      content: '+14452236543'),
                  AboutUsListViewChild(
                      icon: Image.asset('assets/images/whatsapp.png',
                          height: 24, width: 24),
                      iconBackgroundColor: Colors.green,
                      title: callAndWhats.tr,
                      content: '+966557346096'),
                  AboutUsListViewChild(
                      icon: Icon(Icons.email, color: Colors.white),
                      iconBackgroundColor: Colors.red,
                      title: email.tr,
                      content: 'nouraldeenalkalab1@gmail.com')
                ]),
              ))
        ],
      ),
    );
  }
}
