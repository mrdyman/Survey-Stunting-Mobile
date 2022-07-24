import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:survey_stunting/components/custom_elevated_button_icon.dart';
import 'package:survey_stunting/consts/colors.dart';

/// the default is show, to hide, pass false to show parameter
Future syncPromptDialog(BuildContext context, {bool show = true}) async {
  Size size = MediaQuery.of(context).size;
  if (show) {
    Get.defaultDialog(
      title: '',
      barrierDismissible: false,
      content: WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LottieBuilder.asset(
                'assets/anim/sync_prompt_anim.json',
                width: size.width * 0.4,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(17, 5, 17, 10),
                child: Text(
                  'Untuk beralih ke MODE ONLINE, lakukan sinkronisasi terlebih dahulu.',
                  style: TextStyle(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    overflow: TextOverflow.clip,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '* KETERANGAN *',
                  style: TextStyle(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.red[400],
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 7),
                child: Text(
                  '• Tekan "Selanjutnya" untuk melanjutkan survey dengan MODE OFFLINE',
                  style: TextStyle(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.amber,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '• Tekan "Sinkronisasi" untuk melanjutkan survey dengan MODE ONLINE',
                  style: TextStyle(
                    fontFamily: GoogleFonts.inter().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      buttonColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onCancel: () => Get.back(),
      textCancel: "Selanjutnya",
      cancelTextColor: Theme.of(context).colorScheme.primary,
      textConfirm: "Sinkronisasi",
      confirmTextColor: Colors.white,
    );
  } else {
    Navigator.pop(context);
  }
}
