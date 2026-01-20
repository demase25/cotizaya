enum BudgetStatus { pending, paid }

class BudgetModel {
  final String id;
  final String clientName;
  final double total;
  final BudgetStatus status;
  final DateTime date;

  BudgetModel({
    required this.id,
    required this.clientName,
    required this.total,
    required this.status,
    required this.date,
  });

  bool get isPaid => status == BudgetStatus.paid;
  bool get isPending => status == BudgetStatus.pending;

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientName': clientName,
        'total': total,
        'status': status.index,
        'date': date.toIso8601String(),
      };

  factory BudgetModel.fromMap(Map map) {
    return BudgetModel(
      id: map['id'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] != null
          ? BudgetStatus.values[map['status'] as int]
          : BudgetStatus.pending,
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
    );
  }

  BudgetModel copyWith({
    String? id,
    String? clientName,
    double? total,
    BudgetStatus? status,
    DateTime? date,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      total: total ?? this.total,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}
