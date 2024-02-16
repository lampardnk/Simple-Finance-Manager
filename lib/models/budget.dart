class Budget {
  final String type;
  double amount;

  Budget({
    required this.type,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
    };
  }
}
