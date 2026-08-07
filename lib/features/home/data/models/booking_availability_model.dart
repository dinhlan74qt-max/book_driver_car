class BookingAvailabilityModel {
  final int id;
  final DateTime startDate;
  final DateTime endDate;

  const BookingAvailabilityModel({
    required this.id,
    required this.startDate,
    required this.endDate,
  });

  factory BookingAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return BookingAvailabilityModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: DateTime.parse(json['endDate'].toString()),
    );
  }
}
