import 'package:space_x_launches/i18n.dart';

class Mission {
  Mission.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        name = json['mission_name'],
        details = json['details'] ?? 'No details'.i18n;
  final int id;
  final String name;
  final String details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mission && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}