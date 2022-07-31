import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:survey_stunting/consts/colors.dart';

/// the default is show, to hide, pass false to show parameter
Future loadingDialog(BuildContext context, {bool show = true}) async {
  Size size = MediaQuery.of(context).size;
  if (show) {
    Get.defaultDialog(
      title: '',
      barrierDismissible: false,
      backgroundColor: scaffoldBackground,
      content: WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Mohon tunggu..',
                  style: TextStyle(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontWeight: FontWeight.bold,
                  )),
              LottieBuilder.asset(
                'assets/anim/loading-dot.json',
                width: size.width * 0.2,
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    Navigator.pop(context);
  }
}
