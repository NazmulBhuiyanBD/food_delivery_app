class Voucher {
  final String id;
  final String code;
  final double percentage; // e.g., 0.10 for 10%
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.percentage,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'percentage': percentage,
      'isActive': isActive,
    };
  }

  factory Voucher.fromMap(String id, Map<String, dynamic> data) {
    return Voucher(
      id: id,
      code: data['code'] ?? '',
      percentage: (data['percentage'] as num).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }
}