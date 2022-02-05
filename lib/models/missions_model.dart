import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MissionsModel {
  int missionsPerPage = 10;
  int currentOffset = 0;
  String searchQuery = "";

  final graphQlClient = ValueNotifier(GraphQLClient(
    link: HttpLink('https://api.spacex.land/graphql'),
    cache: GraphQLCache(),
  ));

  String readMissions = """
  query ReadMissions(\$searchQuery: String!, \$missionsPerPage: Int!, \$offset: Int!) {
    launches(find: {mission_name: \$searchQuery}, limit: \$missionsPerPage, sort: "launch_date_unix", offset:\$offset ) {
      details
      mission_name
      ships {
        name
        image
      }
      id
    }
  }
  """;
}
