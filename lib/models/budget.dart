class Budget {
  final String type;
  double amount;

  Budget({
    required this.type,
    required this.amount,
  });

  // Add the fromJson method
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      type: json['type'],
      amount: json['amount'],
    );
  }

  // Add the toJson method
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
    };
  }
}
