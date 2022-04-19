import 'dart:convert';
import 'dart:developer';

import 'package:survey_stunting/models/localDb/objectBox_generated_files/objectbox.g.dart';
import 'package:survey_stunting/models/localDb/profile_model.dart';
import 'package:survey_stunting/models/localDb/responden_model.dart';

import 'jawaban_soal_model.dart';
import 'jawaban_survey_model.dart';
import 'kabupaten_model.dart';
import 'kategori_soal_model.dart';
import 'kecamatan_model.dart';
import 'kelurahan_model.dart';
import 'nama_survey_mode.dart';
import 'provinsi_model.dart';
import 'soal_model.dart';
import 'survey_model.dart';
import 'user_model.dart';

class Objectbox {
  late final Store store;
  late final Admin admin;

  Objectbox._create(this.store) {
    if (Admin.isAvailable()) {
      admin = Admin(store);
    }
  }

  static Future<Objectbox> create() async {
    final store = await openStore();
    return Objectbox._create(store);
  }
}

class DbHelper {
  //? Profile
  /// Params:
  /// - store (ObjextBoxStore)
  /// - ProfileData (ProfileModel)
  /// - id (int) - id of profile optional only if you want to update profile
  static Future<int> putProfile(Store store, ProfileModel profile) async {
    profile.user.targetId = profile.userId;
    return store.box<ProfileModel>().put(profile);
  }

  /// Get all profile data
  static Future<List<ProfileModel>> getProfile(Store store) async {
    return store.box<ProfileModel>().getAll();
  }

  /// Get profile by id
  static Future<ProfileModel?> getProfileById(Store store,
      {required int id}) async {
    return store.box<ProfileModel>().get(id);
  }

  /// Get profile by userId
  static Future<ProfileModel?> getProfileByUserId(Store store,
      {required int userId}) async {
    var profiles = await getProfile(store);
    return profiles.singleWhere((profile) => profile.user.targetId == userId);
  }

  /// param :
  /// id (int) - id of profile
  /// return :
  /// true if profile is deleted
  static Future<bool> deleteProfile(Store store, int id) async {
    return store.box<ProfileModel>().remove(id);
  }

  static Future<int> deleteAllProfile(Store store) async {
    return store.box<ProfileModel>().removeAll();
  }

  //? User
  /// Params:
  /// - store (ObjextBoxStore)
  /// - UserData (UserModel)
  /// - id (int) - id of the user optional only if you want to update the user
  static Future<int> putUser(Store store, UserModel user) async {
    // user.profile.targetId = user.profileId;
    return store.box<UserModel>().put(user);
  }

  /// Get all user
  static Future<List<UserModel>> getUser(Store store) async {
    return store.box<UserModel>().getAll();
  }

  /// Get user by id
  static Future<UserModel?> getUserById(Store store, {required int id}) async {
    return store.box<UserModel>().get(id);
  }

  /// get user by profileId
  // static Future<UserModel?> getUserByProfileId(Store store,
  //     {required int profileId}) async {
  //   final users = await getUser(store);
  //   return users.firstWhere((user) => user.profile.targetId == profileId);
  // }

  /// param :
  /// id (int) - id of the user
  /// return :
  /// true if user is deleted
  static Future<bool> deleteUser(Store store, {required int id}) async {
    return store.box<UserModel>().remove(id);
  }

  static Future<int> deleteAllUser(Store store) async {
    return store.box<UserModel>().removeAll();
  }

  //? Soal
  /// Params:
  /// - store (ObjextBoxStore)
  /// - SoalData (SoalModel)
  /// - id (int) - id of the soal optional only if you want to update the soal
  static Future<int> putSoal(Store store, SoalModel soal) async {
    soal.kategoriSoal.targetId = soal.kategoriSoalId;
    return store.box<SoalModel>().put(soal);
  }

  /// Get all soal
  /// return :
  /// List<SoalModel>
  static Future<List<SoalModel>> getSoal(Store store) async {
    return store.box<SoalModel>().getAll();
  }

