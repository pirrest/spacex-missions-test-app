import 'package:space_x_launches/i18n.dart';

class Mission {
  Mission.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        name = json['mission_name'],
        details = json['details'] ?? 'No details'.i18n,
        ships = [
          for (var shipRaw in json['ships']) MissionShip.fromJson(shipRaw)
        ];
  final int id;
  final String name;
  final String details;
  final List<MissionShip> ships;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mission && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MissionShip {
  MissionShip.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        image = json['image'];
  final String name;
  final String? image;
}
