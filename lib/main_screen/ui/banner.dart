import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdmob extends StatefulWidget {
  double? width, height;
  BannerAdmob({Key? key, this.width, this.height}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _BannerAdmobState();
  }
}

class _BannerAdmobState extends State<BannerAdmob> {
  late BannerAd _bannerAd;
  bool _bannerReady = false;

  final bannerAdId = Platform.isAndroid
      ? 'ca-app-pub-7968575513161002/7749256565'
      : 'ca-app-pub-7968575513161002/8070736489';

  final intrinsialAd = Platform.isAndroid
      ? 'ca-app-pub-7968575513161002/6704285123'
      : 'ca-app-pub-7968575513161002/8074643906';

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: bannerAdId,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _bannerReady = true;
          });
          print('~~~~~~~~~Ready');
        },
        onAdFailedToLoad: (ad, err) {
          setState(() {
            _bannerReady = false;
          });
          print('~~~~~~~~~Failed');

          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerReady
        ? SizedBox(
            width: widget.width != null
                ? widget.width
                : _bannerAd.size.width.toDouble(),
            height: widget.height != null
                ? widget.height
                : _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : Container();
  }
}
