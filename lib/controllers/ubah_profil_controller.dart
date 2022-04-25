import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_stunting/components/error_scackbar.dart';
import 'package:survey_stunting/components/success_scackbar.dart';
import 'package:survey_stunting/models/kabupaten.dart';
import 'package:survey_stunting/models/kecamatan.dart';
import 'package:survey_stunting/models/kelurahan.dart';
import 'package:survey_stunting/models/localDb/helpers.dart';
import 'package:survey_stunting/models/localDb/kecamatan_model.dart';
import 'package:survey_stunting/models/localDb/provinsi_model.dart';
import 'package:survey_stunting/models/provinsi.dart';
import 'package:survey_stunting/models/user_profile.dart';
import 'package:survey_stunting/services/dio_client.dart';
import 'package:survey_stunting/services/handle_errors.dart';

import '../models/localDb/kabupaten_model.dart';
import '../models/localDb/kelurahan_model.dart';
import '../models/localDb/profile_model.dart';

class UbahProfilController extends GetxController {
  String token = GetStorage().read("token");
  int userId = GetStorage().read("userId");

  final namaLengkapTextController = TextEditingController();
  final jenisKelaminTextController = TextEditingController();
  final tempatLahirTextController = TextEditingController();
  final tglLahirTextController = TextEditingController();
  final alamatTextController = TextEditingController();
  final provinsiTEC = TextEditingController();
  final kabupatenTEC = TextEditingController();
  final kecamatanTEC = TextEditingController();
  final kelurahanTEC = TextEditingController();
  final nomorHpTextController = TextEditingController();
  final emailTextController = TextEditingController();

  Rx<UserProfile> profileData = UserProfile().obs;
  var provinsi = [].obs;
  var kabupaten = [].obs;
  var kecamatan = [].obs;
  var kelurahan = [].obs;

  late int provinsiId;
  late int kabupatenId;
  late int kecamatanId;
  late int kelurahanId;

  var isLoaded = false.obs;
  var profileUpdateStatus = ''.obs;

  var namaLengkapError = ''.obs;
  var jenisKelaminError = ''.obs;
  var tempatLahirError = ''.obs;
  var tglLahirError = ''.obs;
  var alamatError = ''.obs;
  var provinsiError = ''.obs;
  var kabupatenError = ''.obs;
  var kecamatanError = ''.obs;
  var kelurahanError = ''.obs;
  var nomorHpError = ''.obs;
  var emailError = ''.obs;

  final tglLahirMaskFormatter = MaskTextInputFormatter(
    mask: '####-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final nomorHpMaskFormatter = MaskTextInputFormatter(
    mask: '############',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    bool offlineMode = prefs.getBool('offline_mode') ?? false;
    if (!offlineMode) {
      debugPrint('get user profile online');
      try {
        UserProfile? response = await DioClient().getProfile(token: token);
        profileData.value = response!;
        provinsiId = int.parse(profileData.value.data!.provinsi);
        kabupatenId = int.parse(profileData.value.data!.kabupatenKota);
        kecamatanId = int.parse(profileData.value.data!.kecamatan);
        kelurahanId = int.parse(profileData.value.data!.desaKelurahan);
      } on DioError catch (e) {
        handleError(error: e);
      }
    } else {
      debugPrint('get user profile local');
      ProfileModel? localProfile =
          await DbHelper.getProfileByUserId(Objectbox.store_, userId: userId);
      if (localProfile != null) {
        profileData.value = UserProfile.fromJson(localProfile.toJson());
        provinsiId = int.parse(profileData.value.data!.provinsi);
        kabupatenId = int.parse(profileData.value.data!.kabupatenKota);
        kecamatanId = int.parse(profileData.value.data!.kecamatan);
        kelurahanId = int.parse(profileData.value.data!.desaKelurahan);
      } else {
        debugPrint('data profile not found on local, please sync from server');
      }
    }
  }