  /// Get soal by id
  static Future<SoalModel?> getSoalById(Store store, {required int id}) async {
    return store.box<SoalModel>().get(id);
  }

  /// Get soal by kategoriSoalId.
  ///
  /// return :
  /// List<SoalModel>
  static Future<List<SoalModel>> getSoalByKategoriSoalId(
    Store store, {
    required int kategoriSoalId,
  }) async {
    final soals = await getSoal(store);
    return soals
        .where((soal) => soal.kategoriSoal.targetId == kategoriSoalId)
        .toList();
  }

  /// delete soal
  /// param :
  ///
  /// return :
  /// true if soal is deleted
  static Future<bool> deleteSoal(Store store, {required int id}) async {
    return store.box<SoalModel>().remove(id);
  }

  /// delete all soal
  static Future<int> deleteAllSoal(Store store) async {
    return store.box<SoalModel>().removeAll();
  }

  //? Kategori Soal
  /// Params:
  /// - store (ObjextBoxStore)
  /// - KategoriSoalData (KategoriSoalModel)
  /// - id (int) - id of the kategori soal optional only if you want to update the kategori soal
  static Future<int> putKategoriSoal(
      Store store, KategoriSoalModel kategoriSoal) async {
    kategoriSoal.namaSurvey.targetId = kategoriSoal.namaSurveyId;
    return store.box<KategoriSoalModel>().put(kategoriSoal);
  }

  /// get all kategori soal
  static Future<List<KategoriSoalModel>> getKategoriSoal(Store store) async {
    return store.box<KategoriSoalModel>().getAll();
  }

  /// get kategori soal by id
  static Future<KategoriSoalModel?> getKategoriSoalById(Store store,
      {required int id}) async {
    return store.box<KategoriSoalModel>().get(id);
  }

  /// Get kategoriSoal by namaSurveyId
  static Future<List<KategoriSoalModel>> getKategoriSoalByNamaSurveyId(
    Store store, {
    required int namaSurveyId,
  }) async {
    final kategoriSoals = await getKategoriSoal(store);
    return kategoriSoals
        .where(
            (kategoriSoal) => kategoriSoal.namaSurvey.targetId == namaSurveyId)
        .toList();
  }

  /// delete kategori soal
  static Future<bool> deleteKategoriSoal(Store store, {required int id}) async {
    return store.box<KategoriSoalModel>().remove(id);
  }

  /// delete all kategori soal
  static Future<int> deleteAllKategoriSoal(Store store) async {
    return store.box<KategoriSoalModel>().removeAll();
  }

  //? Nama Survey
  /// Params:
  /// - store (ObjextBoxStore)
  /// - NamaSurveyData (NamaSurveyModel)
  /// - id (int) - id of the nama survey optional only if you want to update the nama survey
  static Future<int> putNamaSurvey(
      Store store, NamaSurveyModel namaSurvey) async {
    return store.box<NamaSurveyModel>().put(namaSurvey);
  }

  /// get all nama survey
  /// return :
  /// List<NamaSurveyModel>
  static Future<List<NamaSurveyModel>> getNamaSurvey(Store store) async {
    return store.box<NamaSurveyModel>().getAll();
  }

  /// get nama survey by id
  static Future<NamaSurveyModel?> getNamaSurveyById(Store store,
      {required int id}) async {
    return store.box<NamaSurveyModel>().get(id);
  }

  /// delete nama survey
  static Future<bool> deleteNamaSurvey(Store store, {required int id}) async {
    return store.box<NamaSurveyModel>().remove(id);
  }

  /// delete all namaSurvey
  static Future<int> deleteAllNamaSurvey(Store store) async {
    return store.box<NamaSurveyModel>().removeAll();
  }

  // create function jawabanSoal same as kategori soal
  //? Jawaban Soal
  /// Params:
  /// - store (ObjextBoxStore)
  /// - JawabanSoalData (JawabanSoalModel)
  /// - id (int) - id of the jawaban soal optional only if you want to update the jawaban soal
  static Future<int> putJawabanSoal(
      Store store, JawabanSoalModel jawabanSoal) async {
    jawabanSoal.soal.targetId = jawabanSoal.soalId;
    // jawabanSoal.jawabanSurvey.targetId = jawabanSoal.jawabanSurveyId;
    return store.box<JawabanSoalModel>().put(jawabanSoal);
  }

