class Membership {
  final String id;
  final String sirketName;
  final String? profileImagePath;
  final String hireDate;
  final String status;
  final String? endDate;

  Membership({
    required this.id,
    required this.sirketName,
    this.profileImagePath,
    required this.hireDate,
    required this.status,
    this.endDate,
  });

  String? get fullProfileImageUrl {
    if (profileImagePath == null || profileImagePath!.isEmpty) {
      return null;
    }

    if (profileImagePath!.startsWith('http://') ||
        profileImagePath!.startsWith('https://')) {
      return profileImagePath;
    }

    // Path ise domain ekle
    return 'https://merchant.avankart.com$profileImagePath';
  }

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['_id'] ?? '',
      sirketName: json['sirket_name'] ?? '',
      profileImagePath: json['profile_image_path'],
      hireDate: json['hire_date'] ?? '',
      status: json['status'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sirket_name': sirketName,
      'profile_image_path': profileImagePath,
      'hire_date': hireDate,
      'status': status,
      'end_date': endDate,
    };
  }
}

class MembershipDetail {
  final String name;
  final String hireDate;
  final String? endDate;
  final int total;
  final List<dynamic> categories;

  MembershipDetail({
    required this.name,
    required this.hireDate,
    this.endDate,
    required this.total,
    required this.categories,
  });

  factory MembershipDetail.fromJson(Map<String, dynamic> json) {
    return MembershipDetail(
      name: json['name'] ?? '',
      hireDate: json['hire_date'] ?? '',
      endDate: json['end_date'],
      total: json['total'] ?? 0,
      categories: json['categories'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hire_date': hireDate,
      'end_date': endDate,
      'total': total,
      'categories': categories,
    };
  }
}

class MembershipsResponse {
  final bool success;
  final List<Membership> memberships;
  final String? message;

  MembershipsResponse({
    required this.success,
    required this.memberships,
    this.message,
  });

  factory MembershipsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    return MembershipsResponse(
      success: json['success'] ?? false,
      memberships: data.map((item) => Membership.fromJson(item)).toList(),
      message: json['message'],
    );
  }
}

class MembershipDetailResponse {
  final bool success;
  final MembershipDetail? membershipDetail;
  final String? message;

  MembershipDetailResponse({
    required this.success,
    this.membershipDetail,
    this.message,
  });

  factory MembershipDetailResponse.fromJson(Map<String, dynamic> json) {
    return MembershipDetailResponse(
      success: json['success'] ?? false,
      membershipDetail:
          json['data'] != null ? MembershipDetail.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}
