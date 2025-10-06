class QrCheckResponseModel {
  final bool success;
  final String message;
  final QrCheckData? data;

  QrCheckResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory QrCheckResponseModel.fromJson(Map<String, dynamic> json) {
    return QrCheckResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? QrCheckData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class QrCheckData {
  final String qrCodeId;
  final String? muessiseName;
  final String? sirketName;
  final String amount;
  final String transactionId;
  final int qrStatus;
  final String? cardName;
  final int cardBalance;
  final String timestamp;
  final String userSirketId;
  final String qrCode;
  final String expireTime;

  QrCheckData({
    required this.qrCodeId,
    this.muessiseName,
    this.sirketName,
    required this.amount,
    required this.transactionId,
    required this.qrStatus,
    this.cardName,
    required this.cardBalance,
    required this.timestamp,
    required this.userSirketId,
    required this.qrCode,
    required this.expireTime,
  });

  factory QrCheckData.fromJson(Map<String, dynamic> json) {
    return QrCheckData(
      qrCodeId: json['qr_code_id'] ?? '',
      muessiseName: json['muessise_name'],
      sirketName: json['sirket_name'],
      amount: json['amount'] ?? '0.00',
      transactionId: json['transaction_id'] ?? '',
      qrStatus: json['qr_status'] ?? 0,
      cardName: json['card_name'],
      cardBalance: json['card_balance'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      userSirketId: json['user_sirket_id'] ?? '',
      qrCode: json['qr_code'] ?? '',
      expireTime: json['expire_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_code_id': qrCodeId,
      'muessise_name': muessiseName,
      'sirket_name': sirketName,
      'amount': amount,
      'transaction_id': transactionId,
      'qr_status': qrStatus,
      'card_name': cardName,
      'card_balance': cardBalance,
      'timestamp': timestamp,
      'user_sirket_id': userSirketId,
      'qr_code': qrCode,
      'expire_time': expireTime,
    };
  }
}