  /// get all jawaban soal
  static Future<List<JawabanSoalModel>> getJawabanSoal(Store store) async {
    return store.box<JawabanSoalModel>().getAll();
  }

  /// get jawaban soal by id
  static Future<JawabanSoalModel?> getJawabanSoalById(Store store,
      {required int id}) async {
    return store.box<JawabanSoalModel>().get(id);
  }

  /// Get jawabanSoal by soalId
  static Future<List<JawabanSoalModel>> getJawabanSoalBySoalId(
    Store store, {
    required int soalId,
  }) async {
    final jawabanSoals = await getJawabanSoal(store);
    return jawabanSoals
        .where((jawabanSoal) => jawabanSoal.soal.targetId == soalId)
        .toList();
  }

  /// Get jawabanSoal by jawabanSurveyId
  // static Future<List<JawabanSoalModel>> getJawabanSoalByJawabanSurveyId(
  //   Store store, {
  //   required int jawabanSurveyId,
  // }) async {
  //   final jawabanSoals = await getJawabanSoal(store);
  //   return jawabanSoals
  //       .where((jawabanSoal) =>
  //           jawabanSoal.jawabanSurvey.targetId == jawabanSurveyId)
  //       .toList();
  // }

  /// delete all jawabanSoal
  static Future<int> deleteAllJawabanSoal(Store store) async {
    return store.box<JawabanSoalModel>().removeAll();
  }

  // create function jawabanSurvey same as jawaban soal
  //? Jawaban Survey
  /// Params:
  /// - store (ObjextBoxStore)
  /// - JawabanSurveyData (JawabanSurveyModel)
  /// - id (int) - id of the jawaban survey optional only if you want to update the jawaban survey
  static Future<int> putJawabanSurvey(
      Store store, JawabanSurveyModel jawabanSurvey) async {
    jawabanSurvey.soal.targetId = jawabanSurvey.soalId;
    jawabanSurvey.kodeUnikSurvey.targetId = jawabanSurvey.kodeUnikSurveyId;
    jawabanSurvey.kategoriSoal.targetId = jawabanSurvey.kategoriSoalId;
    return store.box<JawabanSurveyModel>().put(jawabanSurvey);
  }

  /// get all jawaban survey
  static Future<List<JawabanSurveyModel>> getJawabanSurvey(Store store) async {
    return store.box<JawabanSurveyModel>().getAll();
  }

  /// get jawaban survey by id
  static Future<JawabanSurveyModel?> getJawabanSurveyById(Store store,
      {required int id}) async {
    return store.box<JawabanSurveyModel>().get(id);
  }

  /// Get jawabanSurvey by soalId
  static Future<List<JawabanSurveyModel>> getJawabanSurveyBySoalId(
    Store store, {
    required int soalId,
  }) async {
    final jawabanSurveys = await getJawabanSurvey(store);
    return jawabanSurveys
        .where((jawabanSurvey) => jawabanSurvey.soal.targetId == soalId)
        .toList();
  }

  /// Get jawabanSurvey by kodeUnikSurveyId
  static Future<List<JawabanSurveyModel>> getJawabanSurveyByKodeUnikSurveyId(
    Store store, {
    required int kodeUnikSurveyId,
  }) async {
    final jawabanSurveys = await getJawabanSurvey(store);
    return jawabanSurveys
        .where((jawabanSurvey) =>
            jawabanSurvey.kodeUnikSurvey.targetId == kodeUnikSurveyId)
        .toList();
  }

  /// Get jawabanSurvey by kategoriSoalId
  static Future<List<JawabanSurveyModel>> getJawabanSurveyByKategoriSoalId(
    Store store, {
    required int kategoriSoalId,
  }) async {
    final jawabanSurveys = await getJawabanSurvey(store);
    return jawabanSurveys
        .where((jawabanSurvey) =>
            jawabanSurvey.kategoriSoal.targetId == kategoriSoalId)
        .toList();
  }

