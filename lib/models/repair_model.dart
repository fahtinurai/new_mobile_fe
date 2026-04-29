class RepairModel {
  final int id;
  final String unitName;
  final String progress;
  final String mechanicName;

  RepairModel({
    required this.id,
    required this.unitName,
    required this.progress,
    required this.mechanicName,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['id'],
      unitName: json['unit_name'],
      progress: json['progress'],
      mechanicName: json['mechanic_name'],
    );
  }
}