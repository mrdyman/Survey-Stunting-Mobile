import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:survey_stunting/components/filled_autocomplete.dart';
import 'package:survey_stunting/components/filled_text_field.dart';
import 'package:survey_stunting/controllers/ubah_profil_controller.dart';

class UbahProfilScreen extends StatefulWidget {
  const UbahProfilScreen({Key? key}) : super(key: key);

  @override
  State<UbahProfilScreen> createState() => _UbahProfilScreenState();
}

class _UbahProfilScreenState extends State<UbahProfilScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    UbahProfilController ubahProfilController = Get.put(UbahProfilController());
    return GetBuilder<UbahProfilController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: SvgPicture.asset(
                "assets/icons/outline/arrow-left.svg",
                color: Theme.of(context).textTheme.headline1!.color,
              ),
            ),
            // title: Text(
            //   "Dahboard",
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
          ),
          body: Obx(
            () => SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: size.height * 0.02,
                    children: [
                      Text("Update Profil",
                          style: Theme.of(context).textTheme.headline1),
                      SizedBox(
                        height: size.height * 0.06,
                      ),
                      FilledTextField(
                        controller: TextEditingController(
                            text: ubahProfilController
                                .profileData.value.data?.namaLengkap),
                        title: "Nama Lengkap",
                        textInputAction: TextInputAction.next,
                      ),
                      FilledAutocomplete(
                        controller: controller.jenisKelamin,
                        title: "Jenis Kelamin",
                        items: const [
                          {"label": "1", "value": "Laki - laki"},
                          {"label": "2", "value": "Perempuan"}
                        ],
                        textInputAction: TextInputAction.next,
                        onSuggestionSelected:
                            (Map<String, dynamic> suggestion) {
                          controller.jenisKelamin.text = suggestion["value"];
                        },
                      ),
                      FilledTextField(
                        controller: TextEditingController(
                            text: ubahProfilController
                                .profileData.value.data?.tempatLahir),
                        title: "Tempat Lahir",
                        textInputAction: TextInputAction.next,
                      ),
                      FilledTextField(
                        controller: TextEditingController(
                            text: ubahProfilController
                                .profileData.value.data?.tanggalLahir),
                        title: "Tanggal Lahir",
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [controller.maskFormatter],
                        helperText: "Contoh: 14-01-1998",
                      ),
                      FilledTextField(
                        controller: TextEditingController(
                            text: ubahProfilController
                                .profileData.value.data?.alamat),
                        title: "Alamat",
                        minLine: 2,
                        maxLine: null,
                        textInputAction: TextInputAction.next,
                      ),
                      FilledAutocomplete(
                        controller: controller.provinsi,
                        title: "Provisi",
                        items: const [
                          {"label": "1", "value": "1"},
                          {"label": "2", "value": "2"},
                          {"label": "3", "value": "3"}
                        ],
                        textInputAction: TextInputAction.next,
                        onSuggestionSelected:
                            (Map<String, dynamic> suggestion) {
                          controller.provinsi.text = suggestion["value"];
                        },
                      ),
                      FilledAutocomplete(
                        controller: controller.kabupatan,
                        title: "Kabupaten / Kota",
                        items: const [
                          {"label": "1", "value": "1"},
                          {"label": "2", "value": "2"},
                          {"label": "3", "value": "3"}
                        ],
                        textInputAction: TextInputAction.next,
                        onSuggestionSelected:
                            (Map<String, dynamic> suggestion) {
                          controller.kabupatan.text = suggestion["value"];
                        },
                      ),
                      FilledAutocomplete(
                        controller: controller.kecamatan,
                        title: "Kecamatan",
                        items: const [
                          {"label": "1", "value": "1"},
                          {"label": "2", "value": "2"},
                          {"label": "3", "value": "3"}
                        ],
                        textInputAction: TextInputAction.next,
                        onSuggestionSelected:
                            (Map<String, dynamic> suggestion) {
                          controller.kecamatan.text = suggestion["value"];
                        },
                      ),
                      FilledAutocomplete(
                        controller: controller.kelurahan,
                        title: "Desa / Kelurahan",
                        items: const [
                          {"label": "1", "value": "1"},
                          {"label": "2", "value": "2"},
                          {"label": "3", "value": "3"}
                        ],
                        textInputAction: TextInputAction.next,
                        onSuggestionSelected:
                            (Map<String, dynamic> suggestion) {
                          controller.kelurahan.text = suggestion["value"];
                        },
                      ),
                      FilledTextField(
                        controller: TextEditingController(
                            text: ubahProfilController
                                .profileData.value.data?.nomorHp),
                        title: "Nomor HP",
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      FilledTextField(
                        controller: TextEditingController(
                            text: ubahProfilController
                                .profileData.value.data?.email),
                        title: "Email",
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                      ),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: SvgPicture.asset(
                            "assets/icons/outline/tick-square.svg",
                            color: Colors.white,
                          ),
                          label: Text(
                            "Simpan",
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