  /// Get jawabanSurvey by jawabanSoalId
  static Future<List<JawabanSurveyModel>> getJawabanSurveyByJawabanSoalId(
    Store store, {
    required int jawabanSoalId,
  }) async {
    final jawabanSurveys = await getJawabanSurvey(store);
    return jawabanSurveys
        .where((jawabanSurvey) => jawabanSurvey.jawabanSoalId == jawabanSoalId)
        .toList();
  }

  /// delete jawaban survey
  static Future<bool> deleteJawabanSurvey(Store store,
      {required int id}) async {
    return store.box<JawabanSurveyModel>().remove(id);
  }

  // create function Survey same as jawaban survey
  //? Survey
  /// Params:
  /// - store (ObjextBoxStore)
  /// - SurveyData (SurveyModel)
  /// - id (int) - id of the survey optional only if you want to update the survey
  static Future<int> putSurvey(Store store, SurveyModel survey) async {
    survey.namaSurvey.targetId = survey.namaSurveyId;
    survey.profile.targetId = survey.profileId;
    survey.kodeUnikResponden.targetId = survey.kodeUnikRespondenId;
    return store.box<SurveyModel>().put(survey);
  }

  /// get all survey
  static Future<List<SurveyModel>> getSurvey(Store store) async {
    return store.box<SurveyModel>().getAll();
  }

  /// get survey by id
  static Future<SurveyModel?> getSurveyById(Store store,
      {required int id}) async {
    return store.box<SurveyModel>().get(id);
  }

  /// Get survey by namaSurveyId
  static Future<List<SurveyModel>> getSurveyByNamaSurveyId(
    Store store, {
    required int namaSurveyId,
  }) async {
    final surveys = await getSurvey(store);
    return surveys
        .where((survey) => survey.namaSurvey.targetId == namaSurveyId)
        .toList();
  }

  /// Get survey by profileId
  static Future<List<SurveyModel>> getSurveyByProfileId(
    Store store, {
    required int profileId,
  }) async {
    final surveys = await getSurvey(store);
    return surveys
        .where((survey) => survey.profile.targetId == profileId)
        .toList();
  }

  /// Get survey by kodeUnikRespondenId
  static Future<List<SurveyModel>> getSurveyByKodeUnikRespondenId(
    Store store, {
    required int kodeUnikRespondenId,
  }) async {
    final surveys = await getSurvey(store);
    return surveys
        .where((survey) =>
            survey.kodeUnikResponden.targetId == kodeUnikRespondenId)
        .toList();
  }

  /// Get survey with isSelesai = 0
  /// - isSelesai = 0 means that the survey is not finished yet
  /// - isSelesai = 1 means that the survey is finished
  static Future<List<SurveyModel>> getSurveyByIsSelesai(
    Store store, {
    required int isSelesai,
  }) async {
    final surveys = await getSurvey(store);
    return surveys.where((survey) => survey.isSelesai == isSelesai).toList();
  }

  // Get detail survey
  /// Params:
  /// - store (ObjextBoxStore)
  /// - kodeUnik (int)
  static Future<dynamic> getDetailSurvey(Store store,
      {required int profileId}) async {
    // Get survey with kodeUnik = 92230298
    // Get Responden object id with kodeUnikResponden = 11223344
    // Get namaSurvey with id = 1
    // Get profile with id = 1
    // QueryBuilder<SurveyModel> builder =
    //     store.box<SurveyModel>().query(SurveyModel_.kodeUnik.equals(92230298));
    // builder.link(SurveyModel_.kodeUnikResponden,
    //     RespondenModel_.kodeUnik.equals(11223344));
    // builder.link(SurveyModel_.namaSurvey, NamaSurveyModel_.id.equals(1));
    // builder.link(SurveyModel_.profile, ProfileModel_.id.equals(1));
    // Query<SurveyModel> query = builder.build();
    // List<dynamic> result = query.find();
    // query.close();
    // return result;
    List allSurveys = [];
    List surveys = await getSurveyByProfileId(store, profileId: profileId);
    for (var survey in surveys) {
      survey.map((e) => {
            'id': e.id,
            'kodeUnikResponden': e.kodeUnikResponden.kodeUnik,
            'namaSurveyId': e.namaSurvey.namaSurvey,
            'profileId': e.profile.namaLengkap,
            'kategoriSelanjutnya': e.kodeUnikResponden.kodeUnik,
            'isSelesai': e.isSelesai,
            'kodeUnik': e.kodeUnikResponden.kodeUnik,
            'updatedAt': e.kodeUnikResponden.kodeUnik,
          });
    }
  }

