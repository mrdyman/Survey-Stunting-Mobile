import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_stunting/components/error_scackbar.dart';
import 'package:survey_stunting/components/filled_text_field.dart';
import 'package:survey_stunting/components/loading_dialog.dart';
import 'package:survey_stunting/components/success_scackbar.dart';
import 'package:survey_stunting/controllers/beranda_controller.dart';
import 'package:survey_stunting/controllers/export_survey_controller.dart';
import 'package:survey_stunting/controllers/survey_controller.dart';
import 'package:survey_stunting/controllers/sync_data_controller.dart';
import 'package:survey_stunting/models/jawaban_soal.dart';
import 'package:survey_stunting/models/jawaban_survey.dart';
import 'package:survey_stunting/models/kategori_soal.dart';
import 'package:survey_stunting/models/localDb/helpers.dart';
import 'package:survey_stunting/models/localDb/kategori_soal_model.dart';
import 'package:survey_stunting/models/soal.dart';
import 'package:survey_stunting/models/soal_and_jawaban.dart';
import 'package:survey_stunting/models/survey.dart';
import 'package:survey_stunting/services/dio_client.dart';
import 'package:survey_stunting/services/handle_errors.dart';
import '../consts/globals_lib.dart' as global;
import '../models/localDb/jawaban_soal_model.dart';
import '../models/localDb/jawaban_survey_model.dart';
import '../models/localDb/soal_model.dart';
import '../models/localDb/survey_model.dart';

class IsiSurveyController extends GetxController {
  String token = GetStorage().read("token");
  Rx<String> title = "".obs;
  late int kodeUnikResponden;
  late int namaSurveyId;
  late int profileId;
  var isLoading = true.obs;
  var isLoadingNext = false.obs;
  var isLoadingPrevious = false.obs;
  late KategoriSoal currentKategoriSoal;
  late Survey survey;
  late bool isEdit;
  late List<KategoriSoal> kategoriSoal = [];
  late List<JawabanSurvey> initialJawabanSurvey = [];
  late List<JawabanSurvey> currentJawabanSurvey;
  late bool isConnect;
  final soal = RxList<Soal>();
  final soalAndJawaban = RxList<SoalAndJawaban>();
  final formKey = GlobalKey<FormState>();
  int currentOrder = 0;

  @override
  void onInit() async {
    await checkConnection();
    survey = Get.arguments[0];
    isEdit = Get.arguments[1];

    if (survey.responden == null) {
      kodeUnikResponden = int.parse(survey.kodeUnikResponden);
    } else {
      kodeUnikResponden = int.parse(survey.responden!.kodeUnik);
    }

    if (survey.namaSurvey == null) {
      namaSurveyId = int.parse(survey.namaSurveyId);
    } else {
      namaSurveyId = survey.namaSurvey!.id;
    }

    if (survey.profile == null) {
      profileId = int.parse(survey.profileId);
    } else {
      profileId = survey.profile!.id;
    }

    await getKategoriSoal();

    if (survey.kategoriSelanjutnya != null) {
      currentKategoriSoal = kategoriSoal.firstWhere(
          (element) => element.id.toString() == survey.kategoriSelanjutnya!);
    } else {
      currentKategoriSoal = kategoriSoal[0];
    }

    await getJawabanSurvey();
    title.value = currentKategoriSoal.nama;
    currentOrder = int.parse(currentKategoriSoal.urutan);

    await getSoal();
    await getJawabanSoal();
    isLoading.value = false;
    currentJawabanSurvey = [];
    super.onInit();
  }

