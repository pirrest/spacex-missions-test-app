import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  final _inputKey = const ValueKey("input");
  final _animationDuration = const Duration(milliseconds: 300);
  late MissionsModel _missionsModel;
  Timer? _searchTimer;
  final _inputFocusNode = FocusNode();
  final _textEditingController = TextEditingController(text: "");
  final _pagingController = PagingController<int, Mission>(firstPageKey: 0);

  get _trimmedQuery => _textEditingController.text.trim();

  _resetSearch({bool keepQuery = false}) {
    setState(() {
      if (!keepQuery) {
        _textEditingController.text = "";
      }
      _resultsVisible = false;
      _removeSearchTimer();
    });
  }

  _gainFocus() {
    if (!_inputFocusNode.hasFocus && _inputFocusNode.canRequestFocus) {
      _inputFocusNode.requestFocus();
    }
  }

  _releaseFocus() {
    if (_inputFocusNode.hasFocus) {
      _inputFocusNode.unfocus();
    }
  }

  _searchFieldChanged(String newValue) {
    setState(() {
      if (_trimmedQuery.length > 3) {
        _removeSearchTimer();
        _searchTimer = Timer(const Duration(seconds: 1), _search);
      } else {
        _resetSearch(keepQuery: true);
      }
    });
  }

  _search() {
    _removeSearchTimer();
    setState(() {
      _pagingController.refresh();
      _fetchPage(0);
    });
  }

  _fetchPage(int pageKey) async {
    if (_trimmedQuery.length <= 3) {
      _resultsVisible = false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Search query should contain more than 3 characters".i18n),
      ));
      return;
    }
    try {
      _resultsVisible = true;
      final newMissions =
          await _missionsModel.loadMissions(_trimmedQuery, pageKey);
      final isLastPage = newMissions.length < _missionsModel.missionsPerPage;
      if (isLastPage) {
        _pagingController.appendLastPage(newMissions);
      } else {
        final nextPageKey = pageKey + newMissions.length;
        _pagingController.appendPage(newMissions, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _removeSearchTimer() {
    _searchTimer?.cancel();
    _searchTimer = null;
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _removeSearchTimer();
    _inputFocusNode.dispose();
    _textEditingController.dispose();
    _pagingController.dispose();
    super.dispose();
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
                    child: PagedListView<int, Mission>(
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Mission>(
                        animateTransitions: true,
                        transitionDuration: _animationDuration,
                        itemBuilder: (context, mission, index) {
                          return ListTile(
                            title: Text(mission.name),
                            subtitle: Text(mission.details),
                          );
                        },
                        firstPageProgressIndicatorBuilder: (context) =>
                            const CircularProgressIndicator.adaptive(),
                        newPageProgressIndicatorBuilder: (context) =>
                            const CircularProgressIndicator.adaptive(),
                        noItemsFoundIndicatorBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text("Nothing found".i18n,
                                  style: Theme.of(context).textTheme.headline6),
                              Text('Try "star"'.i18n,
                                  style: Theme.of(context).textTheme.caption)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              AnimatedAlign(
                key: _inputKey,
                curve: Curves.easeInOut,
                duration: _animationDuration,
                alignment:
                    _resultsVisible ? Alignment.topCenter : Alignment.center,
                child: Container(
                  height: inputHeight,
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
                                border: InputBorder.none,
                                hintText: "Search for SpaceX missions".i18n,
                              ),
                              onChanged: (value) => _searchFieldChanged(value),
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
                              onPressed: null, icon: Icon(Icons.search))
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