  // !TODO : Get total survey

  // Get survey by keyword (name, kartu keluarga, kodeUnikResponden)
  /// - name (String) - optional
  /// - kartuKeluarga (int) - optional
  /// - kodeUnikResponden (int) - optional
  // static Future<List<SurveyModel>> getSurveyByKeyword(
  //   Store store, {
  //   String? name,
  //   int? kartuKeluarga,
  //   int? kodeUnikResponden,
  // }) async {
  //   final surveys = await getSurvey(store);
  //   if (name != null) {
  //     surveys.where((survey) => survey.namaSurvey.name.contains(name));
  //   }
  //   if (kartuKeluarga != null) {
  //     surveys.where((survey) => survey.profile.kartuKeluarga == kartuKeluarga);
  //   }
  //   if (kodeUnikResponden != null) {
  //     surveys.where(
  //         (survey) => survey.kodeUnikResponden.targetId == kodeUnikResponden);
  //   }
  //   return surveys;
  // }

  /// delete survey
  static Future<bool> deleteSurvey(Store store, {required int id}) async {
    return store.box<SurveyModel>().remove(id);
  }

  static Future<dynamic> getTest(Store store, int profileId, int userId) async {
    // Get survey with kodeUnik = 92230298
    // Get Responden object id with kodeUnikResponden = 11223344
    // Get namaSurvey with id = 1
    // Get profile with id = 1
    QueryBuilder<ProfileModel> builder =
        store.box<ProfileModel>().query(ProfileModel_.id.equals(profileId));
    // builder.link(SurveyModel_.kodeUnikResponden,
    //     RespondenModel_.kodeUnik.equals(11223344));
    builder.link(ProfileModel_.user, UserModel_.id.equals(userId));
    // builder.link(SurveyModel_.profile, ProfileModel_.id.equals(1));
    Query<ProfileModel> query = builder.build();
    List<dynamic> result = query.find();

    log(result.toString());
    query.close();
    return result;
  }

  //? Responden
  /// Params:
  /// - store (ObjextBoxStore)
  /// - RespondenData (RespondenModel)
  /// - id (int) - id of the survey optional only if you want to update the survey
  static Future<int> putResponden(Store store, RespondenModel responden) async {
    responden.provinsi.targetId = responden.provinsiId;
    responden.kabupaten.targetId = responden.kabupatenId;
    responden.kecamatan.targetId = responden.kecamatanId;
    responden.kelurahan.targetId = responden.kelurahanId;
    return store.box<RespondenModel>().put(responden);
  }

  /// Get responden
  static Future<List<RespondenModel>> getResponden(Store store) async {
    return store.box<RespondenModel>().getAll();
  }

  /// Get responden by id
  static Future<RespondenModel?> getRespondenById(
    Store store, {
    required int id,
  }) async {
    return store.box<RespondenModel>().get(id);
  }

  /// Get responden by kodeUnik
  static Future<RespondenModel?> getRespondenByKodeUnik(
    Store store, {
    required int kodeUnik,
  }) async {
    final respondens = await getResponden(store);
    return respondens.firstWhere((responden) => responden.kodeUnik == kodeUnik);
  }

  /// Delete responden
  static Future<bool> deleteResponden(Store store, {required int id}) async {
    return store.box<RespondenModel>().remove(id);
  }

  //? Provinsi
  /// Get all provinsi
  static Future<List<ProvinsiModel>> getProvinsi(Store store) async {
    return store.box<ProvinsiModel>().getAll();
  }

