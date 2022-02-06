import 'dart:async';

import 'package:flutter/material.dart';
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
  late MissionsModel _missionsModel;
  Set<Mission> _missions = {};
  int _page = 0;
  int _nextPage = 0;
  Timer? _searchTimer;
  Future<List<Mission>>? _searchFuture;
  final _inputFocusNode = FocusNode();
  String get _trimmedQuery => _textEditingController.text.trim();

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: "");
    _resultsListScrollController = ScrollController();
    _resultsListScrollController
        .addListener(_resultsListScrollControllerHandler);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _resultsListScrollController
        .removeListener(_resultsListScrollControllerHandler);
    _resultsListScrollController.dispose();
    _removeSearchTimer();
    _inputFocusNode.dispose();
    super.dispose();
  }

  _resultsListScrollControllerHandler() {
    if (_nextPage > _page &&
        _resultsListScrollController.offset >=
            _resultsListScrollController.position.maxScrollExtent) {
      print("_nextPage: $_nextPage, _page: $_page");
      setState(() {
        _page = _nextPage;
        _search(keepLastResult: true);
      });
    }
  }

  _resetSearch({bool keepQuery = false}) {
    setState(() {
      if(!keepQuery) {
        _textEditingController.text = "";
      }
      _page = 0;
      _nextPage = 0;
      _missions = {};
      _resultsVisible = false;
      _removeSearchTimer();
      _missionsModel.cancelLoadMissions();
    });
  }

  _gainFocus() {
    if (!_inputFocusNode.hasFocus && _inputFocusNode.canRequestFocus) {
      _inputFocusNode.requestFocus();
    }
  }

  _releaseFocus() {
    if(_inputFocusNode.hasFocus) {
      _inputFocusNode.unfocus();
    }
  }

  _searchFiledChanged(String newValue) {
    setState(() {
      if (_trimmedQuery.length > 3) {
        _missionsModel.cancelLoadMissions();
        _removeSearchTimer();
        _searchTimer = Timer(const Duration(seconds: 1), _search);
      } else {
        _resetSearch(keepQuery: true);
      }
    });
  }

  _search({bool keepLastResult = false}) {
    _removeSearchTimer();
    setState(() {
      if(!keepLastResult) {
        _missions.clear();
      }
      _searchFuture =
          _missionsModel.loadMissions(_trimmedQuery, _page*_missionsModel.missionsPerPage);
      _resultsVisible = true;
    });
  }

  void _removeSearchTimer() {
    _searchTimer?.cancel();
    _searchTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    _missionsModel = Provider.of<MissionsModel>(context);
    const inputHeight = 50.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
          child: Stack(
            children: [
              if (_resultsVisible)
                GestureDetector(
                  onTapDown: (details) => _releaseFocus(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: inputHeight),
                    child: FutureBuilder<List<Mission>>(
                      future: _searchFuture,
                      builder: (context, snapshot) {

                        if (snapshot.hasError) {
                          return Center(
                              child: Text(snapshot.error!.toString()));
                        }

                        if (!snapshot.hasData ||
                            (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                _missions.isEmpty)) {
                          return const Center(
                              child: CircularProgressIndicator.adaptive());
                        }

                        var newMissions = snapshot.data!;
                        if (newMissions.length <
                            _missionsModel.missionsPerPage) {
                          _nextPage = -1;
                        } else {
                          _nextPage++;
                        }
                        _missions.addAll(newMissions);
                        var missionsToShow = _missions.toList();
                        print("missionsToShow: ${missionsToShow.length}");
                        if (missionsToShow.isEmpty) {
                          return Center(child: Text('Nothing found'.i18n));
                        }
                        return ListView.builder(
                            controller: _resultsListScrollController,
                            itemCount: missionsToShow.length,
                            itemBuilder: (context, index) {
                              var mission = missionsToShow[index];
                              return ListTile(
                                title: Text(mission.name),
                                subtitle: Text(mission.details),
                              );
                            });
                      },
                    ),
                  ),
                ),
              AnimatedAlign(
                curve: Curves.easeInOut,
                duration: _animationDuration,
                alignment:
                    _resultsVisible ? Alignment.topCenter : Alignment.center,
                child: Container(
                  height: inputHeight,
                  key: _inputKey,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border:
                          Border.all(color: Theme.of(context).primaryColor)),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: TextField(
                              focusNode: _inputFocusNode,
                              onEditingComplete: () {
                                _releaseFocus();
                                _search();
                              },
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.search,
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                // contentPadding: const EdgeInsets.all(0.0),
                                border: InputBorder.none,
                                hintText: "Search for SpaceX missions".i18n,
                              ),
                              onChanged: (value) => _searchFiledChanged(value),
                            ),
                          ),
                        ),
                        if (_trimmedQuery.isNotEmpty)
                          IconButton(
                              onPressed: () {
                                _resetSearch();
                                _gainFocus();
                              },
                              icon: const Icon(Icons.cancel)),
                        if (_trimmedQuery.isEmpty)
                        const IconButton(
                            onPressed: null,
                            icon: Icon(Icons.search))
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
