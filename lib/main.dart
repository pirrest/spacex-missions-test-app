import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:space_x_launches/models/missions_model.dart';
import 'package:space_x_launches/screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var missionsModel = MissionsModel();
    return Provider<MissionsModel>(
      create: (context) => missionsModel,
      child: GraphQLProvider(
        client: missionsModel.graphQlClient,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ""),
            Locale('ru', ""),
            Locale('uk', ""),
          ],
          home: const SearchScreen(),
        ),
      ),
    );
  }
}