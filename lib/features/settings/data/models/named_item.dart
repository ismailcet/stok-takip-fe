/// Firma ve dolap gibi {id, name} yapısındaki kayıtlar.
class NamedItem {
  final int id;
  final String name;

  const NamedItem({required this.id, required this.name});

  factory NamedItem.fromJson(Map<String, dynamic> json) {
    return NamedItem(id: json['id'] as int, name: json['name'] as String);
  }
}
