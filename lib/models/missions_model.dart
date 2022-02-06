import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:space_x_launches/models/mission.dart';

class MissionsModel {
  final missionsPerPage = 10;

  final GraphQLClient graphQlClient = GraphQLClient(
    link: HttpLink('https://api.spacex.land/graphql'),
    cache: GraphQLCache(),
  );

  String readMissions = """
  query ReadMissions(\$searchQuery: String!, \$missionsPerPage: Int!, \$offset: Int!) {
    launches(find: {mission_name: \$searchQuery}, limit: \$missionsPerPage, sort: "launch_date_unix", offset:\$offset ) {
      id
      details
      mission_name
    }
  }
  """;

  StreamSubscription? _loadMissionsSubscription;

  // bool get loadMissionsInProgress => _loadMissionsSubscription != null;

  Future<List<Mission>> loadMissions(String query, int offset) async {
    print("offset: $offset");
    cancelLoadMissions();
    var completer = Completer<List<Mission>>();
    var options = QueryOptions(
      document: gql(readMissions),
      fetchPolicy: FetchPolicy.noCache,
      variables: {
        'searchQuery': query,
        'missionsPerPage': missionsPerPage,
        'offset': offset,
      },
    ).asWatchQueryOptions();
    var observableQuery = graphQlClient.watchQuery(options);
    _loadMissionsSubscription = observableQuery.stream.listen((event) {
      var data = observableQuery.latestResult?.data;
      if (data != null) {
        final List launchesRaw = data['launches'];
        final missions = List<Mission>.from(
            launchesRaw.map((value) => Mission.fromJson(value)));
        cancelLoadMissions();
        completer.complete(missions);
      }
    }, onError: (object) {
      completer.completeError(object);
    });
    return completer.future;
  }

  cancelLoadMissions() {
    _loadMissionsSubscription?.cancel();
    _loadMissionsSubscription = null;
  }
}
