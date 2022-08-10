import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_stunting/components/error_scackbar.dart';
import 'package:survey_stunting/components/success_scackbar.dart';
import 'package:survey_stunting/models/localDb/kategori_soal_model.dart';
import 'package:survey_stunting/models/nama_survey.dart';
import 'package:survey_stunting/models/responden.dart';
import 'package:survey_stunting/models/session.dart';
import 'package:survey_stunting/models/survey.dart';
import 'package:survey_stunting/models/survey_parameters.dart';
import 'package:survey_stunting/routes/route_name.dart';
import 'package:survey_stunting/services/dio_client.dart';
import 'package:survey_stunting/services/handle_errors.dart';

import '../components/loading_dialog.dart';
import '../models/localDb/helpers.dart';
import '../models/localDb/nama_survey_mode.dart';
import '../models/localDb/responden_model.dart';
import '../models/localDb/survey_model.dart';

import '../consts/globals_lib.dart' as global;

class SurveyController extends GetxController {
  final typeSurveyEditingController = TextEditingController();
  final statusSurveyEditingController = TextEditingController();
  final searchSurveyEditingController = TextEditingController();
  final respondenTEC = TextEditingController();
  final namaSurveyTEC = TextEditingController();
  final respondenError = "".obs;
  final namaSurveyError = "".obs;
  var isLoading = false.obs;
  var isLoadingFilter = false.obs;
  String typeSurvey = "";
  String statusSurvey = "";
  String kodeUnikResponden = "";
  int namaSurveyId = 0;
  var surveys = <Survey>[].obs;
  List<Responden> responden = [];
  List<NamaSurvey> namaSurvey = [];
  String token = GetStorage().read("token");
  Session session = sessionFromJson(GetStorage().read("session"));
  int userId = GetStorage().read("userId");
  late bool isConnect;