  Future getProvinsi() async {
    final prefs = await SharedPreferences.getInstance();
    bool offlineMode = prefs.getBool('offline_mode') ?? false;
    if (!offlineMode) {
      debugPrint('get provinsi online');
      try {
        List<Provinsi>? response = await DioClient().getProvinsi(
          token: token,
        );
        provinsi.value = response!;
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          provinsi.value = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('get provinsi local');
      List<ProvinsiModel>? localProvinsi =
          await DbHelper.getProvinsi(Objectbox.store_);
      if (localProvinsi.isNotEmpty) {
        provinsi.value = localProvinsi;
      } else {
        provinsi.value = [];
        debugPrint('data provinsi not found on local, please sync from server');
      }
    }
  }

  Future getKabupaten() async {
    kabupaten.value = [];
    kabupatenTEC.text = "";
    final prefs = await SharedPreferences.getInstance();
    bool offlineMode = prefs.getBool('offline_mode') ?? false;
    if (!offlineMode) {
      debugPrint('get kabupaten online');
      try {
        List<Kabupaten>? response = await DioClient().getKabupaten(
          token: token,
          provinsiId: provinsiId.toString(),
        );
        kabupaten.value = response!;
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          kabupaten.value = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('get kabupaten local');
      List<KabupatenModel>? localKabupaten =
          await DbHelper.getKabupatenByProvinsiId(Objectbox.store_,
              provinsiId: provinsiId);
      if (localKabupaten.isNotEmpty) {
        kabupaten.value = localKabupaten;
      } else {
        kabupaten.value = [];
        debugPrint(
            'data kabupaten not found on local, please sync from server');
      }
    }
  }

  Future getKecamatan() async {
    kecamatan.value = [];
    kecamatanTEC.text = "";
    final prefs = await SharedPreferences.getInstance();
    bool offlineMode = prefs.getBool('offline_mode') ?? false;
    if (!offlineMode) {
      debugPrint('get kecamatan online');
      try {
        List<Kecamatan>? response = await DioClient().getKecamatan(
          token: token,
          kabupatenId: kabupatenId.toString(),
        );
        kecamatan.value = response!;
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          kecamatan.value = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('get kecamatan local');
      List<KecamatanModel>? localKecamatan =
          await DbHelper.getKecamatanByKabupatenId(Objectbox.store_,
              kabupatenId: kabupatenId);
      if (localKecamatan.isNotEmpty) {
        kecamatan.value = localKecamatan;
      } else {
        kecamatan.value = [];
        debugPrint(
            'data kecamatan not found on local, please sync from server');
      }
    }
  }

  Future getKelurahan() async {
    kelurahan.value = [];
    kelurahanTEC.text = "";
    final prefs = await SharedPreferences.getInstance();
    bool offlineMode = prefs.getBool('offline_mode') ?? false;
    if (!offlineMode) {
      debugPrint('get kelurahan online');
      try {
        List<Kelurahan>? response = await DioClient().getKelurahan(
          token: token,
          kecamatanId: kecamatanId.toString(),
        );
        kelurahan.value = response!;
      } on DioError catch (e) {
        if (e.response?.statusCode == 404) {
          kelurahan.value = [];
        } else {
          handleError(error: e);
        }
      }
    } else {
      debugPrint('get kelurahan local');
      List<KelurahanModel>? localKelurahan =
          await DbHelper.getKelurahanByKecamatanId(Objectbox.store_,
              kecamatanId: kecamatanId);
      if (localKelurahan.isNotEmpty) {
        kelurahan.value = localKelurahan;
      } else {
        kelurahan.value = [];
        debugPrint(
            'data kelurahan not found on local, please sync from server');
      }
    }
  }

  Future updateUserProfile({
    required String nama,
    required String jenisKelamin,
    required String tempatLahir,
    required String tglLahir,
    required String alamat,
    required String nomorHp,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool offlineMode = prefs.getBool('offline_mode') ?? false;
    if (validate()) {
      if (!offlineMode) {
        debugPrint('update user profile online');
        try {
          profileUpdateStatus.value = 'waiting';
          bool response = await DioClient().updateProfile(
            token: token,
            nama: nama,
            jenisKelamin: jenisKelamin,
            tempatLahir: tempatLahir,
            tglLahir: tglLahir,
            alamat: alamat,
            provinsi: provinsiId.toString(),
            kabupaten: kabupatenId.toString(),
            kecamatan: kecamatanId.toString(),
            kelurahan: kelurahanId.toString(),
            nomorHp: nomorHp,
            email: email,
            updatedAt: DateTime.now().toString(),
          );
          if (response) {
            profileUpdateStatus.value = 'successful';
            successScackbar('Profile berhasil diupdate.');
          } else {
            profileUpdateStatus.value = 'failed';
            errorScackbar('Update profile gagal.');
          }
        } on DioError catch (e) {
          handleError(error: e);
        }
      } else {
        debugPrint('update profile local');
        profileUpdateStatus.value = 'waiting';
        ProfileModel profile = ProfileModel(
            id: profileData.value.data!.id,
            namaLengkap: nama,
            jenisKelamin: jenisKelamin,
            tempatLahir: tempatLahir,
            tanggalLahir: tglLahir,
            alamat: alamat,
            provinsiId: provinsiId.toString(),
            kabupatenId: kabupatenId.toString(),
            kecamatanId: kecamatanId.toString(),
            kelurahanId: kelurahanId.toString(),
            nomorHp: nomorHp,
            email: email,
            userId: userId,
            lastModified: DateTime.now().toString());
        int response = await DbHelper.putProfile(Objectbox.store_, profile);
        if (response > 0) {
          profileUpdateStatus.value = 'successful';
          successScackbar('Profile berhasil diupdate.');
        } else {
          profileUpdateStatus.value = 'failed';
          errorScackbar('Update profile gagal.');
        }
      }
    } else {
      debugPrint('validation failed');
    }
  }

  bool validate() {
    namaLengkapError.value = '';
    jenisKelaminError.value = '';
    tempatLahirError.value = '';
    tglLahirError.value = '';
    alamatError.value = '';
    provinsiError.value = '';
    kabupatenError.value = '';
    kecamatanError.value = '';
    kelurahanError.value = '';
    nomorHpError.value = '';
    emailError.value = '';

    if (namaLengkapTextController.value.text.trim().isEmpty) {
      namaLengkapError.value = 'Nama wajib diisi';
    }

    if (jenisKelaminTextController.value.text.trim().isEmpty) {
      jenisKelaminError.value = 'Jenis Kelamin wajib diisi';
    }

    if (tempatLahirTextController.value.text.trim().isEmpty) {
      tempatLahirError.value = 'Tempat lahir wajib diisi';
    }

    if (tglLahirTextController.value.text.trim().isEmpty) {
      tglLahirError.value = 'Tanggal lahir wajib diisi';
    }

    if (alamatTextController.value.text.trim().isEmpty) {
      alamatError.value = 'Alamat wajib diisi';
    }

    if (provinsiTEC.value.text.trim().isEmpty) {
      provinsiError.value = 'Provinsi wajib diisi';
    }

    if (provinsiTEC.value.text.trim().contains('-')) {
      provinsiError.value = 'Provinsi tidak valid';
    }

    if (kabupatenTEC.value.text.trim().isEmpty) {
      kabupatenError.value = 'Kabupaten wajib diisi';
    }

    if (kabupatenTEC.value.text.trim().contains('-')) {
      kabupatenError.value = 'Kabupaten tidak valid';
    }

    if (kecamatanTEC.value.text.trim().isEmpty) {
      kecamatanError.value = 'Kecamatan wajib diisi';
    }

    if (kecamatanTEC.value.text.trim().contains('-')) {
      kecamatanError.value = 'Kecamatan tidak valid';
    }

    if (kelurahanTEC.value.text.trim().isEmpty) {
      kelurahanError.value = 'Kelurahan wajib diisi';
    }

    if (kelurahanTEC.value.text.trim().contains('-')) {
      kelurahanError.value = 'Kelurahan tidak valid';
    }

    if (nomorHpTextController.value.text.trim().isEmpty) {
      nomorHpError.value = 'Nomor Hp wajib diisi';
    }

    if (emailTextController.value.text.trim().isEmpty) {
      emailError.value = 'E-mail wajib diisi';
    }

    if (namaLengkapError.value.isNotEmpty ||
        jenisKelaminError.value.isNotEmpty ||
        tempatLahirError.value.isNotEmpty ||
        tglLahirError.value.isNotEmpty ||
        alamatError.value.isNotEmpty ||
        provinsiError.value.isNotEmpty ||
        kabupatenError.value.isNotEmpty ||
        kecamatanError.value.isNotEmpty ||
        kelurahanError.value.isNotEmpty ||
        nomorHpError.value.isNotEmpty ||
        emailError.value.isNotEmpty) {
      return false;
    }
    return true;
  }

  void displayUserData() {
    isLoaded.value = false;
    if (profileData.value.data != null) {
      namaLengkapTextController.text = profileData.value.data!.namaLengkap;
      jenisKelaminTextController.text = profileData.value.data!.jenisKelamin;
      tempatLahirTextController.text = profileData.value.data!.tempatLahir;
      tglLahirTextController.text = profileData.value.data!.tanggalLahir;
      alamatTextController.text = profileData.value.data!.alamat;
      nomorHpTextController.text = profileData.value.data!.nomorHp;
      emailTextController.text = profileData.value.data!.email;
      provinsiTEC.text =
          provinsi.firstWhere((element) => element.id == provinsiId).nama;
      kabupatenTEC.text =
          kabupaten.firstWhere((element) => element.id == kabupatenId).nama;
      kecamatanTEC.text =
          kecamatan.firstWhere((element) => element.id == kecamatanId).nama;
      kelurahanTEC.text =
          kelurahan.firstWhere((element) => element.id == kelurahanId).nama;
    }
    isLoaded.value = true;
  }

  @override
  void onInit() async {
    await getUserProfile();
    await getProvinsi();
    await getKabupaten();
    await getKecamatan();
    await getKelurahan();
    displayUserData();
    super.onInit();
  }
}
