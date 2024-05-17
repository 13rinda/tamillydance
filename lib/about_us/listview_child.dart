import 'package:flutter/material.dart';
import 'package:streaming_post_demo/common/size_config.dart';

class AboutUsListViewChild extends StatelessWidget {
  final Widget icon;
  final Color iconBackgroundColor;
  final String title, content;

  const AboutUsListViewChild(
      {Key? key,
      required this.icon,
      required this.iconBackgroundColor,
      required this.title,
      required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: icon,
              )),
          SizedBox(width: 15),
          Container(
            height: 60,
            width: 1,
            color: Colors.grey[300],
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical / 2),
                SelectableText(
                  content,
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
