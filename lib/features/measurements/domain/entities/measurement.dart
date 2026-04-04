class Measurement {
  final String id;
  final DateTime date;
  final double? weight;
  final double? waist;
  final double? chest;
  final double? hips;

  Measurement({required this.id, required this.date, this.weight, this.waist, this.chest, this.hips});
}