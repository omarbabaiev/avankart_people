import 'package:avankart_people/models/company_models.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? surname;
  final CompanyModel? companyInfo;
  final double? totalBalance;
  final DateTime? lastPaymentDate;
  final String? lastPaymentLocation;
  final String? email;
  final String? password;
  final DateTime? lastPasswordUpdate;
  final int? phoneSuffix;
  final String? phone;
  final DateTime? birthDate;
  final int? totalQrCodes;
  final int? todayQrCodes;
  final String? duty;
  final String? perm;
  final String? lastLoginIp;
  final String? lastUserAgent;
  final String? language;
  final String? theme;
  final String? gender;
  final String? otpCode;
  final DateTime? hireDate;
  final DateTime? dismissalDate;
  final String? otpDestination;
  final int? otpEmailStatus;
  final int? otpSmsStatus;
  final int? otpAuthenticatorStatus;
  final int? status;
  final String? token;
  final String? firebaseToken;
  final bool? deleted;
  final DateTime? lastQrCode;
  final DateTime? otpSendTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? peopleId;
  final int? version;

  UserModel({
    this.id,
    this.name,
    this.surname,
    this.companyInfo,
    this.totalBalance,
    this.lastPaymentDate,
    this.lastPaymentLocation,
    this.email,
    this.password,
    this.lastPasswordUpdate,
    this.phoneSuffix,
    this.phone,
    this.birthDate,
    this.totalQrCodes,
    this.todayQrCodes,
    this.duty,
    this.perm,
    this.lastLoginIp,
    this.lastUserAgent,
    this.language,
    this.theme,
    this.gender,
    this.otpCode,
    this.hireDate,
    this.dismissalDate,
    this.otpDestination,
    this.otpEmailStatus,
    this.otpSmsStatus,
    this.otpAuthenticatorStatus,
    this.status,
    this.token,
    this.firebaseToken,
    this.deleted,
    this.lastQrCode,
    this.otpSendTime,
    this.createdAt,
    this.updatedAt,
    this.peopleId,
    this.version,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      surname: json['surname'],
      companyInfo: json['sirket_id'] != null
          ? CompanyModel.fromJson(json['sirket_id'])
          : null,
      totalBalance: json['totalBalance']?.toDouble(),
      lastPaymentDate: json['lastPaymentDate'] != null
          ? DateTime.parse(json['lastPaymentDate'])
          : null,
      lastPaymentLocation: json['lastPaymentLocation'],
      email: json['email'],
      password: json['password'],
      lastPasswordUpdate: json['last_password_update'] != null
          ? DateTime.parse(json['last_password_update'])
          : null,
      phoneSuffix: json['phone_suffix'],
      phone: json['phone'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      totalQrCodes: json['total_qr_codes'],
      todayQrCodes: json['today_qr_codes'],
      duty: json['duty'],
      perm: json['perm'],
      lastLoginIp: json['last_login_ip'],
      lastUserAgent: json['last_user_agent'],
      language: json['language'],
      theme: json['theme'],
      gender: json['gender'],
      otpCode: json['otp_code'],
      hireDate:
          json['hire_date'] != null ? DateTime.parse(json['hire_date']) : null,
      dismissalDate: json['dismissal_date'] != null
          ? DateTime.parse(json['dismissal_date'])
          : null,
      otpDestination: json['otp_destination'],
      otpEmailStatus: json['otp_email_status'],
      otpSmsStatus: json['otp_sms_status'],
      otpAuthenticatorStatus: json['otp_authenticator_status'],
      status: json['status'],
      token: json['token'],
      firebaseToken: json['firebase_token'],
      deleted: json['deleted'],
      lastQrCode: json['last_qr_code'] != null
          ? DateTime.parse(json['last_qr_code'])
          : null,
      otpSendTime: json['otp_send_time'] != null
          ? DateTime.parse(json['otp_send_time'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      peopleId: json['people_id'],
      version: json['__v'],
    );
  }
}
