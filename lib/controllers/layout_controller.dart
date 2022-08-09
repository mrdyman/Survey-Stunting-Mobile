import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_stunting/components/custom_elevated_button_icon.dart';
import 'package:survey_stunting/consts/colors.dart';
import 'package:survey_stunting/controllers/sync_data_controller.dart';
import 'package:survey_stunting/models/session.dart';

import '../models/localDb/helpers.dart';

import '../consts/globals_lib.dart' as global;

class LayoutController extends GetxController {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime backButtonPressedTime = DateTime.now();
  bool canExit = false;
  RxBool isDiscalimerCheck = false.obs;

  Session session = Session.fromJson(jsonDecode(GetStorage().read("session")));
  RxBool isDarkTheme = false.obs;

  var tabIndex = 0;

  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();

    bool cannotExit = !canExit ||
        currentTime.difference(backButtonPressedTime) >
            const Duration(milliseconds: 1500);

    if (cannotExit) {
      backButtonPressedTime = currentTime;
      Fluttertoast.showToast(
        msg: "Tekan sekali lagi untuk keluar",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return false;
    }
    return true;
  }

  void changeTabIndex(int index) {
    tabIndex = index;
    if (tabIndex == 3) {
      global.isFabVisible.value = false;
    } else {
      global.isFabVisible.value = true;
    }
    update();
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  Future checkConnection() async {
    log('checking connection..');
    bool connect = await global.isConnected();
    final prefs = await SharedPreferences.getInstance();
    if (connect) {
      bool firstInstall_ = await firstInstall();
      if (firstInstall_) {
        debugPrint('FIRST_INSTALL');
        showDialog(scaffoldKey.currentContext!);
        await SyncDataController(store_: Objectbox.store_).pullDataFromServer();
        prefs.setBool('first_install', false);
        Navigator.pop(scaffoldKey.currentContext!);
        showDisclaimer(scaffoldKey.currentContext!, prefs);
      } else {
        debugPrint('ALREADY INSTALLED BEFORE');
        showDialog(scaffoldKey.currentContext!);
        await SyncDataController(store_: Objectbox.store_)
            .syncData(syncAll: false);
        Navigator.pop(scaffoldKey.currentContext!);
        bool? disclaimer = prefs.getBool('isDisclaimerCheck');
        if (disclaimer == null || disclaimer == false) {
          showDisclaimer(scaffoldKey.currentContext!, prefs);
        }
      }
    }
  }

  Future<bool> firstInstall() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("first_install") ?? true;
  }

  Future isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkTheme.value = prefs.getBool("isDarkMode") ?? false;
  }

  Future setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }

  @override
  void onInit() async {
    await checkConnection();
    await isDarkMode();
    Get.changeThemeMode(
      isDarkTheme.value ? ThemeMode.dark : ThemeMode.light,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      canExit = true;
    });
    super.onInit();
  }

  void showDialog(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
  }

  void showDisclaimer(BuildContext context, SharedPreferences prefs) {
    Size size = MediaQuery.of(context).size;
    isDiscalimerCheck.value = prefs.getBool("isDisclaimerCheck") ?? false;
    Get.defaultDialog(
        title: '',
        barrierDismissible: false,
        backgroundColor: scaffoldBackground,
        content: WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LottieBuilder.asset(
                    'assets/anim/alert.json',
                    width: size.width * 0.2,
                  ),
                  Text('PERHATIAN !!!',
                      style: TextStyle(
                        fontFamily: GoogleFonts.inter().fontFamily,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      )),
                  const SizedBox(height: 10),
                  Text('Mohon Untuk meperhatikan hal berikut ini:',
                      style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 10),
                  Text(
                      '1. Pastikan untuk melakukan sinkronisasi sebelum melakukan survey pertamakali.',
                      style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(
                      '2. Jika koneksi internet kurang stabil, disarankan untuk menonaktifkan Data Cellular agar sistem beralih ke mode offline.',
                      style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(
                      '3. Setiap kali selesai melakukan survey, diwajibkan untuk melakukan pengecekan terhadap jawaban survey yang baru saja dilakukan guna memastikan jawaban survey telah benar - benar terinput pada sistem.',
                      style: TextStyle(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Obx(
                    () => CheckboxListTile(
                      title: Text("Jangan tampilkan pesan ini lagi",
                          style: TextStyle(
                              fontFamily: GoogleFonts.inter().fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      value: isDiscalimerCheck.value,
                      onChanged: (newValue) =>
                          isDiscalimerCheck.value = !isDiscalimerCheck.value,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: primaryColor,
                      visualDensity: const VisualDensity(horizontal: -4),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        confirm: CustomElevatedButtonIcon(
            label: "Ya, Saya Mengerti",
            icon: SvgPicture.asset("assets/icons/outline/information.svg",
                color: Colors.white),
            onPressed: () {
              prefs.setBool('isDisclaimerCheck', isDiscalimerCheck.value);
              Get.back();
            }));
  }
}
