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
  final DateTime? date;
  final String status;
  final String? muessiseName;
  final String? muessiseCategory;
  final String? category;
  final String? transactionId;
  final String? subject;
  final String? note;
  final String? currency;
  final String? destination;
  final double? comission;
  final double? cashback;
  final String? cardId;
  final String? userId;
  final String? from;
  final String? fromSirket;
  final Map<String, dynamic>? to;
  final Map<String, dynamic>? additionalData;

  CardTransactionDetails({
    required this.id,
    required this.amount,
    this.createdAt,
    this.date,
    required this.status,
    this.muessiseName,
    this.muessiseCategory,
    this.category,
    this.transactionId,
    this.subject,
    this.note,
    this.currency,
    this.destination,
    this.comission,
    this.cashback,
    this.cardId,
    this.userId,
    this.from,
    this.fromSirket,
    this.to,
    this.additionalData,
  });

  factory CardTransactionDetails.fromJson(Map<String, dynamic> json) {
    // "to" objesi içinden muessise_name'i al
    String? muessiseName;
    if (json['to'] != null && json['to'] is Map<String, dynamic>) {
      muessiseName = json['to']['muessise_name'];
    } else {
      muessiseName = json['muessise_name'];
    }

    return CardTransactionDetails(
      id: json['_id'] ?? json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      status: json['status'] ?? '',
      muessiseName: muessiseName,
      muessiseCategory: json['muessise_category'] ?? json['cardCategory'],
      category: json['category'] ?? json['cardCategory'] ?? 'transaction',
      transactionId: json['transaction_id'],
      subject: json['subject'],
      note: json['note'],
      currency: json['currency'],
      destination: json['destination'],
      comission: json['comission'] != null
          ? (json['comission'] as num).toDouble()
          : null,
      cashback: json['cashback'] != null
          ? (json['cashback'] as num).toDouble()
          : null,
      cardId: json['cards'] ?? json['card_id'],
      userId: json['user'],
      from: json['from'],
      fromSirket: json['from_sirket'],
      to: json['to'] is Map<String, dynamic> ? json['to'] : null,
      additionalData: json['additional_data'] ?? json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'created_at': createdAt?.toIso8601String(),
      'date': date?.toIso8601String(),
      'status': status,
      'muessise_name': muessiseName,
      'muessise_category': muessiseCategory,
      'category': category,
      'transaction_id': transactionId,
      'subject': subject,
      'note': note,
      'currency': currency,
      'destination': destination,
      'comission': comission,
      'cashback': cashback,
      'cards': cardId,
      'user': userId,
      'from': from,
      'from_sirket': fromSirket,
      'to': to,
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
    
    // Önce data objesi içinde transaction detail'i ara
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      details = CardTransactionDetails.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json['transaction_details'] != null && json['transaction_details'] is Map<String, dynamic>) {
      details = CardTransactionDetails.fromJson(json['transaction_details'] as Map<String, dynamic>);
    }

    return CardTransactionDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      transactionDetails: details,
    );
  }
}

/// Card filter item - Filter için kart bilgisi
class CardFilterItem {
  final String id;
  final String name;

  CardFilterItem({
    required this.id,
    required this.name,
  });

  factory CardFilterItem.fromJson(Map<String, dynamic> json) {
    return CardFilterItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Card filter category - Filter için kategori bilgisi
class CardFilterCategory {
  final String id;
  final String name;
  final List<CardFilterItem> cards;

  CardFilterCategory({
    required this.id,
    required this.name,
    required this.cards,
  });

  factory CardFilterCategory.fromJson(Map<String, dynamic> json) {
    List<CardFilterItem> cardsList = [];
    if (json['cards'] != null && json['cards'] is List) {
      cardsList = (json['cards'] as List)
          .map((cardJson) => CardFilterItem.fromJson(cardJson))
          .toList();
    }

    return CardFilterCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cards: cardsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }
}

/// Card filter response - Filter cards endpoint response
class CardFilterResponse {
  final bool success;
  final List<CardFilterCategory> data;

  CardFilterResponse({
    required this.success,
    required this.data,
  });

  factory CardFilterResponse.fromJson(Map<String, dynamic> json) {
    List<CardFilterCategory> categoriesList = [];
    if (json['data'] != null && json['data'] is List) {
      categoriesList = (json['data'] as List)
          .map((categoryJson) => CardFilterCategory.fromJson(categoryJson))
          .toList();
    }

    return CardFilterResponse(
      success: json['success'] ?? false,
      data: categoriesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((category) => category.toJson()).toList(),
    };
  }
}