  Future getSurvey({SurveyParameters? queryParameters}) async {
    await checkConnection();
    isLoading.value = true;
    if (isConnect) {
      debugPrint('get online survey');
      try {
        List<Survey>? response = await DioClient().getSurvey(
          token: token,
          queryParameters: queryParameters,
        );
        surveys.value = response!;
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          surveys.value = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('get local survey');
      var profileData =
          await DbHelper.getProfileByUserId(Objectbox.store_, userId: userId);
      int profileId = profileData!.id!;
      List<SurveyModel>? localSurveys_ = await DbHelper.getDetailSurvey(
        Objectbox.store_,
        profileId: profileId,
        isSelesai: (statusSurvey == "selesai")
            ? 1
            : (statusSurvey == "belum_selesai")
                ? 0
                : null,
        namaSurveyId: typeSurvey,
        keyword: searchSurveyEditingController.text == ""
            ? null
            : searchSurveyEditingController.text,
      );
      surveys.value = localSurveys_
          .map((e) => Survey.fromJson(e.toJson()))
          .toList()
        ..sort((a, b) => b.id!.compareTo(a.id!));
    }
    isLoading.value = false;
  }

  Future getResponden() async {
    await checkConnection();
    if (isConnect) {
      debugPrint('get online responden');
      try {
        List<Responden>? response = await DioClient().getResponden(
          token: token,
        );
        responden = response!;
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          responden = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('get local responden');
      List<RespondenModel>? localResponden =
          await DbHelper.getResponden(Objectbox.store_);

      List<RespondenModel> tempLocalResponden = localResponden;

      for (var i = 0; i < localResponden.length; i++) {
        for (var j = i + 1; j < tempLocalResponden.length; j++) {
          if (tempLocalResponden[j].kartuKeluarga ==
              localResponden[i].kartuKeluarga) {
            tempLocalResponden.removeAt(j);
            j--;
          }
        }
      }
      tempLocalResponden.where((element) =>
          element.deletedAt == "null" || element.deletedAt == null);
      responden = tempLocalResponden
          .map((e) => Responden.fromJson(e.toJson()))
          .toList()
        ..sort((a, b) => b.id!.compareTo(a.id!));
    }
  }

  Future getNamaSurvey() async {
    await checkConnection();
    if (isConnect) {
      debugPrint('get online nama survey');
      try {
        List<NamaSurvey>? nResponse = await DioClient().getNamaSurvey(
          token: token,
        );
        if (nResponse != null) {
          List<NamaSurvey>? response =
              nResponse.where((element) => element.isAktif == 1).toList();
          namaSurvey = response;
        }
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          namaSurvey = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('message: get local nama survey');
      List<NamaSurveyModel>? nlocalNamaSurvey =
          await DbHelper.getNamaSurvey(Objectbox.store_);
      List<NamaSurveyModel> localNamaSurvey =
          nlocalNamaSurvey.where((element) => element.isAktif == 1).toList();
      namaSurvey =
          localNamaSurvey.map((e) => NamaSurvey.fromJson(e.toJson())).toList();
    }
  }

  bool validate() {
    respondenError.value = "";
    namaSurveyError.value = "";
    if (kodeUnikResponden.toString() == "") {
      respondenError.value = "Pilih responden yang terdaftar";
    }
    if (respondenTEC.text.trim() == "") {
      respondenError.value = "Responden wajib diisi";
    }
    if (namaSurveyId == 0) {
      namaSurveyError.value = "Pilih jenis survey yang terdaftar";
    }
    if (namaSurveyTEC.text.trim() == "") {
      namaSurveyError.value = "Jenis survey wajib diisi";
    }
    if (respondenError.value.isNotEmpty || namaSurveyError.value.isNotEmpty) {
      return false;
    }
    return true;
  }

  Future submitForm(BuildContext context) async {
    loadingDialog(context);
    await checkConnection();
    var profileData =
        await DbHelper.getProfileByUserId(Objectbox.store_, userId: userId);
    int profileId = profileData!.id!;
    if (validate()) {
      isLoading.value = true;
      if (isConnect) {
        debugPrint('create survey online');
        try {
          Survey data = Survey(
            kodeUnikResponden: kodeUnikResponden.toString(),
            namaSurveyId: namaSurveyId.toString(),
            profileId: profileId.toString(),
            isSelesai: "0",
          );
          List<Survey>? response =
              await DioClient().createSurvey(token: token, data: data);
          isLoading.value = false;
          if (response != null) {
            //For optimistic UI
            surveys.insert(
              0,
              response[0],
            );
            Get.back(closeOverlays: true);
            Get.toNamed(RouteName.isiSurvey, arguments: [response[0], false]);
            //also create data local
            List<SurveyModel> nSurvey =
                await DbHelper.getSurvey(Objectbox.store_);
            var survey = nSurvey.firstWhereOrNull((element) =>
                element.kodeUnikResponden.targetId ==
                    int.parse(kodeUnikResponden) &&
                element.namaSurvey.targetId == namaSurveyId);
            //local survey not found in local?
            if (survey == null) {
              List<KategoriSoalModel> kategoriSoal =
                  await DbHelper.getKategoriSoalByNamaSurveyId(Objectbox.store_,
                      namaSurveyId: namaSurveyId);
              int nextCategori = kategoriSoal[0].id!;
              SurveyModel data = SurveyModel(
                kodeUnik: int.parse(response[0].kodeUnik!),
                kodeUnikRespondenId: int.parse(kodeUnikResponden),
                namaSurveyId: namaSurveyId,
                profileId: profileId,
                isSelesai: 0,
                kategoriSelanjutnya: nextCategori,
                lastModified: DateTime.now().toString(),
              );
              await DbHelper.putSurvey(Objectbox.store_, [data]);
            }
          } else {
            loadingDialog(context, show: false);
            errorScackbar("Survey sudah pernah dibuat sebelumnya");
          }
        } on DioError catch (e) {
          loadingDialog(context, show: false);
          if (e.response?.statusCode == 302) {
            errorScackbar(
                'Survey dengan responden tersebut sudah ada. Silahkan pilih responden lain.');
          } else {
            handleError(error: e);
          }
        }
      } else {
        debugPrint('create survey offline');
        List<SurveyModel> nSurvey = await DbHelper.getSurvey(Objectbox.store_);
        var survey = nSurvey.firstWhereOrNull((element) =>
            element.kodeUnikResponden.targetId ==
                int.parse(kodeUnikResponden) &&
            element.namaSurvey.targetId == namaSurveyId);
        if (survey != null) {
          errorScackbar('Survey sudah ada');
          loadingDialog(context, show: false);
          isLoading.value = false;
          return;
        }
        List<KategoriSoalModel> kategoriSoal =
            await DbHelper.getKategoriSoalByNamaSurveyId(Objectbox.store_,
                namaSurveyId: namaSurveyId);
        int nextCategori = kategoriSoal[0].id!;
        int uniqueCode = await generateUniqueCode();
        SurveyModel data = SurveyModel(
          kodeUnik: uniqueCode,
          kodeUnikRespondenId: int.parse(kodeUnikResponden),
          namaSurveyId: namaSurveyId,
          profileId: profileId,
          isSelesai: 0,
          kategoriSelanjutnya: nextCategori,
          lastModified: DateTime.now().toString(),
        );
        await DbHelper.putSurvey(Objectbox.store_, [data]);
        isLoading.value = false;
        Get.back(closeOverlays: true);
        Get.toNamed(RouteName.isiSurvey,
            arguments: [Survey.fromJson(data.toJson()), false]);
        successScackbar("Survey berhasil disimpan");
      }
      isLoading.value = false;
    } else {
      loadingDialog(context, show: false);
    }
  }

  Future deleteSurvey({required dynamic kodeUnik}) async {
    isLoading.value = true;
    await checkConnection();
    if (isConnect) {
      debugPrint('delete online survey');
      try {
        await DioClient().deleteSurvey(
          token: token,
          kodeUnik: kodeUnik,
        );
        await DbHelper.deleteSurvey(Objectbox.store_,
            kodeUnik: int.parse(kodeUnik));
        surveys.removeWhere((element) => element.kodeUnik == kodeUnik);
        successScackbar("Survey berhasil dihapus");
      } on DioError catch (e) {
        handleError(error: e);
      }
    } else {
      debugPrint('delete local survey' + kodeUnik.toString());
      await DbHelper.deleteSurvey(Objectbox.store_,
          kodeUnik: int.parse(kodeUnik));
      surveys.removeWhere((element) => element.kodeUnik == kodeUnik);
      successScackbar("Survey berhasil dihapus");
    }
    isLoading.value = false;
  }

  void _setToEmpty() {
    if (statusSurveyEditingController.text == "") {
      statusSurvey = statusSurveyEditingController.text;
    }
    if (typeSurveyEditingController.text == "") {
      typeSurvey = "";
    }
  }

  Future<int> generateUniqueCode() async {
    debugPrint('get data list survey local');
    List<SurveyModel>? localSurvey = await DbHelper.getSurvey(Objectbox.store_);
    late int uniqueCode;
    late List kodeUnik;
    do {
      debugPrint('generate random number');
      uniqueCode = Random.secure().nextInt(89999999) + 10000000;
      kodeUnik =
          localSurvey.where((survey) => survey.kodeUnik == uniqueCode).toList();
    } while (kodeUnik.isNotEmpty);
    return uniqueCode;
  }

  Future checkConnection() async {
    isConnect = await global.isConnected();
  }

  @override
  void onInit() async {
    await checkConnection();
    await getSurvey();
    statusSurveyEditingController.addListener(_setToEmpty);
    typeSurveyEditingController.addListener(_setToEmpty);
    searchSurveyEditingController.addListener(() async {
      await getSurvey(
          queryParameters: SurveyParameters(
        search: searchSurveyEditingController.text,
        status: statusSurvey,
        namaSurveyId: typeSurvey,
      ));
    });
    super.onInit();
  }

  @override
  void dispose() {
    statusSurveyEditingController.dispose();
    typeSurveyEditingController.dispose();
    respondenTEC.dispose();
    namaSurveyTEC.dispose();
    searchSurveyEditingController.dispose();
    super.dispose();
  }
}
