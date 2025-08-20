class MuessiseModel {
  final String? id;
  final String? activityType;
  final int? commissionPercentage;
  final Map<String, dynamic>? authorizedPerson;
  final String? muessiseId;
  final int? companyStatus;
  final String? muessiseName;
  final String? muessiseCategory;
  final String? address;
  final List<String>? services;
  final String? description;
  final List<dynamic>? cards;
  final Map<String, dynamic>? schedule;
  final List<String>? phone;
  final List<String>? email;
  final List<String>? website;
  final Map<String, dynamic>? social;
  final String? xariciCoverImage;
  final String? xariciCoverImagePath;
  final String? daxiliCoverImage;
  final String? daxiliCoverImagePath;
  final String? profileImage;
  final String? profileImagePath;

  MuessiseModel({
    this.id,
    this.activityType,
    this.commissionPercentage,
    this.authorizedPerson,
    this.muessiseId,
    this.companyStatus,
    this.muessiseName,
    this.muessiseCategory,
    this.address,
    this.services,
    this.description,
    this.cards,
    this.schedule,
    this.phone,
    this.email,
    this.website,
    this.social,
    this.xariciCoverImage,
    this.xariciCoverImagePath,
    this.daxiliCoverImage,
    this.daxiliCoverImagePath,
    this.profileImage,
    this.profileImagePath,
  });

  factory MuessiseModel.fromJson(Map<String, dynamic> json) {
    return MuessiseModel(
      id: json['_id'],
      activityType: json['activity_type'],
      commissionPercentage: json['commission_percentage'],
      authorizedPerson: json['authorized_person'],
      muessiseId: json['muessise_id'],
      companyStatus: json['company_status'],
      muessiseName: json['muessise_name'],
      muessiseCategory: json['muessise_category'],
      address: json['address'],
      services:
          json['services'] != null ? List<String>.from(json['services']) : null,
      description: json['description'],
      cards: json['cards'],
      schedule: json['schedule'],
      phone: json['phone'] != null ? List<String>.from(json['phone']) : null,
      email: json['email'] != null ? List<String>.from(json['email']) : null,
      website:
          json['website'] != null ? List<String>.from(json['website']) : null,
      social: json['social'],
      xariciCoverImage: json['xarici_cover_image'],
      xariciCoverImagePath: json['xarici_cover_image_path'],
      daxiliCoverImage: json['daxili_cover_image'],
      daxiliCoverImagePath: json['daxili_cover_image_path'],
      profileImage: json['profile_image'],
      profileImagePath: json['profile_image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'activity_type': activityType,
      'commission_percentage': commissionPercentage,
      'authorized_person': authorizedPerson,
      'muessise_id': muessiseId,
      'company_status': companyStatus,
      'muessise_name': muessiseName,
      'muessise_category': muessiseCategory,
      'address': address,
      'services': services,
      'description': description,
      'cards': cards,
      'schedule': schedule,
      'phone': phone,
      'email': email,
      'website': website,
      'social': social,
      'xarici_cover_image': xariciCoverImage,
      'xarici_cover_image_path': xariciCoverImagePath,
      'daxili_cover_image': daxiliCoverImage,
      'daxili_cover_image_path': daxiliCoverImagePath,
      'profile_image': profileImage,
      'profile_image_path': profileImagePath,
    };
  }
}

class UserModel {
  final String? id;
  final String? name;
  final String? surname;
  final String? partnyorId;
  final dynamic muessiseId; // String veya MuessiseModel olabilir
  final String? email;
  final String? username;
  final String? phone;
  final DateTime? birthDate;
  final int? totalQrCodes;
  final int? todayQrCodes;
  final String? lastLoginIp;
  final String? lastUserAgent;
  final String? language;
  final String? theme;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.surname,
    this.partnyorId,
    this.muessiseId,
    this.email,
    this.username,
    this.phone,
    this.birthDate,
    this.totalQrCodes,
    this.todayQrCodes,
    this.lastLoginIp,
    this.lastUserAgent,
    this.language,
    this.theme,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // muessise_id alanını kontrol et
    dynamic muessiseIdData = json['muessise_id'];
    dynamic parsedMuessiseId;

    if (muessiseIdData != null) {
      if (muessiseIdData is String) {
        // String ise olduğu gibi kullan
        parsedMuessiseId = muessiseIdData;
      } else if (muessiseIdData is Map<String, dynamic>) {
        // Map ise MuessiseModel'e çevir
        parsedMuessiseId = MuessiseModel.fromJson(muessiseIdData);
      }
    }

    return UserModel(
      id: json['_id'],
      name: json['name'],
      surname: json['surname'],
      partnyorId: json['partnyor_id'],
      muessiseId: parsedMuessiseId,
      email: json['email'],
      username: json['username'],
      phone: json['phone'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      totalQrCodes: json['total_qr_codes'],
      todayQrCodes: json['today_qr_codes'],
      lastLoginIp: json['last_login_ip'],
      lastUserAgent: json['last_user_agent'],
      language: json['language'],
      theme: json['theme'],
      status: json['status'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'surname': surname,
      'partnyor_id': partnyorId,
      'muessise_id':
          muessiseId is MuessiseModel ? muessiseId.toJson() : muessiseId,
      'email': email,
      'username': username,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'total_qr_codes': totalQrCodes,
      'today_qr_codes': todayQrCodes,
      'last_login_ip': lastLoginIp,
      'last_user_agent': lastUserAgent,
      'language': language,
      'theme': theme,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Muessise bilgilerini almak için yardımcı metodlar
  String? get muessiseIdString {
    if (muessiseId is String) {
      return muessiseId as String;
    } else if (muessiseId is MuessiseModel) {
      return (muessiseId as MuessiseModel).muessiseId;
    }
    return null;
  }

  MuessiseModel? get muessiseModel {
    if (muessiseId is MuessiseModel) {
      return muessiseId as MuessiseModel;
    }
    return null;
  }

  String? get muessiseName {
    if (muessiseId is MuessiseModel) {
      return (muessiseId as MuessiseModel).muessiseName;
    }
    return null;
  }

  String? get muessiseCategory {
    if (muessiseId is MuessiseModel) {
      return (muessiseId as MuessiseModel).muessiseCategory;
    }
    return null;
  }

  // Profil bilgileri için yardımcı metodlar
  String? get fullName {
    if (name != null && surname != null) {
      return '$name $surname';
    } else if (name != null) {
      return name;
    } else if (surname != null) {
      return surname;
    }
    return null;
  }

  String? get formattedBirthDate {
    if (birthDate != null) {
      return '${birthDate!.day.toString().padLeft(2, '0')}.${birthDate!.month.toString().padLeft(2, '0')}.${birthDate!.year}';
    }
    return null;
  }

  String? get formattedPhone {
    if (phone != null) {
      String cleanPhone =
          phone!.replaceAll(RegExp(r'[^\d]'), ''); // Sadece rakamları al

      // Eğer telefon numarası 994 ile başlıyorsa
      if (cleanPhone.startsWith('994')) {
        cleanPhone = cleanPhone.substring(3); // 994'ü çıkar
      }

      // Eğer telefon numarası 9 haneli değilse null döndür
      if (cleanPhone.length != 9) {
        return null;
      }

      // +994 XX XXX XX XX formatında formatla
      return '+994 ${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 5)} ${cleanPhone.substring(5, 7)} ${cleanPhone.substring(7, 9)}';
    }
    return null;
  }
}
