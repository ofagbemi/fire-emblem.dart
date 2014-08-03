library cursor;

import 'package:unit/unit.dart';
import 'dart:html';

const String CURSOR_MOVE_EVENT = 'cursormove';

CustomEvent moveEvent({Point from, Point to}) {
  return new CustomEvent(
      CURSOR_MOVE_EVENT,
      detail: {'from': from, 'to': to}
  );
}

class Cursor extends Entity {
  Cursor({sprites, map}) :
    super(sprites: sprites, map: map);

  @override
  setTile(num x, num y) {
    window.dispatchEvent(
    moveEvent(to: new Point(x, y)));
    super.setTile(x, y);
  }

  @override
  Point<int> up() {
    var to = super.up();
    window.dispatchEvent(
        moveEvent(
            from: currentTilePoint,
            to: to));
    return to;
  }

  @override
  Point<int> down() {
    var to = super.down();
    window.dispatchEvent(
        moveEvent(
            from: currentTilePoint,
            to: to));
    return to;
  }

  @override
  Point<int> left() {
    var to = super.left();
    window.dispatchEvent(
        moveEvent(
            from: currentTilePoint,
            to: to));
    return to;
  }

  @override
  Point<int> right() {
    var to = super.right();
    window.dispatchEvent(
        moveEvent(
            from: currentTilePoint,
            to: to));
    return to;
  }
}