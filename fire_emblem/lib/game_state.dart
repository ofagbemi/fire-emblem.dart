library game_state;

import 'dart:math';

const String ON_MAP = 'on map';
const String MOVING_UNIT = 'moving unit';
const String MOVED_UNIT = 'moved unit';

class GameState {
  final String state;
  Map properties;

  GameState(this.state, this.properties);

  factory GameState.onMap({Point cursorPosition}) {
    return new GameState(
        ON_MAP,
        {'cursorPosition': cursorPosition}
    );
  }

  factory GameState.movingUnit() {
    return new GameState(
        MOVING_UNIT,
        {}
    );
  }

  factory GameState.movedUnit({Point from, Point to}) {
    return new GameState(
        MOVED_UNIT,
        {'from': from, 'to': to}
    );
  }
}