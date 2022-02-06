# space_x_launches

Test app to search for SpaceX Missions

## Installation

1. Install Flutter
1. Clone this repo
1. Open your favorite command line tool and point it to folder where you clonned the repo (`cd /path/to/repo`)
1. Connect your test device or launch simulator/emulator.
1. Run `flutter run lib/main.dart`

## The Task

Implement an app with a search box, following these requirements:
Fundamental points
1. The user must be able to type a text to search into the SpaceX missions
2. The search must be done by calling the GraphQL query "launches" filtering by the
   “mission_name” field exposed by this public backend: https://api.spacex.land/graphql/
3. The user should see, as a result of the performed search, a list of items composed by
   the ***mission_name*** and ***details*** fields as returned by the server.
4. The search should start only for search text longer than 3 characters. 
5. A reviewer should be able to download the project, install and launch it by reading the README file.
   
## Extra points

1. Use bloc and repo pattern (P of EAA: Repository (martinfowler.com)) (2 points) OR use
   plain change notifier provider (1 point)
2. Cover the project with bloc (unit) tests (2 points)
3. Paginated list of 10 items each
   
## Important

- Remember that a pleasant user experience will be taken into consideration
- Don't forget the KISS principle: https://en.wikipedia.org/wiki/KISS_principle
