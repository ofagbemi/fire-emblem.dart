library game_state;

import 'package:unit/unit.dart';

import 'dart:math';

const String ON_MAP = 'on map';
const String MOVING_UNIT = 'moving unit';
const String MOVED_UNIT = 'moved unit';

class GameState {
  final String state;
  Map properties;

  GameState(this.state, this.properties);

  factory GameState.onMap({Point<int> cursorPosition}) {
    return new GameState(
        ON_MAP,
        {'cursorPosition': cursorPosition}
    );
  }

  factory GameState.movingUnit({Unit unit, Point<int> from}) {
    return new GameState(
        MOVING_UNIT,
        {'unit': unit, 'from': from}
    );
  }

  factory GameState.movedUnit({Unit unit, Point<int> from, Point<int> to}) {
    return new GameState(
        MOVED_UNIT,
        {'unit': unit, 'from': from, 'to': to}
    );
  }
}