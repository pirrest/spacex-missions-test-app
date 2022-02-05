import 'dart:async';

import 'package:flutter/cupertino.dart';
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
  int _offset = 0;
  bool _lastPageReached = false;
  Timer? _searchTimer;
  Future<List<Mission>>? _searchFuture;

  _resultsListScrollControllerHandler() {
    if (!_lastPageReached &&
        _resultsListScrollController.offset >=
            _resultsListScrollController.position.maxScrollExtent) {
      setState(() {
        _offset += _missionsModel.missionsPerPage;
      });
    }
  }

  _resetSearch() {
    setState(() {
      _offset = 0;
      _textEditingController.text = "";
      _lastPageReached = false;
      _missions = {};
      _resultsVisible = false;
      _missionsModel.cancelLoadMissions();
    });
  }

  _stopSearch() {
    setState(() {
      _missionsModel.cancelLoadMissions();
    });
  }

  final _inputFocusNode = FocusNode();

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

  _searchFiledChanged(String newValue) {
    setState(() {
      /*if (_query.length > 3) {
        _tryToSearch();
      } else {
        _resultsVisible = false;
      }*/
    });
  }

  _tryToSearch() {
    _searchTimer = Timer(const Duration(seconds: 1), _search);
  }

  _search() {
    _removeSearchTimer();
    setState(() {
      _missions.clear();
      _searchFuture =
          _missionsModel.loadMissions(_textEditingController.text, _offset);
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
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                        print(
                            "snapshot.hasData: ${snapshot.hasData}, ${snapshot.connectionState}");

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
                          _lastPageReached = true;
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
                              return ListTile(
                                title: Text(missionsToShow[index].name),
                                subtitle: Text(missionsToShow[index].details),
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
                                hintText: "Start here".i18n,
                              ),
                              onChanged: (value) => _searchFiledChanged(value),
                            ),
                          ),
                        ),
                        if (_textEditingController.text.isNotEmpty)
                          IconButton(
                              onPressed: () {
                                _resetSearch();
                                _gainFocus();
                              },
                              icon: const Icon(Icons.cancel)),
                        if (_textEditingController.text.isEmpty)
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