  Future getJawabanSurvey() async {
    await checkConnection();
    if (isConnect) {
      debugPrint('get jawaban survey online');
      try {
        List<JawabanSurvey>? response = await DioClient().getJawabanSurvey(
          token: token,
          kodeUnikSurvey: survey.kodeUnik!,
          kategoriSoalId: currentKategoriSoal.id.toString(),
        );
        if (response != null) {
          initialJawabanSurvey = response;
        } else {
          initialJawabanSurvey = [];
        }
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          initialJawabanSurvey = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('get jawaban survey offline');
      try {
        List<JawabanSurveyModel> jawabanSurveyModel =
            await DbHelper.getJawabanSurveyByKodeUnikSurveyId(Objectbox.store_,
                kodeUnikSurveyId: int.parse(survey.kodeUnik!),
                kategoriSoalId: currentKategoriSoal.id);
        if (jawabanSurveyModel.isNotEmpty) {
          initialJawabanSurvey = jawabanSurveyModel
              .map((e) => JawabanSurvey.fromJson(e.toJson()))
              .toList();
        } else {
          initialJawabanSurvey = [];
        }
      } catch (e) {
        initialJawabanSurvey = [];
      }
    }
  }

  Future getKategoriSoal() async {
    // await checkConnection();
    // if (isConnect) {
    //   debugPrint('get kategori soal online');
    //   try {
    //     List<KategoriSoal>? response = await DioClient().getKategoriSoal(
    //         token: token, namaSurveyId: namaSurveyId.toString());
    //     kategoriSoal = response!;
    //   } on DioError catch (e) {
    //     handleError(error: e);
    //   }
    // } else {
    debugPrint('get kategori soal local');
    List<KategoriSoalModel> kategoriSoalModel =
        await DbHelper.getKategoriSoalByNamaSurveyId(
      Objectbox.store_,
      namaSurveyId: namaSurveyId,
    );
    kategoriSoal = kategoriSoalModel
        .map((e) => KategoriSoal.fromJson(e.toJson()))
        .toList();
    // }
  }

  Future getSoal() async {
    // await checkConnection();
    // if (isConnect) {
    //   debugPrint('get soal online');
    //   try {
    //     List<Soal>? response = await DioClient().getSoal(
    //       token: token,
    //       kategoriSoalId: currentKategoriSoal.id.toString(),
    //     );
    //     soal.value = response!;
    //   } on DioError catch (e) {
    //     handleError(error: e);
    //   }
    // } else {
    debugPrint('get soal local');
    List<SoalModel> soalModel = await DbHelper.getSoalByKategoriSoalId(
      Objectbox.store_,
      kategoriSoalId: currentKategoriSoal.id,
    );
    soal.value = soalModel.map((e) => Soal.fromJson(e.toJson())).toList();
    // }
  }

  Future getJawabanSoal() async {
    // await checkConnection();
    // if (isConnect) {
    //   debugPrint('get jawaban soal online');
    //   try {
    //     for (var item in soal) {
    //       if (item.tipeJawaban == "Jawaban Singkat") {
    //         soalAndJawaban.add(SoalAndJawaban(soal: item));
    //       } else {
    //         List<JawabanSoal>? response = await DioClient()
    //             .getJawabanSoal(token: token, soalId: item.id.toString());
    //         soalAndJawaban
    //             .add(SoalAndJawaban(soal: item, jawabanSoal: response));
    //       }
    //     }
    //   } on DioError catch (e) {
    //     handleError(error: e);
    //   }
    // } else {
    debugPrint('get jawaban soal local');
    for (var item in soal) {
      if (item.tipeJawaban == "Jawaban Singkat") {
        soalAndJawaban.add(SoalAndJawaban(soal: item));
      } else {
        List<JawabanSoalModel> jawabanSoalModel =
            await DbHelper.getJawabanSoalBySoalId(
          Objectbox.store_,
          soalId: item.id,
        );
        soalAndJawaban.add(SoalAndJawaban(
          soal: item,
          jawabanSoal: jawabanSoalModel
              .map((e) => JawabanSoal.fromJson(e.toJson()))
              .toList(),
        ));
      }
    }
    // }
  }

  Widget generateSoalUI({
    required int number,
    required String soal,
    required String typeJawaban,
    required int isNumerik,
    required int soalId,
    List<JawabanSoal>? jawabanSoal,
    required BuildContext context,
  }) {
    switch (typeJawaban) {
      case "Pilihan Ganda":
        bool isLainnya = false;
        var options = jawabanSoal!.map((value) {
          JawabanSurvey jawabanSurvey;
          var check = initialJawabanSurvey.firstWhereOrNull((element) =>
              element.soalId == soalId.toString() &&
              element.jawabanSoalId == value.id.toString());
          if (check != null) {
            jawabanSurvey = check;
          } else {
            jawabanSurvey = JawabanSurvey(
              soalId: soalId.toString(),
              kodeUnikSurvey: survey.kodeUnik.toString(),
              kategoriSoalId: currentKategoriSoal.id.toString(),
              jawabanSoalId: value.id.toString(),
            );
          }
          return FormBuilderFieldOption(
            value: jawabanSurvey,
            child: value.isLainnya == "0"
                ? Text(value.jawaban)
                : FilledTextField(
                    initialValue: jawabanSurvey.jawabanLainnya ?? "",
                    onChanged: (value) => jawabanSurvey.jawabanLainnya = value,
                    hintText: "Lainnya",
                    onSaved: (value) {},
                    validator: (jawab) {
                      if (isLainnya) {
                        if (jawab == "null" || jawab == null || jawab == "") {
                          isLainnya = false;
                          return "Jawaban Lainnya wajib diisi";
                        }
                      } else {
                        if (jawab != "") {
                          return "Kosongkan jika tidak memilih jawaban Lainnya";
                        }
                      }
                      return null;
                    },
                  ),
          );
        }).toList();

        var initalValue = initialJawabanSurvey
            .firstWhereOrNull((element) => element.soalId == soalId.toString());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$number. $soal",
              style: Theme.of(context).textTheme.headline3,
            ),
            FormBuilderRadioGroup(
              name: soalId.toString(),
              activeColor: Theme.of(context).primaryColor,
              orientation: OptionsOrientation.vertical,
              initialValue: initalValue,
              options: options,
              validator: (value) {
                if (value == null) {
                  return "Jawaban tidak boleh kosong";
                } else {
                  value as JawabanSurvey;
                  String? currentJawabanChecked = jawabanSoal
                      .firstWhereOrNull((element) =>
                          element.id == int.parse(value.jawabanSoalId!))
                      ?.jawaban;
                  if (currentJawabanChecked == "Lainnya") {
                    isLainnya = true;
                  }
                  if (isLainnya && value.jawabanLainnya == null) {
                    return "Pilih Jawaban Lainnya dan input Kembali jawaban";
                  }
                }
                return null;
              },
              onSaved: (value) async {
                value as JawabanSurvey;
                currentJawabanSurvey.add(value);
              },
            )
          ],
        );
      case "Kotak Centang":
        bool isLainnya = false;
        var options = jawabanSoal!.map((value) {
          JawabanSurvey jawabanSurvey;
          var check = initialJawabanSurvey.firstWhereOrNull((element) =>
              element.soalId == soalId.toString() &&
              element.jawabanSoalId == value.id.toString());
          if (check != null) {
            jawabanSurvey = check;
          } else {
            jawabanSurvey = JawabanSurvey(
              soalId: soalId.toString(),
              kodeUnikSurvey: survey.kodeUnik.toString(),
              kategoriSoalId: currentKategoriSoal.id.toString(),
              jawabanSoalId: value.id.toString(),
            );
          }
          return FormBuilderFieldOption(
            value: jawabanSurvey,
            child: value.isLainnya == "0"
                ? Text(value.jawaban)
                : FilledTextField(
                    initialValue: jawabanSurvey.jawabanLainnya ?? "",
                    onChanged: (value) => jawabanSurvey.jawabanLainnya = value,
                    hintText: "Lainnya",
                    onSaved: (value) {},
                    validator: (jawab) {
                      if (isLainnya) {
                        if (jawab == "null" || jawab == null || jawab == "") {
                          isLainnya = false;
                          return "Jawaban Lainnya wajib diisi";
                        }
                      } else {
                        if (jawab != "") {
                          return "Kosongkan jika tidak memilih jawaban Lainnya";
                        }
                      }
                      return null;
                    },
                  ),
          );
        }).toList();
        var initialValue = initialJawabanSurvey
            .where((e) => e.soalId == soalId.toString())
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$number. $soal",
              style: Theme.of(context).textTheme.headline3,
            ),
            FormBuilderCheckboxGroup(
              name: soalId.toString(),
              activeColor: Theme.of(context).primaryColor,
              orientation: OptionsOrientation.vertical,
              initialValue: initialValue,
              options: options,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Jawaban tidak boleh kosong";
                } else {
                  for (var item in value) {
                    item as JawabanSurvey;
                    String? currentJawabanChecked = jawabanSoal
                        .firstWhereOrNull((element) =>
                            element.id == int.parse(item.jawabanSoalId!))
                        ?.jawaban;
                    if (currentJawabanChecked == "Lainnya") {
                      isLainnya = true;
                    } else {
                      isLainnya = false;
                    }
                  }
                  return null;
                }
              },
              onSaved: (value) async {
                if (value!.isNotEmpty) {
                  for (var item in value) {
                    currentJawabanSurvey.add(item as JawabanSurvey);
                  }
                }
              },
            ),
          ],
        );
      default:
        var initialValue = initialJawabanSurvey
            .firstWhereOrNull((element) => element.soalId == soalId.toString());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledTextField(
              keyboardType: isNumerik == 1 ? TextInputType.number : null,
              inputFormatters: isNumerik == 1
                  ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                  : null,
              title: "$number. $soal",
              initialValue: initialValue?.jawabanLainnya ?? "",
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Jawaban tidak boleh kosong";
                }
                return null;
              },
              onSaved: (value) async {
                currentJawabanSurvey.add(
                  JawabanSurvey(
                    soalId: soalId.toString(),
                    kodeUnikSurvey: survey.kodeUnik.toString(),
                    kategoriSoalId: currentKategoriSoal.id.toString(),
                    jawabanLainnya: value,
                  ),
                );
              },
            ),
          ],
        );
    }
  }

  Future submitForm(BuildContext context) async {
    if (soal.isEmpty) {
      return;
    }
    loadingDialog(context);
    await checkConnection();
    if (isConnect) {
      debugPrint('create jawaban survey online');
      try {
        if (formKey.currentState!.validate()) {
          currentJawabanSurvey.clear();
          formKey.currentState!.save();

          isLoadingNext.value = true;

          if (initialJawabanSurvey.isNotEmpty) {
            await DioClient().deleteJawabanSurvey(
              token: token,
              kodeUnikSurvey: int.parse(survey.kodeUnik!),
              kategoriSoalId: currentKategoriSoal.id,
            );

            ///also create jawaban survey local
            //delete jawaban if exist before create
            await DbHelper.deleteJawabanSurveyByKategoriSoal(
              Objectbox.store_,
              kodeUnikSurvey: int.parse(survey.kodeUnik!),
              kategoriId: currentKategoriSoal.id,
            );
          }

          await DioClient()
              .createJawabanSurvey(token: token, data: currentJawabanSurvey);

          var jawabanSurveyModel = currentJawabanSurvey
              .map((e) => JawabanSurveyModel.fromJson(e.toJson()))
              .toList();
          await DbHelper.putJawabanSurvey(Objectbox.store_, jawabanSurveyModel);
          loadingDialog(context, show: false);
          await nextCategory();
          successScackbar("Data berhasil disimpan");
        } else {
          loadingDialog(context, show: false);
          errorScackbar('Mohon Lengkapi jawaban');
        }
      } on DioError catch (e) {
        loadingDialog(context, show: false);
        if (e.response?.statusCode == 400) {
          //survey not found in server, failed to store jawaban survey
          // run sync.
          loadingDialog(context);
          await SyncDataController(store_: Objectbox.store_)
              .syncData(syncAll: false);
          loadingDialog(context, show: false);
        } else {
          handleError(error: e);
        }
      }
      isLoadingNext.value = false;
    } else {
      debugPrint('create jawaban survey local');
      if (formKey.currentState!.validate()) {
        currentJawabanSurvey.clear();
        formKey.currentState!.save();

        isLoadingNext.value = true;

        if (initialJawabanSurvey.isNotEmpty) {
          await DbHelper.deleteJawabanSurveyByKategoriSoal(
            Objectbox.store_,
            kodeUnikSurvey: int.parse(survey.kodeUnik!),
            kategoriId: currentKategoriSoal.id,
          );
        }

        var jawabanSurveyModel = currentJawabanSurvey
            .map((e) => JawabanSurveyModel.fromJson(e.toJson()))
            .toList();
        await DbHelper.putJawabanSurvey(Objectbox.store_, jawabanSurveyModel);
        loadingDialog(context, show: false);
        await nextCategory();
        successScackbar("Data berhasil disimpan");
      } else {
        loadingDialog(context, show: false);
        errorScackbar('Mohon Lengkapi jawaban');
      }
      isLoadingNext.value = false;
    }
  }

  Future nextCategory() async {
    currentOrder++;
    await refreshPage();
  }

  Future previousCategory() async {
    currentOrder--;
    await refreshPage();
  }

  Future updateSurvey() async {
    await checkConnection();
    if (isConnect) {
      debugPrint('update survey online');
      await DioClient().updateSurvey(
        token: token,
        data: {
          "kode_unik": survey.kodeUnik,
          "kode_unik_responden": kodeUnikResponden.toString(),
          "nama_survey_id": namaSurveyId.toString(),
          "profile_id": profileId.toString(),
          "kategori_selanjutnya": kategoriSoal
              .firstWhere((element) =>
                  element.urutan ==
                  (survey.isSelesai == "0" ? currentOrder.toString() : "1"))
              .id
              .toString(),
          "is_selesai": survey.isSelesai,
        },
      );
      //also update survey local
      int idToUpdate = await getSurveyId(kodeUnik: int.parse(survey.kodeUnik!));
      if (idToUpdate != -1) {
        var surveyModel = SurveyModel(
          id: idToUpdate,
          kategoriSelanjutnya: kategoriSoal
              .firstWhere((element) =>
                  element.urutan ==
                  (survey.isSelesai == "0" ? currentOrder.toString() : "1"))
              .id,
          kodeUnikRespondenId: kodeUnikResponden,
          namaSurveyId: namaSurveyId,
          profileId: profileId,
          kodeUnik: int.parse(survey.kodeUnik!),
          isSelesai: int.parse(survey.isSelesai),
          lastModified: DateTime.now().toString(),
        );
        await DbHelper.putSurvey(Objectbox.store_, [surveyModel]);
      } else {
        errorScackbar('Survey tidak ditemukan');
      }
    } else {
      debugPrint('update survey local');
      int idToUpdate = await getSurveyId(kodeUnik: int.parse(survey.kodeUnik!));
      if (idToUpdate != -1) {
        var surveyModel = SurveyModel(
          id: idToUpdate,
          kategoriSelanjutnya: kategoriSoal
              .firstWhere((element) =>
                  element.urutan ==
                  (survey.isSelesai == "0" ? currentOrder.toString() : "1"))
              .id,
          kodeUnikRespondenId: kodeUnikResponden,
          namaSurveyId: namaSurveyId,
          profileId: profileId,
          kodeUnik: int.parse(survey.kodeUnik!),
          isSelesai: int.parse(survey.isSelesai),
          lastModified: DateTime.now().toString(),
        );
        await DbHelper.putSurvey(Objectbox.store_, [surveyModel]);
      } else {
        errorScackbar('Survey tidak ditemukan');
      }
    }
  }

  Future<int> getSurveyId({required int kodeUnik}) async {
    var survey = await DbHelper.getSurveyByKodeUnik(Objectbox.store_,
        kodeUnik: kodeUnik);
    if (survey != null) {
      return survey.id!;
    } else {
      return -1;
    }
  }

  Future refreshPage() async {
    isLoading.value = true;
    soalAndJawaban.clear();
    if (currentOrder > kategoriSoal.length) {
      survey.isSelesai = "1";
      await updateSurvey();
      refreshUI();
      Get.back();
      return;
    }
    currentKategoriSoal = kategoriSoal
        .firstWhere((element) => element.urutan == currentOrder.toString());
    title.value = currentKategoriSoal.nama;
    survey.kategoriSelanjutnya = currentKategoriSoal.id.toString();

    if (!isEdit || survey.isSelesai == "0") {
      await updateSurvey();
    }
    if (isEdit) {
      await DbHelper.touchSurvey(Objectbox.store_,
          kodeUnikSurvey: int.parse(survey.kodeUnik!));
    }
    await getJawabanSurvey();
    await getSoal();
    await getJawabanSoal();
    currentJawabanSurvey = [];

    await checkConnection();
    if (isConnect) {
      isLoading.value = false;
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        isLoading.value = false;
      });
    }
  }

  Future checkConnection() async {
    isConnect = await global.isConnected();
  }

  /// refresh UI survey list data
  void refreshUI() {
    BerandaController berandaController;
    SurveyController surveyController;
    ExportSurveyController exportSurveyController;

    berandaController = Get.isRegistered<BerandaController>()
        ? Get.find()
        : Get.put(BerandaController());

    surveyController = Get.isRegistered<SurveyController>()
        ? Get.find()
        : Get.put(SurveyController());
    exportSurveyController = Get.isRegistered<ExportSurveyController>()
        ? Get.find()
        : Get.put(ExportSurveyController());

    berandaController.getSurvey();
    surveyController.getSurvey();
    exportSurveyController.getSurvey(namaSurveyId: "");
  }
}
