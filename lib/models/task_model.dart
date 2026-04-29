class TaskModel {
  final int id;
  final String title;
  final String description;
  final String status;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
    );
  }
}