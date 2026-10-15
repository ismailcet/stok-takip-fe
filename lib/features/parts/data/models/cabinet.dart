class Cabinet {
  final int id;
  final String name;

  const Cabinet({required this.id, required this.name});

  factory Cabinet.fromJson(Map<String, dynamic> json) {
    return Cabinet(id: json['id'] as int, name: json['name'] as String);
  }
}
