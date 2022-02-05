import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:space_x_launches/i18n.dart';
import 'package:space_x_launches/models/mission.dart';
import 'package:space_x_launches/models/missions_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _resultsVisible = false;
  late TextEditingController _textEditingController;
  late ScrollController _resultsListScrollController;
  final _inputKey = const ValueKey("input");
  final _animationDuration = const Duration(milliseconds: 300);

  String _query = "";

  _resultsListScrollControllerHandler() {
    print("_resultsListScrollController: ${_resultsListScrollController.offset}");
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: _query);
    _resultsListScrollController = ScrollController();
    _resultsListScrollController.addListener(_resultsListScrollControllerHandler);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _resultsListScrollController.removeListener(_resultsListScrollControllerHandler);
    _resultsListScrollController.dispose();
    super.dispose();
  }

  _searchFiledChanged(String newValue) {
    setState(() {
      _query = _textEditingController.text;
      if (_query.length > 3) {
        _resultsVisible = true;
        _performSearch();
      } else {
        _resultsVisible = false;
      }
    });
  }

  _performSearch() {}

  @override
  Widget build(BuildContext context) {
    var missionsModel = Provider.of<MissionsModel>(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              if (!_resultsVisible) Expanded(child: AnimatedContainer(duration: _animationDuration,)),
              AnimatedContainer(
                duration: _animationDuration,
                key: _inputKey,
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: Theme.of(context).primaryColor)),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: TextField(
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              border: InputBorder.none,
                              hintText: "Start here".i18n,
                              // labelText: "Search".i18n,
                            ),
                            onChanged: (value) => _searchFiledChanged(value),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: _performSearch,
                          icon: const Icon(Icons.search))
                    ]),
              ),
              if (!_resultsVisible) const Spacer(),
              if (_resultsVisible) Expanded(child:
                  Query(
                    options: QueryOptions(
                      document: gql(missionsModel.readMissions),
                      variables: {
                        'searchQuery': _query,
                        'missionsPerPage': missionsModel.missionsPerPage,
                        'offset': missionsModel.currentOffset,
                      },
                      // pollInterval: const Duration(seconds: 10),
                    ),
                    builder: (result, {fetchMore, refetch}) {
                      if (result.hasException) {
                        return Center(child: Text(result.exception.toString()));
                      }
                      if (result.isLoading) {
                        return Center(child: Text('Loading'.i18n));
                      }

                      List launchesRaw = result.data!['launches'];

                      if(launchesRaw.isEmpty) {
                        return Center(child: Text('Nothing found'.i18n));
                      }

                      final missions = List<Mission>.from(launchesRaw.map((value) => Mission.fromJson(value)));
                      final missionsCount = missions.length;

                      return ListView.builder(
                        controller: _resultsListScrollController,
                          itemCount: missionsCount,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(missions[index].name),
                              subtitle: Text(missions[index].details),
                            );
                          });
                    },
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
