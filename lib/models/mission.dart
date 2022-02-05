class Mission {
  Mission.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        name = json['mission_name'],
        details = json['details'],
        ships = [
          for (var shipRaw in json['ships']) MissionShip.fromJson(shipRaw)
        ];
  final int id;
  final String name;
  final String details;
  final List<MissionShip> ships;
}

class MissionShip {
  MissionShip.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        image = json['image'];
  final String name;
  final String image;
}