  /// put provinsi
  static Future<int> putProvinsi(Store store, ProvinsiModel provinsi) async {
    return store.box<ProvinsiModel>().put(provinsi);
  }

  /// Get provinsi by id
  static Future<ProvinsiModel?> getProvinsiById(
    Store store, {
    required int id,
  }) async {
    return store.box<ProvinsiModel>().get(id);
  }

  /// Delete all provinsi
  static Future<int> deleteAllProvinsi(Store store) async {
    return store.box<RespondenModel>().removeAll();
  }

  //? Kabupaten
  /// Get all kabupaten
  static Future<List<KabupatenModel>> getKabupaten(Store store) async {
    return store.box<KabupatenModel>().getAll();
  }

  /// put kabupaten
  static Future<int> putKabupaten(Store store, KabupatenModel kabupaten) async {
    kabupaten.provinsi.targetId = kabupaten.provinsiId;
    return store.box<KabupatenModel>().put(kabupaten);
  }

  /// delete all kabupaten
  static Future<int> deleteAllKabupaten(Store store) async {
    return store.box<KabupatenModel>().removeAll();
  }

  /// Get kabupaten by id
  static Future<KabupatenModel?> getKabupatenById(
    Store store, {
    required int id,
  }) async {
    return store.box<KabupatenModel>().get(id);
  }

  /// Get kabupaten by provinsiId
  static Future<List<KabupatenModel>> getKabupatenByProvinsiId(
    Store store, {
    required int provinsiId,
  }) async {
    final kabupatens = await getKabupaten(store);
    return kabupatens
        .where((kabupaten) => kabupaten.provinsi.targetId == provinsiId)
        .toList();
  }

  //? Kecamatan
  /// Get all kecamatan
  static Future<List<KecamatanModel>> getKecamatan(Store store) async {
    return store.box<KecamatanModel>().getAll();
  }

  /// Get kecamatan by id
  static Future<KecamatanModel?> getKecamatanById(
    Store store, {
    required int id,
  }) async {
    return store.box<KecamatanModel>().get(id);
  }

  /// Get kecamatan by kabupatenId
  /// - kabupatenId (int)
  static Future<List<KecamatanModel>> getKecamatanByKabupatenId(
    Store store, {
    required int kabupatenId,
  }) async {
    final kecamatans = await getKecamatan(store);
    return kecamatans
        .where((kecamatan) => kecamatan.kabupaten.targetId == kabupatenId)
        .toList();
  }

  /// put kecamatan
  static Future<int> putKecamatan(Store store, KecamatanModel kecamatan) async {
    kecamatan.kabupaten.targetId = kecamatan.kabupatenId;
    return store.box<KecamatanModel>().put(kecamatan);
  }

  /// delete all kecamatan
  static Future<int> deleteAllKecamatan(Store store) async {
    return store.box<KecamatanModel>().removeAll();
  }

  //? Kelurahan
  /// Get all kelurahan
  static Future<List<KelurahanModel>> getKelurahan(Store store) async {
    return store.box<KelurahanModel>().getAll();
  }

  /// Get kelurahan by id
  static Future<KelurahanModel?> getKelurahanById(
    Store store, {
    required int id,
  }) async {
    return store.box<KelurahanModel>().get(id);
  }

  /// Get kelurahan by kecamatanId
  /// - kecamatanId (int)
  static Future<List<KelurahanModel>> getKelurahanByKecamatanId(
    Store store, {
    required int kecamatanId,
  }) async {
    final kelurahans = await getKelurahan(store);
    return kelurahans
        .where((kelurahan) => kelurahan.kecamatan.targetId == kecamatanId)
        .toList();
  }

  /// put kelurahan
  static Future<int> putKelurahan(Store store, KelurahanModel kelurahan) async {
    kelurahan.kecamatan.targetId = kelurahan.kecamatanId;
    return store.box<KelurahanModel>().put(kelurahan);
  }

  /// delete all kelurahan
  static Future<int> deleteAllKelurahan(Store store) async {
    return store.box<KelurahanModel>().removeAll();
  }
}
