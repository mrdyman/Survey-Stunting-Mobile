import 'package:objectbox/objectbox.dart';
import 'package:survey_stunting/models/localDb/profile_model.dart';

@Entity()
class UserModel {
  int? id = 0;
  String? username;
  String? password;
  String? status;
  String? role;
  int? profileId;

  UserModel(
      {this.id,
      this.username,
      this.password,
      this.status,
      this.role,
      this.profileId});

  final profile = ToOne<ProfileModel>();
}
