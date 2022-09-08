import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:survey_stunting/components/custom_elevated_button_icon.dart';
import 'package:survey_stunting/components/ux/isi_survey_loading.dart';
import 'package:survey_stunting/consts/colors.dart';
import 'package:survey_stunting/controllers/isi_survey.controller.dart';

class IsiSurveyScreen extends StatelessWidget {
  const IsiSurveyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IsiSurveyController>(builder: (controller) {
      controller.currentJawabanSurvey = [];
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              controller.refreshUI();
              Get.back();
            },
            icon: SvgPicture.asset(
              "assets/icons/outline/arrow-left.svg",
              color: Theme.of(context).textTheme.headline1!.color,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                runSpacing: 20,
                children: [
                  Obx(
                    () => Visibility(
                      visible: !controller.isLoading.value,
                      replacement: Shimmer.fromColors(
                        child: Container(
                          width: 100,
                          height: 25,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[300]),
                        ),
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                      child: Text(
                        "Isi Survey",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(
                    () => Visibility(
                      visible: !controller.isLoading.value,
                      replacement: isiSurveyLoading(context),
                      child: Form(
                        key: controller.formKey,
                        child: Wrap(
                          runSpacing: 20,
                          children: [
                            Center(
                              child: Text(
                                controller.title.value,
                                style: Theme.of(context).textTheme.headline2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ...controller.soalAndJawaban.map((value) {
                              var index =
                                  controller.soalAndJawaban.indexOf(value);
                              return controller.generateSoalUI(
                                number: index + 1,
                                context: context,
                                soal: value.soal.soal,
                                soalId: value.soal.id,
                                typeJawaban: value.soal.tipeJawaban,
                                isNumerik: int.parse(value.soal.isNumerik),
                                jawabanSoal: value.jawabanSoal,
                              );
                            }).toList(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (controller.currentOrder > 1)
                                    CustomElevatedButtonIcon(
                                      backgroundColor: primaryColor,
                                      label: "Kembali",
                                      icon: SvgPicture.asset(
                                        "assets/icons/outline/arrow-left.svg",
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        if (!controller.isLoadingNext.value) {
                                          await controller.previousCategory();
                                        }
                                      },
                                    ),
                                  if (controller.currentOrder > 1)
                                    const SizedBox(
                                      width: 8,
                                    ),
                                  CustomElevatedButtonIcon(
                                    label: "Selanjutnya",
                                    icon: SvgPicture.asset(
                                      "assets/icons/outline/arrow-right2.svg",
                                      color: Colors.white,
                                    ),
                                    isLoading: controller.isLoadingNext.value,
                                    onPressed: () async {
                                      await controller.submitForm(context);
                                    },
                                  ),
                                ])
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
