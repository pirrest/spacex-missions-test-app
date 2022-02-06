import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:space_x_launches/models/mission.dart';

class MissionsModel {
  final missionsPerPage = 10;

  final GraphQLClient _graphQlClient = GraphQLClient(
    link: HttpLink('https://api.spacex.land/graphql'),
    cache: GraphQLCache(),
  );

  final String _readMissions = """
  query ReadMissions(\$searchQuery: String!, \$missionsPerPage: Int!, \$offset: Int!) {
    launches(find: {mission_name: \$searchQuery}, limit: \$missionsPerPage, offset:\$offset ) {
      id
      details
      mission_name
    }
  }
  """;

  Future<List<Mission>> loadMissions(String query, int offset) async {
    var completer = Completer<List<Mission>>();
    var options = QueryOptions(
      document: gql(_readMissions),
      variables: {
        'searchQuery': query,
        'missionsPerPage': missionsPerPage,
        'offset': offset,
      },
    );
    _graphQlClient.query(options).then((value) {
      var data = value.data;
      if (data != null) {
        final List launchesRaw = data['launches'];
        final missions = List<Mission>.from(
            launchesRaw.map((value) => Mission.fromJson(value)));
        completer.complete(missions);
      }
    });
    return completer.future;
  }
}
