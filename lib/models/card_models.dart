class CardCondition {
  final String id;
  final String title;
  final String description;
  final String status;

  CardCondition({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory CardCondition.fromJson(Map<String, dynamic> json) {
    return CardCondition(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
    };
  }
}

class Card {
  final String id;
  final String name;
  final String? description;
  final String backgroundColor;
  final String icon;
  final String? category;
  final String currentStatus;
  final bool isActive;
  final List<CardCondition> conditions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? balance; // API'den gelen balance bilgisi

  Card({
    required this.id,
    required this.name,
    this.description,
    required this.backgroundColor,
    required this.icon,
    this.category,
    required this.currentStatus,
    this.isActive = false,
    this.conditions = const [],
    this.createdAt,
    this.updatedAt,
    this.balance,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    List<CardCondition> conditionsList = [];
    if (json['conditions'] != null && json['conditions'] is List) {
      conditionsList = (json['conditions'] as List)
          .map((conditionJson) => CardCondition.fromJson(conditionJson))
          .toList();
    }

    return Card(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      backgroundColor: json['color'] ?? json['background_color'] ?? '#4CAF50',
      icon: json['icon'] ?? '',
      category: json['category'],
      currentStatus: json['current_status'] ?? 'inactive',
      isActive: json['isActive'] ?? false,
      conditions: conditionsList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      balance:
          json['balance'] != null ? (json['balance'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'background_color': backgroundColor,
      'icon': icon,
      'category': category,
      'current_status': currentStatus,
      'isActive': isActive,
      'conditions': conditions.map((condition) => condition.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'balance': balance,
    };
  }
}

class CardTransaction {
  final String id;
  final double amount;
  final DateTime? createdAt;
  final String status;
  final String? muessiseName;
  final String? muessiseCategory;
  final String category;

  CardTransaction({
    required this.id,
    required this.amount,
    this.createdAt,
    required this.status,
    this.muessiseName,
    this.muessiseCategory,
    required this.category,
  });

  factory CardTransaction.fromJson(Map<String, dynamic> json) {
    return CardTransaction(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      status: json['status'] ?? '',
      muessiseName: json['muessise_name'],
      muessiseCategory: json['muessise_category'],
      category: json['category'] ?? 'transaction',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'created_at': createdAt?.toIso8601String(),
      'status': status,
      'muessise_name': muessiseName,
      'muessise_category': muessiseCategory,
      'category': category,
    };
  }
}

class CardTransactionDetails {
  final String id;
  final double amount;
  final DateTime? createdAt;
  final String status;
  final String? muessiseName;
  final String? muessiseCategory;
  final String category;
  final Map<String, dynamic>? additionalData;

  CardTransactionDetails({
    required this.id,
    required this.amount,
    this.createdAt,
    required this.status,
    this.muessiseName,
    this.muessiseCategory,
    required this.category,
    this.additionalData,
  });

  factory CardTransactionDetails.fromJson(Map<String, dynamic> json) {
    return CardTransactionDetails(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      status: json['status'] ?? '',
      muessiseName: json['muessise_name'],
      muessiseCategory: json['muessise_category'],
      category: json['category'] ?? 'transaction',
      additionalData: json['additional_data'] ?? json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'created_at': createdAt?.toIso8601String(),
      'status': status,
      'muessise_name': muessiseName,
      'muessise_category': muessiseCategory,
      'category': category,
      'additional_data': additionalData,
    };
  }
}

class CardsResponse {
  final bool success;
  final String? message;
  final List<Card>? cards;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  CardsResponse({
    required this.success,
    this.message,
    this.cards,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });

  factory CardsResponse.fromJson(Map<String, dynamic> json) {
    List<Card> cardsList = [];
    if (json['cards'] != null && json['cards'] is List) {
      cardsList = (json['cards'] as List)
          .map((cardJson) => Card.fromJson(cardJson))
          .toList();
    } else if (json['data'] != null && json['data'] is List) {
      cardsList = (json['data'] as List)
          .map((cardJson) => Card.fromJson(cardJson))
          .toList();
    }

    return CardsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      cards: cardsList,
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['total_pages'] ?? json['totalPages'],
    );
  }
}

class CardTransactionsResponse {
  final bool success;
  final String? message;
  final List<CardTransaction>? transactions;
  final int? page;
  final int? skip;
  final int? limit;
  final int? total;

  CardTransactionsResponse({
    required this.success,
    this.message,
    this.transactions,
    this.page,
    this.skip,
    this.limit,
    this.total,
  });

  factory CardTransactionsResponse.fromJson(Map<String, dynamic> json) {
    List<CardTransaction> transactionsList = [];
    if (json['data'] != null && json['data'] is List) {
      transactionsList = (json['data'] as List)
          .map((transactionJson) => CardTransaction.fromJson(transactionJson))
          .toList();
    }

    return CardTransactionsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      transactions: transactionsList,
      page: json['page'],
      skip: json['skip'],
      limit: json['limit'],
      total: json['total'],
    );
  }
}

class CardTransactionDetailsResponse {
  final bool success;
  final String? message;
  final CardTransactionDetails? transactionDetails;

  CardTransactionDetailsResponse({
    required this.success,
    this.message,
    this.transactionDetails,
  });

  factory CardTransactionDetailsResponse.fromJson(Map<String, dynamic> json) {
    CardTransactionDetails? details;
    if (json['transaction_details'] != null) {
      details = CardTransactionDetails.fromJson(json['transaction_details']);
    } else if (json['data'] != null) {
      details = CardTransactionDetails.fromJson(json['data']);
    }

    return CardTransactionDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      transactionDetails: details,
    );
  }
}
