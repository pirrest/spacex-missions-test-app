// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:space_x_launches/models/missions_model.dart';

void main() {
  test('Testing Missions model', () async {
    var model = MissionsModel();
    var missions = await model.loadMissions("star", 0);
    expect(missions.isNotEmpty, true);
  });
}
