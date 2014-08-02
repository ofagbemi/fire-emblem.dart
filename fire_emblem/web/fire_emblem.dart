import 'package:mapper/mapper.dart';
import 'package:unit/unit.dart';

import 'package:fire_emblem/chapter.dart';
import 'package:fire_emblem/game_state.dart';

import 'dart:html';
import 'dart:async';

void main() {
  BodyElement body = querySelector('body');

  ImageElement sacaeTilesetImg = new ImageElement(src: 'images/tilesets/sacae1.png');
  sacaeTilesetImg.className = 'spritesheet';

  CanvasElement mapCanvas = querySelector('#map');
  CanvasElement rangeCanvas = querySelector('#range');
  CanvasElement overworldCanvas = querySelector('#overworld');

  List<CanvasElement> canvases = [mapCanvas, rangeCanvas, overworldCanvas];

  int tileSize = 32;

  canvases.forEach((c) {
    c.width = 15 * tileSize;
    c.height = 10 * tileSize;
    c.context2D.imageSmoothingEnabled = false;
  });

  Chapter ch = new Chapter(
      'json/test_chapter.json',
      mapCanvas, rangeCanvas, overworldCanvas,
      tileSize, tileSize
  );
  ch.loadChapter();

  window.onKeyDown.listen((KeyboardEvent e) {
    var cursor = ch.cursor;
    switch(e.keyCode) {
      case KeyCode.UP:
        cursor.up();
        break;
      case KeyCode.DOWN:
        cursor.down();
        break;
      case KeyCode.LEFT:
        cursor.left();
        break;
      case KeyCode.RIGHT:
        cursor.right();
        break;
      case KeyCode.X:
        switch(ch.gameState.state) {
          case MOVING_UNIT:
            var tile = ch.selectedUnit.currentTilePointRounded;
            ch.cursor.setTile(tile.x, tile.y);
            ch.selectedUnit.setSprite('overworld', 'active');
            ch.selectedUnit = null;
            ch.map.clearRange();
            ch.gameState = new GameState.onMap(
                cursorPosition: cursor.currentTilePointRounded
            );
            break;
          case MOVED_UNIT:
            // set state to moving unit
            Unit unit = ch.gameState.properties['unit'];
            var from = ch.gameState.properties['from'];
            var gameState = new GameState.movingUnit(
                unit: unit,
                from: from
            );
            ch.setState(gameState);
            break;
        }
        break;
      case KeyCode.Z:
        if(ch.selectedUnit != null) {
          // check if unit can move to this spot
          if(1 == 1) {
            // set state to moved unit
            var fromTilePoint = ch.selectedUnit.currentTilePointRounded;
            var toTilePoint = cursor.currentTilePointRounded;
            var gameState = new GameState.movedUnit(
                from: fromTilePoint, to: toTilePoint,
                unit: ch.selectedUnit
            );
            ch.setState(gameState);
          } else {
            // play sound and block movement
          }
        } else {
          Unit unit = ch.getUnitAtTile(cursor.currentTilePoint);
          if(unit != null) { // TODO: check if the unit can still move
            // set state to moving unit
            var gameState = new GameState.movingUnit(
                unit: unit,
                from: unit.currentTilePointRounded
            );
            ch.setState(gameState);
          }
        }
        break;
    }
  });

  int frame = 0;
  void update(Timer t) {
    if(!ch.loaded) return;

    if(ch.map != null) ch.map.drawSelf();

    ch.overworldCanvas.context2D.clearRect(0, 0, overworldCanvas.width, overworldCanvas.height);

    ch.entities.forEach((u) {
      u.move(onDone: () {});
      u.currentSprite.setAnimationFrame(frame);
      u.drawSelfAtTile(ch.map, ch.overworldCanvas.context2D);
    });
    frame++;
  }
  ch.loop(60, update);
}