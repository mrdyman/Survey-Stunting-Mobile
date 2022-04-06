import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_stunting/components/custom_check_box.dart';
import 'package:survey_stunting/components/custom_combo_box.dart';
import 'package:survey_stunting/components/filled_text_field.dart';
import 'package:survey_stunting/components/success_scackbar.dart';
import 'package:survey_stunting/models/jawaban_soal.dart';
import 'package:survey_stunting/models/jawaban_survey.dart';
import 'package:survey_stunting/models/kategori_soal.dart';
import 'package:survey_stunting/models/soal.dart';
import 'package:survey_stunting/models/soal_and_jawaban.dart';
import 'package:survey_stunting/models/survey.dart';
import 'package:survey_stunting/services/dio_client.dart';
import 'package:survey_stunting/services/handle_errors.dart';

class IsiSurveyController extends GetxController {
  String token = GetStorage().read("token");
  Rx<String> currentKategoriSoalTitle = "".obs;
  late KategoriSoal currentKategoriSoal;
  late Survey survey;
  late List<KategoriSoal> kategoriSoal;
  final soal = RxList<Soal>();
  final soalAndJawaban = RxList<SoalAndJawaban>();
  late List<JawabanSurvey> listJawabanSurvey;
  var isLoading = true.obs;
  final formKey = GlobalKey<FormState>();

  Future getKategoriSoal() async {
    try {
      List<KategoriSoal>? response = await DioClient().getKategoriSoal(
          token: token, namaSurveyId: survey.namaSurvey!.id.toString());
      kategoriSoal = response!;
    } on DioError catch (e) {
      handleError(error: e);
    }
  }

  Future getSoal() async {
    try {
      List<Soal>? response = await DioClient().getSoal(
        token: token,
        kategoriSoalId: currentKategoriSoal.id.toString(),
      );
      soal.value = response!;
    } on DioError catch (e) {
      handleError(error: e);
    }
  }

  Future getJawabanSoal() async {
    try {
      for (var item in soal) {
        if (item.tipeJawaban == "Jawaban Singkat") {
          soalAndJawaban.add(SoalAndJawaban(soal: item));
        } else {
          List<JawabanSoal>? response = await DioClient()
              .getJawabanSoal(token: token, soalId: item.id.toString());
          soalAndJawaban.add(SoalAndJawaban(soal: item, jawabanSoal: response));
        }
      }
    } on DioError catch (e) {
      handleError(error: e);
    }
  }

  Widget generateSoalUI({
    required int number,
    required String soal,
    required String typeJawaban,
    required int soalId,
    List<JawabanSoal>? jawaban,
    required BuildContext context,
  }) {
    switch (typeJawaban) {
      case "Pilihan Ganda":
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
              validator: (value) {
                log("yyyy $value");
                if (value == null) {
                  return "Jawaban tidak boleh kosong";
                }
                return null;
              },
              options: jawaban!.map((value) {
                return FormBuilderFieldOption(
                  value: JawabanSurvey(
                    soalId: soalId.toString(),
                    kodeUnikSurvey: survey.kodeUnik.toString(),
                    kategoriSoalId: currentKategoriSoal.id.toString(),
                    jawabanSoalId: value.id.toString(),
                  ),
                  child: Text(value.jawaban),
                );
              }).toList(),
            )
          ],
        );
      case "Kotak Centang":
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Jawaban tidak boleh kosong";
                }
                log("xxxx ${listJawabanSurveyToJson(value as List<JawabanSurvey>)}");
                return null;
              },
              orientation: OptionsOrientation.vertical,
              options: jawaban!.map((value) {
                String key = UniqueKey().toString();
                JawabanSurvey jawabanSurvey = JawabanSurvey(
                  key: key,
                  soalId: soalId.toString(),
                  kodeUnikSurvey: survey.kodeUnik.toString(),
                  kategoriSoalId: currentKategoriSoal.id.toString(),
                  jawabanSoalId: value.id.toString(),
                );
                return FormBuilderFieldOption(
                  value: jawabanSurvey,
                  child: value.isLainnya == "0"
                      ? Text(value.jawaban)
                      : FilledTextField(
                          onChanged: (value) =>
                              jawabanSurvey.jawabanLainnya = value,
                          hintText: "Lainnya",
                          // validator: (x) {
                          //   if (x!.trim().isEmpty) {
                          //     return "Jawaban tidak boleh kosong";
                          //   }
                          //   return null;
                          // },
                          onSaved: (value) {},
                        ),
                );
              }).toList(),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledTextField(
              title: "$number. $soal",
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Jawaban tidak boleh kosong";
                }
                return null;
              },
              onSaved: (value) {
                JawabanSurvey jawabanSurvey = JawabanSurvey(
                  soalId: soalId.toString(),
                  kodeUnikSurvey: survey.kodeUnik.toString(),
                  kategoriSoalId: currentKategoriSoal.id.toString(),
                  jawabanLainnya: value,
                );
                listJawabanSurvey.add(jawabanSurvey);
              },
            ),
          ],
        );
    }
  }

  Future submitForm() async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        successScackbar("Data berhasil disimpan");
      }
    } on DioError catch (e) {
      handleError(error: e);
    }
  }

  @override
  void onInit() async {
    survey = Get.arguments;
    await getKategoriSoal();
    currentKategoriSoal = kategoriSoal.firstWhere(
        (element) => element.id.toString() == survey.kategoriSelanjutnya!);
    currentKategoriSoalTitle.value = currentKategoriSoal.nama;
    await getSoal();
    await getJawabanSoal();
    log(soalAndJawaban.toString());
    isLoading.value = false;
    listJawabanSurvey = [];
    super.onInit();
  }
}
