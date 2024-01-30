class Budget {
  final String type;
  double amount;

  Budget({
    required this.type,
    required this.amount,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      type: json['type'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
    };
  }
}
