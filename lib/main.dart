import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';
import 'package:space_x_launches/i18n.dart';
import 'package:space_x_launches/models/missions_model.dart';
import 'package:space_x_launches/screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Future<void> _loadLocalizations;

  @override
  void initState() {
    super.initState();
    _loadLocalizations = MyI18n.loadTranslations();
  }

  @override
  Widget build(BuildContext context) {
    var missionsModel = MissionsModel();
    return FutureBuilder(
      future:_loadLocalizations,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          return Provider<MissionsModel>(
            create: (context) => missionsModel,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
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
              home: I18n(child: const SearchScreen()),
            ),
          );
        } else {
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset(
                  "assets/images/logo.png",
                ),
              ));
        }
      },
    );
  }
}
